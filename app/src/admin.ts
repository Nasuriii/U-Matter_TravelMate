import type { SupabaseClient } from '@supabase/supabase-js';
import { loadNotifications } from './notifications';
import { tidy } from './ui';
type Row = Record<string, any>;
const $ = (id: string) => document.getElementById(id)!;
const peso = (n: any) => (n == null ? '—' : '₱' + Number(n).toLocaleString());
const hhmm = (t: any) => (t ? String(t).slice(0, 5) : '—');
const LABEL: Record<string, string> = { hotel: 'Hotel', restaurant: 'Restaurant', attraction: 'Attraction' };
function h(tag: string, cls = '', text = '') { const e = document.createElement(tag); if (cls) e.className = cls; if (text) e.textContent = text; return e; }
function list(items: string[], empty: string) { const ul = h('ul', 'o-items'); for (const t of items) ul.append(h('li', '', t)); if (!items.length) ul.append(h('li', 'muted', empty)); return ul; }

/**
 * Administrator review of business listings (Business Processes 3, 4, 5).
 * Reads go through admin_review_queue() / admin_reviewed_listings(), writes through admin_review_listing();
 * all three check the admin role in the database (database/09 and 10), so hiding this page is only a convenience.
 */
export function initAdmin(client: SupabaseClient) {
  const db = client.schema('public');
  let queue: Row[] = [], filter = 'all';
  const say = (m: string, err = false) => { const n = $('a-notice'); n.textContent = m; n.classList.toggle('error', err); };
  const fail = (e: any) => say(/admin_review_queue|admin_reviewed_listings|admin_review_listing|PGRST202/i.test(String(e?.message) + String(e?.code))
    ? 'The database is not ready for reviews yet. Run database/09_hotel_listing.sql and database/10_admin_review.sql in the Supabase SQL Editor. (' + (e?.message ?? e) + ')'
    : (e?.message ?? String(e)), true);

  async function decide(l: Row, approve: boolean, reason: string, buttons: HTMLButtonElement[]) {
    if (!approve && !reason.trim()) return say('Write a reason so the owner knows what to fix.', true);
    buttons.forEach(b => (b.disabled = true));
    const x = await db.rpc('admin_review_listing', { p_listing: l.id, p_approve: approve, p_reason: approve ? null : reason.trim() });
    if (x.error) { buttons.forEach(b => (b.disabled = false)); return fail(x.error); }
    say(approve ? `“${l.name}” approved. The owner has been notified.` : `“${l.name}” rejected. The owner has been notified.`);
    await refresh();
  }

  function details(c: HTMLElement, l: Row) {
    if (l.type === 'hotel') {
      c.append(h('p', '', `Check-in ${hhmm(l.check_in)} · Check-out ${hhmm(l.check_out)}`), h('h4', '', 'Rooms'),
        list(((l.rooms ?? []) as Row[]).map(r => `Room ${r.room_number} · ${r.room_type} · ${r.max_guests} guests · ${peso(r.rate)}/night · ${r.status}`), 'No rooms added.'),
        h('h4', '', 'Amenities'), h('p', '', (l.amenities ?? []).length ? (l.amenities as string[]).join(', ') : 'None selected.'));
    } else if (l.type === 'restaurant') {
      c.append(h('p', '', `Hours: ${l.operating_hours || '—'} · Reservation fee ${peso(l.reservation_fee)}`), h('h4', '', 'Menu'),
        list(((l.menu ?? []) as Row[]).map(m => `${m.name}${m.category ? ' (' + m.category + ')' : ''} · ${peso(m.price)}${m.available ? '' : ' · unavailable'}`), 'No menu items.'),
        h('h4', '', 'Cuisines'), h('p', '', (l.cuisines ?? []).length ? (l.cuisines as string[]).join(', ') : 'None selected.'));
    } else if (l.type === 'attraction') {
      c.append(h('p', '', `Entrance fee: ${l.entrance_fee == null ? '—' : Number(l.entrance_fee) === 0 ? 'Free' : peso(l.entrance_fee)}`), h('h4', '', 'Operating schedule'),
        list(((l.schedule ?? []) as Row[]).map(s => `${s.day}: ${s.hours}`), 'No operating days added.'));
    }
  }

  async function photoStrip(c: HTMLElement, id: string) {
    const box = h('div', 'a-photos'); c.append(h('h4', '', 'Photos'), box);
    const x = await db.rpc('admin_listing_photos', { p_listing: id });
    if (x.error) { box.append(h('p', 'muted', 'Photos unavailable: ' + x.error.message)); return; }
    const rows = (x.data ?? []) as Row[]; if (!rows.length) { box.append(h('p', 'muted', 'No photos uploaded.')); return; }
    for (const p of rows) {
      const img = document.createElement('img'); img.alt = ''; img.loading = 'lazy'; box.append(img);
      void client.storage.from('travelmate-listings').createSignedUrl(p.object_path, 3600).then(s => { if (s.data) img.src = s.data.signedUrl; else img.alt = 'Photo could not be loaded'; });
    }
  }
  function card(l: Row) {
    const c = h('article', 'a-card'), problems = (l.problems ?? []) as string[];
    c.append(h('span', 'a-type', LABEL[l.type] ?? String(l.type)), h('h3', '', l.name), h('p', 'muted', `${l.destination} · ${l.address ?? 'No address'}`),
      h('p', 'muted', `Owner: ${l.owner ?? '—'}${l.owner_email ? ' (' + l.owner_email + ')' : ''}`));
    if (l.description) c.append(h('p', '', l.description));
    details(c, l);
    void photoStrip(c, l.id);
    if (problems.length) { const w = h('ul', 'a-problems'); for (const p of problems) w.append(h('li', '', p)); c.append(h('h4', '', 'Blocks approval'), w); }
    const reason = document.createElement('input'); reason.placeholder = 'Reason (required to reject)'; reason.maxLength = 300; reason.setAttribute('aria-label', 'Rejection reason');
    const ok = h('button', 'primary', 'Approve') as HTMLButtonElement, no = h('button', 'quiet', 'Reject') as HTMLButtonElement; ok.type = no.type = 'button';
    ok.disabled = problems.length > 0; ok.title = problems.length ? 'Fix the listed problems first, or reject with a reason.' : '';
    ok.addEventListener('click', () => void decide(l, true, '', [ok, no]));
    no.addEventListener('click', () => void decide(l, false, reason.value, [ok, no]));
    const acts = h('div', 'a-acts'); acts.append(reason, ok, no); c.append(acts);
    return c;
  }

  function renderQueue() {
    const count = (t: string) => (t === 'all' ? queue.length : queue.filter(l => l.type === t).length);
    document.querySelectorAll<HTMLButtonElement>('#a-filter button').forEach(b => {
      const t = b.dataset.type!, base = b.textContent!.replace(/ \(\d+\)$/, '');
      b.textContent = count(t) ? `${base} (${count(t)})` : base;
      b.className = t === filter ? 'primary' : 'quiet'; b.setAttribute('aria-pressed', String(t === filter));
    });
    const rows = filter === 'all' ? queue : queue.filter(l => l.type === filter);
    $('a-count').textContent = queue.length ? `(${queue.length})` : '';
    $('a-list').replaceChildren(...(rows.length ? rows.map(card) : [h('p', 'muted', queue.length ? 'Nothing of this type is waiting.' : 'Nothing is waiting for review.')]));
    const link = document.querySelector<HTMLElement>('a[data-admin-only]');
    const lbl = link?.querySelector('span'); if (lbl) lbl.textContent = queue.length ? `Review (${queue.length})` : 'Review';
  }

  function renderHistory(rows: Row[]) {
    const box = $('a-history');
    if (!rows.length) { box.replaceChildren(h('p', 'muted', 'No decisions yet.')); return; }
    const ul = h('ul', 'a-history');
    for (const r of rows) {
      const li = h('li', ''), when = r.reviewed_at ? new Date(r.reviewed_at) : null;
      li.append(h('strong', '', r.name), h('span', r.status === 'approved' ? 'a-ok' : 'a-no', r.status === 'approved' ? 'Approved' : 'Rejected'),
        h('small', 'muted', `${LABEL[r.type] ?? r.type} · ${r.reviewer ?? 'an administrator'}${when && !Number.isNaN(when.getTime()) ? ' · ' + when.toLocaleString() : ''}`));
      if (r.status === 'rejected' && r.reason) li.append(h('small', 'o-reason', tidy('Reason: ' + r.reason)));
      ul.append(li);
    }
    box.replaceChildren(ul);
  }

  async function refresh() {
    const x = await db.rpc('admin_review_queue');
    if (x.error) return fail(x.error);
    queue = (x.data ?? []) as Row[]; renderQueue();
    const y = await db.rpc('admin_reviewed_listings', { p_limit: 15 });
    if (!y.error) renderHistory((y.data ?? []) as Row[]);
    void loadNotifications(client, $('a-notes'));
  }

  document.querySelectorAll<HTMLButtonElement>('#a-filter button').forEach(b => b.addEventListener('click', () => { filter = b.dataset.type!; renderQueue(); }));
  window.addEventListener('hashchange', () => { if (location.hash === '#/admin') void refresh(); });
  return { refresh };
}
