<?php
namespace App\Http\Controllers;

use App\Services\TravelMateReservations as R;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class TravelMateInventoryController extends Controller
{
    private function owned(Request $request,string $listing,bool $lock=false)
    {
        $owner=DB::table('business_owners')->where('user_id',$request->user()->id)->value('id');
        abort_unless($owner,403);
        $q=DB::table('business_listings')->where('id',$listing)->where('owner_id',$owner)
            ->whereIn('listing_type',['hotel','restaurant']);
        $row=($lock?$q->lockForUpdate():$q)->first();
        abort_unless($row,404);
        return $row;
    }

    public function index(Request $request,string $listing)
    {
        $venue=$this->owned($request,$listing);
        $request->validate(['page'=>['nullable','integer','min:1','max:100000']]);
        $inventory=$venue->listing_type==='hotel'
            ? DB::table('rooms')->where('hotel_id',$listing)->orderBy('room_number')->paginate(20)
            : DB::table('restaurant_slots')->where('restaurant_id',$listing)->orderByDesc('starts_at')->paginate(20);
        return view('travelmate.inventory.index',compact('venue','inventory'));
    }

    private function roomData(Request $request): array
    {
        return $request->validate([
            'room_number'=>['required','string','max:20'],'room_type'=>['required','string','max:80'],
            'max_guests'=>['required','integer','between:1,65535'],
            'base_nightly_rate'=>['nullable','numeric','min:0','max:9999999999.99','decimal:0,2'],
            'operational_status'=>['required',Rule::in(['available','maintenance','unavailable'])],
        ]);
    }

    public function store(Request $request,string $listing)
    {
        $venue=$this->owned($request,$listing);
        if($venue->listing_type==='hotel'){
            $data=$this->roomData($request);
        }else{
            $data=$request->validate([
                'starts_at'=>['required','date_format:Y-m-d\TH:i'],
                'ends_at'=>['required','date_format:Y-m-d\TH:i','after:starts_at'],
                'capacity'=>['required','integer','between:1,65535'],
            ]);
        }
        DB::transaction(function()use($request,$listing,$data){
            $venue=$this->owned($request,$listing,true);
            if($venue->listing_type==='hotel'){
                $duplicate=DB::table('rooms')->where('hotel_id',$listing)->where('room_number',$data['room_number'])->lockForUpdate()->first(['id']);
                if($duplicate)R::fail('That room number already exists in this hotel.');
                DB::table('rooms')->insert($data+['hotel_id'=>$listing]);
            }else{
                $start=CarbonImmutable::createFromFormat('!Y-m-d\TH:i',$data['starts_at'],'Asia/Manila')->utc();
                $end=CarbonImmutable::createFromFormat('!Y-m-d\TH:i',$data['ends_at'],'Asia/Manila')->utc();
                if($start<=CarbonImmutable::now('UTC') || $end<=$start || $end->year>9999)
                    R::fail('Choose a future start and a later end time.');
                $conflict=DB::table('restaurant_slots')->where('restaurant_id',$listing)
                    ->where('starts_at','<',$end->format('Y-m-d H:i:s'))
                    ->where('ends_at','>',$start->format('Y-m-d H:i:s'))->lockForUpdate()->first(['id']);
                if($conflict)R::fail('This seating time overlaps an existing slot. Use separate time ranges.');
                DB::table('restaurant_slots')->insert(['restaurant_id'=>$listing,
                    'starts_at'=>$start->format('Y-m-d H:i:s'),'ends_at'=>$end->format('Y-m-d H:i:s'),
                    'capacity'=>$data['capacity'],'is_open'=>1]);
            }
        },3);
        return redirect()->route('owner.inventory',$listing)->with('status','Inventory added.');
    }

    public function edit(Request $request,string $listing,string $inventory)
    {
        $venue=$this->owned($request,$listing);
        $item=$venue->listing_type==='hotel'
            ? DB::table('rooms')->where('id',$inventory)->where('hotel_id',$listing)->first()
            : DB::table('restaurant_slots')->where('id',$inventory)->where('restaurant_id',$listing)->first();
        abort_unless($item,404);
        return view('travelmate.inventory.edit',compact('venue','item'));
    }

    public function update(Request $request,string $listing,string $inventory)
    {
        $venue=$this->owned($request,$listing);
        $data=$venue->listing_type==='hotel'?$this->roomData($request):$request->validate([
            'capacity'=>['required','integer','between:1,65535'],'is_open'=>['required',Rule::in(['0','1'])]]);
        DB::transaction(function()use($request,$listing,$inventory,$data){
            $venue=$this->owned($request,$listing,true);
            if($venue->listing_type==='hotel'){
                $q=DB::table('rooms')->where('id',$inventory)->where('hotel_id',$listing);
                abort_unless((clone $q)->lockForUpdate()->first(['id']),404);
                $duplicate=DB::table('rooms')->where('hotel_id',$listing)->where('room_number',$data['room_number'])
                    ->where('id','<>',$inventory)->lockForUpdate()->first(['id']);
                if($duplicate)R::fail('That room number already exists.');
                $existing=R::active(DB::table('booking_rooms as br')->join('hotel_bookings as hb','hb.booking_id','=','br.booking_id')
                    ->join('bookings as b','b.id','=','hb.booking_id')->where('br.room_id',$inventory)
                    ->where('hb.check_out','>',CarbonImmutable::today('Asia/Manila')->format('Y-m-d')))
                    ->lockForUpdate()->get(['b.guest_count']);
                if(($existing->max('guest_count')??0)>$data['max_guests'])
                    R::fail('This capacity would be below an existing reservation’s guest count.');
                $q->update($data);
            }else{
                $q=DB::table('restaurant_slots')->where('id',$inventory)->where('restaurant_id',$listing);
                abort_unless((clone $q)->lockForUpdate()->first(['id']),404);
                if(R::occupiedGuests($inventory)>$data['capacity'])R::fail('Capacity cannot be below currently held or reserved seats.');
                $q->update($data);
            }
        },3);
        return redirect()->route('owner.inventory',$listing)->with('status','Inventory updated. Existing booking prices are unchanged.');
    }
}
