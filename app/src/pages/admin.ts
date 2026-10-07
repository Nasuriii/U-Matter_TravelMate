// Administrator review page (Business Processes 3, 4 and 5: approve or reject hotel, restaurant and attraction listings).
export const adminPage = `<section data-page="admin" class="owner" hidden>
<div class="o-head a-header"><div><p class="eyebrow">ADMIN CONSOLE / LISTING REVIEWS</p><h1>Listing reviews</h1><p>Review local businesses before they appear in travelers’ plans.</p></div><button id="a-refresh" type="button" class="quiet">↻ Refresh queue</button></div>
<p id="a-notice" class="o-notice" role="status" aria-live="polite"></p>
<div class="a-summary" aria-label="Queue overview"><div><span>Awaiting review</span><strong id="a-total">—</strong></div><div><span>Ready for approval</span><strong id="a-ready">—</strong></div><div><span>Needs attention</span><strong id="a-blocked">—</strong></div></div>
<div class="a-grid">
<div>
<div class="o-card a-queue"><div class="a-section-head"><div><h2>Review queue <span id="a-count"></span></h2><p>Check the details, then approve or explain what needs fixing.</p></div></div>
<label class="a-search" for="a-search">Search listings<input id="a-search" type="search" placeholder="Business, destination or owner…" autocomplete="off"></label>
<div id="a-filter" class="a-chips" role="group" aria-label="Filter by listing type">
<button type="button" data-type="all">All</button><button type="button" data-type="hotel">Hotels</button><button type="button" data-type="restaurant">Restaurants</button><button type="button" data-type="attraction">Attractions</button>
</div>
<p id="a-results" class="a-results" role="status" aria-live="polite"></p><div id="a-list"><p class="muted">Loading listings…</p></div></div>
<div class="o-card a-recent"><h2>Recent decisions</h2><p class="a-history-caption">The latest 15 reviewed listings.</p><div id="a-history"><p class="muted">Loading…</p></div></div>
</div>
<div class="o-card" id="a-notes"></div>
</div>
</section>`;
