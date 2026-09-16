@extends('travelmate.layout')
@section('title', 'Manage inventory')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('owner.edit',$venue->id) }}">← {{ $venue->name }}</a><h1>{{ $venue->listing_type === 'hotel' ? 'Hotel rooms' : 'Restaurant seating times' }}</h1></header>
@include('travelmate.errors')
<section class="planner-panel"><h2>{{ $venue->listing_type === 'hotel' ? 'Add a room' : 'Add a seating time' }}</h2>
<form class="profile-form" method="POST" action="{{ route('owner.inventory.store',$venue->id) }}">@csrf
@if($venue->listing_type === 'hotel')
@include('travelmate.inventory.room-fields')
@else
<div class="profile-row">
<div class="profile-field"><label for="start">Starts (Philippine time)</label><input id="start" name="starts_at" type="datetime-local" required value="{{ old('starts_at') }}"></div>
<div class="profile-field"><label for="end">Ends (Philippine time)</label><input id="end" name="ends_at" type="datetime-local" required value="{{ old('ends_at') }}"></div>
</div>
<div class="profile-field"><label for="capacity">Guest capacity</label><input id="capacity" name="capacity" type="number" min="1" max="65535" required value="{{ old('capacity',10) }}"></div>
<p class="planner-hint">Choose a future time range that does not overlap another seating time.</p>
@endif
<button class="profile-save-btn" type="submit">Add inventory</button></form>
</section>
<div class="dest-grid browse-grid">
@forelse($inventory as $entry)
<article class="card-wrap"><div class="card-body">
@if($venue->listing_type === 'hotel')
<p class="dest-code">{{ ucfirst($entry->operational_status) }}</p><h2>Room {{ $entry->room_number }}</h2><p>{{ $entry->room_type }} · Up to {{ $entry->max_guests }} guests</p>
<p>{{ $entry->base_nightly_rate === null ? 'Rate not set' : '₱'.number_format((float)$entry->base_nightly_rate,2).' / night' }}</p>
@else
<p class="dest-code">{{ $entry->is_open ? 'Open' : 'Closed' }}</p>
<h2>{{ \Carbon\CarbonImmutable::parse($entry->starts_at,'UTC')->setTimezone('Asia/Manila')->format('M j, Y · g:i A') }}</h2>
<p>Ends {{ \Carbon\CarbonImmutable::parse($entry->ends_at,'UTC')->setTimezone('Asia/Manila')->format('M j · g:i A') }} · {{ $entry->capacity }} guests maximum</p>
@endif
<a class="link-btn" href="{{ route('owner.inventory.edit',[$venue->id,$entry->id]) }}">Edit inventory →</a>
</div></article>
@empty<div class="browse-empty"><p>No inventory yet. Add your first entry above.</p></div>@endforelse
</div>
@include('travelmate.browse-pagination',['paginator'=>$inventory])

</main>
@endsection
