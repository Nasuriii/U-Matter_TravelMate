<?php
namespace App\Services;
use Illuminate\Support\Facades\DB;
class TravelMatePresentation
{
    public static function covers(string $kind,array $ids):array {
        if(!$ids || !in_array($kind,['destination','listing']))return [];
        $rows=DB::table('photos')->whereIn($kind.'_id',$ids)->where('status','approved')->where('url','like','travelmate-media/%')->orderBy('sort_order')->orderBy('id')->get(['id',$kind.'_id','url','caption']);
        $out=[];foreach($rows as $row){$id=$row->{$kind.'_id'};if(isset($out[$id]))continue;
            if(preg_match('~\Atravelmate-media/[a-f0-9-]{36}\.(jpg|png|webp)\z~D',$row->url) && is_file(storage_path('app/'.$row->url)))$out[$id]=$row;
        }return $out;
    }
}
