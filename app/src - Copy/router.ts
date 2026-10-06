// Tiny hash router. To add a page: add a route here and a <section data-page="..."> in src/pages/.
// access: 'out' = guests only, 'in' = signed-in only, 'any' = everyone.
type Access = 'in' | 'out' | 'any' | 'owner' | 'admin';
const routes: Record<string, { page: string; access: Access }> = {
  '/': { page: 'landing', access: 'out' },
  '/login': { page: 'auth', access: 'out' },
  '/register': { page: 'auth', access: 'out' },
  '/forgot': { page: 'auth', access: 'out' },
  '/reset': { page: 'auth', access: 'any' },
  '/trips': { page: 'trips', access: 'in' },
  '/home': { page: 'home', access: 'in' },
  '/explore': { page: 'explore', access: 'in' },
  '/stay': { page: 'stay', access: 'in' },
  '/eat': { page: 'eat', access: 'in' },
  '/attractions': { page: 'attractions', access: 'in' },
  '/owner': { page: 'owner', access: 'owner' },
  '/admin': { page: 'admin', access: 'admin' },
  '/account': { page: 'account', access: 'in' },
};
export const go = (path: string) => { location.hash = '#' + path; };
let lastPath = '';
export function route() {
  const state = document.body.dataset.auth; // undefined until the session is known
  let path = location.hash.replace(/^#/, '') || '/';
  if (!routes[path]) path = '/';
  const { page, access } = routes[path];
  if (state === 'in' && access === 'out') { go('/home'); return; }
  if (state === 'out' && (access === 'in' || access === 'owner' || access === 'admin')) { go('/login'); return; }
  if (access === 'owner' && document.body.dataset.owner === 'no') { go('/home'); return; }
  if (access === 'admin' && document.body.dataset.admin === 'no') { go('/home'); return; }
  const waiting = (state === undefined && (access === 'in' || access === 'owner' || access === 'admin')) || (access === 'owner' && document.body.dataset.owner === undefined) || (access === 'admin' && document.body.dataset.admin === undefined);
  document.querySelectorAll<HTMLElement>('[data-page]').forEach(s => { s.hidden = waiting || s.dataset.page !== page; });
  const mode = path.slice(1);
  document.body.dataset.view = page; document.body.dataset.mode = mode;
  document.querySelectorAll<HTMLElement>('[data-for]').forEach(n => { n.hidden = !(n.dataset.for || '').split(' ').includes(mode); });
  document.querySelectorAll<HTMLElement>('[data-nav]').forEach(a => { const on = a.dataset.nav === path; a.classList.toggle('current', on); if (on) a.setAttribute('aria-current', 'page'); else a.removeAttribute('aria-current'); });
  if (path !== lastPath) window.scrollTo(0, 0);
  lastPath = path;
}
