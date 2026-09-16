@extends('travelmate.layout')
@section('title', 'My transport providers')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><a href="{{ route('owner.index') }}">← My business</a><h1>My transport providers</h1><p>Manage provider contacts and submit services for approval.</p></header>@include('travelmate.errors')
<section class="planner-panel"><h2>Add a provider</h2><form class="profile-form" method="POST" action="{{ route('transport.owner.store') }}">@csrf @include('travelmate.transport.provider-fields',['provider'=>null,'phones'=>[]])<button class="profile-save-btn">Create provider</button></form></section>
<div class="dest-grid browse-grid">@forelse($providers as $provider)<article class="card-wrap"><div class="card-body"><h2>{{ $provider->company_name }}</h2><a class="chip" href="{{ route('transport.owner.edit',$provider->id) }}">Manage provider →</a></div></article>@empty<p>No providers yet.</p>@endforelse</div>@include('travelmate.browse-pagination',['paginator'=>$providers])
</main>
@endsection
