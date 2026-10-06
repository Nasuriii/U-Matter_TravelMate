// Administrator review page (Business Processes 3, 4 and 5: approve or reject hotel, restaurant and attraction listings).
export const adminPage = `<section data-page="admin" class="owner" hidden>
<div class="o-head"><p class="eyebrow">ADMINISTRATOR</p><h1>Review business listings</h1><p>Approve a listing to make it visible to travelers, or reject it with a reason the owner will see. A listing can only be approved when it is complete: a hotel needs valid check-in/check-out times and an available room, a restaurant needs operating hours and a menu item, an attraction needs an entrance fee and an operating day.</p></div>
<p id="a-notice" class="o-notice" role="status" aria-live="polite"></p>
<div class="a-grid">
<div>
<div class="o-card"><h2>Awaiting review <span id="a-count"></span></h2>
<div id="a-filter" class="a-chips" role="group" aria-label="Filter by listing type">
<button type="button" data-type="all">All</button><button type="button" data-type="hotel">Hotels</button><button type="button" data-type="restaurant">Restaurants</button><button type="button" data-type="attraction">Attractions</button>
</div>
<div id="a-list"><p class="muted">Loading…</p></div></div>
<div class="o-card"><h2>Recently reviewed</h2><div id="a-history"><p class="muted">Loading…</p></div></div>
</div>
<div class="o-card" id="a-notes"></div>
</div>
</section>`;
