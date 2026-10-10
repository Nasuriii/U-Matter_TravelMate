// Tiny hash router. To add a page: add a route here and a <section data-page="..."> in src/pages/.
// access: 'out' = guests only, 'in' = signed-in only, 'any' = everyone.
import { redirectForAccess, type Access, type Workspace } from './route-access';
import { purposeForPath } from './signup-flow';
const routes: Record<string, { page: string; access: Access }> = {
  '/': { page: 'landing', access: 'out' },
  '/login': { page: 'auth', access: 'out' },
  '/register': { page: 'auth', access: 'out' },
  '/register/traveler': { page: 'auth', access: 'out' },
  '/register/business': { page: 'auth', access: 'out' },
  '/preferences': { page: 'preferences', access: 'traveler' },
  '/forgot': { page: 'auth', access: 'out' },
  '/reset': { page: 'auth', access: 'any' },
  '/saved': {page:'saved',access:'traveler'},
  '/trips': { page: 'trips', access: 'traveler' },
  '/home': { page: 'home', access: 'in' },
  '/explore': { page: 'explore', access: 'traveler' },
  '/stay': { page: 'stay', access: 'traveler' },
  '/eat': { page: 'eat', access: 'traveler' },
  '/attractions': { page: 'attractions', access: 'traveler' },
  '/bookings': { page: 'bookings', access: 'traveler' },
  '/reservations': { page: 'reservations', access: 'owner' },
  '/reports': { page: 'reports', access: 'staff' },
  '/owner': { page: 'owner', access: 'owner' },
  '/admin': { page: 'admin', access: 'admin' },
  '/account': { page: 'account', access: 'in' },
};
export const go = (path: string) => { location.hash = '#' + path; };
let lastPath = '';
export function route() {
  const state = document.body.dataset.auth; // undefined until the session is known
  let path = (location.hash.replace(/^#/, '') || '/').split('?')[0];
  const dynamic = path.match(/^\/(destination|listing|book)\/[0-9a-f-]{36}$/i);
  if (!routes[path] && !dynamic) path = '/';
  const { page, access } = dynamic ? {page: dynamic[1], access: (dynamic[1] === 'book' ? 'traveler' : 'discovery') as Access} : routes[path];
  const role = (document.body.dataset.workspace || (state === 'out' ? 'guest' : 'loading')) as Workspace;
  const redirect = redirectForAccess(role, access);
  if (redirect) { go(redirect); return; }
  const waiting = role === 'loading' && access !== 'out' && access !== 'any';
  document.querySelectorAll<HTMLElement>('[data-page]').forEach(s => { s.hidden = waiting || s.dataset.page !== page; });
  const signup = purposeForPath(path);
  const mode = signup ? 'register' : path.slice(1);
  if (signup) sessionStorage.setItem('travelmate:entry-intent', signup);
  const password = document.querySelector<HTMLInputElement>('#auth-password');
  if (password) password.autocomplete = mode === 'register' || mode === 'reset' ? 'new-password' : 'current-password';
  const signupTitle = document.querySelector<HTMLElement>('.auth-box h1[data-for="register"]');
  const signupCopy = document.querySelector<HTMLElement>('.auth-box .sub[data-for="register"]');
  const businessSignup = signup === 'business_owner';
  if (signupTitle) signupTitle.textContent = businessSignup ? 'Create your business account' : 'Create your traveler account';
  if (signupCopy) signupCopy.textContent = businessSignup ? 'Your business portal starts here. Add your first listing after signing up.' : 'Next: choose your travel style, then create your first itinerary.';
  document.body.dataset.signup = businessSignup ? 'business' : 'traveler';
  const signupAside = document.querySelector<HTMLElement>('.auth-copy h2[data-for="register"]');
  const signupAsideCopy = document.querySelector<HTMLElement>('.auth-copy p[data-for="register"]');
  if (signupAside) signupAside.textContent = businessSignup ? 'Your next guest starts here' : 'Your kind of journey';
  if (signupAsideCopy) signupAsideCopy.textContent = businessSignup ? 'Showcase your hotel, restaurant, or attraction to travelers discovering your destination.' : 'Beaches, mountains, food stops, and scenic detours. Make room for what you love.';
  const signupButton = document.querySelector<HTMLElement>('#auth-submit span[data-for="register"]');
  if (signupButton) signupButton.textContent = businessSignup ? 'Create business account' : 'Create traveler account';
  document.body.dataset.view = page; document.body.dataset.mode = mode;
  document.querySelectorAll<HTMLElement>('[data-for]').forEach(n => { n.hidden = !(n.dataset.for || '').split(' ').includes(mode); });
  document.querySelectorAll<HTMLElement>('[data-nav]').forEach(a => { const on = a.dataset.nav === path; a.classList.toggle('current', on); if (on) a.setAttribute('aria-current', 'page'); else a.removeAttribute('aria-current'); });
  if (path !== lastPath) window.scrollTo(0, 0);
  lastPath = path;
}
