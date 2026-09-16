<?php
namespace App\Services;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Carbon\CarbonImmutable;
class TravelMateOperations
{
    public const REPORT_TYPES=['bug','listing','destination','review','photo','transport','other'];
    public static function admin($user):void {TravelMateTransport::role($user,'admin');}
    public static function isAdmin($id):bool{return DB::table('user_roles as ur')->join('roles as r','r.id','=','ur.role_id')->where('ur.user_id',$id)->where('r.name','admin')->exists();}
    public static function account($actor,string $id,array $input):void {
        self::admin($actor);
        $d=Validator::make($input,['account_status'=>['required',Rule::in(['active','suspended'])],'expected_status'=>['required',Rule::in(['active','suspended'])]])->validate();
        DB::transaction(function()use($actor,$id,$d){
            $row=DB::table('users')->where('id',$id)->lockForUpdate()->first();abort_unless($row,404);
            if((string)$actor->id===$id || self::isAdmin($id))throw ValidationException::withMessages(['account_status'=>'Admin accounts cannot be changed through this screen.']);
            if($row->account_status!==$d['expected_status'])throw ValidationException::withMessages(['account_status'=>'Account status changed. Reload before trying again.']);
            if($row->account_status===$d['account_status'])return;
            DB::table('users')->where('id',$id)->update(['account_status'=>$d['account_status'],'updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            TravelMateInbox::send([$row->id],"Your account status is now {$d['account_status']}.");
            TravelMateInbox::send(TravelMateInbox::admins(),"Admin #{$actor->id} set account #{$row->id} to {$d['account_status']}.");
        },3);
    }
    public static function target(string $type,?string $id):?array {
        if(!$id)return null;
        if($type==='listing'){
            $r=DB::table('business_listings as l')->join('destinations as d','d.id','=','l.destination_id')->where('l.id',$id)->where('l.status','approved')->where('d.is_active',1)->first(['l.id','l.name']);
            abort_unless($r,404);return ['column'=>'listing_id','id'=>$r->id,'label'=>$r->name];
        }
        if($type==='destination'){$r=DB::table('destinations')->where('id',$id)->where('is_active',1)->first();abort_unless($r,404);return ['column'=>'destination_id','id'=>$r->id,'label'=>$r->name];}
        if($type==='transport'){$r=TravelMateTransport::publicQuery()->where('s.id',$id)->first();abort_unless($r,404);return ['column'=>'transport_id','id'=>$r->id,'label'=>$r->service_name];}
        if($type==='review'){
            $r=DB::table('reviews')->where('id',$id)->where('status','published')->first();abort_unless($r,404);
            self::target($r->listing_id?'listing':'destination',(string)($r->listing_id?:$r->destination_id));
            return ['column'=>'review_id','id'=>$r->id,'label'=>'Review #'.$r->id];
        }
        if($type==='photo'){
            $r=DB::table('photos')->where('id',$id)->first();abort_unless($r && TravelMateContent::canSee(null,$r),404);
            return ['column'=>'photo_id','id'=>$r->id,'label'=>$r->caption?:'Photo #'.$r->id];
        }
        abort(422,'This report category does not accept an item.');
    }
    public static function report($user,array $input) {
        abort_unless($user && $user->account_status==='active',403);
        $d=Validator::make($input,['report_type'=>['required',Rule::in(self::REPORT_TYPES)],'target_id'=>'nullable|integer|min:1','description'=>'required|string|min:10|max:5000|regex:/\S/u'])->validate();
        $target=self::target($d['report_type'],isset($d['target_id'])?(string)$d['target_id']:null);
        return DB::transaction(function()use($user,$d,$target){
            $row=DB::table('users')->where('id',$user->id)->lockForUpdate()->first();abort_unless($row && $row->account_status==='active',403);
            if($target){
                $table=match($d['report_type']){'listing'=>'business_listings','destination'=>'destinations','transport'=>'transportation_services','review'=>'reviews','photo'=>'photos'};
                if(!DB::table($table)->where('id',$target['id'])->sharedLock()->first())throw ValidationException::withMessages(['description'=>'The related item is no longer available. Submit a general issue instead.']);
            }
            $id=DB::table('user_reports')->insertGetId(['user_id'=>$user->id,'report_type'=>$d['report_type'],'description'=>trim($d['description']),'status'=>'pending']+($target?[$target['column']=>$target['id']]:[]));
            TravelMateInbox::send(TravelMateInbox::admins(),"Issue #{$id} was submitted. Open Admin > Reported issues.");return $id;
        },3);
    }
    public static function issue($user,string $id,bool $admin=false) {
        if($admin)self::admin($user);
        $q=DB::table('user_reports')->where('id',$id);if(!$admin)$q->where('user_id',$user->id);
        $row=$q->first();abort_unless($row,404);return $row;
    }
    public static function fingerprint($row):string{return hash('sha256',json_encode($row));}
    public static function moderate($user,string $id,array $input):void {
        self::admin($user);$d=Validator::make($input,['action'=>['required',Rule::in(['assign','resolve','reopen'])],'fingerprint'=>'required|string|size:64'])->validate();
        DB::transaction(function()use($user,$id,$d){
            $row=DB::table('user_reports')->where('id',$id)->lockForUpdate()->first();abort_unless($row,404);
            if(!hash_equals(self::fingerprint($row),$d['fingerprint']))throw ValidationException::withMessages(['action'=>'This issue changed. Reload before updating.']);
            $values=['assigned_to'=>$user->id];
            if($d['action']==='resolve')$values+=['status'=>'resolved','resolved_at'=>now('UTC')->format('Y-m-d H:i:s')];
            if($d['action']==='reopen')$values+=['status'=>'pending','resolved_at'=>null];
            DB::table('user_reports')->where('id',$id)->update($values);
            if($d['action']!=='assign')TravelMateInbox::send([$row->user_id],"Your issue #{$id} is now ".($d['action']==='resolve'?'resolved.':'pending review again.'));
        },3);
    }
    public static function period(array $input):array {
        $d=Validator::make($input,['period_start'=>'nullable|required_with:period_end|date_format:Y-m-d|after_or_equal:2000-01-01|before_or_equal:2099-12-30','period_end'=>'nullable|required_with:period_start|date_format:Y-m-d|after_or_equal:period_start|before_or_equal:2099-12-30'])->validate();
        return ['period_start'=>$d['period_start']??null,'period_end'=>$d['period_end']??null];
    }
    public static function metrics(array $period):array {
        $metrics=[];$now=now('UTC')->format('Y-m-d H:i:s');
        $base=function($table,$column='created_at')use($period){$q=DB::table($table);if($period['period_start'])$q->where($column,'>=',$period['period_start'].' 00:00:00')->where($column,'<',CarbonImmutable::parse($period['period_end'],'UTC')->addDay()->format('Y-m-d').' 00:00:00');return $q;};
        $metrics['Accounts created']=$base('users')->count();
        $metrics['Listings submitted']=$base('business_listings')->count();
        $metrics['Bookings created']=$base('bookings')->count();
        foreach(['confirmed','completed','cancelled'] as $status)$metrics['Bookings currently '.$status]=$base('bookings')->where('status',$status)->count();
        $metrics['Bookings awaiting confirmation']=$base('bookings')->where('status','pending')->where('hold_expires_at','>',$now)->count();
        $metrics['Bookings with expired holds']=$base('bookings')->where(function($q)use($now){$q->where('status','expired')->orWhere(function($q)use($now){$q->where('status','pending')->where('hold_expires_at','<=',$now);});})->count();
        $metrics['Reviews submitted']=$base('reviews')->count();
        $metrics['Issues submitted']=$base('user_reports','submitted_at')->count();
        $metrics['Issues currently pending']=$base('user_reports','submitted_at')->where('status','pending')->count();
        return $metrics;
    }
    public static function generate($user,array $input) {
        self::admin($user);$period=self::period($input);
        return DB::transaction(function()use($user,$period){
            // SELECTs share the MariaDB REPEATABLE READ snapshot used by this project.
            $metrics=self::metrics($period);
            $id=DB::table('analytics_reports')->insertGetId($period+['generated_by'=>$user->id,'status'=>'generated','generated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            foreach($metrics as $name=>$value)DB::table('report_metrics')->insert(['report_id'=>$id,'name'=>$name,'value'=>$value,'unit'=>'count']);
            DB::table('report_types')->insertOrIgnore(['name'=>'TravelMate activity summary']);
            DB::table('report_report_types')->insert(['report_id'=>$id,'report_type_id'=>DB::table('report_types')->where('name','TravelMate activity summary')->value('id')]);
            foreach(['users','business_listings','bookings','reviews','user_reports'] as $name){DB::table('data_sources')->insertOrIgnore(['name'=>$name]);DB::table('report_data_sources')->insert(['report_id'=>$id,'data_source_id'=>DB::table('data_sources')->where('name',$name)->value('id')]);}
            return $id;
        },3);
    }
    public static function snapshot($user,string $id):array {
        self::admin($user);$row=DB::table('analytics_reports')->where('id',$id)->where('status','generated')->first();abort_unless($row,404);
        return ['report'=>$row,'metrics'=>DB::table('report_metrics')->where('report_id',$id)->orderBy('id')->get()];
    }
}
