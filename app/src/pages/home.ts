// Signed-in home page (copies the prototype's Home: headline, search, photo, feature tiles, reviews).
const IMG = 'https://upload.wikimedia.org/wikipedia/commons/8/86/El_Nido_Palawan_Big_Lagoon.jpg';
const ico = (d: string) => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true">${d}</svg>`;
export const homePage = `<section data-page="home" class="home" hidden>
<div class="h-hero"><div class="h-copy"><p class="eyebrow">WELCOME BACK, <span id="hm-name">TRAVELER</span></p>
<h1>7,641 islands.<br><span class="accent">One itinerary.</span></h1>
<p class="lead">A field guide to the Philippines: where to sleep, eat and disappear, built from real traveler ratings and reviews, not brochure copy.</p>
<form id="home-search-form" class="ticket"><div class="ticket-field"><label for="home-search">Destination or province</label><input id="home-search" type="search" placeholder="Try “Bauang”, “San Juan” or “La Union”"></div><button class="primary" type="submit">Search →</button></form>
<div class="h-chips"><span><b id="hm-dest">–</b> destinations</span><span><b id="hm-stay">–</b> places to stay</span><span><b id="hm-eat">–</b> places to eat</span></div></div>
<div class="h-photo"><img src="${IMG}" alt="Big Lagoon, El Nido, Palawan" loading="eager"><div class="stamp"><b id="hm-rate">–</b><small>★ RATED</small></div><div class="h-caption">BIG LAGOON, EL NIDO · PHOTO: WIKIMEDIA COMMONS</div></div></div>
<div class="h-tiles">
<a class="tile" href="#/explore">${ico('<circle cx="12" cy="10" r="3"/><path d="M12 21s7-6.7 7-11.5A7 7 0 0 0 5 9.5C5 14.3 12 21 12 21z"/>')}<h3>Where to go</h3><p>Destinations across the archipelago, from limestone lagoons to rice terraces.</p><span class="go">Browse destinations →</span></a>
<a class="tile" href="#/stay">${ico('<path d="M3 19V7a1 1 0 0 1 1-1h5v13M3 19h18M9 19V6M9 10h5a2 2 0 0 1 2 2v7M20 19v-4a2 2 0 0 0-2-2h-2"/>')}<h3>Where to sleep</h3><p>Hotels, resorts and homestays, beachfront to backpacker, side by side.</p><span class="go">Browse hotels →</span></a>
<a class="tile" href="#/eat">${ico('<path d="M6 2v7a2 2 0 0 0 2 2v11M6 2v20M10 2v9M18 2c-2 0-3 2-3 5v3h6M18 2v20"/>')}<h3>Where to eat</h3><p>Local kitchens and cafés with menus, hours and cuisines.</p><span class="go">Browse restaurants →</span></a>
<a class="tile" href="#/attractions">${ico('<path d="M12 3l2.8 5.7 6.2.9-4.5 4.4 1 6.2L12 17.3 6.5 20.2l1-6.2L3 9.6l6.2-.9z"/>')}<h3>Things to do</h3><p>Gardens, tours and sights with entrance fees and schedules.</p><span class="go">Browse attractions →</span></a>
</div>
<section class="band" id="home-reviews" hidden><p class="eyebrow">WHAT TRAVELERS SAY</p><h2>Straight from people who went</h2><div class="l-grid" id="home-review-grid"></div></section>
</section>`;
