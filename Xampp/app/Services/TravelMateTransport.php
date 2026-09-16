<?php
namespace App\Services;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
class TravelMateTransport
{
    public const TYPES=['Bus','Van','Taxi','Shuttle','Ferry','Other'];
    public static function role($user,string $role):void {
        abort_unless($user && $user->account_status==='active' && DB::table('user_roles as ur')->join('roles as r','r.id','=','ur.role_id')->where('ur.user_id',$user->id)->where('r.name',$role)->exists(),403);
    }
    public static function owner($user) {
        self::role($user,'business_owner');
        $id=DB::table('business_owners')->where('user_id',$user->id)->value('id');abort_unless($id,403);return $id;
    }
    public static function provider($user,string $id,bool $lock=false) {
        $q=DB::table('transport_providers')->where('id',$id)->where('owner_id',self::owner($user));
        $row=($lock?$q->lockForUpdate():$q)->first();abort_unless($row,404);return $row;
    }
    public static function contacts($id,bool $lock=false) {
        $q=DB::table('transport_provider_contacts')->where('provider_id',$id)->orderBy('id');return ($lock?$q->lockForUpdate():$q)->get();
    }
    public static function saveProvider($user,?string $id,array $input) {
        $owner=self::owner($user);
        $data=Validator::make($input,['company_name'=>'required|string|max:150|regex:/\S/u','description'=>'nullable|string|max:5000','phones'=>'nullable|array|max:5','phones.*'=>['nullable','string','max:20','regex:/^[0-9+().\s-]{5,20}$/']])->validate();
        $phones=array_values(array_unique(array_filter(array_map(fn($v)=>trim($v??''),$data['phones']??[]))));
        return DB::transaction(function()use($user,$owner,$id,$data,$phones){
            if($id){self::provider($user,$id,true);DB::table('transport_providers')->where('id',$id)->update(['company_name'=>trim($data['company_name']),'description'=>$data['description']??null]);}
            else {
                DB::table('business_owners')->where('id',$owner)->lockForUpdate()->first();
                if(DB::table('transport_providers')->where('owner_id',$owner)->count()>=20)throw ValidationException::withMessages(['company_name'=>'Maximum 20 providers per owner.']);
                $id=DB::table('transport_providers')->insertGetId(['owner_id'=>$owner,'company_name'=>trim($data['company_name']),'description'=>$data['description']??null]);
            }
            DB::table('transport_provider_contacts')->where('provider_id',$id)->delete();
            foreach($phones as $phone)DB::table('transport_provider_contacts')->insert(['provider_id'=>$id,'phone_number'=>$phone]);
            $changed=DB::table('transportation_services')->where('provider_id',$id)->where('status','!=','inactive')->update(['status'=>'pending']);
            if($changed)TravelMateInbox::send(TravelMateInbox::admins(),"Transport provider #{$id} changed. Review its pending services.");
            return $id;
        },3);
    }
    public static function saveService($user,string $provider,?string $id,array $input) {
        self::provider($user,$provider);
        $data=Validator::make($input,['service_name'=>'required|string|max:150|regex:/\S/u','transport_type'=>['required',Rule::in(self::TYPES)],'destination_id'=>'required|integer|min:1'])->validate();
        return DB::transaction(function()use($user,$provider,$id,$data){
            self::provider($user,$provider,true);
            if($id)abort_unless(DB::table('transportation_services')->where('id',$id)->where('provider_id',$provider)->lockForUpdate()->first(),404);
            $active=DB::table('destinations')->where('id',$data['destination_id'])->where('is_active',1)->lockForUpdate()->first();
            if(!$active)throw ValidationException::withMessages(['destination_id'=>'Choose an active destination.']);
            if(!self::contacts($provider,true)->count())throw ValidationException::withMessages(['service_name'=>'Add at least one provider contact number before submitting a service.']);
            $values=$data+['status'=>'pending'];$values['service_name']=trim($values['service_name']);
            if($id)DB::table('transportation_services')->where('id',$id)->update($values);
            else {
                if(DB::table('transportation_services')->where('provider_id',$provider)->count()>=100)throw ValidationException::withMessages(['service_name'=>'Maximum 100 services per provider.']);
                $id=DB::table('transportation_services')->insertGetId($values+['provider_id'=>$provider]);
            }
            TravelMateInbox::send(TravelMateInbox::admins(),"Transport service #{$id} was submitted for approval.");return $id;
        },3);
    }
    public static function deactivate($user,string $provider,string $id):void {
        DB::transaction(function()use($user,$provider,$id){
            self::provider($user,$provider,true);$q=DB::table('transportation_services')->where('id',$id)->where('provider_id',$provider);
            abort_unless((clone $q)->lockForUpdate()->first(),404);$q->update(['status'=>'inactive']);
        },3);
    }
    public static function snapshot(string $id,bool $lock=false):array {
        // Provider is immutable for a service; all writers lock provider before service.
        $pid=DB::table('transportation_services')->where('id',$id)->value('provider_id');abort_unless($pid,404);
        $p=DB::table('transport_providers')->where('id',$pid);$provider=($lock?$p->lockForUpdate():$p)->first();abort_unless($provider,404);
        $s=DB::table('transportation_services')->where('id',$id);$service=($lock?$s->lockForUpdate():$s)->first();abort_unless($service,404);
        return [$service,$provider,self::contacts($pid,$lock)->all()];
    }
    public static function fingerprint(array $snapshot):string {return hash('sha256',json_encode($snapshot));}
    public static function decide($user,string $id,array $input):void {
        self::role($user,'admin');
        $d=Validator::make($input,['decision'=>['required',Rule::in(['approved','rejected','inactive'])],'fingerprint'=>'required|string|size:64'])->validate();
        DB::transaction(function()use($id,$d){
            $snapshot=self::snapshot($id,true);[$service,$provider,$contacts]=$snapshot;
            if(!hash_equals(self::fingerprint($snapshot),$d['fingerprint']))throw ValidationException::withMessages(['decision'=>'Details changed. Reload this page and review again.']);
            if($d['decision']!=='inactive' && $service->status!=='pending')throw ValidationException::withMessages(['decision'=>'Only pending services can be approved or rejected.']);
            if($d['decision']==='approved') {
                $active=DB::table('destinations')->where('id',$service->destination_id)->where('is_active',1)->lockForUpdate()->first();
                $ownerActive=DB::table('business_owners as o')->join('users as u','u.id','=','o.user_id')->where('o.id',$provider->owner_id)->where('u.account_status','active')->exists();
                if(!$active || !$contacts || !$ownerActive)throw ValidationException::withMessages(['decision'=>'Approval needs an active destination, active owner and provider contact.']);
            }
            DB::table('transportation_services')->where('id',$id)->update(['status'=>$d['decision']]);
            $uid=DB::table('business_owners')->where('id',$provider->owner_id)->value('user_id');
            if($uid)TravelMateInbox::send([$uid],"Transport service #{$id}: {$d['decision']}.");
        },3);
    }
    public static function publicQuery() {
        return DB::table('transportation_services as s')->join('transport_providers as p','p.id','=','s.provider_id')->join('destinations as d','d.id','=','s.destination_id')->join('business_owners as o','o.id','=','p.owner_id')->join('users as u','u.id','=','o.user_id')->where('s.status','approved')->where('d.is_active',1)->where('u.account_status','active')->select('s.*','p.company_name','p.description','d.name as destination_name','d.slug as destination_slug','d.province');
    }
}
