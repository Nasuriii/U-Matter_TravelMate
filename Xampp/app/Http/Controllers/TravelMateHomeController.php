<?php
namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB;
use App\Services\TravelMatePresentation as P;
class TravelMateHomeController extends Controller
{
    public function index(){
        $places=DB::table('destinations as d')->join('categories as c','c.id','=','d.category_id')->where('d.is_active',1)->orderBy('d.name')->limit(6)->get(['d.id','d.name','d.slug','d.province','d.description','c.name as category_name']);
        $covers=P::covers('destination',$places->pluck('id')->all());
        return view('travelmate.landing',['places'=>$places,'covers'=>$covers,'heroPhoto'=>collect($covers)->first(),'destinationCount'=>DB::table('destinations')->where('is_active',1)->count(),'listingCount'=>DB::table('business_listings as l')->join('destinations as d','d.id','=','l.destination_id')->where('l.status','approved')->where('d.is_active',1)->count()]);
    }
}
