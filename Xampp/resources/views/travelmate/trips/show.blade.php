@extends('travelmate.layout')
@section('title', $trip->name)
@section('content')
<main class="browse-shell">
<header class="browse-heading"><a class="back-link" href="{{ route('trips.index') }}">← My trips</a><h1>{{ $trip->name }}</h1>
<p>{{ ucfirst($trip->status) }} · {{ $trip->start_date ? $trip->start_date.' to '.$trip->end_date : 'Dates to be decided' }}</p></header>
@include('travelmate.errors')
<details class="planner-panel" @if(old('_form') === 'trip') open @endif><summary>Edit trip details</summary>
<form class="profile-form" method="POST" action="{{ route('trips.update', $trip->id) }}">@csrf @method('PATCH')
@include('travelmate.trips.trip-fields')
<button class="profile-save-btn" type="submit">Save trip details</button></form>
</details>
<section class="planner-panel"><h2>Itinerary</h2>
@if($items->isEmpty())<p>No activities yet. Add your first stop below.</p>@endif
@foreach($items as $entry)
<article class="planner-entry">
<div class="planner-entry-head"><span class="tm-role">{{ ucfirst($entry->status) }}</span><span>{{ $entry->planned_date ?? 'Unscheduled' }}{{ $entry->planned_time ? ' · '.substr($entry->planned_time, 0, 5) : '' }}</span></div>
<h3>{{ $loop->iteration }}. {{ $entry->activity }}</h3>
@if($entry->destination_id)
@if($entry->destination_active)<a class="link-btn" href="{{ route('destinations.show', $entry->destination_slug) }}">{{ $entry->destination_name }}</a>@else<p>Destination unavailable</p>@endif
@elseif($entry->listing_id)
@if($entry->listing_status === 'approved' && $entry->listing_destination_active)<a class="link-btn" href="{{ route('listings.show', $entry->listing_slug) }}">{{ $entry->listing_name }}</a>@else<p>Listing unavailable</p>@endif
@endif
@if($entry->notes)<p class="browse-prose">{{ $entry->notes }}</p>@endif
<div class="planner-entry-actions">
<a class="chip" href="{{ route('trips.items.edit', [$trip->id, $entry->id]) }}">Edit activity</a>
<form method="POST" action="{{ route('trips.items.destroy', [$trip->id, $entry->id]) }}">@csrf @method('DELETE')
<button class="wishlist-remove" type="submit" aria-label="Remove {{ $entry->activity }}">Remove activity</button></form>
</div>
</article>
@endforeach
</section>
<section class="planner-panel"><h2>Add an activity</h2>
<form class="profile-form" method="POST" action="{{ route('trips.items.store', $trip->id) }}">@csrf
@include('travelmate.trips.item-fields')
<button class="profile-save-btn" type="submit">Add to itinerary</button></form>
</section>
</main>
@endsection
