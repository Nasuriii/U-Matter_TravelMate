<?php
namespace App\Services;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
class TravelMateSecurity
{
    public static function stamp(string $hash):string{return hash_hmac('sha256',$hash,(string)config('app.key'));}
    public static function key(string $email):string{return 'tm-reset:'.hash_hmac('sha256',mb_strtolower(trim($email)),(string)config('app.key'));}
    public static function password(array $input):string {
        $d=Validator::make($input,['password'=>['required','string','min:12','max:72','confirmed']])->validate();
        if(strlen($d['password'])>72)throw ValidationException::withMessages(['password'=>'Use at most 72 bytes for the new password.']);return $d['password'];
    }
    public static function change(int $id,array $input):string {
        $password=self::password($input);$d=Validator::make($input,['current_password'=>'required|string|max:256'])->validate();
        return DB::transaction(function()use($id,$password,$d){
            $row=DB::table('users')->where('id',$id)->lockForUpdate()->first();abort_unless($row && $row->account_status==='active',403);
            try{$valid=Hash::check($d['current_password'],$row->password_hash);}catch(\RuntimeException $e){$valid=false;}
            if(!$valid)throw ValidationException::withMessages(['current_password'=>'Current password is incorrect.']);
            $hash=Hash::make($password);DB::table('users')->where('id',$id)->update(['password_hash'=>$hash,'updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);return self::stamp($hash);
        },3);
    }
    // Returns a token only to the server-side mail sender. Never include it in the HTTP response.
    public static function issue(string $email):?string {
        $email=mb_strtolower(trim($email));$key=self::key($email);
        return Cache::store('file')->lock($key.':lock',30)->block(5,function()use($email,$key){
            $old=Cache::store('file')->get($key);if($old && ($old['issued']??0)>time()-60)return null;
            $row=DB::table('users')->where('email',$email)->where('account_status','active')->first();if(!$row)return null;
            $token=bin2hex(random_bytes(32));Cache::store('file')->put($key,['digest'=>hash('sha256',$token),'id'=>$row->id,'stamp'=>self::stamp($row->password_hash),'issued'=>time()],now()->addMinutes(30));return $token;
        });
    }
    public static function reset(array $input):void {
        $password=self::password($input);$d=Validator::make($input,['email'=>'required|string|email|max:254','token'=>'required|string|size:64|regex:/^[a-f0-9]+$/'])->validate();$email=mb_strtolower(trim($d['email']));$key=self::key($email);
        Cache::store('file')->lock($key.':lock',30)->block(5,function()use($email,$key,$d,$password){
            $record=Cache::store('file')->get($key);
            if(!$record || !hash_equals($record['digest'],hash('sha256',$d['token'])))throw ValidationException::withMessages(['email'=>'This recovery link is invalid or expired. Request another one.']);
            DB::transaction(function()use($record,$email,$password){
                $row=DB::table('users')->where('id',$record['id'])->where('email',$email)->lockForUpdate()->first();
                if(!$row || $row->account_status!=='active' || !hash_equals($record['stamp'],self::stamp($row->password_hash)))throw ValidationException::withMessages(['email'=>'This recovery link is no longer valid.']);
                DB::table('users')->where('id',$row->id)->update(['password_hash'=>Hash::make($password),'updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            },3);Cache::store('file')->forget($key);
        });
    }
}
