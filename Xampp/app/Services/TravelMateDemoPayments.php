<?php
namespace App\Services;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Carbon\CarbonImmutable;
class TravelMateDemoPayments
{
    public static function enabled():bool{return app()->environment('local') && (bool)config('travelmate.demo_payments');}
    private static function gate():void{abort_unless(self::enabled(),404);}
    private static function lock(string $id):array{
        $lid=TravelMateReservations::listingForBooking($id);abort_unless($lid,404);
        $venue=DB::table('business_listings')->where('id',$lid)->lockForUpdate()->first();$b=DB::table('bookings')->where('id',$id)->lockForUpdate()->first();abort_unless($venue && $b,404);return [$b,$venue];
    }
    public static function beforeStart($b):void {
        $d=TravelMateReservations::details($b);
        $future=$d['stay']?$d['stay']->check_in>CarbonImmutable::today('Asia/Manila')->format('Y-m-d'):($d['slot'] && $d['slot']->starts_at>now('UTC')->format('Y-m-d H:i:s'));
        if(!$future)TravelMateReservations::fail('Demo payments and refunds are available only before the stay or seating starts.');
    }
    public static function pay(int $user,string $booking,array $input):int{
        self::gate();$d=Validator::make($input,['request_key'=>'required|uuid','result'=>['required',Rule::in(['succeeded','failed'])]])->validate();
        return DB::transaction(function()use($user,$booking,$d){
            [$b,$venue]=self::lock($booking);abort_unless((int)$b->user_id===$user,404);
            $key='tm-demo-pay:'.hash('sha256',$user.'|'.$booking.'|'.$d['request_key']);
            $old=DB::table('payments')->where('idempotency_key',$key)->lockForUpdate()->first();if($old)return (int)$old->id;
            if($b->status!=='confirmed')TravelMateReservations::fail('The owner must confirm this booking before a demo payment.');self::beforeStart($b);
            if(TravelMateReservations::cents((string)$b->total_amount)<=0)TravelMateReservations::fail('This booking has no amount to pay.');
            if(DB::table('payments')->where('booking_id',$booking)->whereIn('status',['succeeded','pending'])->lockForUpdate()->first())TravelMateReservations::fail('A payment is already recorded or pending.');
            $id=DB::table('payments')->insertGetId(['booking_id'=>$booking,'method'=>'pay_at_venue','provider'=>'demo','provider_reference'=>$key,'idempotency_key'=>$key,'amount'=>$b->total_amount,'status'=>$d['result'],'is_demo'=>1,'paid_at'=>$d['result']==='succeeded'?now('UTC')->format('Y-m-d H:i:s'):null]);
            TravelMateInbox::booking($b,$venue,'DEMO payment '.$d['result'].' (no money moved)');return $id;
        },3);
    }
    public static function requestRefund(int $user,string $booking,array $input):int{
        self::gate();$d=Validator::make($input,['request_key'=>'required|uuid','reason'=>'required|string|min:5|max:255'])->validate();
        return DB::transaction(function()use($user,$booking,$d){
            [$b,$venue]=self::lock($booking);abort_unless((int)$b->user_id===$user,404);
            $key='tm-demo-ref:'.hash('sha256',$user.'|'.$booking.'|'.$d['request_key']);
            $old=DB::table('refunds')->where('idempotency_key',$key)->lockForUpdate()->first();if($old)return (int)$old->id;
            if($b->status!=='confirmed')TravelMateReservations::fail('Only a confirmed booking can request a demo refund.');self::beforeStart($b);
            $pay=DB::table('payments')->where('booking_id',$booking)->where('status','succeeded')->lockForUpdate()->first();
            if(!$pay || !$pay->is_demo || $pay->provider!=='demo')TravelMateReservations::fail('No successful demo payment is available for refund.');
            if(DB::table('refunds')->where('payment_id',$pay->id)->whereIn('status',['pending','succeeded'])->lockForUpdate()->first())TravelMateReservations::fail('A refund is already pending or completed.');
            $id=DB::table('refunds')->insertGetId(['payment_id'=>$pay->id,'amount'=>$pay->amount,'reason'=>$d['reason'],'status'=>'pending','idempotency_key'=>$key]);
            TravelMateInbox::send(TravelMateInbox::admins(),"DEMO refund #{$id} needs review. No money has moved.");return $id;
        },3);
    }
    public static function decide($admin,string $id,string $decision):void{
        self::gate();TravelMateOperations::admin($admin);abort_unless(in_array($decision,['succeeded','failed']),422);
        DB::transaction(function()use($id,$decision){
            $lookup=DB::table('refunds as r')->join('payments as p','p.id','=','r.payment_id')->where('r.id',$id)->first(['p.booking_id','p.id as payment_id']);abort_unless($lookup,404);
            [$b,$venue]=self::lock((string)$lookup->booking_id);$pay=DB::table('payments')->where('id',$lookup->payment_id)->lockForUpdate()->first();$refund=DB::table('refunds')->where('id',$id)->lockForUpdate()->first();
            abort_unless($pay && $refund && $pay->provider==='demo' && $pay->is_demo,404);
            if($refund->status===$decision)return;
            if($refund->status!=='pending')TravelMateReservations::fail('This refund has already been reviewed.');
            if($decision==='succeeded'){
                if($b->status!=='confirmed' || $pay->status!=='succeeded')TravelMateReservations::fail('Booking or payment is no longer eligible.');self::beforeStart($b);
                if(TravelMateReservations::cents((string)$refund->amount)!==TravelMateReservations::cents((string)$pay->amount))TravelMateReservations::fail('Only full demo refunds are supported.');
                $other=DB::table('refunds')->where('payment_id',$pay->id)->where('id','!=',$id)->whereIn('status',['pending','succeeded'])->lockForUpdate()->get();if($other->isNotEmpty())TravelMateReservations::fail('Another refund reserves this payment amount.');
                DB::table('bookings')->where('id',$b->id)->update(['status'=>'cancelled','hold_expires_at'=>null,'updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            }
            DB::table('refunds')->where('id',$id)->update(['status'=>$decision,'provider_reference'=>'demo-refund-'.$id,'refunded_at'=>$decision==='succeeded'?now('UTC')->format('Y-m-d H:i:s'):null]);
            TravelMateInbox::booking($b,$venue,'DEMO refund '.$decision.($decision==='succeeded'?'; booking cancelled':'').'; no money moved');
        },3);
    }
}
