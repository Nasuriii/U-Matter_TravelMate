@extends('travelmate.layout')
@section('title', 'Notifications')
@section('content')
<main class="browse-shell">
<header class="browse-heading"><h1>Notifications</h1><p>{{ $unread }} unread {{ $unread === 1 ? 'update' : 'updates' }}</p></header>
@include('travelmate.errors')
<section class="planner-panel">
@if($unread)
<form method="POST" action="{{ route('notifications.readAll') }}">@csrf<input type="hidden" name="up_to" value="{{ $upTo }}"><button class="chip" type="submit">Mark all as read</button></form>
@endif
@forelse($notifications as $notification)
<article class="notification-entry {{ $notification->read_at === null ? 'unread' : '' }}">
@if($notification->read_at === null)<span class="inbox-badge">Unread</span>@endif
<p>{{ $notification->message }}</p>
<time datetime="{{ \Carbon\CarbonImmutable::parse($notification->created_at,'UTC')->toIso8601String() }}">{{ \Carbon\CarbonImmutable::parse($notification->created_at,'UTC')->setTimezone('Asia/Manila')->format('M j, Y · g:i A') }}</time>
@if($notification->read_at === null)
<form method="POST" action="{{ route('notifications.read',$notification->id) }}">@csrf<button class="link-btn" type="submit">Mark as read</button></form>
@endif
</article>
@empty
<h2>Your inbox is clear</h2><p>Booking and listing updates will appear here.</p>
@endforelse
</section>
@include('travelmate.browse-pagination',['paginator'=>$notifications])
</main>
@endsection
