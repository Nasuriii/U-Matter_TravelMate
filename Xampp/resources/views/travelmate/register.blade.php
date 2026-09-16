@extends('travelmate.layout')
@section('title', 'Sign Up')
@section('publicScreen', 'yes')
@section('content')
<main class="auth-wrap">
<a class="back-link auth-back" href="{{ route('home') }}">← Back to TravelMate</a>
<div class="auth-card">
<nav class="auth-tabs" aria-label="Account access">
<a class="auth-tab " href="{{ route('login') }}">Log In</a>
<a class="auth-tab active" href="{{ route('register') }}">Sign Up</a>
</nav>
<h1>Start your next adventure.</h1>
@include('travelmate.errors')

<form method="POST" action="{{ route('register.store') }}" class="profile-form">
@csrf
<fieldset style="border:0">
<legend class="auth-intro">Choose your account type</legend>
<div class="signup-role-toggle">
<label class="chip"><input type="radio" name="account_type" value="traveler" @checked(old('account_type', request('type')) !== 'business_owner')>I'm a Traveler</label>
<label class="chip"><input type="radio" name="account_type" value="business_owner" @checked(old('account_type', request('type')) === 'business_owner')>I'm a Business Owner</label>
</div>
</fieldset>
<div class="profile-row">
<div class="profile-field"><label for="full_name">Full Name</label>
<input id="full_name" name="full_name" value="{{ old('full_name') }}" required maxlength="150" autocomplete="name" placeholder="Juan Dela Cruz"></div>
<div class="profile-field"><label for="email">Email</label>
<input id="email" name="email" type="email" value="{{ old('email') }}" required maxlength="254" autocomplete="username" placeholder="juan@email.com"></div>
</div>
<div class="profile-row">
<div class="profile-field"><label for="password">Password</label>
<input id="password" name="password" type="password" required minlength="12" maxlength="72" autocomplete="new-password" aria-describedby="password-help"></div>
<div class="profile-field"><label for="password_confirmation">Confirm Password</label>
<input id="password_confirmation" name="password_confirmation" type="password" required minlength="12" maxlength="72" autocomplete="new-password"></div>
</div>
<p id="password-help" class="review-form-note">Use at least 12 characters. A memorable passphrase works well.</p>
<button class="profile-save-btn" type="submit">Create Account</button>
<p class="review-form-note">Already have an account? <a class="link-btn" href="{{ route('login') }}">Log in →</a></p>
</form>

</div>
</main>
@endsection
