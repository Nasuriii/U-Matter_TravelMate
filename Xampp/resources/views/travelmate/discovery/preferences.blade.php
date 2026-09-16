@extends('travelmate.layout')
@section('title', 'Preference options')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><a href="{{ route('admin.index') }}">← Admin dashboard</a><h1>Preference options</h1><p>Add interests travelers can select in their profiles.</p></header>@include('travelmate.errors')
<section class="planner-panel"><form class="profile-form" method="POST" action="{{ route('discovery.preferences.store') }}">@csrf<label>Group<input name="category" required maxlength="100" placeholder="Travel Style"></label><label>Interest<input name="name" required maxlength="100" placeholder="Beach trips"></label><button class="profile-save-btn">Add option</button></form><p>Use clear interest words that also appear in relevant destination categories or descriptions.</p></section>
<section class="planner-panel">@forelse($preferences as $preference)<p>{{ $preference->category }} — {{ $preference->name }}</p>@empty<p>No options yet.</p>@endforelse</section>@include('travelmate.browse-pagination',['paginator'=>$preferences])
</main>
@endsection
