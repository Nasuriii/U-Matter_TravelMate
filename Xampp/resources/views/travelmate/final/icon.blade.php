<svg class="tm-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
@switch($name)
@case('compass')<circle cx="12" cy="12" r="9"/><path d="m16 8-2 6-6 2 2-6z"/>@break
@case('places')<path d="M3 21h18M5 21V5h14v16M9 9h1m4 0h1M9 13h1m4 0h1M10 21v-4h4v4"/>@break
@case('heart')<path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8Z"/>@break
@case('plan')<rect x="4" y="5" width="16" height="16" rx="2"/><path d="M8 3v4m8-4v4M4 11h16M8 15h3m-3 3h7"/>@break
@case('booking')<rect x="4" y="4" width="16" height="17" rx="2"/><path d="m8 12 3 3 5-6M9 3h6"/>@break
@case('transport')<rect x="5" y="3" width="14" height="16" rx="3"/><path d="M5 11h14M8 19l-2 3m10-3 2 3M9 15h.01M15 15h.01"/>@break
@case('user')<circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/>@break
@case('spark')<path d="m12 3 2.5 6.5L21 12l-6.5 2.5L12 21l-2.5-6.5L3 12l6.5-2.5z"/>@break
@case('inbox')<path d="M4 4h16v16H4zM4 13h5l2 3h2l2-3h5"/>@break
@case('search')<circle cx="10" cy="10" r="6"/><path d="m15 15 6 6"/>@break
@case('arrow')<path d="M4 12h16m-6-6 6 6-6 6"/>@break
@case('menu')<path d="M4 6h16M4 12h16M4 18h16"/>@break
@case('shield')<path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6z"/>@break
@default<circle cx="12" cy="12" r="8"/>
@endswitch
</svg>