@extends('travelmate.layout')
@section('title', 'Transportation')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><p class="eyebrow">Getting there</p><h1>Transportation</h1><p>Explore approved services and contact their providers for current arrangements.</p></header>
@include('travelmate.errors')
<form method="GET" action="{{ route('transport.index') }}" class="planner-panel profile-form"><div class="profile-row"><label>Search<input name="q" maxlength="150" value="{{ $filters['q']??'' }}" placeholder="Service, company or destination"></label><label>Destination<select name="destination"><option value="">All destinations</option>@foreach($destinations as $d)<option value="{{ $d->id }}" @selected((string)($filters['destination']??'')===(string)$d->id)>{{ $d->name }} · {{ $d->province }}</option>@endforeach</select></label><label>Transport type<select name="type"><option value="">All types</option>@foreach($types as $type)<option @selected(($filters['type']??'')===$type)>{{ $type }}</option>@endforeach</select></label></div><div><button class="profile-save-btn">Search services</button> <a href="{{ route('transport.index') }}">Clear filters</a></div></form>
<div class="dest-grid browse-grid">@forelse($services as $service)<article class="card-wrap"><div class="card-body"><p class="dest-code">{{ $service->transport_type }} · {{ $service->destination_name }}</p><h2>{{ $service->service_name }}</h2><p>{{ $service->company_name }}</p><a class="link-btn" href="{{ route('transport.show',$service->id) }}">Provider details →</a></div></article>@empty<div class="browse-empty"><h2>No matching services</h2><p>Try another filter or check back after providers have been approved.</p></div>@endforelse</div>
@include('travelmate.browse-pagination',['paginator'=>$services])
</main>
@endsection
