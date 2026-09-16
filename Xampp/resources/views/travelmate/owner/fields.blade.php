<input type="hidden" name="listing_type" value="{{ $type }}">
<div class="profile-field"><label for="name">Business name</label><input id="name" name="name" value="{{ old('name', $listing->name ?? '') }}" required maxlength="150"></div>
@if(!isset($listing))
<div class="profile-field"><label for="destination">Destination</label><select id="destination" name="destination_id" required><option value="">Choose a destination</option>
@foreach($destinations as $d)<option value="{{ $d->id }}" @selected((string)old('destination_id') === (string)$d->id)>{{ $d->name }}, {{ $d->province }}</option>@endforeach
</select></div>
@endif
<div class="profile-field"><label for="address">Address</label><input id="address" name="address" value="{{ old('address', $listing->address ?? '') }}" required maxlength="255"></div>
<div class="profile-field"><label for="description">Description</label><textarea id="description" name="description" rows="4" required maxlength="10000">{{ old('description', $listing->description ?? '') }}</textarea></div>
@if($type === 'hotel')
<div class="profile-row">
<div class="profile-field"><label for="check-in">Check-in time</label><input id="check-in" type="time" name="check_in_time" value="{{ old('check_in_time', isset($details->check_in_time) ? substr($details->check_in_time,0,5) : '') }}"></div>
<div class="profile-field"><label for="check-out">Check-out time</label><input id="check-out" type="time" name="check_out_time" value="{{ old('check_out_time', isset($details->check_out_time) ? substr($details->check_out_time,0,5) : '') }}"></div>
</div>
@elseif($type === 'restaurant')
<div class="profile-field"><label for="hours">Operating hours</label><input id="hours" name="operating_hours" maxlength="255" value="{{ old('operating_hours', $details->operating_hours ?? '') }}"></div>
<div class="profile-field"><label for="fee">Reservation fee (PHP)</label><input id="fee" name="reservation_fee" type="number" min="0" max="9999999999.99" step="0.01" value="{{ old('reservation_fee', $details->reservation_fee ?? 0) }}"></div>
@else
<div class="profile-field"><label for="fee">Entrance fee (PHP, optional)</label><input id="fee" name="entrance_fee" type="number" min="0" max="9999999999.99" step="0.01" value="{{ old('entrance_fee', $details->entrance_fee ?? '') }}"></div>
@endif
