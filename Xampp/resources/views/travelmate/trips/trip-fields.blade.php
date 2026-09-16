@php
$value = fn ($key, $default = '') => old('_form') === 'trip' ? old($key, $default) : $default;
@endphp
<input type="hidden" name="_form" value="trip">
<div class="profile-field"><label for="trip-name">Trip name</label><input id="trip-name" name="name" maxlength="150" required value="{{ $value('name', $trip->name ?? '') }}" placeholder="La Union weekend"></div>
<div class="profile-row">
<div class="profile-field"><label for="trip-start">Start date</label><input id="trip-start" type="date" name="start_date" min="1000-01-01" max="9999-12-31" value="{{ $value('start_date', $trip->start_date ?? '') }}"></div>
<div class="profile-field"><label for="trip-end">End date</label><input id="trip-end" type="date" name="end_date" min="1000-01-01" max="9999-12-31" value="{{ $value('end_date', $trip->end_date ?? '') }}"></div>
</div>
<div class="profile-row">
<div class="profile-field"><label for="trip-budget">Budget in PHP (optional)</label><input id="trip-budget" name="budget" type="number" min="0" max="9999999999.99" step="0.01" value="{{ $value('budget', $trip->budget ?? '') }}"></div>
<div class="profile-field"><label for="trip-status">Trip status</label><select id="trip-status" name="status">
@foreach(['draft','planned','ongoing','completed','cancelled'] as $status)
<option value="{{ $status }}" @selected($value('status', $trip->status ?? 'draft') === $status)>{{ ucfirst($status) }}</option>
@endforeach
</select></div>
</div>
<p class="planner-hint">You can leave both dates blank for a draft. Other statuses need a start and end date.</p>
