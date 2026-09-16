<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\TravelMateInbox;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class TravelMateAdminController extends Controller
{
    private function snapshot(string $id, bool $lock=false): array
    {
        $q=DB::table('business_listings')->where('id',$id);
        $row=($lock?$q->lockForUpdate():$q)->first();
        abort_unless($row,404);
        $table=match($row->listing_type){'hotel'=>'hotels','restaurant'=>'restaurants','attraction'=>'attractions'};
        $details=DB::table($table)->where('listing_id',$row->id)->first();
        return [$row,$details];
    }

    public function index(Request $request)
    {
        $data=$request->validate(['status'=>['nullable',Rule::in(['pending','approved','rejected','inactive','all'])],
            'page'=>['nullable','integer','min:1','max:100000']]);
        $status=$data['status']??'pending';
        $q=DB::table('business_listings');
        if($status!=='all')$q->where('status',$status);
        return view('travelmate.admin.index',['status'=>$status,
            'listings'=>$q->orderBy('updated_at')->orderBy('id')->paginate(15)->withQueryString()]);
    }

    public function show(string $listing)
    {
        [$row,$details]=$this->snapshot($listing);
        return view('travelmate.admin.show',['listing'=>$row,'details'=>$details,
            'fingerprint'=>hash('sha256',json_encode([$row,$details,\App\Services\TravelMateContent::details($row)]))]);
    }

    public function decide(Request $request, string $listing)
    {
        $data=$request->validate(['decision'=>['required',Rule::in(['approved','rejected','inactive'])],
            'fingerprint'=>['required','string','size:64']]);
        DB::transaction(function()use($listing,$data){
            [$row,$details]=$this->snapshot($listing,true);
            if(!hash_equals(hash('sha256',json_encode([$row,$details,\App\Services\TravelMateContent::details($row)])),$data['fingerprint']))
                throw ValidationException::withMessages(['decision'=>'This listing changed. Reload and review its latest details before deciding.']);
            if($data['decision']!=='inactive' && $row->status!=='pending')
                throw ValidationException::withMessages(['decision'=>'Only pending submissions can be approved or rejected.']);
            if($data['decision']==='approved'){
                $active=DB::table('destinations')->where('id',$row->destination_id)->where('is_active',1)->exists();
                if(!$active || !$details || !trim($row->address??'') || !trim($row->description??''))
                    throw ValidationException::withMessages(['decision'=>'Approval requires an active destination, subtype details, an address and a description.']);
            }
            DB::table('business_listings')->where('id',$row->id)->update([
                'status'=>$data['decision'],'updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            TravelMateInbox::listingDecision($row,$data['decision']);
        },3);
        return redirect()->route('admin.index')->with('status','Listing decision saved.');
    }

    public function reviews(Request $request)
    {
        $request->validate(['page'=>['nullable','integer','min:1','max:100000']]);
        return view('travelmate.admin.reviews',['reviews'=>DB::table('reviews')
            ->orderByDesc('updated_at')->orderByDesc('id')->paginate(15)]);
    }

    public function moderateReview(Request $request, string $review)
    {
        $data=$request->validate(['status'=>['required',Rule::in(['published','hidden'])]]);
        DB::transaction(function()use($review,$data){
            $row=DB::table('reviews')->where('id',$review)->lockForUpdate()->first();
            abort_unless($row,404);
            if($row->status === $data['status'])return;
            DB::table('reviews')->where('id',$review)->update($data+['updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            TravelMateInbox::send([$row->user_id],"Your review #{$row->id} is now {$data['status']}.");
        },3);
        return redirect()->route('admin.reviews')->with('status','Review visibility updated.');
    }
}
