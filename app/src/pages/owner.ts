import { searchControl } from '../search-control';
// Business-owner dashboard (Business Processes 3-5: hotel, restaurant, attraction listing management).
export const ownerPage = `<section data-page="owner" class="owner" hidden>
<div class="o-head"><p class="eyebrow">BUSINESS DASHBOARD</p><h1>Manage your listings</h1><p>Keep your places up to date. Select a listing to manage its details.</p></div>
<div class="o-stats"><button type="button" data-listing-status="all" aria-pressed="true"><strong id="o-total">0</strong><span>All listings</span></button><button type="button" data-listing-status="approved" aria-pressed="false"><strong id="o-active">0</strong><span>Live</span></button><button type="button" data-listing-status="pending" aria-pressed="false"><strong id="o-pending">0</strong><span>Awaiting review</span></button></div>
<p id="o-notice" class="o-notice" role="status" aria-live="polite"></p>
<div class="o-grid">
<div class="o-card o-create-listing"><button type="button" id="o-create-listing" aria-haspopup="dialog"><span class="o-add-icon" aria-hidden="true">+</span><span><strong>Add a listing</strong><small>Rooms, menus, schedules and photos</small></span><span aria-hidden="true">↗</span></button><div id="o-create-form-shell" hidden>
<form id="ol-form" novalidate><p class="muted">Prepare your business details, menu or rooms, and photos together. Submit everything for review when it is ready. You can keep editing while approval is pending.</p>
<label for="ol-type">Business type</label><select id="ol-type"><option value="hotel">Hotel</option><option value="restaurant">Restaurant</option><option value="attraction">Attraction</option></select>
<label for="ol-name">Business name</label><input id="ol-name" maxlength="150" placeholder="Sunset Grill">
<label for="ol-dest">Destination</label><select id="ol-dest"><option value="">Loading…</option></select>
<label for="ol-address">Address</label><input id="ol-address" maxlength="200">
<label for="ol-desc">Description</label><textarea id="ol-desc" rows="3"></textarea>
<div data-type="hotel" class="row2"><div><label for="ol-checkin">Check-in time</label><input id="ol-checkin" type="time"></div><div><label for="ol-checkout">Check-out time</label><input id="ol-checkout" type="time"></div></div>
<p data-type="hotel" id="ol-time-hint" class="time-hint"></p><div data-type="hotel" id="ol-guide-slot"></div>
<div data-type="restaurant" hidden><label for="ol-hours">Operating hours (required)</label><input id="ol-hours" maxlength="500" placeholder="Mon–Sat, 10:00 AM – 9:00 PM; Sunday closed"><p class="muted">Add your opening days and hours, then build your menu with a price and photo for each item in Menu &amp; dish photos.</p><label for="ol-resfee">Reservation fee (₱)</label><input id="ol-resfee" type="number" min="0" step="0.01" value="0"></div>
<div data-type="attraction" hidden><label for="ol-fee">Entrance fee (₱)</label><input id="ol-fee" type="number" min="0" step="0.01"><div class="row2"><div><label for="ol-day">Operating day</label><select id="ol-day"><option>Daily</option><option>Monday</option><option>Tuesday</option><option>Wednesday</option><option>Thursday</option><option>Friday</option><option>Saturday</option><option>Sunday</option></select></div><div><label for="ol-slot">Time slot</label><input id="ol-slot" placeholder="08:00 AM - 05:00 PM"></div></div></div>
<button id="ol-submit" class="primary" type="submit">Create listing</button></form></div></div>
<div class="o-card o-listings-card"><div class="o-section-heading"><h2>My listings</h2><span id="o-results" role="status" aria-live="polite"></span></div><div class="browse-toolbar o-listing-tools"><label>Search listings${searchControl('<input id="o-search" type="search" maxlength="120" placeholder="Name or destination">')}</label><label>Type<select id="o-type"><option value="all">All types</option><option value="hotel">Hotels</option><option value="restaurant">Restaurants</option><option value="attraction">Attractions</option></select></label><label>Status<select id="o-status"><option value="all">All statuses</option><option value="pending">Awaiting review</option><option value="approved">Live</option><option value="rejected">Needs changes</option><option value="inactive">Inactive</option></select></label></div><div id="o-list"><div class="skel"></div><div class="skel"></div></div><nav id="o-pagination" aria-label="My listings pages"></nav></div>
</div>
<div id="o-notes" class="o-card"></div>
<div id="o-manage" class="o-card" hidden></div>
</section>`;
