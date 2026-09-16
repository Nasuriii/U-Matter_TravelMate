@extends('travelmate.layout')
@section('title', 'My business')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><h1>My business</h1><p>Manage your listings and submit updates for approval.</p><p style="margin-top:16px"><a class="chip" href="{{ route('owner.bookings') }}">Manage reservations →</a></p>
<p><a class="chip" href="{{ route('transport.owner') }}">My transport providers →</a></p></header>
@include('travelmate.errors')
<section class="planner-panel"><h2>Add a listing</h2>
<nav class="browse-tabs">
@foreach(['hotel','restaurant','attraction'] as $t)<a class="chip {{ $type === $t ? 'active' : '' }}" href="{{ route('owner.index',['type'=>$t]) }}">{{ ucfirst($t) }}</a>@endforeach
</nav>
<form class="profile-form" method="POST" action="{{ route('owner.store') }}">@csrf
@include('travelmate.owner.fields')
<button class="profile-save-btn" type="submit">Submit for approval</button></form>
</section>
<div class="dest-grid browse-grid">
@forelse($listings as $listing)
<article class="card-wrap"><div class="card-body"><p class="dest-code">{{ ucfirst($listing->listing_type) }} · {{ ucfirst($listing->status) }}</p><h2>{{ $listing->name }}</h2><a class="link-btn" href="{{ route('owner.edit',$listing->id) }}">Manage listing →</a></div></article>
@empty<div class="browse-empty"><h2>No listings yet</h2><p>Submit your first listing above.</p></div>@endforelse
</div>
@include('travelmate.browse-pagination',['paginator'=>$listings])

</main>
@endsection
