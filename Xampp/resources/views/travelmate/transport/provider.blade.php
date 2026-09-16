@extends('travelmate.layout')
@section('title', 'Manage transport provider')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><a href="{{ route('transport.owner') }}">← My transport providers</a><h1>{{ $provider->company_name }}</h1></header>@include('travelmate.errors')
<section class="planner-panel"><h2>Provider profile</h2><p>Saving changes sends all services that are not inactive back for approval.</p><form class="profile-form" method="POST" action="{{ route('transport.owner.update',$provider->id) }}">@csrf @method('PATCH') @include('travelmate.transport.provider-fields')<button class="profile-save-btn">Save provider</button></form></section>
<section class="planner-panel"><h2>Add a service</h2><form class="profile-form" method="POST" action="{{ route('transport.services.store',$provider->id) }}">@csrf @include('travelmate.transport.service-fields',['service'=>null])<button class="profile-save-btn">Submit service</button></form></section>
<section class="planner-panel"><h2>Services</h2>@forelse($services as $s)<article class="tm-service-row"><h3>{{ $s->service_name }}</h3><p>{{ $s->transport_type }} · {{ $s->destination_name }} · {{ ucfirst($s->status) }}</p><a class="chip" href="{{ route('transport.services.edit',[$provider->id,$s->id]) }}">Edit service</a>@if($s->status!=='inactive')<form method="POST" action="{{ route('transport.services.deactivate',[$provider->id,$s->id]) }}">@csrf<button class="wishlist-remove">Take offline</button></form>@endif</article>@empty<p>No services added.</p>@endforelse</section>
</main>
@endsection
