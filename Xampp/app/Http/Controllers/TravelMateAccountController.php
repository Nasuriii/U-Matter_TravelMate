<?php
namespace App\Http\Controllers;

use App\Services\TravelMateInbox;
use App\Services\TravelMateProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TravelMateAccountController extends Controller
{
    public function edit(Request $request)
    {
        return view('travelmate.account.profile',[
            'profile'=>$request->user(),
            'phones'=>DB::table('user_phones')->where('user_id',$request->user()->id)->orderBy('id')->pluck('phone_number')->all(),
            'preferences'=>DB::table('preferences')->orderBy('category')->orderBy('name')->get()->groupBy('category'),
            'selected'=>DB::table('user_preferences')->where('user_id',$request->user()->id)->pluck('preference_id')->all(),
        ]);
    }

    public function update(Request $request)
    {
        TravelMateProfile::save((int)$request->user()->id,$request->all());
        return redirect()->route('profile.edit')->with('status','Your profile and travel preferences have been saved.');
    }

    public function notifications(Request $request)
    {
        $request->validate(['page'=>['nullable','integer','min:1','max:100000']]);
        $query=DB::table('notifications')->where('user_id',$request->user()->id);
        return view('travelmate.account.notifications',[
            'notifications'=>(clone $query)->orderByDesc('id')->paginate(15),
            'unread'=>(clone $query)->whereNull('read_at')->count(),
            'upTo'=>(string)((clone $query)->max('id')??0),
        ]);
    }

    public function read(Request $request,string $notification)
    {
        TravelMateInbox::markRead((int)$request->user()->id,$notification);
        return redirect()->route('notifications.index')->with('status','Notification marked as read.');
    }

    public function readAll(Request $request)
    {
        $data=$request->validate(['up_to'=>['required','integer','min:0']]);
        TravelMateInbox::markAllRead((int)$request->user()->id,(string)$data['up_to']);
        return redirect()->route('notifications.index')->with('status','Notifications marked as read.');
    }
}
