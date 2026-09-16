@extends('travelmate.layout')
@section('title', 'Booking details')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route($ownerView ? 'owner.bookings' : 'bookings.index') }}">← Reservations</a><h1>Booking #{{ $booking->id }}</h1><p>{{ $venue->name }} · {{ ucfirst($effectiveStatus) }}</p>@if(!$ownerView && \App\Services\TravelMateDemoPayments::enabled())<p><a class="chip" href="{{ route('demo.show',$booking->id) }}">Demo payment practice →</a></p>@endif</header>
@include('travelmate.errors')
<section class="planner-panel">
<h2>Reservation details</h2>
<dl class="browse-facts">
<div><dt>Guest</dt><dd>{{ $booking->guest_name }}</dd></div>
<div><dt>Party size</dt><dd>{{ $booking->guest_count }}</dd></div>
<div><dt>Email</dt><dd>{{ $booking->guest_email }}</dd></div>
<div><dt>Phone</dt><dd>{{ $booking->guest_phone ?: 'Not provided' }}</dd></div>
<div><dt>Booking total</dt><dd>₱{{ number_format((float)$booking->total_amount,2) }}</dd></div>
@if($stay)
<div><dt>Stay</dt><dd>{{ $stay->check_in }} to {{ $stay->check_out }}</dd></div>
@foreach($rooms as $room)<div><dt>Room {{ $room->room_number }}</dt><dd>{{ $room->room_type }} · ₱{{ number_format((float)$room->nightly_rate,2) }}/night</dd></div>@endforeach
@elseif($slot)
<div><dt>Seating time (Philippine time)</dt><dd>{{ \Carbon\CarbonImmutable::parse($slot->starts_at,'UTC')->setTimezone('Asia/Manila')->format('M j, Y · g:i A') }}</dd></div>
@endif
@if($effectiveStatus === 'pending')
<div><dt>Confirmation deadline (Philippine time)</dt><dd>{{ \Carbon\CarbonImmutable::parse($booking->hold_expires_at,'UTC')->setTimezone('Asia/Manila')->format('M j, Y · g:i A') }}</dd></div>
@endif
</dl>
<p class="reservation-notice">Booking status does not indicate payment. This reservation feature does not collect money.</p>
@if($ownerView)
<form class="management-actions" method="POST" action="{{ route('owner.bookings.decide',$booking->id) }}">@csrf
@if($effectiveStatus === 'pending')<button class="profile-save-btn" name="action" value="confirmed">Confirm request</button>@endif
@if($effectiveStatus === 'confirmed')<button class="chip" name="action" value="completed">Mark completed</button>@endif
@if(in_array($effectiveStatus,['pending','confirmed']))<button class="wishlist-remove" name="action" value="cancelled">Cancel booking</button>@endif
</form>
@elseif(in_array($effectiveStatus,['pending','confirmed']))
<form class="management-actions" method="POST" action="{{ route('bookings.cancel',$booking->id) }}">@csrf<button class="wishlist-remove" type="submit">Cancel booking</button></form>
@endif
@if($effectiveStatus === 'expired')<p>The confirmation deadline passed. The inventory hold has been released.</p>@endif
</section>
</main>
@endsection
