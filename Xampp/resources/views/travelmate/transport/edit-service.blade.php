@extends('travelmate.layout')
@section('title', 'Edit transport service')
@section('content')
<main class="browse-shell tm-discovery">
<header class="browse-heading"><a href="{{ route('transport.owner.edit',$provider->id) }}">← {{ $provider->company_name }}</a><h1>Edit service</h1></header>@include('travelmate.errors')
<section class="planner-panel"><p>Saving submits this service for approval again. If its destination was deactivated, select an active destination.</p><form class="profile-form" method="POST" action="{{ route('transport.services.update',[$provider->id,$service->id]) }}">@csrf @method('PATCH') @include('travelmate.transport.service-fields')<button class="profile-save-btn">Save and submit</button></form></section>
</main>
@endsection
