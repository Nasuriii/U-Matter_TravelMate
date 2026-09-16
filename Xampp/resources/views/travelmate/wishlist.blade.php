@extends('travelmate.layout')
@section('title', 'My wishlist')
@section('content')
<main class="browse-shell">
<header class="browse-heading">
<p class="eyebrow">YOUR NEXT ADVENTURE</p>
<h1>My wishlist</h1>
<p>Keep the places you want to explore in one place.</p>
<div class="wishlist-actions"><a class="chip" href="{{ route('destinations.index') }}">Explore destinations →</a></div>
</header>
@include('travelmate.errors')
<div class="browse-results"><p>{{ $destinations->total() }} saved {{ $destinations->total() === 1 ? 'destination' : 'destinations' }}</p></div>
<div class="dest-grid browse-grid">
@forelse($destinations as $destination)
<article class="card-wrap wishlist-card">
<div class="card-body">
@if($destination->is_active)
<p class="dest-code">{{ $destination->province }}</p>
<h2><a href="{{ route('destinations.show', $destination->slug) }}">{{ $destination->name }}</a></h2>
<a class="link-btn" href="{{ route('destinations.show', $destination->slug) }}">Explore destination →</a>
@else
<h2>Destination unavailable</h2>
<p>This saved place is no longer available to browse.</p>
@endif
<form method="POST" action="{{ route('wishlist.destroy', $destination->id) }}">
@csrf
@method('DELETE')
<button class="wishlist-remove" type="submit" aria-label="Remove {{ $destination->is_active ? $destination->name : 'unavailable destination' }} from wishlist">Remove from wishlist</button>
</form>
</div>
</article>
@empty
<div class="browse-empty"><h2>Your wishlist is empty</h2><p>Open a destination and choose “Save to wishlist” to keep it here.</p><a class="link-btn" href="{{ route('destinations.index') }}">Find a destination →</a></div>
@endforelse
</div>
@include('travelmate.browse-pagination', ['paginator' => $destinations])
</main>
@endsection
