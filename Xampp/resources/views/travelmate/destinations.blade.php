@extends('travelmate.layout')
@section('title', 'Explore destinations')
@section('content')
<main class="browse-shell">
<header class="browse-heading">
<p class="eyebrow">THE PHILIPPINE FIELD GUIDE</p>
<h1>Where will you go next?</h1>
<p>Explore destinations across the Philippines.</p>
</header>
@include('travelmate.errors')
<form class="browse-filter" method="GET" action="{{ route('destinations.index') }}" role="search">
<label>Destination or province
<input name="q" value="{{ $filters['q'] ?? '' }}" maxlength="150" placeholder="Try San Juan or Benguet" type="search"></label>
<label>Category
<select name="category">
<option value="">All categories</option>
@foreach($categories as $category)
<option value="{{ $category->id }}" @selected((string)($filters['category'] ?? '') === (string)$category->id)>{{ $category->name }}</option>
@endforeach
</select></label>
<label>Sort by
<select name="sort">
<option value="name_asc" @selected(($filters['sort'] ?? 'name_asc') === 'name_asc')>Name: A–Z</option>
<option value="name_desc" @selected(($filters['sort'] ?? '') === 'name_desc')>Name: Z–A</option>
</select></label>
<button type="submit" class="cta-btn">Search</button>
<a class="link-btn" href="{{ route('destinations.index') }}">Reset</a>
</form>
<div class="browse-results"><p>{{ $destinations->total() }} {{ $destinations->total() === 1 ? 'destination' : 'destinations' }} found</p></div>
@php($covers=\App\Services\TravelMatePresentation::covers('destination',$destinations->pluck('id')->all()))
<div class="dest-grid browse-grid">
@forelse($destinations as $destination)
<article class="card-wrap">
<a class="dest-card" href="{{ route('destinations.show', $destination->slug) }}">
@include('travelmate.final.cover',['cover'=>$covers[$destination->id]??null,'coverLabel'=>$destination->category_name])<div class="card-body">
<p class="dest-code">{{ $destination->category_name }} · {{ $destination->province }}</p>
<h2>{{ $destination->name }}</h2>
<p class="browse-description">{{ \Illuminate\Support\Str::limit($destination->description ?? '', 170) }}</p>
<div class="browse-card-footer"><span>{{ $destination->listing_count }} {{ (int)$destination->listing_count === 1 ? 'listing' : 'listings' }}</span><span>Explore →</span></div>
</div>
</a>
</article>
@empty
<div class="browse-empty"><h2>No destinations found</h2><p>Try another name or province, or reset your filters.</p><a class="link-btn" href="{{ route('destinations.index') }}">See all destinations →</a></div>
@endforelse
</div>
@include('travelmate.browse-pagination', ['paginator' => $destinations])
</main>
@endsection
