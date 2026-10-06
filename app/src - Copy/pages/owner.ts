// Business-owner dashboard (Business Processes 3-5: hotel, restaurant, attraction listing management).
export const ownerPage = `<section data-page="owner" class="owner" hidden>
<div class="o-head"><p class="eyebrow">BUSINESS DASHBOARD</p><h1>Manage your listings</h1><p>Add hotels, restaurants and attractions. New and edited listings are reviewed by an administrator before travelers can see them.</p></div>
<div class="o-stats"><div><strong id="o-total">0</strong><span>Total listings</span></div><div><strong id="o-active">0</strong><span>Live (approved)</span></div><div><strong id="o-pending">0</strong><span>Awaiting review</span></div></div>
<p id="o-notice" class="o-notice" role="status" aria-live="polite"></p>
<div class="o-grid">
<form id="ol-form" class="o-card" novalidate><h2>Add a listing</h2>
<label for="ol-type">Business type</label><select id="ol-type"><option value="hotel">Hotel</option><option value="restaurant">Restaurant</option><option value="attraction">Attraction</option></select>
<label for="ol-name">Business name</label><input id="ol-name" maxlength="150" placeholder="Sunset Grill">
<label for="ol-dest">Destination</label><select id="ol-dest"><option value="">Loading…</option></select>
<label for="ol-address">Address</label><input id="ol-address" maxlength="200">
<label for="ol-desc">Description</label><textarea id="ol-desc" rows="3"></textarea>
<div data-type="hotel" class="row2"><div><label for="ol-checkin">Check-in time</label><input id="ol-checkin" type="time"></div><div><label for="ol-checkout">Check-out time</label><input id="ol-checkout" type="time"></div></div>
<p data-type="hotel" id="ol-time-hint" class="time-hint"></p><div data-type="hotel" id="ol-guide-slot"></div>
<div data-type="restaurant" hidden><label for="ol-hours">Operating hours</label><input id="ol-hours" placeholder="10:00 AM - 9:00 PM"><label for="ol-resfee">Reservation fee (₱)</label><input id="ol-resfee" type="number" min="0" step="0.01" value="0"></div>
<div data-type="attraction" hidden><label for="ol-fee">Entrance fee (₱)</label><input id="ol-fee" type="number" min="0" step="0.01"><div class="row2"><div><label for="ol-day">Operating day</label><select id="ol-day"><option>Daily</option><option>Monday</option><option>Tuesday</option><option>Wednesday</option><option>Thursday</option><option>Friday</option><option>Saturday</option><option>Sunday</option></select></div><div><label for="ol-slot">Time slot</label><input id="ol-slot" placeholder="08:00 AM - 05:00 PM"></div></div></div>
<button id="ol-submit" class="primary" type="submit">Submit for review</button></form>
<div class="o-card"><h2>My listings</h2><div id="o-list"><div class="skel"></div><div class="skel"></div></div></div>
</div>
<div id="o-notes" class="o-card"></div>
<div id="o-manage" class="o-card" hidden></div>
</section>`;
