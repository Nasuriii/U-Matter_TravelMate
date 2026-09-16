@extends('travelmate.layout')
@section('title', 'Listing approvals')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><h1>Listing approvals</h1><p><a class="link-btn" href="{{ route('admin.reviews') }}">Moderate reviews →</a></p><nav class="management-actions" aria-label="Admin sections">
<a class="chip" href="{{ route('admin.places') }}">Manage destinations</a>
<a class="chip" href="{{ route('admin.categories') }}">Manage categories</a>
</nav>
<p><a class="chip" href="{{ route('content.queue') }}">Photo approvals →</a></p><p><a class="chip" href="{{ route('transport.admin') }}">Transport approvals →</a> <a class="chip" href="{{ route('discovery.preferences') }}">Preference options →</a></p><nav class="tm-action-row"><a class="chip" href="{{ route('operations.accounts') }}">Account access →</a><a class="chip" href="{{ route('operations.issues') }}">Reported issues →</a><a class="chip" href="{{ route('operations.analytics') }}">Activity dashboard →</a></nav>@if(\App\Services\TravelMateDemoPayments::enabled())<p><a class="chip" href="{{ route('demo.admin') }}">Demo refund requests →</a></p>@endif</header>
<nav class="browse-tabs">
@foreach(['pending','approved','rejected','inactive','all'] as $s)<a class="chip {{ $status === $s ? 'active' : '' }}" href="{{ route('admin.index',['status'=>$s]) }}">{{ ucfirst($s) }}</a>@endforeach
</nav>
<div class="dest-grid browse-grid">
@forelse($listings as $listing)<article class="card-wrap"><div class="card-body"><p class="dest-code">{{ ucfirst($listing->status) }} · {{ ucfirst($listing->listing_type) }}</p><h2>{{ $listing->name }}</h2><a class="link-btn" href="{{ route('admin.show',$listing->id) }}">Review submission →</a></div></article>
@empty<div class="browse-empty"><p>No listings in this status.</p></div>@endforelse
</div>
@include('travelmate.browse-pagination',['paginator'=>$listings])

</main>
@endsection
