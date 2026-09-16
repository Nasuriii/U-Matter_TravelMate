<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class TravelMateBrowseController extends Controller
{
    public function index(Request $request): View
    {
        $filters = $request->validate([
            'q' => ['nullable', 'string', 'max:150'],
            'category' => ['nullable', 'integer', Rule::exists('categories', 'id')],
            'sort' => ['nullable', Rule::in(['name_asc', 'name_desc'])],
            'page' => ['nullable', 'integer', 'min:1', 'max:100000'],
        ]);
        $search = trim($filters['q'] ?? '');
        $query = DB::table('destinations as d')
            ->join('categories as c', 'c.id', '=', 'd.category_id')
            ->where('d.is_active', 1)
            ->select('d.id', 'd.name', 'd.province', 'd.slug', 'd.description', 'd.latitude', 'd.longitude', 'c.name as category_name')
            ->selectSub(function ($counts) {
                $counts->from('business_listings as b')->selectRaw('COUNT(*)')
                    ->whereColumn('b.destination_id', 'd.id')->where('b.status', 'approved');
            }, 'listing_count');

        if ($search !== '') {
            // Bind input and escape LIKE wildcards so %, _ and ! are literal.
            $pattern = '%'.str_replace(['!', '%', '_'], ['!!', '!%', '!_'], $search).'%';
            $query->where(function ($match) use ($pattern) {
                $match->whereRaw("d.name LIKE ? ESCAPE '!'", [$pattern])
                    ->orWhereRaw("d.province LIKE ? ESCAPE '!'", [$pattern]);
            });
        }
        if (! empty($filters['category'])) {
            $query->where('d.category_id', $filters['category']);
        }
        $query->orderBy('d.name', ($filters['sort'] ?? '') === 'name_desc' ? 'desc' : 'asc')
            ->orderBy('d.id');

        return view('travelmate.destinations', [
            'destinations' => $query->paginate(12)->appends($request->only(['q', 'category', 'sort'])),
            'categories' => DB::table('categories')->orderBy('name')->get(['id', 'name']),
            'filters' => $filters,
        ]);
    }

    public function destination(Request $request, string $slug): View
    {
        $filters = $request->validate([
            'type' => ['nullable', Rule::in(['hotel', 'restaurant', 'attraction'])],
            'page' => ['nullable', 'integer', 'min:1', 'max:100000'],
        ]);
        $destination = DB::table('destinations as d')
            ->join('categories as c', 'c.id', '=', 'd.category_id')
            ->where('d.slug', $slug)->where('d.is_active', 1)
            ->select('d.id', 'd.name', 'd.province', 'd.slug', 'd.description', 'd.latitude', 'd.longitude', 'c.name as category_name')
            ->first();
        abort_unless($destination, 404);

        $query = DB::table('business_listings')
            ->where('destination_id', $destination->id)->where('status', 'approved');
        $counts = (clone $query)->select('listing_type')->selectRaw('COUNT(*) as total')
            ->groupBy('listing_type')->pluck('total', 'listing_type');
        if (! empty($filters['type'])) {
            $query->where('listing_type', $filters['type']);
        }

        $isSaved = $request->user()
            ? DB::table('wishlist_destinations as wd')
                ->join('wishlists as w', 'w.id', '=', 'wd.wishlist_id')
                ->where('w.user_id', $request->user()->id)
                ->where('wd.destination_id', $destination->id)->exists()
            : false;

        return view('travelmate.destination-detail', [
            'isSaved' => $isSaved,
            'destination' => $destination,
            'counts' => $counts,
            'type' => $filters['type'] ?? '',
            'listings' => $query->orderBy('name')->orderBy('id')
                ->paginate(12, ['name', 'slug', 'listing_type', 'description', 'address'])
                ->appends($request->only('type')),
        ]);
    }

    public function listing(string $slug): View
    {
        // The same publication rules apply to direct links, not only cards.
        $listing = DB::table('business_listings as b')
            ->join('destinations as d', 'd.id', '=', 'b.destination_id')
            ->where('b.slug', $slug)->where('b.status', 'approved')->where('d.is_active', 1)
            ->select('b.id', 'b.name', 'b.slug', 'b.listing_type', 'b.description', 'b.address',
                'd.name as destination_name', 'd.slug as destination_slug', 'd.province')
            ->first();
        abort_unless($listing, 404);

        $details = match ($listing->listing_type) {
            'hotel' => DB::table('hotels')->where('listing_id', $listing->id)
                ->first(['check_in_time', 'check_out_time']),
            'restaurant' => DB::table('restaurants')->where('listing_id', $listing->id)
                ->first(['operating_hours', 'reservation_fee']),
            'attraction' => DB::table('attractions')->where('listing_id', $listing->id)
                ->first(['entrance_fee']),
            default => null,
        };

        return view('travelmate.listing-detail', compact('listing', 'details'));
    }
}
