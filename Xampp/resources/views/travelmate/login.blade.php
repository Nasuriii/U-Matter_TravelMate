@extends('travelmate.layout')
@section('title', 'Log In')
@section('publicScreen', 'yes')
@section('content')
<main class="auth-wrap">
<a class="back-link auth-back" href="{{ route('home') }}">← Back to TravelMate</a>
<div class="auth-card">
<nav class="auth-tabs" aria-label="Account access">
<a class="auth-tab active" href="{{ route('login') }}">Log In</a>
<a class="auth-tab " href="{{ route('register') }}">Sign Up</a>
</nav>
<h1>Welcome back.</h1>
@include('travelmate.errors')

<form method="POST" action="{{ route('login.store') }}" class="profile-form">
@csrf
<p class="auth-intro">Log in as a traveler or a business owner.</p>
<div class="profile-field"><label for="email">Email</label>
<input id="email" name="email" type="email" value="{{ old('email') }}" required maxlength="254" autocomplete="username" placeholder="juan@email.com"></div>
<div class="profile-field"><label for="password">Password</label>
<input id="password" name="password" type="password" required autocomplete="current-password"></div>
<button class="profile-save-btn" type="submit">Log In</button>
<p class="review-form-note">No account yet? <a class="link-btn" href="{{ route('register') }}">Sign up →</a></p>
</form><p><a href="{{ route('security.forgot') }}">Forgot password?</a></p>

</div>
</main>
@endsection
