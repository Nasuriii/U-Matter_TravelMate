<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class TravelMateTripController extends Controller
{
    private function owned(Request $request, string $trip, bool $lock = false)
    {
        $query = DB::table('trips')->where('id', $trip)->where('user_id', $request->user()->id);
        $row = ($lock ? $query->lockForUpdate() : $query)->first();
        abort_unless($row, 404);
        return $row;
    }

    private function tripData(Request $request): array
    {
        return $request->validate([
            'name' => ['required', 'string', 'max:150'],
            'start_date' => ['nullable', 'required_with:end_date', 'date_format:Y-m-d', 'after_or_equal:1000-01-01', 'before_or_equal:9999-12-31'],
            'end_date' => ['nullable', 'required_with:start_date', 'date_format:Y-m-d', 'after_or_equal:1000-01-01', 'before_or_equal:9999-12-31', 'after_or_equal:start_date'],
            'budget' => ['nullable', 'numeric', 'min:0', 'max:9999999999.99', 'decimal:0,2'],
            'status' => ['required', Rule::in(['draft', 'planned', 'ongoing', 'completed', 'cancelled'])],
        ]);
    }

    private function checkDates(array $data): void
    {
        if ($data['status'] !== 'draft' && empty($data['start_date'])) {
            throw ValidationException::withMessages(['start_date' => 'Set both trip dates before changing its status from Draft.']);
        }
    }

    private function itemData(Request $request): array
    {
        return $request->validate([
            'activity' => ['required', 'string', 'max:255'],
            'planned_date' => ['nullable', 'required_with:planned_time', 'date_format:Y-m-d', 'after_or_equal:1000-01-01', 'before_or_equal:9999-12-31'],
            'planned_time' => ['nullable', 'date_format:H:i'],
            'notes' => ['nullable', 'string', 'max:5000'],
            'status' => ['required', Rule::in(['planned', 'completed', 'skipped'])],
        ]);
    }

    private function checkSchedule($trip, array $data): void
    {
        if (! empty($data['planned_date']) &&
            (! $trip->start_date || ! $trip->end_date ||
             $data['planned_date'] < $trip->start_date || $data['planned_date'] > $trip->end_date)) {
            throw ValidationException::withMessages(['planned_date' => 'Choose a day within the trip dates. Set trip dates first if this is an undated draft.']);
        }
    }

    public function index(Request $request)
    {
        $request->validate(['page' => ['nullable', 'integer', 'min:1', 'max:100000']]);
        return view('travelmate.trips.index', [
            'trips' => DB::table('trips')->where('user_id', $request->user()->id)
                ->orderByDesc('updated_at')->orderByDesc('id')->paginate(12),
        ]);
    }

    public function store(Request $request)
    {
        $data = $this->tripData($request);
        $this->checkDates($data);
        $data['user_id'] = $request->user()->id;
        $data['completed_at'] = $data['status'] === 'completed' ? now('UTC')->format('Y-m-d H:i:s') : null;
        $id = DB::table('trips')->insertGetId($data);
        return redirect()->route('trips.show', $id)->with('status', 'Trip created. Add your first activity below.');
    }

    public function show(Request $request, string $trip)
    {
        $record = $this->owned($request, $trip);
        return view('travelmate.trips.show', [
            'trip' => $record,
            'items' => DB::table('trip_items as i')
                ->leftJoin('destinations as d', 'd.id', '=', 'i.destination_id')
                ->leftJoin('business_listings as b', 'b.id', '=', 'i.listing_id')
                ->leftJoin('destinations as bd', 'bd.id', '=', 'b.destination_id')
                ->where('i.trip_id', $record->id)->orderBy('i.sequence_number')
                ->select('i.*', 'd.name as destination_name', 'd.slug as destination_slug',
                    'd.is_active as destination_active', 'b.name as listing_name', 'b.slug as listing_slug',
                    'b.status as listing_status', 'bd.is_active as listing_destination_active')->get(),
            'destinations' => DB::table('destinations')->where('is_active', 1)->orderBy('name')
                ->get(['id', 'name', 'province']),
        ]);
    }

    public function update(Request $request, string $trip)
    {
        $this->owned($request, $trip);
        $data = $this->tripData($request);
        $this->checkDates($data);
        DB::transaction(function () use ($request, $trip, $data) {
            $record = $this->owned($request, $trip, true);
            $scheduled = DB::table('trip_items')->where('trip_id', $record->id)->whereNotNull('planned_date');
            if (empty($data['start_date'])) {
                $conflicts = $scheduled->exists();
            } else {
                $conflicts = $scheduled->where(function ($q) use ($data) {
                    $q->where('planned_date', '<', $data['start_date'])
                        ->orWhere('planned_date', '>', $data['end_date']);
                })->exists();
            }
            if ($conflicts) {
                throw ValidationException::withMessages(['start_date' => 'Some itinerary entries fall outside these dates. Reschedule or unschedule those entries first.']);
            }
            $data['completed_at'] = $data['status'] === 'completed'
                ? ($record->completed_at ?? now('UTC')->format('Y-m-d H:i:s')) : null;
            $data['updated_at'] = now('UTC')->format('Y-m-d H:i:s');
            DB::table('trips')->where('id', $record->id)->where('user_id', $request->user()->id)->update($data);
        }, 3);
        return redirect()->route('trips.show', $trip)->with('status', 'Trip updated.');
    }

    public function storeItem(Request $request, string $trip)
    {
        $this->owned($request, $trip);
        $data = $this->itemData($request);
        $target = $request->validate(['destination_id' => ['nullable', 'integer', 'min:1']]);
        DB::transaction(function () use ($request, $trip, $data, $target) {
            $record = $this->owned($request, $trip, true);
            $this->checkSchedule($record, $data);
            if (! empty($target['destination_id'])) {
                $exists = DB::table('destinations')->where('id', $target['destination_id'])
                    ->where('is_active', 1)->lockForUpdate()->first(['id']);
                if (! $exists) {
                    throw ValidationException::withMessages(['destination_id' => 'Choose an available destination.']);
                }
            }
            $data['trip_id'] = $record->id;
            $data['destination_id'] = $target['destination_id'] ?? null;
            $data['sequence_number'] = 1 + (int) DB::table('trip_items')->where('trip_id', $record->id)->max('sequence_number');
            DB::table('trip_items')->insert($data);
            DB::table('trips')->where('id', $record->id)->update(['updated_at' => now('UTC')->format('Y-m-d H:i:s')]);
        }, 3);
        return redirect()->route('trips.show', $trip)->with('status', 'Activity added.');
    }

    public function editItem(Request $request, string $trip, string $item)
    {
        $record = $this->owned($request, $trip);
        $entry = DB::table('trip_items')->where('trip_id', $record->id)->where('id', $item)->first();
        abort_unless($entry, 404);
        return view('travelmate.trips.edit-item', ['trip' => $record, 'item' => $entry]);
    }

    public function updateItem(Request $request, string $trip, string $item)
    {
        $this->owned($request, $trip);
        $data = $this->itemData($request);
        DB::transaction(function () use ($request, $trip, $item, $data) {
            $record = $this->owned($request, $trip, true);
            $entry = DB::table('trip_items')->where('trip_id', $record->id)->where('id', $item);
            abort_unless($entry->exists(), 404);
            $this->checkSchedule($record, $data);
            $entry->update($data);
            DB::table('trips')->where('id', $record->id)->update(['updated_at' => now('UTC')->format('Y-m-d H:i:s')]);
        }, 3);
        return redirect()->route('trips.show', $trip)->with('status', 'Activity updated.');
    }

    public function destroyItem(Request $request, string $trip, string $item)
    {
        DB::transaction(function () use ($request, $trip, $item) {
            $record = $this->owned($request, $trip, true);
            $entry = DB::table('trip_items')->where('trip_id', $record->id)->where('id', $item);
            abort_unless($entry->exists(), 404);
            $entry->delete();
            DB::table('trips')->where('id', $record->id)->update(['updated_at' => now('UTC')->format('Y-m-d H:i:s')]);
        }, 3);
        return redirect()->route('trips.show', $trip)->with('status', 'Activity removed.');
    }
}
