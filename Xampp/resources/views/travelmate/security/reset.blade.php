@extends('travelmate.layout')
@section('title', 'Reset password')
@section('publicScreen', 'yes')
@section('content')
<main class="browse-shell tm-security">
<header class="browse-heading"><h1>Reset password</h1><a href="{{ route('security.forgot') }}">Request a new recovery link</a></header>@include('travelmate.errors')<section class="planner-panel"><form class="profile-form" method="POST" action="{{ route('security.reset') }}">@csrf<input type="hidden" name="token" value="{{ $token }}"><input type="hidden" name="email" value="{{ $email }}"><label>New password<input type="password" name="password" required minlength="12" maxlength="72" autocomplete="new-password"></label><label>Confirm new password<input type="password" name="password_confirmation" required minlength="12" maxlength="72" autocomplete="new-password"></label><p>Use a unique password with at least 12 characters (maximum 72 bytes).</p><button class="profile-save-btn">Reset password</button></form></section>
</main>
@endsection
