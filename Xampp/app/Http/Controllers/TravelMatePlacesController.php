<?php
namespace App\Http\Controllers;

use App\Services\TravelMatePlaces;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TravelMatePlacesController extends Controller
{
    public function directory(Request $request)
    {
        [$query,$filters]=TravelMatePlaces::directory($request->query());
        return view('travelmate.directory',[
            'listings'=>$query->paginate(12)->appends($filters),'filters'=>$filters,
            'destinations'=>DB::table('destinations')->where('is_active',1)->orderBy('name')->get(['id','name','province']),
        ]);
    }

    public function index(Request $request)
    {
        $request->validate(['page'=>['nullable','integer','min:1','max:100000']]);
        return view('travelmate.places.index',[
            'places'=>DB::table('destinations as d')->join('categories as c','c.id','=','d.category_id')
                ->orderBy('d.name')->orderBy('d.id')->paginate(15,['d.*','c.name as category_name']),
        ]);
    }

    public function create()
    {
        return view('travelmate.places.form',['place'=>null,'categories'=>DB::table('categories')->orderBy('name')->get()]);
    }

    public function store(Request $request)
    {
        $id=TravelMatePlaces::saveDestination(null,$request->all());
        return redirect()->route('admin.places.edit',$id)->with('status','Destination created.');
    }

    public function edit(string $destination)
    {
        $place=DB::table('destinations')->where('id',$destination)->first();
        abort_unless($place,404);
        return view('travelmate.places.form',['place'=>$place,'categories'=>DB::table('categories')->orderBy('name')->get()]);
    }

    public function update(Request $request,string $destination)
    {
        TravelMatePlaces::saveDestination($destination,$request->all());
        return redirect()->route('admin.places.edit',$destination)->with('status','Destination updated.');
    }

    public function categories(Request $request)
    {
        $request->validate(['page'=>['nullable','integer','min:1','max:100000']]);
        return view('travelmate.places.categories',['categories'=>DB::table('categories')->orderBy('name')->paginate(20)]);
    }

    public function storeCategory(Request $request)
    {
        TravelMatePlaces::saveCategory(null,$request->all());
        return redirect()->route('admin.categories')->with('status','Category created.');
    }

    public function editCategory(string $category)
    {
        $entry=DB::table('categories')->where('id',$category)->first();
        abort_unless($entry,404);
        return view('travelmate.places.category-form',['category'=>$entry]);
    }

    public function updateCategory(Request $request,string $category)
    {
        TravelMatePlaces::saveCategory($category,$request->all());
        return redirect()->route('admin.categories')->with('status','Category updated.');
    }
}
