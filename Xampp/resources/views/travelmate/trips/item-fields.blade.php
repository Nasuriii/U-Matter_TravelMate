@php
$value = fn ($key, $default = '') => old('_form') === 'item' ? old($key, $default) : $default;
@endphp
<input type="hidden" name="_form" value="item">
<div class="profile-field"><label for="activity">Activity</label><input id="activity" name="activity" maxlength="255" required value="{{ $value('activity', $item->activity ?? '') }}" placeholder="Explore San Juan"></div>
@if(!isset($item))
<div class="profile-field"><label for="destination">Destination (optional)</label><select id="destination" name="destination_id">
<option value="">General activity / travel time</option>
@foreach($destinations as $destination)
<option value="{{ $destination->id }}" @selected((string)$value('destination_id') === (string)$destination->id)>{{ $destination->name }}, {{ $destination->province }}</option>
@endforeach
</select></div>
@endif
<div class="profile-row">
<div class="profile-field"><label for="planned-date">Day (optional)</label><input id="planned-date" type="date" name="planned_date" min="{{ $trip->start_date ?? '1000-01-01' }}" max="{{ $trip->end_date ?? '9999-12-31' }}" value="{{ $value('planned_date', $item->planned_date ?? '') }}"></div>
<div class="profile-field"><label for="planned-time">Time (optional)</label><input id="planned-time" name="planned_time" type="time" value="{{ $value('planned_time', isset($item->planned_time) ? substr($item->planned_time, 0, 5) : '') }}"></div>
</div>
<div class="profile-field"><label for="notes">Notes (optional)</label><textarea id="notes" name="notes" rows="3" maxlength="5000">{{ $value('notes', $item->notes ?? '') }}</textarea></div>
<div class="profile-field"><label for="item-status">Activity status</label><select id="item-status" name="status">
@foreach(['planned','completed','skipped'] as $status)
<option value="{{ $status }}" @selected($value('status', $item->status ?? 'planned') === $status)>{{ ucfirst($status) }}</option>
@endforeach
</select></div>
<p class="planner-hint">Use a day within the trip dates. A time requires a day. Leave both blank to schedule later.</p>
