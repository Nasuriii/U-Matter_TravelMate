<?php
namespace App\Http\Controllers;

use App\Services\TravelMateReservations as R;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class TravelMateBookingController extends Controller
{
    public function create(Request $request, string $listing)
    {
        $venue=R::publicListing($listing);
        $inventory=R::inventory($listing,$venue->listing_type);
        $fee=$venue->listing_type==='restaurant'
            ? DB::table('restaurants')->where('listing_id',$listing)->value('reservation_fee') : null;
        $quote=Crypt::encryptString(json_encode([
            'user'=>(int)$request->user()->id,'listing'=>$listing,'expires'=>time()+3600,
            'rates'=>$venue->listing_type==='hotel'?$inventory->pluck('base_nightly_rate','id')->all():[],
            'fee'=>$fee,
        ]));
        return view('travelmate.bookings.create',compact('venue','inventory','fee','quote')+[
            'requestKey'=>(string)Str::uuid(),
            'tomorrow'=>CarbonImmutable::tomorrow('Asia/Manila')->format('Y-m-d'),
        ]);
    }

    public function store(Request $request, string $listing)
    {
        $data=$request->validate([
            'guest_name'=>['required','string','max:150'],'guest_email'=>['required','email','max:254'],
            'guest_phone'=>['nullable','string','max:20'],'guest_count'=>['required','integer','between:1,65535'],
            'room_id'=>['nullable','integer','min:1'],'slot_id'=>['nullable','integer','min:1'],
            'check_in'=>['nullable','date_format:Y-m-d','after_or_equal:1000-01-01','before_or_equal:9999-12-31'],
            'check_out'=>['nullable','date_format:Y-m-d','after_or_equal:1000-01-01','before_or_equal:9999-12-31'],
            'request_key'=>['required','uuid'],'quote'=>['required','string','max:100000'],
        ]);
        $id=R::reserve((int)$request->user()->id,$listing,$data);
        return redirect()->route('bookings.show',$id)->with('status','Reservation request saved. Check its current status below. No payment was collected.');
    }

    public function index(Request $request)
    {
        $request->validate(['page'=>['nullable','integer','min:1','max:100000']]);
        return view('travelmate.bookings.index',[
            'ownerView'=>false,
            'bookings'=>DB::table('bookings')->where('user_id',$request->user()->id)
                ->orderByDesc('id')->paginate(15),
        ]);
    }

    public function ownerIndex(Request $request)
    {
        $request->validate(['page'=>['nullable','integer','min:1','max:100000']]);
        $owner=DB::table('business_owners')->where('user_id',$request->user()->id)->value('id');
        abort_unless($owner,403);
        $q=DB::table('bookings as b')->where(function($match)use($owner){
            $match->whereExists(function($h)use($owner){
                $h->selectRaw('1')->from('hotel_bookings as hb')
                    ->join('business_listings as bl','bl.id','=','hb.hotel_id')
                    ->whereColumn('hb.booking_id','b.id')->where('bl.owner_id',$owner);
            })->orWhereExists(function($r)use($owner){
                $r->selectRaw('1')->from('restaurant_bookings as rb')
                    ->join('restaurant_slots as s','s.id','=','rb.slot_id')
                    ->join('business_listings as bl','bl.id','=','s.restaurant_id')
                    ->whereColumn('rb.booking_id','b.id')->where('bl.owner_id',$owner);
            });
        });
        return view('travelmate.bookings.index',['ownerView'=>true,'bookings'=>$q->orderByDesc('b.id')->paginate(15,['b.*'])]);
    }

    private function showFor(Request $request,string $booking,bool $ownerView)
    {
        $row=DB::table('bookings')->where('id',$booking)->first();
        abort_unless($row,404);
        $listing=R::listingForBooking($booking);
        $venue=DB::table('business_listings')->where('id',$listing)->first();
        abort_unless($venue,404);
        if($ownerView){
            abort_unless(DB::table('business_owners')->where('id',$venue->owner_id)->where('user_id',$request->user()->id)->exists(),404);
        }else{abort_unless((int)$row->user_id===(int)$request->user()->id,404);}
        return view('travelmate.bookings.show',[
            'booking'=>$row,'venue'=>$venue,'ownerView'=>$ownerView,
            'effectiveStatus'=>R::effectiveStatus($row),
        ]+R::details($row));
    }

    public function show(Request $request,string $booking){return $this->showFor($request,$booking,false);}
    public function ownerShow(Request $request,string $booking){return $this->showFor($request,$booking,true);}

    public function cancel(Request $request,string $booking)
    {
        R::transition((int)$request->user()->id,$booking,'cancelled');
        return redirect()->route('bookings.show',$booking)->with('status','Booking cancelled.');
    }

    public function decide(Request $request,string $booking)
    {
        $data=$request->validate(['action'=>['required',Rule::in(['confirmed','cancelled','completed'])]]);
        R::transition((int)$request->user()->id,$booking,$data['action'],true);
        return redirect()->route('owner.bookings.show',$booking)->with('status','Booking status updated.');
    }
}
