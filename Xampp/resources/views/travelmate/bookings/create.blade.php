@extends('travelmate.layout')
@section('title', 'Request a reservation')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('listings.show',$venue->slug) }}">← {{ $venue->name }}</a><h1>Request a reservation</h1><p>{{ $venue->name }}</p></header>
@include('travelmate.errors')
<section class="planner-panel">
@if($inventory->isEmpty())
<h2>No inventory available</h2><p>The business has not opened any rooms or future seating times for requests.</p>
@else
<form class="profile-form" method="POST" action="{{ route('bookings.store',$venue->id) }}">@csrf
<input type="hidden" name="request_key" value="{{ old('request_key',$requestKey) }}">
<input type="hidden" name="quote" value="{{ $quote }}">
<div class="profile-row">
<div class="profile-field"><label for="guest">Guest name</label><input id="guest" name="guest_name" required maxlength="150" autocomplete="name" value="{{ old('guest_name',auth()->user()->full_name) }}"></div>
<div class="profile-field"><label for="email">Guest email</label><input id="email" name="guest_email" type="email" required maxlength="254" autocomplete="email" value="{{ old('guest_email',auth()->user()->email) }}"></div>
</div>
<div class="profile-row">
<div class="profile-field"><label for="phone">Phone (optional)</label><input id="phone" name="guest_phone" maxlength="20" autocomplete="tel" value="{{ old('guest_phone') }}"></div>
<div class="profile-field"><label for="guests">Number of guests</label><input id="guests" name="guest_count" type="number" min="1" max="65535" required value="{{ old('guest_count',1) }}"></div>
</div>
@if($venue->listing_type === 'hotel')
<div class="profile-field"><label for="room">Room and nightly rate</label><select id="room" name="room_id" required><option value="">Choose a room</option>
@foreach($inventory as $entry)<option value="{{ $entry->id }}" @selected((string)old('room_id') === (string)$entry->id)>Room {{ $entry->room_number }} · {{ $entry->room_type }} · max {{ $entry->max_guests }} guests · ₱{{ number_format((float)$entry->base_nightly_rate,2) }}/night</option>@endforeach
</select></div>
<div class="profile-row">
<div class="profile-field"><label for="in">Check-in date</label><input id="in" name="check_in" type="date" min="{{ $tomorrow }}" required value="{{ old('check_in') }}"></div>
<div class="profile-field"><label for="out">Check-out date</label><input id="out" name="check_out" type="date" min="{{ $tomorrow }}" required value="{{ old('check_out') }}"></div>
</div>
<p class="planner-hint">Total = nightly rate × number of nights. Stays may be 1–30 nights, with arrival from tomorrow onward. Date availability is checked when you submit.</p>
@else
<div class="profile-field"><label for="slot">Seating time (Philippine time)</label><select id="slot" name="slot_id" required><option value="">Choose a time</option>
@foreach($inventory as $entry)<option value="{{ $entry->id }}" @selected((string)old('slot_id') === (string)$entry->id)>{{ \Carbon\CarbonImmutable::parse($entry->starts_at,'UTC')->setTimezone('Asia/Manila')->format('M j, Y · g:i A') }}</option>@endforeach
</select></div>
<p>Flat reservation fee: ₱{{ number_format((float)$fee,2) }}</p>
<p class="planner-hint">The fee is per reservation, not per guest. Seating capacity is checked when you submit. Meal charges are not included.</p>
@endif
<p class="reservation-notice">No payment is collected here. The business must confirm your request before it expires, within 24 hours or before the stay or seating time begins.</p>
<button class="profile-save-btn" type="submit">Submit reservation request</button>
</form>
@endif
</section>

</main>
@endsection
