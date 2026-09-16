<?php
namespace App\Services;

use Illuminate\Support\Facades\DB;

class TravelMateInbox
{
    public static function send(array $recipients, string $message): void
    {
        $ids=array_values(array_unique(array_map('intval',$recipients)));
        // Recipients come from server-side ownership/role queries.
        if(!$ids)return;
        $now=now('UTC')->format('Y-m-d H:i:s');
        DB::table('notifications')->insert(array_map(fn($id)=>[
            'user_id'=>$id,'message'=>$message,'created_at'=>$now,'read_at'=>null,
        ],$ids));
    }

    public static function admins(): array
    {
        return DB::table('user_roles as ur')->join('roles as r','r.id','=','ur.role_id')
            ->join('users as u','u.id','=','ur.user_id')
            ->where('r.name','admin')->where('u.account_status','active')->pluck('u.id')->all();
    }

    public static function booking($booking,$venue,string $event): void
    {
        $owner=DB::table('business_owners')->where('id',$venue->owner_id)->value('user_id');
        self::send(array_filter([$booking->user_id,$owner]),
            "Booking #{$booking->id} at {$venue->name}: {$event}.");
    }

    public static function submitted($venue): void
    {
        $owner=DB::table('business_owners')->where('id',$venue->owner_id)->value('user_id');
        self::send(array_merge(self::admins(),$owner?[$owner]:[]),
            "Listing #{$venue->id} ({$venue->name}) was submitted for approval.");
    }

    public static function listingDecision($venue,string $decision): void
    {
        $owner=DB::table('business_owners')->where('id',$venue->owner_id)->value('user_id');
        if($owner)self::send([$owner],"Listing #{$venue->id} ({$venue->name}): {$decision}.");
    }

    public static function markRead(int $user,string $notification): void
    {
        $q=DB::table('notifications')->where('user_id',$user)->where('id',$notification);
        abort_unless((clone $q)->exists(),404);
        $q->whereNull('read_at')->update(['read_at'=>now('UTC')->format('Y-m-d H:i:s')]);
    }

    public static function markAllRead(int $user,string $upTo): void
    {
        DB::table('notifications')->where('user_id',$user)->where('id','<=',$upTo)
            ->whereNull('read_at')->update(['read_at'=>now('UTC')->format('Y-m-d H:i:s')]);
    }
}
