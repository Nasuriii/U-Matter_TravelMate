@extends('travelmate.layout')
@section('title', 'Review submission')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('admin.index') }}">← Listing approvals</a><h1>{{ $listing->name }}</h1><p>{{ ucfirst($listing->listing_type) }} · {{ ucfirst($listing->status) }}</p><p><a class="chip" href="{{ route('content.manage',['listing',$listing->id]) }}">Manage photos & details →</a></p></header>
@include('travelmate.errors')
<section class="planner-panel"><h2>Submission details</h2>
<p class="browse-prose">{{ $listing->description }}</p>
<p class="management-note"><strong>Address:</strong> {{ $listing->address }}</p>
@if($details)
@if($listing->listing_type === 'hotel')<p>Check-in: {{ $details->check_in_time ?? 'Not provided' }} · Check-out: {{ $details->check_out_time ?? 'Not provided' }}</p>
@elseif($listing->listing_type === 'restaurant')<p>Hours: {{ $details->operating_hours ?? 'Not provided' }}</p><p>Reservation fee: ₱{{ number_format((float)$details->reservation_fee,2) }}</p>
@else<p>Entrance fee: {{ $details->entrance_fee === null ? 'Not provided' : '₱'.number_format((float)$details->entrance_fee,2) }}</p>@endif
@else<p>Required subtype details are missing.</p>@endif
<form class="management-actions" method="POST" action="{{ route('admin.decide',$listing->id) }}">@csrf
<input type="hidden" name="fingerprint" value="{{ $fingerprint }}">
@if($listing->status === 'pending')
<button class="profile-save-btn" name="decision" value="approved">Approve</button>
<button class="wishlist-remove" name="decision" value="rejected">Reject</button>
@endif
@if($listing->status !== 'inactive')<button class="chip" name="decision" value="inactive">Take offline</button>@endif
</form>
</section>

@include('travelmate.content.details')
</main>
@endsection
