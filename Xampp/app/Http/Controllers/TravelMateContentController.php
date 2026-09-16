<?php
namespace App\Http\Controllers;
use App\Services\TravelMateContent as C;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
class TravelMateContentController extends Controller
{
    public function queue(Request $request) {
        abort_unless(C::admin($request->user()),403);
        $request->validate(['page'=>'nullable|integer|min:1|max:100000']);
        return view('travelmate.content.queue',['photos'=>DB::table('photos')->where('status','pending')->orderBy('id')->paginate(20)]);
    }
    public function index(Request $request,string $kind,string $target) {
        $row=C::target($request->user(),$kind,$target);
        return view('travelmate.content.manage',['row'=>$row,'kind'=>$kind,'admin'=>C::admin($request->user()),'photos'=>C::photos($kind,$target)->get(),'extras'=>$kind==='listing'?C::details($row):[], 'amenities'=>DB::table('amenities')->orderBy('name')->get()]);
    }
    public function save(Request $request,string $kind,string $target) {
        C::target($request->user(),$kind,$target);abort_unless($kind==='listing',422);
        C::save($request->user(),$target,$request->all());
        return back()->with('status','Details saved. The listing needs admin approval again.');
    }
    public function upload(Request $request,string $kind,string $target) {
        C::target($request->user(),$kind,$target);
        $d=$request->validate(['photo'=>'required|image|mimes:jpg,jpeg,png,webp|max:2048|dimensions:max_width=4096,max_height=4096','caption'=>'nullable|string|max:255','sort_order'=>'required|integer|min:0|max:9999']);
        $extension=match($request->file('photo')->getMimeType()){'image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp',default=>abort(422)};
        $name=(string)Str::uuid().'.'.$extension;
        $folder=storage_path('app/travelmate-media');
        if(!is_dir($folder) && !mkdir($folder,0755,true) && !is_dir($folder))throw new \RuntimeException('Cannot create photo directory.');
        $request->file('photo')->move($folder,$name);
        try {
            DB::transaction(function()use($request,$kind,$target,$d,$name){
                C::target($request->user(),$kind,$target,true);
                if(C::photos($kind,$target)->count()>=20)throw ValidationException::withMessages(['photo'=>'Maximum 20 photos per destination or listing. Remove one first.']);
                DB::table('photos')->insert([$kind.'_id'=>$target,'url'=>'travelmate-media/'.$name,'caption'=>$d['caption']??null,'sort_order'=>$d['sort_order'],'status'=>C::admin($request->user())?'approved':'pending']);
                if(!C::admin($request->user()))\App\Services\TravelMateInbox::send(\App\Services\TravelMateInbox::admins(),"A photo for listing #{$target} is awaiting review. Open Admin > Photo approvals.");
            },3);
        }catch(\Throwable $e){@unlink($folder.'/'.$name);throw $e;}
        return back()->with('status','Photo saved. Owner uploads need photo approval before appearing publicly.');
    }
    public function photoAction(Request $request,string $kind,string $target,string $photo) {
        $d=$request->validate(['action'=>['required',Rule::in(['remove','approved','rejected'])]]);
        DB::transaction(function()use($request,$kind,$target,$photo,$d){
            C::target($request->user(),$kind,$target,true);
            $q=DB::table('photos')->where($kind.'_id',$target)->where('id',$photo);
            abort_unless((clone $q)->lockForUpdate()->first(),404);
            if($d['action']==='remove'){
                if(DB::table('user_reports')->where('photo_id',$photo)->lockForUpdate()->first())$q->update(['status'=>'rejected']);
                else $q->delete();
            }
            else {abort_unless(C::admin($request->user()),403);$q->update(['status'=>$d['action']]);}
        },3);
        return back()->with('status','Photo updated.');
    }
    public function image(Request $request,string $photo) {
        // This route also serves public images, so it cannot require login.
        // Discard stale session privileges before evaluating private photo access.
        $viewer = $request->user();
        if ($viewer) {
            $stamp = $request->session()->get('tm_password_stamp');
            if (!is_string($stamp) || !hash_equals(
                \App\Services\TravelMateSecurity::stamp($viewer->getAuthPassword()), $stamp
            )) {
                $viewer = null;
            }
        }
        $row=DB::table('photos')->where('id',$photo)->first();abort_unless($row && C::canSee($viewer,$row),404);
        abort_unless(preg_match('~\Atravelmate-media/[a-f0-9-]{36}\.(jpg|png|webp)\z~D',$row->url),404);
        $path=storage_path('app/'.$row->url);abort_unless(is_file($path),404);
        $mime=match(pathinfo($path,PATHINFO_EXTENSION)){'jpg'=>'image/jpeg','png'=>'image/png','webp'=>'image/webp'};
        return response()->file($path,['Content-Type'=>$mime,'X-Content-Type-Options'=>'nosniff','Cache-Control'=>'private, no-store']);
    }
    public function amenity(Request $request) {
        abort_unless(C::admin($request->user()),403);
        $d=$request->validate(['name'=>'required|string|max:100']);
        DB::table('amenities')->insertOrIgnore($d);
        return back()->with('status','Amenity is available to hotel owners.');
    }
}
