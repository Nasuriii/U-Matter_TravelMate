@extends('travelmate.layout')
@section('title', 'Suggested for you')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><p class="eyebrow">Find your next destination</p><h1>Suggested for you</h1><p>Matches use words in your saved interests and destination categories or descriptions.</p><a class="chip" href="{{ route('profile.edit') }}">Update my interests →</a></header>
@if($preferences->isEmpty())<section class="planner-panel"><p>You have not selected any interests yet. These are active destinations you can explore.</p></section>@else<section class="planner-panel"><h2>Your saved interests</h2><div class="tm-interest-list">@foreach($preferences as $pref)<span class="chip">{{ $pref->name }}</span>@endforeach</div></section>@endif
<div class="dest-grid browse-grid">@forelse($suggestions as $place)<article class="card-wrap"><div class="card-body"><p class="dest-code">{{ $place->category_name }} · {{ $place->province }}</p><h2>{{ $place->name }}</h2><p>{{ $place->reason }}</p><a class="link-btn" href="{{ route('destinations.show',$place->slug) }}">Explore destination →</a></div></article>@empty<div class="browse-empty"><h2>No destinations available yet</h2><p>Suggestions appear when an admin activates a destination.</p></div>@endforelse</div>
</main>
@endsection
