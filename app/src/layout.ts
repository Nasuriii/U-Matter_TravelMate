// Header, footer and shared dialogs. Pages live in src/pages/.
export const header = `<header class="top"><a href="#/" class="brand">TRAVEL<span>MATE</span></a>
<nav class="top-nav" data-auth-only aria-label="Main"><a href="#/explore">Explore</a><a href="#/account">My account</a></nav>
<div class="top-actions"><a class="plain" href="#/login" data-guest-only>Log in</a><a class="btn primary" href="#/register" data-guest-only>Get started</a><button id="top-logout" class="quiet" data-auth-only type="button">Log out</button></div></header>`;
export const footer = `<footer><span class="brand">TRAVEL<span>MATE</span></span><span>© 2026 TravelMate — a U-Matter platform</span></footer>`;
export const dialogs = `<dialog id="destination-dialog"><button id="close-detail" class="quiet">Close ×</button><p id="detail-province" class="eyebrow"></p><h2 id="detail-name"></h2><p id="detail-description"></p></dialog>
<dialog id="role-dialog"><p class="eyebrow">ONE LAST STEP</p><h2>How will you use TravelMate?</h2><p>Choose your account type to continue.</p><div class="roles"><button type="button" class="role-card" data-role="traveler"><strong>I'm a Traveler</strong><span>Discover places, save favorites, plan trips and write reviews.</span></button><button type="button" class="role-card" data-role="business_owner"><strong>I'm a Business Owner</strong><span>List and manage your hotel, restaurant, attraction or transport service.</span></button></div><p id="role-error" class="error" role="alert" hidden></p></dialog>
`;
