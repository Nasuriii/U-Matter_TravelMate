@extends('travelmate.layout')
@section('title', 'Transport approvals')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><a href="{{ route('admin.index') }}">← Admin dashboard</a><h1>Transport approvals</h1></header>@include('travelmate.errors')
<nav class="browse-tabs">@foreach(['pending','approved','rejected','inactive','all'] as $s)<a class="chip {{ $status===$s?'active':'' }}" href="{{ route('transport.admin',['status'=>$s]) }}">{{ ucfirst($s) }}</a>@endforeach</nav>
<section class="planner-panel">@forelse($services as $service)<article class="tm-service-row"><h2>{{ $service->service_name }}</h2><p>{{ $service->company_name }} · {{ ucfirst($service->status) }}</p><a class="chip" href="{{ route('transport.review',$service->id) }}">Review service →</a></article>@empty<p>No services in this group.</p>@endforelse</section>@include('travelmate.browse-pagination',['paginator'=>$services])
</main>
@endsection
