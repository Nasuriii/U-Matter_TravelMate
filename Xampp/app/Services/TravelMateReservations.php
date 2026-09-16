<?php
namespace App\Services;

use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Validation\ValidationException;

class TravelMateReservations
{
    public static function fail(string $message): never
    {
        throw ValidationException::withMessages(['reservation' => $message]);
    }

    public static function cents(string $amount): int
    {
        [$whole,$fraction] = array_pad(explode('.', $amount, 2),2,'');
        return ((int)$whole * 100) + (int)str_pad($fraction,2,'0');
    }

    public static function money(int $cents): string
    {
        return intdiv($cents,100).'.'.str_pad((string)($cents%100),2,'0',STR_PAD_LEFT);
    }

    public static function active($query, string $alias='b')
    {
        return $query->where(function($q)use($alias){
            $q->where($alias.'.status','confirmed')
                ->orWhere(function($p)use($alias){
                    $p->where($alias.'.status','pending')
                        ->where($alias.'.hold_expires_at','>',CarbonImmutable::now('UTC')->format('Y-m-d H:i:s'));
                });
        });
    }

    public static function effectiveStatus($booking): string
    {
        return $booking->status==='pending' && $booking->hold_expires_at <= CarbonImmutable::now('UTC')->format('Y-m-d H:i:s')
            ? 'expired' : $booking->status;
    }

    public static function occupiedGuests(string $slot): int
    {
        return (int)self::active(DB::table('restaurant_bookings as rb')
            ->join('bookings as b','b.id','=','rb.booking_id')->where('rb.slot_id',$slot))->lockForUpdate()->get(['b.guest_count'])->sum('guest_count');
    }

    public static function listingForBooking(string $booking)
    {
        $hotel=DB::table('hotel_bookings')->where('booking_id',$booking)->value('hotel_id');
        if($hotel!==null)return $hotel;
        return DB::table('restaurant_bookings as rb')->join('restaurant_slots as s','s.id','=','rb.slot_id')
            ->where('rb.booking_id',$booking)->value('s.restaurant_id');
    }

    public static function publicListing(string $listing, bool $lock=false)
    {
        $q=DB::table('business_listings')->where('id',$listing)->where('status','approved')
            ->whereIn('listing_type',['hotel','restaurant']);
        $row=($lock?$q->lockForUpdate():$q)->first();
        abort_unless($row && DB::table('destinations')->where('id',$row->destination_id)->where('is_active',1)->exists(),404);
        return $row;
    }

    public static function inventory(string $listing, string $type)
    {
        if($type==='hotel'){
            return DB::table('rooms')->where('hotel_id',$listing)->where('operational_status','available')
                ->whereNotNull('base_nightly_rate')->orderBy('room_number')->get();
        }
        return DB::table('restaurant_slots')->where('restaurant_id',$listing)->where('is_open',1)
            ->where('starts_at','>',CarbonImmutable::now('UTC')->format('Y-m-d H:i:s'))
            ->orderBy('starts_at')->limit(100)->get();
    }

    public static function reserve(int $user, string $listing, array $data): int
    {
        return DB::transaction(function()use($user,$listing,$data){
            // Account lock serializes duplicate keys; listing lock serializes all
            // inventory checks/writes made through this reservation feature.
            DB::table('users')->where('id',$user)->lockForUpdate()->first(['id']);
            $key='tm7:'.hash('sha256',$user.'|'.$data['request_key']);
            $old=DB::table('bookings')->where('idempotency_key',$key)->where('user_id',$user)->lockForUpdate()->first(['id']);
            if($old)return (int)$old->id;
            $venue=self::publicListing($listing,true);
            try {$quote=json_decode(Crypt::decryptString($data['quote']),true,512,JSON_THROW_ON_ERROR);}
            catch(\Throwable $e){self::fail('The price quote is invalid. Reload the reservation page.');}
            if(!is_array($quote) || ($quote['user']??null)!==$user || (string)($quote['listing']??'')!==$listing ||
                (int)($quote['expires']??0)<time())self::fail('The price quote expired. Reload the reservation page.');

            $now=CarbonImmutable::now('UTC');
            if($venue->listing_type==='hotel'){
                if(empty($data['room_id']) || empty($data['check_in']) || empty($data['check_out']))
                    self::fail('Choose a room and both stay dates.');
                $arrival=CarbonImmutable::createFromFormat('!Y-m-d',$data['check_in'],'Asia/Manila');
                $departure=CarbonImmutable::createFromFormat('!Y-m-d',$data['check_out'],'Asia/Manila');
                $nights=(int)$arrival->diffInDays($departure,false);
                if($arrival<=CarbonImmutable::today('Asia/Manila') || $nights<1 || $nights>30)
                    self::fail('Choose a future arrival date and a stay of 1 to 30 nights.');
                $room=DB::table('rooms')->where('id',$data['room_id'])->where('hotel_id',$venue->id)
                    ->where('operational_status','available')->whereNotNull('base_nightly_rate')->lockForUpdate()->first();
                if(!$room || $room->max_guests<$data['guest_count'])self::fail('That room cannot accommodate this request.');
                $rate=self::cents((string)$room->base_nightly_rate);
                if((string)($quote['rates'][(string)$room->id]??'')!==(string)$room->base_nightly_rate)
                    self::fail('The room price changed. Reload the page to review the new price.');
                $overlap=self::active(DB::table('booking_rooms as br')
                    ->join('hotel_bookings as hb','hb.booking_id','=','br.booking_id')
                    ->join('bookings as b','b.id','=','hb.booking_id')
                    ->where('br.room_id',$room->id)
                    ->where('hb.check_in','<',$data['check_out'])
                    ->where('hb.check_out','>',$data['check_in']))->lockForUpdate()->get(['b.id'])->isNotEmpty();
                if($overlap)self::fail('That room is already held or reserved for these dates. Choose another room or stay.');
                $amount=$rate*$nights;
                $serviceStart=$arrival->utc();
            }else{
                if(empty($data['slot_id']))self::fail('Choose a reservation time.');
                $slot=DB::table('restaurant_slots')->where('id',$data['slot_id'])->where('restaurant_id',$venue->id)
                    ->where('is_open',1)->where('starts_at','>',$now->format('Y-m-d H:i:s'))->lockForUpdate()->first();
                if(!$slot)self::fail('That seating time is no longer available.');
                if(self::occupiedGuests((string)$slot->id)+$data['guest_count']>$slot->capacity)
                    self::fail('There are not enough seats left at that time.');
                $fee=DB::table('restaurants')->where('listing_id',$venue->id)->lockForUpdate()->first(['reservation_fee'])?->reservation_fee;
                if($fee===null)self::fail('This restaurant is not ready for reservations.');
                if((string)($quote['fee']??'')!==(string)$fee)
                    self::fail('The reservation fee changed. Reload the page to review the new price.');
                $amount=self::cents((string)$fee);
                $serviceStart=CarbonImmutable::parse($slot->starts_at,'UTC');
            }
            if($amount>999999999999)self::fail('The total exceeds the supported booking amount.');
            $expiry=$now->addHours(24);
            if($serviceStart<$expiry)$expiry=$serviceStart;
            $id=DB::table('bookings')->insertGetId([
                'user_id'=>$user,'booking_type'=>$venue->listing_type,
                'guest_name'=>$data['guest_name'],'guest_email'=>$data['guest_email'],
                'guest_phone'=>$data['guest_phone']??null,'guest_count'=>$data['guest_count'],
                'total_amount'=>self::money($amount),'status'=>'pending',
                'hold_expires_at'=>$expiry->format('Y-m-d H:i:s'),'idempotency_key'=>$key,
                'created_at'=>$now->format('Y-m-d H:i:s'),'updated_at'=>$now->format('Y-m-d H:i:s'),
            ]);
            if($venue->listing_type==='hotel'){
                DB::table('hotel_bookings')->insert(['booking_id'=>$id,'hotel_id'=>$venue->id,
                    'check_in'=>$data['check_in'],'check_out'=>$data['check_out']]);
                DB::table('booking_rooms')->insert(['booking_id'=>$id,'room_id'=>$room->id,'nightly_rate'=>self::money($rate)]);
            }else{
                DB::table('restaurant_bookings')->insert(['booking_id'=>$id,'slot_id'=>$slot->id]);
            }
            TravelMateInbox::booking((object)['id'=>$id,'user_id'=>$user],$venue,'request received; awaiting confirmation');
            return (int)$id;
        },3);
    }

    public static function details($booking): array
    {
        if($booking->booking_type==='hotel'){
            $stay=DB::table('hotel_bookings')->where('booking_id',$booking->id)->first();
            $rooms=DB::table('booking_rooms as br')->join('rooms as r','r.id','=','br.room_id')
                ->where('br.booking_id',$booking->id)->get(['r.room_number','r.room_type','br.nightly_rate']);
            return ['stay'=>$stay,'rooms'=>$rooms,'slot'=>null];
        }
        $slot=DB::table('restaurant_bookings as rb')->join('restaurant_slots as s','s.id','=','rb.slot_id')
            ->where('rb.booking_id',$booking->id)->first(['s.starts_at','s.ends_at']);
        return ['stay'=>null,'rooms'=>collect(),'slot'=>$slot];
    }

    public static function transition(int $actor, string $booking, string $action, bool $owner=false): void
    {
        DB::transaction(function()use($actor,$booking,$action,$owner){
            $listing=self::listingForBooking($booking);
            abort_unless($listing,404);
            $venue=DB::table('business_listings')->where('id',$listing)->lockForUpdate()->first();
            abort_unless($venue,404);
            $row=DB::table('bookings')->where('id',$booking)->lockForUpdate()->first();
            abort_unless($row,404);
            if($owner){
                abort_unless(DB::table('business_owners')->where('id',$venue->owner_id)->where('user_id',$actor)->exists(),404);
            }else{abort_unless((int)$row->user_id===$actor,404);}
            $status=self::effectiveStatus($row);
            if($action==='confirmed'){
                abort_unless($owner,403);
                if($status!=='pending')self::fail('Only an unexpired pending request can be confirmed.');
                // Closing inventory stops new requests but does not void existing holds.
            }elseif($action==='cancelled'){
                if(!in_array($status,['pending','confirmed'],true))self::fail('This booking cannot be cancelled.');
                $d=self::details($row);
                $started=$d['stay']
                    ? $d['stay']->check_in <= CarbonImmutable::today('Asia/Manila')->format('Y-m-d')
                    : (!$d['slot'] || $d['slot']->starts_at <= CarbonImmutable::now('UTC')->format('Y-m-d H:i:s'));
                if($started)self::fail('Cancellation is available only before the stay or seating time begins.');
                if(DB::table('payments')->where('booking_id',$row->id)->where('status','succeeded')->lockForUpdate()->get(['id'])->isNotEmpty())
                    self::fail('This booking has a recorded payment. A refund workflow is required before cancellation.');
            }elseif($action==='completed'){
                abort_unless($owner,403);
                if($status!=='confirmed')self::fail('Only confirmed bookings can be completed.');
                $d=self::details($row);
                $ended=$d['stay']
                    ? $d['stay']->check_out <= CarbonImmutable::today('Asia/Manila')->format('Y-m-d')
                    : ($d['slot'] && $d['slot']->ends_at <= CarbonImmutable::now('UTC')->format('Y-m-d H:i:s'));
                if(!$ended)self::fail('Complete the booking after the stay or seating time has ended.');
            }else{abort(422);}
            DB::table('bookings')->where('id',$row->id)->update([
                'status'=>$action,'hold_expires_at'=>null,'updated_at'=>CarbonImmutable::now('UTC')->format('Y-m-d H:i:s')]);
            TravelMateInbox::booking($row,$venue,$action);
        },3);
    }
}
