// Tiny hash router. To add a page: add a route here and a <section data-page="..."> in src/pages/.
// access: 'out' = guests only, 'in' = signed-in only, 'any' = everyone.
import { redirectForAccess, type Access, type Workspace } from './route-access';
const routes: Record<string, { page: string; access: Access }> = {
  '/': { page: 'landing', access: 'out' },
  '/login': { page: 'auth', access: 'out' },
  '/register': { page: 'auth', access: 'out' },
  '/forgot': { page: 'auth', access: 'out' },
  '/reset': { page: 'auth', access: 'any' },
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
  const { page, access } = dynamic ? {page: dynamic[1], access: 'traveler' as Access} : routes[path];
  const role = (document.body.dataset.workspace || (state === 'out' ? 'guest' : 'loading')) as Workspace;
  const redirect = redirectForAccess(role, access);
  if (redirect) { go(redirect); return; }
  const waiting = role === 'loading' && access !== 'out' && access !== 'any';
  document.querySelectorAll<HTMLElement>('[data-page]').forEach(s => { s.hidden = waiting || s.dataset.page !== page; });
  const mode = path.slice(1);
  document.body.dataset.view = page; document.body.dataset.mode = mode;
  document.querySelectorAll<HTMLElement>('[data-for]').forEach(n => { n.hidden = !(n.dataset.for || '').split(' ').includes(mode); });
  document.querySelectorAll<HTMLElement>('[data-nav]').forEach(a => { const on = a.dataset.nav === path; a.classList.toggle('current', on); if (on) a.setAttribute('aria-current', 'page'); else a.removeAttribute('aria-current'); });
  if (path !== lastPath) window.scrollTo(0, 0);
  lastPath = path;
}
