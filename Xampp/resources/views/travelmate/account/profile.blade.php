@extends('travelmate.layout')
@section('title', 'My profile')
@section('content')
@php
$profileValue = function ($key, $default = '') {
    $value = old($key, $default);
    return is_scalar($value) ? (string)$value : '';
};
@endphp
<main class="browse-shell">
<header class="browse-heading"><h1>My profile</h1><p>Update your details and keep your travel preferences together.</p><p><a class="chip" href="{{ route('security.edit') }}">Change password →</a></p></header>
@include('travelmate.errors')
<section class="planner-panel">
<form class="profile-form" method="POST" action="{{ route('profile.update') }}">@csrf @method('PATCH')
<div class="profile-field"><label for="full-name">Full name</label><input id="full-name" name="full_name" required maxlength="150" autocomplete="name" value="{{ $profileValue('full_name',$profile->full_name) }}"></div>
<div class="profile-field"><label>Sign-in email</label><p class="profile-readonly">{{ $profile->email }}</p></div>
<div class="profile-field"><label for="address">Address (optional)</label><input id="address" name="address" maxlength="255" autocomplete="street-address" value="{{ $profileValue('address',$profile->address) }}"></div>
<p class="profile-private">Your address and phone numbers are private account details. Your name appears on reviews.</p>
<fieldset class="preference-group"><legend>Phone numbers (optional)</legend>
@for($i=0;$i<5;$i++)
<div class="profile-field" style="margin-bottom:12px"><label for="phone-{{ $i }}">Phone {{ $i+1 }}</label><input id="phone-{{ $i }}" name="phones[]" type="tel" maxlength="20" value="{{ $profileValue('phones.'.$i,$phones[$i] ?? '') }}"></div>
@endfor
<p class="planner-hint">Leave a phone field blank to remove that number.</p>
</fieldset>
<h2>Travel preferences</h2>
@php
$selection = session()->hasOldInput() ? old('preferences',[]) : $selected;
$checked = is_array($selection) ? array_map('strval',array_filter($selection,'is_scalar')) : [];
@endphp
@forelse($preferences as $group => $options)
<fieldset class="preference-group"><legend>{{ $group }}</legend><div class="preference-options">
@foreach($options as $option)<label><input type="checkbox" name="preferences[]" value="{{ $option->id }}" @checked(in_array((string)$option->id,$checked,true))>{{ $option->name }}</label>@endforeach
</div></fieldset>
@empty<p>No travel preference options are available yet.</p>@endforelse
<button class="profile-save-btn" type="submit">Save profile</button>
</form>
</section>
</main>
@endsection
