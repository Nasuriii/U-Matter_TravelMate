@extends('travelmate.layout')
@section('title', $destination->name)
@section('content')
<main class="browse-shell">
<header class="browse-heading">
<a class="back-link" href="{{ route('destinations.index') }}">← All destinations</a>
<p class="eyebrow" style="margin-top:24px">{{ $destination->category_name }} · {{ $destination->province }}</p>
<h1>{{ $destination->name }}</h1>
<p class="browse-prose">{{ $destination->description }}</p>
<div class="wishlist-actions">
@auth
@if($isSaved)
<span class="wishlist-saved">♥ Saved to your wishlist</span>
<a class="link-btn" href="{{ route('wishlist.index') }}">View wishlist →</a>
@else
<form method="POST" action="{{ route('wishlist.store', $destination->id) }}">
@csrf
<button class="chip wishlist-save" type="submit">♡ Save to wishlist</button>
</form>
@endif
@else
<a class="chip" href="{{ route('login') }}">Log in to save this destination</a>
@endauth
</div>
<p style="margin-top:20px"><a class="chip" href="{{ route('reviews.index', ['destination', $destination->slug]) }}">Read and write reviews →</a></p>
<div class="tm-interest-list"><a class="chip" href="{{ \App\Services\TravelMateDiscovery::map($destination) }}" target="_blank" rel="noopener noreferrer">{{ isset($destination->latitude,$destination->longitude)?'View location in Google Maps':'Search destination in Google Maps' }} ↗</a><a class="chip" href="{{ route('transport.index',['destination'=>$destination->id]) }}">Transportation to this destination →</a></div><p><a class="link-btn" href="{{ route('issues.create',['type'=>'destination','target'=>$destination->id]) }}">Report an issue →</a></p></header>
@include('travelmate.errors')
<nav class="browse-tabs" aria-label="Listing types">
<a class="chip {{ $type === '' ? 'active' : '' }}" href="{{ route('destinations.show', $destination->slug) }}" @if($type === '') aria-current="page" @endif>All ({{ $counts->sum() }})</a>
@foreach(['hotel' => 'Hotels', 'restaurant' => 'Restaurants', 'attraction' => 'Attractions'] as $key => $label)
<a class="chip {{ $type === $key ? 'active' : '' }}" href="{{ route('destinations.show', ['slug' => $destination->slug, 'type' => $key]) }}" @if($type === $key) aria-current="page" @endif>{{ $label }} ({{ $counts[$key] ?? 0 }})</a>
@endforeach
</nav>
<div class="dest-grid browse-grid">
@forelse($listings as $listing)
<article class="card-wrap">
<a class="dest-card" href="{{ route('listings.show', $listing->slug) }}"><div class="card-body">
<p class="dest-code">{{ ucfirst($listing->listing_type) }}</p>
<h2>{{ $listing->name }}</h2>
<p class="browse-description">{{ \Illuminate\Support\Str::limit($listing->description ?? '', 160) }}</p>
<div class="browse-card-footer"><span>View details →</span></div>
</div></a>
</article>
@empty
<div class="browse-empty"><h2>No listings here yet</h2><p>Try another listing type or explore a different destination.</p><a class="link-btn" href="{{ route('destinations.index') }}">All destinations →</a></div>
@endforelse
</div>
@include('travelmate.browse-pagination', ['paginator' => $listings])
@include('travelmate.content.gallery',['photoKind'=>'destination','photoTarget'=>$destination->id,'photoName'=>$destination->name])
</main>
@endsection
