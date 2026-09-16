@extends('travelmate.layout')
@section('title', 'Destination details')
@section('content')
<main class="browse-shell">

@php
$value=function($key,$fallback='') { $v=old($key,$fallback); return is_scalar($v)?(string)$v:''; };
@endphp
<header class="browse-heading"><a class="back-link" href="{{ route('admin.places') }}">← Manage destinations</a><h1>{{ $place ? 'Edit destination' : 'Add destination' }}</h1>@if($place)<p><a class="chip" href="{{ route('content.manage',['destination',$place->id]) }}">Manage destination photos →</a></p>@endif</header>
@include('travelmate.errors')
<section class="planner-panel">
@if($categories->isEmpty())<p><a class="link-btn" href="{{ route('admin.categories') }}">Create a category first →</a></p>@else
<form class="profile-form" method="POST" action="{{ $place ? route('admin.places.update',$place->id) : route('admin.places.store') }}">@csrf
@if($place)@method('PATCH')@endif
<div class="profile-row">
<div class="profile-field"><label for="name">Destination name</label><input id="name" name="name" required maxlength="150" value="{{ $value('name',$place->name ?? '') }}"></div>
<div class="profile-field"><label for="province">Province / area</label><input id="province" name="province" required maxlength="100" value="{{ $value('province',$place->province ?? '') }}"></div>
</div>
<div class="profile-field"><label for="category">Category</label><select id="category" name="category_id" required><option value="">Choose a category</option>
@foreach($categories as $c)<option value="{{ $c->id }}" @selected($value('category_id',$place->category_id ?? '') === (string)$c->id)>{{ $c->name }}</option>@endforeach
</select></div>
<div class="profile-field"><label for="description">Description (optional)</label><textarea id="description" name="description" rows="4" maxlength="10000">{{ $value('description',$place->description ?? '') }}</textarea></div>
<div class="profile-row">
<div class="profile-field"><label for="latitude">Latitude (optional)</label><input id="latitude" name="latitude" type="number" min="-90" max="90" step="0.0000001" value="{{ $value('latitude',$place->latitude ?? '') }}"></div>
<div class="profile-field"><label for="longitude">Longitude (optional)</label><input id="longitude" name="longitude" type="number" min="-180" max="180" step="0.0000001" value="{{ $value('longitude',$place->longitude ?? '') }}"></div>
</div>
<p class="planner-hint">Provide both coordinates or leave both blank.</p>
<div class="profile-field"><label for="active">Visibility</label><select id="active" name="is_active"><option value="1" @selected($value('is_active',$place->is_active ?? 1) === '1')>Active — visible to travelers</option><option value="0" @selected($value('is_active',$place->is_active ?? 1) === '0')>Inactive — hidden from public browsing</option></select></div>
<p class="planner-hint">Making a destination inactive also hides its businesses from public browsing. Existing bookings and trip records remain.</p>
<button class="profile-save-btn" type="submit">Save destination</button>
</form>
@endif
</section>

</main>
@endsection
