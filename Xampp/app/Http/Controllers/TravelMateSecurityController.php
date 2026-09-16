<?php
namespace App\Http\Controllers;
use App\Services\TravelMateSecurity as S;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
class TravelMateSecurityController extends Controller
{
    public function edit(){return view('travelmate.security.change');}
    public function change(Request $r){$stamp=S::change((int)$r->user()->id,$r->all());$r->session()->regenerate();$r->session()->put('tm_password_stamp',$stamp);return back()->with('status','Password changed. Other sessions must sign in again.');}
    public function forgot(){return view('travelmate.security.forgot');}
    public function send(Request $r){
        $d=$r->validate(['email'=>'required|string|email|max:254']);$email=mb_strtolower(trim($d['email']));
        try{
            $token=S::issue($email);
            if($token){
                // APP_URL is trusted configuration; do not build password links from a request Host header.
                $url=rtrim(config('app.url'),'/').'/reset-password/'.$token.'?'.http_build_query(['email'=>$email]);
                Mail::raw("Reset your TravelMate password within 30 minutes:\n".$url."\nIf you did not request this, ignore this message.",fn($mail)=>$mail->to($email)->subject('TravelMate password recovery'));
            }
        }catch(\Throwable $e){\Illuminate\Support\Facades\Log::warning('TravelMate recovery could not be dispatched. Check mail/cache configuration.');}
        return back()->with('status','If an active account matches, a recovery link will be sent. Please wait a minute before requesting again.');
    }
    public function resetForm(Request $r,string $token){abort_unless(preg_match('/^[a-f0-9]{64}$/',$token),404);$d=$r->validate(['email'=>'required|string|email|max:254']);return response()->view('travelmate.security.reset',['token'=>$token,'email'=>$d['email']])->header('Referrer-Policy','no-referrer')->header('Cache-Control','no-store');}
    public function reset(Request $r){S::reset($r->all());return redirect()->route('login')->with('status','Password reset. Sign in with your new password.');}
}
