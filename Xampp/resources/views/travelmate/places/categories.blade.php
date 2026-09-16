@extends('travelmate.layout')
@section('title', 'Manage categories')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('admin.places') }}">← Manage destinations</a><h1>Categories</h1></header>
@include('travelmate.errors')
<section class="planner-panel"><h2>Add a category</h2><form class="profile-form" method="POST" action="{{ route('admin.categories.store') }}">@csrf
@include('travelmate.places.category-fields')
<button class="profile-save-btn" type="submit">Create category</button></form></section>
<div class="dest-grid browse-grid">
@forelse($categories as $category)<article class="card-wrap"><div class="card-body"><h2>{{ $category->name }}</h2><p>{{ $category->description }}</p><a class="link-btn" href="{{ route('admin.categories.edit',$category->id) }}">Edit category →</a></div></article>
@empty<div class="browse-empty"><p>No categories yet.</p></div>@endforelse
</div>
@include('travelmate.browse-pagination',['paginator'=>$categories])

</main>
@endsection
