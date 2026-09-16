<?php
namespace App\Http\Controllers;
use App\Services\TravelMateDemoPayments as D;
use App\Services\TravelMateOperations as O;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
class TravelMateDemoController extends Controller
{
    public function show(Request $r,string $booking){abort_unless(D::enabled(),404);$b=DB::table('bookings')->where('id',$booking)->where('user_id',$r->user()->id)->first();abort_unless($b,404);return view('travelmate.security.demo',['booking'=>$b,'payments'=>DB::table('payments')->where('booking_id',$booking)->orderByDesc('id')->get(),'refunds'=>DB::table('refunds as r')->join('payments as p','p.id','=','r.payment_id')->where('p.booking_id',$booking)->orderByDesc('r.id')->get(['r.*'])]);}
    public function pay(Request $r,string $booking){D::pay((int)$r->user()->id,$booking,$r->all());return back()->with('status','Demo attempt recorded. No money moved.');}
    public function refund(Request $r,string $booking){D::requestRefund((int)$r->user()->id,$booking,$r->all());return back()->with('status','Demo refund sent for admin review.');}
    public function index(Request $r){abort_unless(D::enabled(),404);O::admin($r->user());$r->validate(['page'=>'nullable|integer|min:1|max:100000']);return view('travelmate.security.refunds',['refunds'=>DB::table('refunds as r')->join('payments as p','p.id','=','r.payment_id')->where('p.is_demo',1)->where('p.provider','demo')->orderByDesc('r.id')->select('r.*','p.booking_id')->paginate(20)]);}
    public function decide(Request $r,string $refund){$d=$r->validate(['decision'=>'required|in:succeeded,failed']);D::decide($r->user(),$refund,$d['decision']);return back()->with('status','Demo refund decision saved.');}
}
