<?php
namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class TravelMateProfile
{
    public static function save(int $user,array $input): void
    {
        $data=Validator::make($input,[
            'full_name'=>['required','string','max:150','regex:/\S/u'],
            'address'=>['nullable','string','max:255'],
            'phones'=>['sometimes','array','max:5'],
            'phones.*'=>['nullable','string','max:20','regex:/^[0-9+().\s-]{5,20}$/'],
            'preferences'=>['sometimes','array','max:100'],
            'preferences.*'=>['required','integer','distinct',Rule::exists('preferences','id')],
        ])->validate();
        $phones=array_values(array_unique(array_filter(array_map(fn($p)=>trim($p??''),$data['phones']??[]))));
        $preferences=$data['preferences']??[];
        DB::transaction(function()use($user,$data,$phones,$preferences){
            $row=DB::table('users')->where('id',$user)->lockForUpdate()->first(['id']);
            abort_unless($row,404);
            DB::table('users')->where('id',$user)->update([
                'full_name'=>trim($data['full_name']),'address'=>isset($data['address'])?trim($data['address']):null,
                'updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            DB::table('user_phones')->where('user_id',$user)->delete();
            foreach($phones as $phone)DB::table('user_phones')->insert(['user_id'=>$user,'phone_number'=>$phone]);
            DB::table('user_preferences')->where('user_id',$user)->delete();
            foreach($preferences as $preference)DB::table('user_preferences')->insert(['user_id'=>$user,'preference_id'=>$preference]);
        },3);
    }
}
