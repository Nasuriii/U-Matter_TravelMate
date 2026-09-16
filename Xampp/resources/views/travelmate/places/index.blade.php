@extends('travelmate.layout')
@section('title', 'Manage destinations')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('admin.index') }}">← Admin</a><h1>Manage destinations</h1>
<nav class="management-actions"><a class="cta-btn" href="{{ route('admin.places.create') }}">Add destination</a><a class="chip" href="{{ route('admin.categories') }}">Categories</a></nav></header>
<div class="dest-grid browse-grid">
@forelse($places as $place)
<article class="card-wrap"><div class="card-body"><p class="dest-code">{{ $place->is_active ? 'Active' : 'Inactive' }} · {{ $place->category_name }}</p><h2>{{ $place->name }}</h2><p>{{ $place->province }}</p><a class="link-btn" href="{{ route('admin.places.edit',$place->id) }}">Edit destination →</a></div></article>
@empty<div class="browse-empty"><p>No destinations yet.</p></div>@endforelse
</div>
@include('travelmate.browse-pagination',['paginator'=>$places])

</main>
@endsection
