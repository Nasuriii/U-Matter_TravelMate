@extends('travelmate.layout')
@section('title', 'Review transport service')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><a href="{{ route('transport.admin') }}">← Transport approvals</a><h1>{{ $service->service_name }}</h1><p>{{ $service->transport_type }} · {{ ucfirst($service->status) }}</p></header>@include('travelmate.errors')
<section class="planner-panel"><h2>{{ $provider->company_name }}</h2><p class="browse-prose">{{ $provider->description }}</p>@foreach($contacts as $contact)<p>{{ $contact->phone_number }}</p>@endforeach<p>Destination: {{ $destination->name }} · {{ $destination->is_active?'Active':'Inactive' }}</p>
<form method="POST" action="{{ route('transport.decide',$service->id) }}">@csrf<input type="hidden" name="fingerprint" value="{{ $fingerprint }}">@if($service->status==='pending')<button class="profile-save-btn" name="decision" value="approved">Approve</button> <button class="chip" name="decision" value="rejected">Reject</button>@endif @if($service->status!=='inactive')<button class="wishlist-remove" name="decision" value="inactive">Take offline</button>@endif</form></section>
</main>
@endsection
