@extends('travelmate.layout')
@section('title', 'Reviews')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route($kind === 'destination' ? 'destinations.show' : 'listings.show',$target->slug) }}">← {{ $target->name }}</a><h1>Reviews for {{ $target->name }}</h1>
<p>{{ $average === null ? 'No ratings yet' : number_format((float)$average,1).' / 5' }} · {{ $reviews->total() }} published reviews</p></header>
@include('travelmate.errors')
<section class="planner-panel">
@auth
@if($isOwner)<p>You manage this business. Reviews are for other travelers.</p>
@else
<h2>{{ $own ? 'Edit your review' : 'Write a review' }}</h2>
@if($own && $own->status !== 'published')<p class="management-note">Your review is {{ $own->status }}. Editing it does not change its visibility.</p>@endif
<form class="profile-form" method="POST" action="{{ route('reviews.store',[$kind,$target->slug]) }}">@csrf
<div class="profile-field"><label for="rating">Your rating</label><select id="rating" name="rating" required><option value="">Select a rating</option>
@foreach([5,4,3,2,1] as $rating)<option value="{{ $rating }}" @selected((string)old('rating',$own->rating ?? '') === (string)$rating)>{{ $rating }} / 5</option>@endforeach
</select></div>
<div class="profile-field"><label for="review">Your experience (optional)</label><textarea id="review" name="review_text" rows="4" maxlength="5000">{{ old('review_text',$own->review_text ?? '') }}</textarea></div>
<button class="profile-save-btn" type="submit">Save review</button></form>
@endif
@else<p><a class="link-btn" href="{{ route('login') }}">Log in to write a review →</a></p>@endauth
</section>
<section class="planner-panel"><h2>Traveler reviews</h2>
@forelse($reviews as $review)<article class="planner-entry"><h3>{{ $review->full_name }}</h3><p>{{ $review->rating }} / 5 · {{ substr($review->created_at,0,10) }}</p><p class="browse-prose">{{ $review->review_text }}</p><a class="link-btn" href="{{ route('issues.create',['type'=>'review','target'=>$review->id]) }}">Report review</a></article>
@empty<p>No published reviews yet.</p>@endforelse
</section>
@include('travelmate.browse-pagination',['paginator'=>$reviews])

</main>
@endsection
