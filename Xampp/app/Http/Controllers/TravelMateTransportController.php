<?php
namespace App\Http\Controllers;
use App\Services\TravelMateTransport as T;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
class TravelMateTransportController extends Controller
{
    public function index(Request $r) {
        $d=$r->validate(['q'=>'nullable|string|max:150','destination'=>['nullable','integer',Rule::exists('destinations','id')->where('is_active',1)],'type'=>['nullable',Rule::in(T::TYPES)],'page'=>'nullable|integer|min:1|max:100000']);
        $q=T::publicQuery();
        if(!empty($d['destination']))$q->where('s.destination_id',$d['destination']);
        if(!empty($d['type']))$q->where('s.transport_type',$d['type']);
        if(!empty($d['q'])){$term='%'.str_replace(['!','%','_'],['!!','!%','!_'],$d['q']).'%';$q->where(function($q)use($term){$q->whereRaw("s.service_name LIKE ? ESCAPE '!'",[$term])->orWhereRaw("p.company_name LIKE ? ESCAPE '!'",[$term])->orWhereRaw("d.name LIKE ? ESCAPE '!'",[$term]);});}
        return view('travelmate.transport.index',['services'=>$q->orderBy('s.service_name')->orderBy('s.id')->paginate(12)->withQueryString(),'filters'=>$d,'destinations'=>$this->destinations(),'types'=>T::TYPES]);
    }
    public function show(string $service) {
        $row=T::publicQuery()->where('s.id',$service)->first();abort_unless($row,404);
        return view('travelmate.transport.show',['service'=>$row,'contacts'=>T::contacts($row->provider_id)]);
    }
    private function destinations(){return DB::table('destinations')->where('is_active',1)->orderBy('name')->get(['id','name','province']);}
    public function owner(Request $r) {
        $r->validate(['page'=>'nullable|integer|min:1|max:100000']);
        return view('travelmate.transport.owner',['providers'=>DB::table('transport_providers')->where('owner_id',T::owner($r->user()))->orderBy('id')->paginate(20)]);
    }
    public function storeProvider(Request $r) {
        $id=T::saveProvider($r->user(),null,$r->all());return redirect()->route('transport.owner.edit',$id)->with('status','Provider created. Add a service below.');
    }
    public function editProvider(Request $r,string $provider) {
        $row=T::provider($r->user(),$provider);
        return view('travelmate.transport.provider',['provider'=>$row,'phones'=>T::contacts($provider)->pluck('phone_number')->all(),'services'=>DB::table('transportation_services as s')->join('destinations as d','d.id','=','s.destination_id')->where('s.provider_id',$provider)->orderBy('s.id')->get(['s.*','d.name as destination_name']),'destinations'=>$this->destinations(),'types'=>T::TYPES]);
    }
    public function updateProvider(Request $r,string $provider) {
        T::saveProvider($r->user(),$provider,$r->all());return back()->with('status','Provider updated. Its active services need approval again.');
    }
    public function storeService(Request $r,string $provider) {
        T::saveService($r->user(),$provider,null,$r->all());return back()->with('status','Service submitted for approval.');
    }
    public function editService(Request $r,string $provider,string $service) {
        $p=T::provider($r->user(),$provider);$s=DB::table('transportation_services')->where('provider_id',$provider)->where('id',$service)->first();abort_unless($s,404);
        return view('travelmate.transport.edit-service',['provider'=>$p,'service'=>$s,'destinations'=>$this->destinations(),'types'=>T::TYPES]);
    }
    public function updateService(Request $r,string $provider,string $service) {
        T::saveService($r->user(),$provider,$service,$r->all());return redirect()->route('transport.owner.edit',$provider)->with('status','Service changes submitted for approval.');
    }
    public function deactivate(Request $r,string $provider,string $service) {
        T::deactivate($r->user(),$provider,$service);return redirect()->route('transport.owner.edit',$provider)->with('status','Service taken offline.');
    }
    public function admin(Request $r) {
        T::role($r->user(),'admin');$d=$r->validate(['status'=>['nullable',Rule::in(['pending','approved','rejected','inactive','all'])],'page'=>'nullable|integer|min:1|max:100000']);$status=$d['status']??'pending';
        $q=DB::table('transportation_services as s')->join('transport_providers as p','p.id','=','s.provider_id')->select('s.*','p.company_name');if($status!=='all')$q->where('s.status',$status);
        return view('travelmate.transport.admin',['services'=>$q->orderBy('s.id')->paginate(20)->withQueryString(),'status'=>$status]);
    }
    public function review(Request $r,string $service) {
        T::role($r->user(),'admin');$snapshot=T::snapshot($service);[$s,$p,$contacts]=$snapshot;
        return view('travelmate.transport.review',['service'=>$s,'provider'=>$p,'contacts'=>$contacts,'destination'=>DB::table('destinations')->where('id',$s->destination_id)->first(),'fingerprint'=>T::fingerprint($snapshot)]);
    }
    public function decide(Request $r,string $service) {
        T::decide($r->user(),$service,$r->all());return redirect()->route('transport.admin')->with('status','Transport decision saved.');
    }
}
