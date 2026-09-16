@extends('travelmate.layout')
@section('title', 'Places to stay and visit')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><h1>Places to stay &amp; visit</h1><p>Find hotels, restaurants and attractions for your next trip.</p></header>
@include('travelmate.errors')
<form class="browse-filter" method="GET" action="{{ route('directory.index') }}" role="search">
<label>Business or location<input type="search" name="q" maxlength="150" value="{{ $filters['q'] ?? '' }}" placeholder="Name, destination or province"></label>
<label>Type<select name="type"><option value="">All types</option>
@foreach(['hotel'=>'Hotels','restaurant'=>'Restaurants','attraction'=>'Attractions'] as $key=>$label)<option value="{{ $key }}" @selected(($filters['type'] ?? '') === $key)>{{ $label }}</option>@endforeach
</select></label>
<label>Destination<select name="destination"><option value="">All destinations</option>
@foreach($destinations as $d)<option value="{{ $d->id }}" @selected((string)($filters['destination'] ?? '') === (string)$d->id)>{{ $d->name }}, {{ $d->province }}</option>@endforeach
</select></label>
<label>Sort by<select name="sort"><option value="name" @selected(($filters['sort'] ?? 'name') === 'name')>Name: A–Z</option><option value="rating" @selected(($filters['sort'] ?? '') === 'rating')>Highest rated</option></select></label>
<button class="cta-btn" type="submit">Search</button><a class="link-btn" href="{{ route('directory.index') }}">Reset</a>
</form>
<div class="browse-results"><p>{{ $listings->total() }} {{ $listings->total() === 1 ? 'listing' : 'listings' }} found</p></div>
@php($covers=\App\Services\TravelMatePresentation::covers('listing',$listings->pluck('id')->all()))
<div class="dest-grid browse-grid">
@forelse($listings as $listing)
<article class="card-wrap"><a class="dest-card" href="{{ route('listings.show',$listing->slug) }}">@include('travelmate.final.cover',['cover'=>$covers[$listing->id]??null,'coverLabel'=>ucfirst($listing->listing_type),'coverIcon'=>'places'])<div class="card-body">
<p class="dest-code">{{ ucfirst($listing->listing_type) }} · {{ $listing->destination_name }}, {{ $listing->province }}</p>
<h2>{{ $listing->name }}</h2>
<p class="rating-line">{{ $listing->average_rating === null ? 'No ratings yet' : number_format((float)$listing->average_rating,1).' / 5' }} <span class="rating-count">({{ $listing->review_count }} reviews)</span></p>
<p class="browse-description">{{ \Illuminate\Support\Str::limit($listing->description ?? '',160) }}</p>
<span class="browse-card-footer">View details →</span>
</div></a></article>
@empty<div class="browse-empty"><h2>No matching places</h2><p>Try another search or reset your filters.</p><a class="link-btn" href="{{ route('directory.index') }}">Reset filters →</a></div>@endforelse
</div>
@include('travelmate.browse-pagination',['paginator'=>$listings])

</main>
@endsection
