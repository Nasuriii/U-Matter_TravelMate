@extends('travelmate.layout')
@section('title', $listing->name)
@section('content')
<main class="browse-shell">
<header class="browse-heading">
<a class="back-link" href="{{ route('destinations.show', $listing->destination_slug) }}">← {{ $listing->destination_name }}</a>
<p class="eyebrow" style="margin-top:24px">{{ ucfirst($listing->listing_type) }} · {{ $listing->province }}</p>
<h1>{{ $listing->name }}</h1>
<p class="browse-prose">{{ $listing->description }}</p>
<p style="margin-top:20px"><a class="chip" href="{{ route('reviews.index', ['listing', $listing->slug]) }}">Read and write reviews →</a></p>
@if(in_array($listing->listing_type,['hotel','restaurant']))
<p style="margin-top:20px"><a class="cta-btn" href="{{ route('bookings.create',$listing->id) }}">Request a reservation →</a></p>
@endif
<p><a class="link-btn" href="{{ route('issues.create',['type'=>'listing','target'=>$listing->id]) }}">Report an issue →</a></p></header>
<div class="browse-detail">
<section class="browse-detail-panel">
<h2>At a glance</h2>
<dl class="browse-facts">
<div><dt>Destination</dt><dd>{{ $listing->destination_name }}, {{ $listing->province }}</dd></div>
<div><dt>Address</dt><dd>{{ $listing->address ?: 'Address not provided' }}</dd></div>
@if($details && $listing->listing_type === 'hotel')
<div><dt>Check-in time</dt><dd>{{ $details->check_in_time ? substr($details->check_in_time, 0, 5) : 'Not provided' }}</dd></div>
<div><dt>Check-out time</dt><dd>{{ $details->check_out_time ? substr($details->check_out_time, 0, 5) : 'Not provided' }}</dd></div>
@elseif($details && $listing->listing_type === 'restaurant')
<div><dt>Operating hours</dt><dd>{{ $details->operating_hours ?: 'Not provided' }}</dd></div>
<div><dt>Reservation fee</dt><dd>₱{{ number_format((float)$details->reservation_fee, 2) }}</dd></div>
@elseif($details && $listing->listing_type === 'attraction')
<div><dt>Entrance fee</dt><dd>{{ $details->entrance_fee === null ? 'Not provided' : '₱'.number_format((float)$details->entrance_fee, 2) }}</dd></div>
@endif
</dl>
</section>
</div>
@include('travelmate.content.gallery',['photoKind'=>'listing','photoTarget'=>$listing->id,'photoName'=>$listing->name])
@include('travelmate.content.details')
</main>
@endsection
