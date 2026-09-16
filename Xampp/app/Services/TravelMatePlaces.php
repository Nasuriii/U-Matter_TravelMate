<?php
namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Illuminate\Database\QueryException;

class TravelMatePlaces
{
    public static function saveDestination(?string $id,array $input): int
    {
        $existing=$id===null?null:DB::table('destinations')->where('id',$id)->first();
        if($id!==null)abort_unless($existing,404);
        foreach(['name','province'] as $field){
            if(isset($input[$field]) && is_string($input[$field]))$input[$field]=trim($input[$field]);
        }
        $unique=Rule::unique('destinations','name')->where('province',is_string($input['province']??null)?$input['province']:'');
        if($existing)$unique->ignore($existing->id);
        $data=Validator::make($input,[
            'name'=>['required','string','max:150',$unique],
            'province'=>['required','string','max:100'],
            'category_id'=>['required','integer',Rule::exists('categories','id')],
            'description'=>['nullable','string','max:10000'],
            'latitude'=>['nullable','required_with:longitude','numeric','between:-90,90','decimal:0,7'],
            'longitude'=>['nullable','required_with:latitude','numeric','between:-180,180','decimal:0,7'],
            'is_active'=>['required',Rule::in(['0','1'])],
        ])->validate();
        $data['latitude']=$data['latitude']??null;
        $data['longitude']=$data['longitude']??null;
        $data['description']=$data['description']??null;
        try{
            return DB::transaction(function()use($existing,$data){
                $data['updated_at']=now('UTC')->format('Y-m-d H:i:s');
                if($existing){
                    abort_unless(DB::table('destinations')->where('id',$existing->id)->lockForUpdate()->first(['id']),404);
                    DB::table('destinations')->where('id',$existing->id)->update($data);
                    return (int)$existing->id;
                }
                $data['slug']=Str::limit(Str::slug($data['name'].'-'.$data['province']),135,'').'-'.Str::uuid();
                $data['created_at']=$data['updated_at'];
                return (int)DB::table('destinations')->insertGetId($data);
            },3);
        }catch(QueryException $e){
            if((int)($e->errorInfo[1]??0)===1062)
                throw ValidationException::withMessages(['name'=>'That destination name and province already exist.']);
            throw $e;
        }
    }

    public static function saveCategory(?string $id,array $input): int
    {
        $existing=$id===null?null:DB::table('categories')->where('id',$id)->first();
        if($id!==null)abort_unless($existing,404);
        if(isset($input['name']) && is_string($input['name']))$input['name']=trim($input['name']);
        $unique=Rule::unique('categories','name');
        if($existing)$unique->ignore($existing->id);
        $data=Validator::make($input,[
            'name'=>['required','string','max:100',$unique],
            'description'=>['nullable','string','max:5000'],
        ])->validate();
        $data['description']=$data['description']??null;
        try{
            if($existing){DB::table('categories')->where('id',$existing->id)->update($data);return (int)$existing->id;}
            return (int)DB::table('categories')->insertGetId($data);
        }catch(QueryException $e){
            if((int)($e->errorInfo[1]??0)===1062)
                throw ValidationException::withMessages(['name'=>'That category name already exists.']);
            throw $e;
        }
    }

    public static function directory(array $input)
    {
        $filters=Validator::make($input,[
            'q'=>['nullable','string','max:150'],
            'type'=>['nullable',Rule::in(['hotel','restaurant','attraction'])],
            'destination'=>['nullable','integer',Rule::exists('destinations','id')->where('is_active',1)],
            'sort'=>['nullable',Rule::in(['name','rating'])],
            'page'=>['nullable','integer','min:1','max:100000'],
        ])->validate();
        $q=DB::table('business_listings as b')->join('destinations as d','d.id','=','b.destination_id')
            ->where('b.status','approved')->where('d.is_active',1)
            ->select('b.id','b.name','b.slug','b.description','b.listing_type','d.name as destination_name','d.province')
            ->selectSub(function($r){$r->from('reviews')->selectRaw('AVG(rating)')
                ->whereColumn('listing_id','b.id')->where('status','published');},'average_rating')
            ->selectSub(function($r){$r->from('reviews')->selectRaw('COUNT(*)')
                ->whereColumn('listing_id','b.id')->where('status','published');},'review_count');
        if(!empty($filters['type']))$q->where('b.listing_type',$filters['type']);
        if(!empty($filters['destination']))$q->where('b.destination_id',$filters['destination']);
        $search=trim($filters['q']??'');
        if($search!==''){
            $pattern='%'.str_replace(['!','%','_'],['!!','!%','!_'],$search).'%';
            $q->where(function($where)use($pattern){
                $where->whereRaw("b.name LIKE ? ESCAPE '!'",[$pattern])
                    ->orWhereRaw("d.name LIKE ? ESCAPE '!'",[$pattern])
                    ->orWhereRaw("d.province LIKE ? ESCAPE '!'",[$pattern]);
            });
        }
        if(($filters['sort']??'name')==='rating')$q->orderByDesc('average_rating');
        $q->orderBy('b.name')->orderBy('b.id');
        return [$q,$filters];
    }
}
