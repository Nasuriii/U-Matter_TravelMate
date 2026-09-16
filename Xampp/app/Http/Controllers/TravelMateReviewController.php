<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TravelMateReviewController extends Controller
{
    private function target(string $kind, string $slug)
    {
        abort_unless(in_array($kind,['destination','listing'],true),404);
        if ($kind==='destination') {
            $row=DB::table('destinations')->where('slug',$slug)->where('is_active',1)
                ->first(['id','name','slug']);
        } else {
            $row=DB::table('business_listings as b')->join('destinations as d','d.id','=','b.destination_id')
                ->where('b.slug',$slug)->where('b.status','approved')->where('d.is_active',1)
                ->first(['b.id','b.name','b.slug','b.owner_id']);
        }
        abort_unless($row,404);
        return $row;
    }

    public function index(Request $request, string $kind, string $slug)
    {
        $request->validate(['page'=>['nullable','integer','min:1','max:100000']]);
        $target=$this->target($kind,$slug);
        $column=$kind==='destination'?'destination_id':'listing_id';
        $q=DB::table('reviews')->where($column,$target->id)->where('status','published');
        $own=$request->user()?DB::table('reviews')->where($column,$target->id)
            ->where('user_id',$request->user()->id)->first():null;
        $isOwner=$kind==='listing' && $request->user() && DB::table('business_owners')
            ->where('id',$target->owner_id)->where('user_id',$request->user()->id)->exists();
        return view('travelmate.reviews.index',[
            'target'=>$target,'kind'=>$kind,'own'=>$own,'isOwner'=>$isOwner,
            'average'=>(clone $q)->avg('rating'),
            'reviews'=>$q->join('users as u','u.id','=','reviews.user_id')
                ->orderByDesc('reviews.created_at')->orderByDesc('reviews.id')
                ->paginate(10,['reviews.rating','reviews.review_text','reviews.created_at','u.full_name']),
        ]);
    }

    public function store(Request $request, string $kind, string $slug)
    {
        $target=$this->target($kind,$slug);
        $data=$request->validate(['rating'=>['required','integer','between:1,5'],
            'review_text'=>['nullable','string','max:5000']]);
        if ($kind==='listing') {
            abort_if(DB::table('business_owners')->where('id',$target->owner_id)
                ->where('user_id',$request->user()->id)->exists(),403);
        }
        $column=$kind==='destination'?'destination_id':'listing_id';
        DB::transaction(function () use ($request,$column,$target,$data) {
            DB::table('users')->where('id',$request->user()->id)->lockForUpdate()->first(['id']);
            $old=DB::table('reviews')->where('user_id',$request->user()->id)->where($column,$target->id)->first();
            $data['updated_at']=now('UTC')->format('Y-m-d H:i:s');
            if ($old) {
                // Editing does not bypass a moderator's hidden/pending decision.
                DB::table('reviews')->where('id',$old->id)->where('user_id',$request->user()->id)->update($data);
            } else {
                DB::table('reviews')->insert($data + ['user_id'=>$request->user()->id,$column=>$target->id,
                    'status'=>'published','created_at'=>now('UTC')->format('Y-m-d H:i:s')]);
            }
        },3);
        return redirect()->route('reviews.index',[$kind,$slug])->with('status','Your review has been saved.');
    }
}
