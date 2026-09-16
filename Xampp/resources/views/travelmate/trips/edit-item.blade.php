@extends('travelmate.layout')
@section('title', 'Edit activity')
@section('content')
<main class="browse-shell">
<header class="browse-heading"><a class="back-link" href="{{ route('trips.show', $trip->id) }}">← {{ $trip->name }}</a><h1>Edit activity</h1></header>
@include('travelmate.errors')
<section class="planner-panel">
<form class="profile-form" method="POST" action="{{ route('trips.items.update', [$trip->id, $item->id]) }}">@csrf @method('PATCH')
@include('travelmate.trips.item-fields')
<button class="profile-save-btn" type="submit">Save activity</button></form>
</section>
</main>
@endsection
