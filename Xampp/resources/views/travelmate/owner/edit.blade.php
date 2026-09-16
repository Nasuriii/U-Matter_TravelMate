@extends('travelmate.layout')
@section('title', 'Manage listing')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('owner.index') }}">← My business</a><h1>{{ $listing->name }}</h1><p>{{ ucfirst($type) }} · {{ ucfirst($listing->status) }}</p>@if(in_array($type,['hotel','restaurant']))
<p style="margin-top:16px"><a class="chip" href="{{ route('owner.inventory',$listing->id) }}">Manage {{ $type === 'hotel' ? 'rooms' : 'seating times' }} →</a></p>
@endif
<p><a class="chip" href="{{ route('content.manage',['listing',$listing->id]) }}">Manage photos & details →</a></p></header>
@include('travelmate.errors')
<section class="planner-panel"><p class="management-note">Saving changes submits the listing for approval again. It stays hidden until approved.</p>
<form class="profile-form" method="POST" action="{{ route('owner.update',$listing->id) }}">@csrf @method('PATCH')
@include('travelmate.owner.fields')
<button class="profile-save-btn" type="submit">Save and submit for approval</button></form>
</section>
@if($listing->status !== 'inactive')
<section class="planner-panel"><h2>Take this listing offline</h2><p class="management-note">This hides it from public browsing and keeps its records.</p>
<form method="POST" action="{{ route('owner.deactivate',$listing->id) }}">@csrf<button class="wishlist-remove" type="submit">Deactivate listing</button></form>
</section>
@endif

</main>
@endsection
