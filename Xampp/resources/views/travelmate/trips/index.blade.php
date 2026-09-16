@extends('travelmate.layout')
@section('title', 'My trips')
@section('content')
<main class="browse-shell">
<header class="browse-heading"><p class="eyebrow">YOUR TRAVEL PLANS</p><h1>My trips</h1><p>A weekend away or a longer adventure—start planning here.</p></header>
@include('travelmate.errors')
<section class="planner-panel"><h2>Create a trip</h2>
<form class="profile-form" method="POST" action="{{ route('trips.store') }}">@csrf
@include('travelmate.trips.trip-fields')
<button class="profile-save-btn" type="submit">Create trip</button>
</form></section>
<div class="dest-grid browse-grid">
@forelse($trips as $trip)
<article class="card-wrap"><a class="dest-card" href="{{ route('trips.show', $trip->id) }}"><div class="card-body">
<p class="dest-code">{{ ucfirst($trip->status) }}</p><h2>{{ $trip->name }}</h2>
<p>{{ $trip->start_date ? $trip->start_date.' to '.$trip->end_date : 'Dates to be decided' }}</p>
@if($trip->budget !== null)<p>Budget: ₱{{ number_format((float)$trip->budget, 2) }}</p>@endif
<span class="browse-card-footer">Open itinerary →</span></div></a></article>
@empty
<div class="browse-empty"><h2>No trips yet</h2><p>Create your first trip using the form above.</p></div>
@endforelse
</div>
@include('travelmate.browse-pagination', ['paginator' => $trips])
</main>
@endsection
