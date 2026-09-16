<?php
namespace App\Http\Controllers;
use App\Services\TravelMateOperations as O;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
class TravelMateOperationsController extends Controller
{
    public function accounts(Request $r){
        O::admin($r->user());$d=$r->validate(['q'=>'nullable|string|max:150','status'=>['nullable',Rule::in(['active','suspended','closed'])],'page'=>'nullable|integer|min:1|max:100000']);
        $q=DB::table('users')->select('id','full_name','email','account_status','created_at');
        if(!empty($d['status']))$q->where('account_status',$d['status']);
        if(!empty($d['q'])){$term='%'.str_replace(['!','%','_'],['!!','!%','!_'],$d['q']).'%';$q->where(function($q)use($term){$q->whereRaw("full_name LIKE ? ESCAPE '!'",[$term])->orWhereRaw("email LIKE ? ESCAPE '!'",[$term]);});}
        $users=$q->orderBy('id')->paginate(20)->withQueryString();
        $roles=DB::table('user_roles as ur')->join('roles as r','r.id','=','ur.role_id')->whereIn('ur.user_id',$users->pluck('id'))->get(['ur.user_id','r.name'])->groupBy('user_id');
        return view('travelmate.operations.accounts',['users'=>$users,'roles'=>$roles,'filters'=>$d]);
    }
    public function account(Request $r,string $account){O::account($r->user(),$account,$r->all());return back()->with('status','Account access updated.');}
    public function issues(Request $r){$r->validate(['page'=>'nullable|integer|min:1|max:100000']);return view('travelmate.operations.issues',['admin'=>false,'issues'=>DB::table('user_reports')->where('user_id',$r->user()->id)->orderByDesc('id')->paginate(15)]);}
    public function create(Request $r){$d=$r->validate(['type'=>['nullable',Rule::in(O::REPORT_TYPES)],'target'=>'nullable|integer|min:1']);$type=$d['type']??'bug';return view('travelmate.operations.create',['type'=>$type,'target'=>O::target($type,isset($d['target'])?(string)$d['target']:null)]);}
    public function store(Request $r){$id=O::report($r->user(),$r->all());return redirect()->route('issues.show',$id)->with('status','Issue submitted to the admins.');}
    public function show(Request $r,string $issue){return view('travelmate.operations.issue',['admin'=>false,'issue'=>O::issue($r->user(),$issue)]);}
    public function adminIssues(Request $r){O::admin($r->user());$d=$r->validate(['status'=>['nullable',Rule::in(['pending','resolved','all'])],'page'=>'nullable|integer|min:1|max:100000']);$status=$d['status']??'pending';$q=DB::table('user_reports');if($status!=='all')$q->where('status',$status);return view('travelmate.operations.issues',['admin'=>true,'status'=>$status,'issues'=>$q->orderByDesc('id')->paginate(20)->withQueryString()]);}
    public function adminIssue(Request $r,string $issue){return view('travelmate.operations.issue',['admin'=>true,'issue'=>O::issue($r->user(),$issue,true)]);}
    public function moderate(Request $r,string $issue){O::moderate($r->user(),$issue,$r->all());return back()->with('status','Issue updated.');}
    public function analytics(Request $r){O::admin($r->user());$r->validate(['page'=>'nullable|integer|min:1|max:100000']);$period=O::period($r->all());return view('travelmate.operations.analytics',['period'=>$period,'metrics'=>DB::transaction(fn()=>O::metrics($period)),'reports'=>DB::table('analytics_reports')->where('status','generated')->orderByDesc('id')->paginate(15)->withQueryString()]);}
    public function generate(Request $r){$id=O::generate($r->user(),$r->all());return redirect()->route('operations.report',$id)->with('status','Activity snapshot saved.');}
    public function report(Request $r,string $report){return view('travelmate.operations.report',O::snapshot($r->user(),$report));}
    private static function csvCell($value):string{$s=(string)($value??'');return preg_match('/^[\s]*[=+@-]/u',$s)?"'".$s:$s;}
    public function csv(Request $r,string $report){
        $snapshot=O::snapshot($r->user(),$report);$row=$snapshot['report'];
        return response()->streamDownload(function()use($snapshot,$row){
            $out=fopen('php://output','w');fwrite($out,"\xEF\xBB\xBF");
            $write=function($cells)use($out){fputcsv($out,array_map([self::class,'csvCell'],$cells),',','"','');};
            $write(['TravelMate activity snapshot',$row->id]);$write(['Generated UTC',$row->generated_at]);$write(['Period start UTC',$row->period_start??'All dates']);$write(['Period end UTC (inclusive)',$row->period_end??'All dates']);
            $write(['Scope','Records created/submitted during the period; their status when generated.']);$write(['Metric','Value','Unit']);
            foreach($snapshot['metrics'] as $m)$write([$m->name,$m->value,$m->unit]);fclose($out);
        },'TravelMate-Activity-'.$row->id.'.csv',['Content-Type'=>'text/csv; charset=UTF-8','Cache-Control'=>'private, no-store']);
    }
}
