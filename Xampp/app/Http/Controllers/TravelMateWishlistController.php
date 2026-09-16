<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Response;

class TravelMateWishlistController extends Controller
{
    public function index(Request $request): Response
    {
        $request->validate(['page' => ['nullable', 'integer', 'min:1', 'max:100000']]);
        $destinations = DB::table('wishlist_destinations as wd')
            ->join('wishlists as w', 'w.id', '=', 'wd.wishlist_id')
            ->join('destinations as d', 'd.id', '=', 'wd.destination_id')
            ->where('w.user_id', $request->user()->id)
            ->orderByDesc('wd.added_at')->orderByDesc('d.id')
            ->paginate(12, ['d.id', 'd.name', 'd.province', 'd.slug', 'd.is_active']);
        return response()->view('travelmate.wishlist', compact('destinations'))
            ->header('Cache-Control', 'no-store, private');
    }

    public function store(Request $request, string $destination): RedirectResponse
    {
        $userId = $request->user()->id;
        $slug = DB::transaction(function () use ($userId, $destination) {
            // Serialize this user's wishlist writes, including initial creation.
            DB::table('users')->where('id', $userId)->lockForUpdate()->first(['id']);
            $place = DB::table('destinations')->where('id', $destination)
                ->where('is_active', 1)->lockForUpdate()->first(['id', 'slug']);
            abort_unless($place, 404);
            $wishlistId = DB::table('wishlists')->where('user_id', $userId)->value('id');
            if ($wishlistId === null) {
                $wishlistId = DB::table('wishlists')->insertGetId(['user_id' => $userId]);
            }
            $entry = DB::table('wishlist_destinations')
                ->where('wishlist_id', $wishlistId)->where('destination_id', $place->id);
            if (! $entry->exists()) {
                DB::table('wishlist_destinations')->insert([
                    'wishlist_id' => $wishlistId,
                    'destination_id' => $place->id,
                    'added_at' => now('UTC')->format('Y-m-d H:i:s'),
                ]);
            }
            return $place->slug;
        }, 3);
        return redirect()->route('destinations.show', $slug)
            ->with('status', 'Destination saved to your wishlist.');
    }

    public function destroy(Request $request, string $destination): RedirectResponse
    {
        $userId = $request->user()->id;
        DB::transaction(function () use ($userId, $destination) {
            DB::table('users')->where('id', $userId)->lockForUpdate()->first(['id']);
            $wishlistId = DB::table('wishlists')->where('user_id', $userId)->value('id');
            if ($wishlistId !== null) {
                // Removal remains possible when a saved destination becomes inactive.
                DB::table('wishlist_destinations')->where('wishlist_id', $wishlistId)
                    ->where('destination_id', $destination)->delete();
            }
        }, 3);
        return redirect()->route('wishlist.index')->with('status', 'Destination removed from your wishlist.');
    }
}
