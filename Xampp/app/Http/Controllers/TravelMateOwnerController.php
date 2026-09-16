<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\TravelMateInbox;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class TravelMateOwnerController extends Controller
{
    private function owner(Request $request)
    {
        $owner = DB::table('business_owners')->where('user_id', $request->user()->id)->first();
        abort_unless($owner, 403);
        return $owner->id;
    }

    private function owned(Request $request, string $listing, bool $lock = false)
    {
        $q = DB::table('business_listings')->where('id', $listing)->where('owner_id', $this->owner($request));
        $row = ($lock ? $q->lockForUpdate() : $q)->first();
        abort_unless($row, 404);
        return $row;
    }

    private function fields(Request $request, string $type): array
    {
        $rules = ['name' => ['required','string','max:150'],
            'description' => ['required','string','max:10000'],
            'address' => ['required','string','max:255']];
        $money = ['nullable','numeric','min:0','max:9999999999.99','decimal:0,2'];
        $rules += match ($type) {
            'hotel' => ['check_in_time' => ['nullable','date_format:H:i'], 'check_out_time' => ['nullable','date_format:H:i']],
            'restaurant' => ['operating_hours' => ['nullable','string','max:255'], 'reservation_fee' => $money],
            'attraction' => ['entrance_fee' => $money],
        };
        $data = $request->validate($rules);
        $base = array_intersect_key($data, array_flip(['name','description','address']));
        $sub = array_diff_key($data, $base);
        if ($type === 'restaurant') $sub['reservation_fee'] = $sub['reservation_fee'] ?? 0;
        return [$base, $sub];
    }

    private function table(string $type): string
    {
        return match ($type) {'hotel' => 'hotels', 'restaurant' => 'restaurants', 'attraction' => 'attractions'};
    }

    public function index(Request $request)
    {
        $data = $request->validate(['type' => ['nullable', Rule::in(['hotel','restaurant','attraction'])],
            'page' => ['nullable','integer','min:1','max:100000']]);
        return view('travelmate.owner.index', [
            'type' => $data['type'] ?? 'hotel',
            'listings' => DB::table('business_listings')->where('owner_id', $this->owner($request))
                ->orderByDesc('updated_at')->orderByDesc('id')->paginate(12)->withQueryString(),
            'destinations' => DB::table('destinations')->where('is_active',1)->orderBy('name')->get(['id','name','province']),
        ]);
    }

    public function store(Request $request)
    {
        $owner = $this->owner($request);
        $target = $request->validate(['listing_type' => ['required', Rule::in(['hotel','restaurant','attraction'])],
            'destination_id' => ['required','integer']]);
        [$base,$sub] = $this->fields($request, $target['listing_type']);
        $id = DB::transaction(function () use ($owner, $target, $base, $sub) {
            $d = DB::table('destinations')->where('id',$target['destination_id'])->where('is_active',1)->lockForUpdate()->first(['id']);
            if (!$d) throw ValidationException::withMessages(['destination_id' => 'Choose an available destination.']);
            $id = DB::table('business_listings')->insertGetId($base + [
                'owner_id'=>$owner, 'destination_id'=>$d->id, 'listing_type'=>$target['listing_type'],
                'slug'=>Str::slug($base['name']).'-'.Str::uuid(), 'status'=>'pending',
            ]);
            DB::table($this->table($target['listing_type']))->insert(['listing_id'=>$id] + $sub);
            TravelMateInbox::submitted(DB::table('business_listings')->where('id',$id)->first());
            return $id;
        }, 3);
        return redirect()->route('owner.edit',$id)->with('status','Listing submitted for approval.');
    }

    public function edit(Request $request, string $listing)
    {
        $row = $this->owned($request,$listing);
        return view('travelmate.owner.edit', ['listing'=>$row,'type'=>$row->listing_type,
            'details'=>DB::table($this->table($row->listing_type))->where('listing_id',$row->id)->first()]);
    }

    public function update(Request $request, string $listing)
    {
        $row = $this->owned($request,$listing);
        [$base,$sub] = $this->fields($request,$row->listing_type);
        DB::transaction(function () use ($request,$listing,$base,$sub) {
            $row = $this->owned($request,$listing,true);
            DB::table('business_listings')->where('id',$row->id)->update($base + [
                'status'=>'pending','updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            DB::table($this->table($row->listing_type))->updateOrInsert(['listing_id'=>$row->id],$sub);
            TravelMateInbox::submitted(DB::table('business_listings')->where('id',$row->id)->first());
        },3);
        return redirect()->route('owner.edit',$listing)->with('status','Changes submitted for approval. The listing is hidden until approved.');
    }

    public function deactivate(Request $request, string $listing)
    {
        DB::transaction(function () use ($request,$listing) {
            $row=$this->owned($request,$listing,true);
            if($row->status === 'inactive')return;
            DB::table('business_listings')->where('id',$row->id)->update([
                'status'=>'inactive','updated_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            TravelMateInbox::listingDecision($row,'taken offline');
        },3);
        return redirect()->route('owner.index')->with('status','Listing deactivated.');
    }
}
