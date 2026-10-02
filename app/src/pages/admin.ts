// Administrator review page (Business Process 3: approve or reject hotel listings).
export const adminPage = `<section data-page="admin" class="owner" hidden>
<div class="o-head"><p class="eyebrow">ADMINISTRATOR</p><h1>Review hotel listings</h1><p>Approve a listing to make it visible to travelers, or reject it with a reason the owner will see. A hotel needs valid check-in/check-out times and at least one available room before it can be approved.</p></div>
<p id="a-notice" class="o-notice" role="status" aria-live="polite"></p>
<div class="a-grid">
<div class="o-card"><h2>Awaiting review <span id="a-count"></span></h2><div id="a-list"><p class="muted">Loading…</p></div></div>
<div class="o-card" id="a-notes"></div>
</div>
</section>`;
