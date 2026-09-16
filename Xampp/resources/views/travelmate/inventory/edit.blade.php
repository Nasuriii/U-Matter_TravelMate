@extends('travelmate.layout')
@section('title', 'Edit inventory')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('owner.inventory',$venue->id) }}">← {{ $venue->name }}</a><h1>Edit inventory</h1></header>
@include('travelmate.errors')
<section class="planner-panel"><form class="profile-form" method="POST" action="{{ route('owner.inventory.update',[$venue->id,$item->id]) }}">@csrf @method('PATCH')
@if($venue->listing_type === 'hotel')@include('travelmate.inventory.room-fields')
@else
<p>Seating time: {{ \Carbon\CarbonImmutable::parse($item->starts_at,'UTC')->setTimezone('Asia/Manila')->format('M j, Y · g:i A') }}</p>
<div class="profile-field"><label for="capacity">Guest capacity</label><input id="capacity" name="capacity" type="number" required min="1" max="65535" value="{{ old('capacity',$item->capacity) }}"></div>
<div class="profile-field"><label for="open">Accept new requests</label><select id="open" name="is_open">
<option value="1" @selected((string)old('is_open',$item->is_open) === '1')>Open</option>
<option value="0" @selected((string)old('is_open',$item->is_open) === '0')>Closed</option>
</select></div>
@endif
<p class="planner-hint">Taking inventory offline stops new requests. Existing holds and confirmed bookings remain. Manage those separately under reservations.</p>
<button class="profile-save-btn" type="submit">Save inventory</button>
</form></section>

</main>
@endsection
