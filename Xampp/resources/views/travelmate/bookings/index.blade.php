@extends('travelmate.layout')
@section('title', 'Reservations')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><h1>{{ $ownerView ? 'Guest reservations' : 'My bookings' }}</h1>
<p>{{ $ownerView ? 'Review requests for your businesses.' : 'Track your reservation requests and confirmed bookings.' }}</p></header>
<div class="dest-grid browse-grid">
@forelse($bookings as $booking)
<article class="card-wrap"><div class="card-body">
<p class="dest-code">{{ ucfirst($booking->booking_type) }} · {{ ucfirst(\App\Services\TravelMateReservations::effectiveStatus($booking)) }}</p>
<h2>Booking #{{ $booking->id }}</h2><p>{{ $booking->guest_name }} · {{ $booking->guest_count }} guests</p>
<p>₱{{ number_format((float)$booking->total_amount,2) }}</p>
<a class="link-btn" href="{{ route($ownerView ? 'owner.bookings.show' : 'bookings.show',$booking->id) }}">View booking →</a>
</div></article>
@empty<div class="browse-empty"><h2>No bookings yet</h2><p>{{ $ownerView ? 'New requests will appear here.' : 'Open a hotel or restaurant listing to request a reservation.' }}</p></div>@endforelse
</div>
@include('travelmate.browse-pagination',['paginator'=>$bookings])

</main>
@endsection
