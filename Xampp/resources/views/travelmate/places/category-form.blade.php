@extends('travelmate.layout')
@section('title', 'Edit category')
@section('content')
<main class="browse-shell">

<header class="browse-heading"><a class="back-link" href="{{ route('admin.categories') }}">← Categories</a><h1>Edit category</h1></header>
@include('travelmate.errors')
<section class="planner-panel"><form class="profile-form" method="POST" action="{{ route('admin.categories.update',$category->id) }}">@csrf @method('PATCH')
@include('travelmate.places.category-fields')
<button class="profile-save-btn" type="submit">Save category</button></form></section>

</main>
@endsection
