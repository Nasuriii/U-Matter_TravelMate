<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="theme-color" content="#1479D1"><meta name="description" content="Explore Philippine destinations, save your favorites and plan your next trip with TravelMate."><title>@yield('title','TravelMate') — TravelMate</title><link rel="icon" type="image/svg+xml" href="{{ asset('images/travelmate-mark.svg') }}"><link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="{{ asset('css/travelmate-prototype.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-browse.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-wishlist.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-planner.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-management.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-reservations.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-account.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-directory.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-content.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-discovery.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-operations.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-security.css') }}">
<link rel="stylesheet" href="{{ asset('css/travelmate-final.css') }}">
<script src="{{ asset('js/travelmate-final.js') }}" defer></script></head>
<body class="tm-final"><a class="tm-skip" href="#main-content">Skip to content</a>
@php
$navRoles=auth()->check()?\Illuminate\Support\Facades\DB::table('user_roles as ur')->join('roles as r','r.id','=','ur.role_id')->where('ur.user_id',auth()->id())->pluck('r.name'):collect();
$navUnread=auth()->check()?\Illuminate\Support\Facades\DB::table('notifications')->where('user_id',auth()->id())->whereNull('read_at')->count():0;
$rail=[['destinations.index','compass','Explore','destinations.*'],['directory.index','places','Places','directory.*'],['transport.index','transport','Transport','transport.index|transport.show'],['discovery.index','spark','For you','discovery.index'],['wishlist.index','heart','Saved','wishlist.*'],['trips.index','plan','My trips','trips.*'],['bookings.index','booking','Bookings','bookings.*']];
@endphp
<aside class="tm-rail"><a class="tm-rail-brand" href="{{ route('home') }}" aria-label="TravelMate home">T<span>m</span></a><nav aria-label="Main navigation">
@foreach($rail as [$route,$icon,$label,$pattern])<a class="tm-rail-link {{ request()->routeIs(...explode('|',$pattern))?'is-current':'' }}" href="{{ route($route) }}" @if(request()->routeIs(...explode('|',$pattern))) aria-current="page" @endif>@include('travelmate.final.icon',['name'=>$icon])<span>{{ $label }}</span></a>@endforeach
</nav><a class="tm-rail-link tm-rail-help" href="{{ route('issues.index') }}">@include('travelmate.final.icon',['name'=>'inbox'])<span>My issues</span></a></aside>
<header class="tm-masthead"><a class="tm-brand" href="{{ route('home') }}"><span class="wordmark">TRAVEL<span>MATE</span></span><small>The Philippine Field Guide</small></a>
<div class="tm-top-actions">@auth<a class="tm-inbox" href="{{ route('notifications.index') }}" aria-label="Inbox, {{ $navUnread }} unread">@include('travelmate.final.icon',['name'=>'inbox'])@if($navUnread)<span>{{ min($navUnread,99) }}{{ $navUnread>99?'+':'' }}</span>@endif</a>@else<a class="tm-sign-in" href="{{ route('login') }}">Log in</a><a class="tm-sign-up" href="{{ route('register') }}">Sign up</a>@endauth
<details class="tm-account-menu"><summary>@auth<span class="tm-avatar">{{ mb_strtoupper(mb_substr(auth()->user()->full_name,0,1)) }}</span><span class="tm-account-name">{{ \Illuminate\Support\Str::words(auth()->user()->full_name,1,'') }}</span>@else
    @include('travelmate.final.icon',['name'=>'menu'])
    <span>Menu</span>@endauth<span aria-hidden="true">⌄</span></summary><nav aria-label="Account and more pages">
@auth<div class="tm-menu-person"><strong>{{ auth()->user()->full_name }}</strong><small>{{ $navRoles->contains('admin')?'Administrator':($navRoles->contains('business_owner')?'Business owner':'Traveler') }}</small></div><a href="{{ route('dashboard') }}">My account</a><a href="{{ route('profile.edit') }}">Profile & preferences</a><a href="{{ route('notifications.index') }}">Inbox</a>@endauth
@guest
<a href="{{ route('login') }}">Log in</a>
<a href="{{ route('register') }}">Sign up</a>
@endguest
<a href="{{ route('destinations.index') }}">Explore destinations</a><a href="{{ route('directory.index') }}">Hotels, restaurants & attractions</a><a href="{{ route('transport.index') }}">Transportation</a><a href="{{ route('discovery.index') }}">Suggested for you</a><a href="{{ route('bookings.index') }}">My bookings</a><a href="{{ route('issues.index') }}">My reported issues</a>
@if($navRoles->contains('business_owner'))<a href="{{ route('owner.index') }}">Manage my business</a><a href="{{ route('owner.bookings') }}">Manage reservations</a><a href="{{ route('transport.owner') }}">My transport providers</a>@endif
@if($navRoles->contains('admin'))<a href="{{ route('admin.index') }}">Admin workspace</a><a href="{{ route('operations.analytics') }}">Activity reports</a>@endif
@auth<form method="POST" action="{{ route('logout') }}">@csrf<button type="submit">Sign out</button></form>@endauth
</nav></details></div></header>
<div class="tm-app-shell" id="main-content" tabindex="-1">@if(session('status'))<div class="tm-message" role="status">{{ session('status') }}</div>@endif @yield('content')
<footer class="tm-app-footer"><a class="wordmark" href="{{ route('home') }}">TRAVEL<span>MATE</span></a><span>Field Guide & Trip Planner</span><a href="{{ route('issues.create') }}">Report an issue</a></footer></div>
<nav class="tm-mobile-nav" aria-label="Mobile navigation">@foreach([['destinations.index','compass','Explore'],['directory.index','places','Places'],['wishlist.index','heart','Saved'],['trips.index','plan','Trips'],['dashboard','user','Account']] as [$route,$icon,$label])<a href="{{ route($route) }}" @if(request()->routeIs($route)) aria-current="page" @endif>@include('travelmate.final.icon',['name'=>$icon])<span>{{ $label }}</span></a>@endforeach</nav>
</body></html>