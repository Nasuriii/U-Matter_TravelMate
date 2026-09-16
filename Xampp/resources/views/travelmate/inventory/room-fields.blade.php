
<div class="profile-row">
<div class="profile-field"><label for="number">Room number</label><input id="number" name="room_number" maxlength="20" required value="{{ old('room_number',$item->room_number ?? '') }}"></div>
<div class="profile-field"><label for="type">Room type</label><input id="type" name="room_type" maxlength="80" required value="{{ old('room_type',$item->room_type ?? '') }}" placeholder="Double room"></div>
</div>
<div class="profile-row">
<div class="profile-field"><label for="capacity">Maximum guests</label><input id="capacity" name="max_guests" type="number" min="1" max="65535" required value="{{ old('max_guests',$item->max_guests ?? 2) }}"></div>
<div class="profile-field"><label for="rate">Nightly rate (PHP)</label><input id="rate" name="base_nightly_rate" type="number" min="0" max="9999999999.99" step="0.01" value="{{ old('base_nightly_rate',$item->base_nightly_rate ?? '') }}"></div>
</div>
<div class="profile-field"><label for="status">Room status</label><select id="status" name="operational_status">
@foreach(['available','maintenance','unavailable'] as $s)<option value="{{ $s }}" @selected(old('operational_status',$item->operational_status ?? 'available') === $s)>{{ ucfirst($s) }}</option>@endforeach
</select></div>
<p class="planner-hint">A blank rate prevents new requests. Available rooms are still checked against the requested stay dates.</p>
