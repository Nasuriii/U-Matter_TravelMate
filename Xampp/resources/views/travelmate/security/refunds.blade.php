@extends('travelmate.layout')
@section('title', 'Demo refund requests')
@section('content')
<main class="browse-shell tm-security">
<header class="browse-heading"><a href="{{ route('admin.index') }}">← Admin dashboard</a><h1>Demo refund requests</h1><p>Classroom simulation only. Approving cancels the booking and records a simulated full refund.</p></header>@include('travelmate.errors')<section class="planner-panel">@forelse($refunds as $refund)<article class="tm-operation-row"><h2>Refund #{{ $refund->id }} · Booking #{{ $refund->booking_id }}</h2><p>{{ $refund->reason }}</p><p>₱{{ number_format((float)$refund->amount,2) }} · {{ ucfirst($refund->status) }}</p>@if($refund->status==='pending')<form class="tm-action-row" method="POST" action="{{ route('demo.decide',$refund->id) }}">@csrf<button class="profile-save-btn" name="decision" value="succeeded">Approve demo refund and cancel booking</button><button class="chip" name="decision" value="failed">Reject demo refund</button></form>@endif</article>@empty<p>No demo refund requests.</p>@endforelse</section>@include('travelmate.browse-pagination',['paginator'=>$refunds])
</main>
@endsection
