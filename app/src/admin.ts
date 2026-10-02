import type { SupabaseClient } from '@supabase/supabase-js';
import { loadNotifications } from './notifications';
type Row = Record<string, any>;
const $ = (id: string) => document.getElementById(id)!;
const peso = (n: any) => (n == null ? '—' : '₱' + Number(n).toLocaleString());
const hhmm = (t: any) => (t ? String(t).slice(0, 5) : '—');
function h(tag: string, cls = '', text = '') { const e = document.createElement(tag); if (cls) e.className = cls; if (text) e.textContent = text; return e; }

/** Administrator review of hotel listings (Business Process 3). Writes go through admin_review_listing(), which checks the admin role. */
export function initAdmin(client: SupabaseClient) {
  const db = client.schema('public');
  const say = (m: string, err = false) => { const n = $('a-notice'); n.textContent = m; n.classList.toggle('error', err); };
  const fail = (e: any) => say(/admin_[a-z_]+|PGRST202/i.test(String(e?.message) + String(e?.code))
    ? 'The database is not ready for reviews yet. Run database/09_hotel_listing.sql in the Supabase SQL Editor. (' + (e?.message ?? e) + ')' : (e?.message ?? String(e)), true);

  async function decide(l: Row, approve: boolean, reason: string, buttons: HTMLButtonElement[]) {
    if (!approve && !reason.trim()) return say('Write a reason so the owner knows what to fix.', true);
    buttons.forEach(b => (b.disabled = true));
    const x = await db.rpc('admin_review_listing', { p_listing: l.id, p_approve: approve, p_reason: approve ? null : reason.trim() });
    if (x.error) { buttons.forEach(b => (b.disabled = false)); return fail(x.error); }
    say(approve ? `“${l.name}” approved. The owner has been notified.` : `“${l.name}” rejected. The owner has been notified.`);
    await refresh();
  }

  function card(l: Row) {
    const c = h('article', 'a-card'), problems = (l.problems ?? []) as string[];
    c.append(h('h3', '', l.name), h('p', 'muted', `${l.destination} · ${l.address ?? 'No address'}`),
      h('p', 'muted', `Owner: ${l.owner ?? '—'}${l.owner_email ? ' (' + l.owner_email + ')' : ''}`));
    if (l.description) c.append(h('p', '', l.description));
    c.append(h('p', '', `Check-in ${hhmm(l.check_in)} · Check-out ${hhmm(l.check_out)}`));
    const rooms = (l.rooms ?? []) as Row[], ul = h('ul', 'o-items');
    for (const r of rooms) ul.append(h('li', '', `Room ${r.room_number} · ${r.room_type} · ${r.max_guests} guests · ${peso(r.rate)}/night · ${r.status}`));
    if (!rooms.length) ul.append(h('li', 'muted', 'No rooms added.'));
    c.append(h('h4', '', 'Rooms'), ul, h('h4', '', 'Amenities'), h('p', '', (l.amenities ?? []).length ? (l.amenities as string[]).join(', ') : 'None selected.'));
    if (problems.length) { const w = h('ul', 'a-problems'); for (const p of problems) w.append(h('li', '', p)); c.append(h('h4', '', 'Blocks approval'), w); }
    const reason = document.createElement('input'); reason.placeholder = 'Reason (required to reject)'; reason.maxLength = 300; reason.setAttribute('aria-label', 'Rejection reason');
    const ok = h('button', 'primary', 'Approve') as HTMLButtonElement, no = h('button', 'quiet', 'Reject') as HTMLButtonElement; ok.type = no.type = 'button';
    ok.disabled = problems.length > 0; ok.title = problems.length ? 'Fix the listed problems first, or reject with a reason.' : '';
    ok.addEventListener('click', () => void decide(l, true, '', [ok, no]));
    no.addEventListener('click', () => void decide(l, false, reason.value, [ok, no]));
    const acts = h('div', 'a-acts'); acts.append(reason, ok, no); c.append(acts);
    return c;
  }

  async function refresh() {
    const x = await db.rpc('admin_pending_listings', { p_type: 'hotel' });
    if (x.error) return fail(x.error);
    const rows = (x.data ?? []) as Row[], box = $('a-list');
    $('a-count').textContent = rows.length ? `(${rows.length})` : '';
    box.replaceChildren(...(rows.length ? rows.map(card) : [h('p', 'muted', 'Nothing is waiting for review.')]));
    void loadNotifications(client, $('a-notes'));
  }
  window.addEventListener('hashchange', () => { if (location.hash === '#/admin') void refresh(); });
  return { refresh };
}
