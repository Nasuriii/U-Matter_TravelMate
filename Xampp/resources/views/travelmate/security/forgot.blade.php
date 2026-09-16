@extends('travelmate.layout')
@section('title', 'Recover your account')
@section('publicScreen', 'yes')
@section('content')
<main class="browse-shell tm-security">
<header class="browse-heading"><a href="{{ route('login') }}">← Sign in</a><h1>Recover your account</h1><p>Enter your registered email to request a recovery link.</p></header>@include('travelmate.errors')<section class="planner-panel"><form class="profile-form" method="POST" action="{{ route('security.send') }}">@csrf<label>Email<input type="email" name="email" required maxlength="254" autocomplete="email"></label><button class="profile-save-btn">Request recovery link</button></form></section>
</main>
@endsection
