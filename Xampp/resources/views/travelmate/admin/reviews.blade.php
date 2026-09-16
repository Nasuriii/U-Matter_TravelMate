@extends('travelmate.layout')
@section('title', 'Review moderation')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('admin.index') }}">← Listing approvals</a><h1>Review moderation</h1></header>
@include('travelmate.errors')
<section class="planner-panel">
@forelse($reviews as $review)<article class="planner-entry"><p>{{ $review->rating }} / 5 · {{ ucfirst($review->status) }}</p><p class="browse-prose">{{ $review->review_text ?: 'Rating-only review' }}</p>
<form class="management-actions" method="POST" action="{{ route('admin.reviews.update',$review->id) }}">@csrf @method('PATCH')
@if($review->status !== 'hidden')<button class="wishlist-remove" name="status" value="hidden">Hide review</button>@endif
@if($review->status !== 'published')<button class="chip" name="status" value="published">Publish review</button>@endif
</form></article>@empty<p>No reviews yet.</p>@endforelse
</section>
@include('travelmate.browse-pagination',['paginator'=>$reviews])

</main>
@endsection
