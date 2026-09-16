<?php
namespace App\Services;
use Illuminate\Support\Facades\DB;
class TravelMateDiscovery
{
    public static function map($place):string {
        $q=isset($place->latitude,$place->longitude)?$place->latitude.','.$place->longitude:$place->name.', '.$place->province;
        return 'https://www.google.com/maps/search/?'.http_build_query(['api'=>1,'query'=>$q],'','&',PHP_QUERY_RFC3986);
    }
    private static function words(string $s):array {
        $words=preg_split('/[^\p{L}\p{N}]+/u',mb_strtolower($s),-1,PREG_SPLIT_NO_EMPTY);
        return array_values(array_unique(array_filter($words,fn($w)=>mb_strlen($w)>=3 && !in_array($w,['the','and','with','for','travel','trips','trip','style','visit','visits','tour','tours']))));
    }
    public static function suggestions(int $user):array {
        // Caller supplies authenticated id only. No client-selected user context.
        $preferences=DB::table('preferences as p')->join('user_preferences as up','up.preference_id','=','p.id')->where('up.user_id',$user)->orderBy('p.id')->limit(100)->get(['p.name','p.category']);
        $tokens=[];foreach($preferences as $pref)foreach(self::words($pref->name) as $word)$tokens[$word]=$word;
        $tokens=array_slice(array_values($tokens),0,64);$best=[];
        $places=DB::table('destinations as d')->join('categories as c','c.id','=','d.category_id')->where('d.is_active',1)->orderBy('d.id')->select('d.*','c.name as category_name')->cursor();
        foreach($places as $place) {
            $category=self::words($place->category_name);$text=self::words($place->name.' '.($place->description??''));
            $categoryMatch=array_intersect($tokens,$category);$textMatch=array_intersect($tokens,$text);
            $matched=array_values(array_unique(array_merge($categoryMatch,$textMatch)));
            $place->match_score=count($categoryMatch)*3+count(array_diff($textMatch,$categoryMatch));
            $place->reason=$matched?'Matches your saved interests: '.implode(', ',array_slice($matched,0,6)).'.':'An active destination to explore; no saved-interest match.';
            $best[]=$place;
            usort($best,fn($a,$b)=>($b->match_score<=>$a->match_score) ?: (strcasecmp($a->name,$b->name) ?: ($a->id<=>$b->id)));
            if(count($best)>12)array_pop($best);
        }
        return ['suggestions'=>collect($best),'preferences'=>$preferences];
    }
}
