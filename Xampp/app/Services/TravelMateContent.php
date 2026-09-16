<?php
namespace App\Services;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
class TravelMateContent
{
    public static function admin($user):bool { return $user && $user->account_status==='active' && DB::table('user_roles')->join('roles','roles.id','=','user_roles.role_id')->where('user_roles.user_id',$user->id)->where('roles.name','admin')->exists(); }
    public static function target($user,string $kind,string $id,bool $lock=false) {
        abort_unless(in_array($kind,['listing','destination']),404);
        abort_unless($user && $user->account_status==='active',403);
        $q=DB::table($kind==='listing'?'business_listings':'destinations')->where('id',$id);
        if(!self::admin($user)) {
            abort_unless($kind==='listing',403);
            abort_unless(DB::table('user_roles')->join('roles','roles.id','=','user_roles.role_id')->where('user_roles.user_id',$user->id)->where('roles.name','business_owner')->exists(),403);
            $owner=DB::table('business_owners')->where('user_id',$user->id)->value('id');
            abort_unless($owner,403);$q->where('owner_id',$owner);
        }
        $row=($lock?$q->lockForUpdate():$q)->first();abort_unless($row,404);return $row;
    }
    public static function photos(string $kind,$id) { return DB::table('photos')->where($kind.'_id',$id)->orderBy('sort_order')->orderBy('id'); }
    public static function details($listing):array {
        return match($listing->listing_type) {
            'hotel'=>['amenities'=>DB::table('amenities')->join('hotel_amenities','amenities.id','=','hotel_amenities.amenity_id')->where('hotel_id',$listing->id)->orderBy('amenities.id')->get(['amenities.id','amenities.name'])->all()],
            'restaurant'=>['menu'=>DB::table('menu_items')->where('restaurant_id',$listing->id)->orderBy('id')->get()->all()],
            'attraction'=>['schedules'=>DB::table('attraction_schedules')->where('attraction_id',$listing->id)->orderBy('id')->get()->all()],
        };
    }
    public static function save($user,string $id,array $input):void {
        DB::transaction(function()use($user,$id,$input){
            $row=self::target($user,'listing',$id,true);
            $action=$input['action']??'';
            if($row->listing_type==='hotel' && $action==='amenities') {
                $d=Validator::make($input,['amenities'=>['nullable','array','max:100'],'amenities.*'=>['integer','distinct',Rule::exists('amenities','id')]])->validate();
                DB::table('hotel_amenities')->where('hotel_id',$id)->delete();
                foreach($d['amenities']??[] as $a)DB::table('hotel_amenities')->insert(['hotel_id'=>$id,'amenity_id'=>$a]);
            } elseif($row->listing_type==='restaurant' && in_array($action,['menu','remove_menu'])) {
                $d=Validator::make($input,['item_id'=>['nullable','integer','min:1']])->validate();
                $item=DB::table('menu_items')->where('restaurant_id',$id)->where('id',$d['item_id']??0);
                if(!empty($d['item_id']))abort_unless((clone $item)->exists(),404);
                if($action==='remove_menu'){abort_unless(!empty($d['item_id']),422);$item->delete();}
                else {
                    $v=Validator::make($input,['name'=>'required|string|max:150','description'=>'nullable|string|max:5000','category'=>'nullable|string|max:80','price'=>'nullable|numeric|min:0|max:9999999999.99|decimal:0,2','is_available'=>'required|boolean'])->validate();
                    $v+=['description'=>null,'category'=>null,'price'=>null];
                    if(!empty($d['item_id']))$item->update($v);else {if(DB::table('menu_items')->where('restaurant_id',$id)->count()>=100)throw ValidationException::withMessages(['name'=>'Maximum 100 menu items.']);DB::table('menu_items')->insert($v+['restaurant_id'=>$id]);}
                }
            } elseif($row->listing_type==='attraction' && $action==='schedule') {
                $d=Validator::make($input,['operating_day'=>['required',Rule::in(['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'])],'schedule_text'=>'required|string|max:255'])->validate();
                DB::table('attraction_schedules')->updateOrInsert(['attraction_id'=>$id,'operating_day'=>$d['operating_day']],['schedule_text'=>$d['schedule_text']]);
            } elseif($row->listing_type==='attraction' && $action==='remove_schedule') {
                $d=Validator::make($input,['item_id'=>'required|integer|min:1'])->validate();
                $q=DB::table('attraction_schedules')->where('attraction_id',$id)->where('id',$d['item_id']);abort_unless((clone $q)->exists(),404);$q->delete();
            } else abort(422,'Invalid content action.');
            DB::table('business_listings')->where('id',$id)->update(['status'=>'pending','updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            TravelMateInbox::submitted(DB::table('business_listings')->where('id',$id)->first());
        },3);
    }
    public static function canSee($user,$photo):bool {
        if($photo->listing_id) {
            $row=DB::table('business_listings')->where('id',$photo->listing_id)->first();if(!$row)return false;
            $public=$photo->status==='approved' && $row->status==='approved' && DB::table('destinations')->where('id',$row->destination_id)->where('is_active',1)->exists();
            $owner=$user && $user->account_status==='active' && DB::table('business_owners')->where('id',$row->owner_id)->where('user_id',$user->id)->exists();
            return $public || $owner || self::admin($user);
        }
        return self::admin($user) || ($photo->status==='approved' && DB::table('destinations')->where('id',$photo->destination_id)->where('is_active',1)->exists());
    }
}
