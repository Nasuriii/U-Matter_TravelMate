@extends('travelmate.layout')
@section('title', 'Change password')
@section('content')
<main class="browse-shell tm-security">
<header class="browse-heading"><a href="{{ route('profile.edit') }}">← My profile</a><h1>Change password</h1><p>Other sessions will need to sign in again.</p></header>@include('travelmate.errors')<section class="planner-panel"><form class="profile-form" method="POST" action="{{ route('security.change') }}">@csrf<label>Current password<input type="password" name="current_password" required autocomplete="current-password"></label><label>New password<input type="password" name="password" required minlength="12" maxlength="72" autocomplete="new-password"></label><label>Confirm new password<input type="password" name="password_confirmation" required minlength="12" maxlength="72" autocomplete="new-password"></label><p>Use a unique password with at least 12 characters (maximum 72 bytes).</p><button class="profile-save-btn">Change password</button></form></section>
</main>
@endsection
