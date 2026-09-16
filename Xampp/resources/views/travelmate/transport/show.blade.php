@extends('travelmate.layout')
@section('title', 'Transport service')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><a class="back-link" href="{{ route('transport.index') }}">← Transportation</a><p class="eyebrow">{{ $service->transport_type }}</p><h1>{{ $service->service_name }}</h1><p>{{ $service->company_name }}</p><p><a class="link-btn" href="{{ route('issues.create',['type'=>'transport','target'=>$service->id]) }}">Report an issue →</a></p></header>
<section class="planner-panel"><h2>Provider details</h2><p class="browse-prose">{{ $service->description ?: 'No provider description supplied.' }}</p><h3>Contact numbers</h3>@forelse($contacts as $contact)<p>{{ $contact->phone_number }}</p>@empty<p>No contact number available.</p>@endforelse<p>Contact the provider to confirm departure points, schedules, fares and availability. TravelMate does not issue transport tickets.</p></section>
<section class="planner-panel"><h2>Destination served</h2><p>{{ $service->destination_name }}, {{ $service->province }}</p><a class="chip" href="{{ route('destinations.show',$service->destination_slug) }}">Explore destination →</a></section>
</main>
@endsection
