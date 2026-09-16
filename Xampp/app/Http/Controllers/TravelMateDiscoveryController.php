<?php
namespace App\Http\Controllers;
use App\Services\TravelMateDiscovery as D;
use App\Services\TravelMateTransport as T;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
class TravelMateDiscoveryController extends Controller
{
    public function index(Request $r){return view('travelmate.discovery.suggestions',D::suggestions((int)$r->user()->id));}
    public function preferences(Request $r){T::role($r->user(),'admin');$r->validate(['page'=>'nullable|integer|min:1|max:100000']);return view('travelmate.discovery.preferences',['preferences'=>DB::table('preferences')->orderBy('category')->orderBy('name')->paginate(30)]);}
    public function addPreference(Request $r){
        T::role($r->user(),'admin');$d=$r->validate(['category'=>'required|string|max:100|regex:/\S/u','name'=>'required|string|max:100|regex:/\S/u']);
        DB::table('preferences')->insertOrIgnore(['category'=>trim($d['category']),'name'=>trim($d['name'])]);return back()->with('status','Preference option is available in user profiles.');
    }
}
