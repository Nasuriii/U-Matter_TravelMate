import { confirmAction } from './action-confirm';
import {labelAction,actionIcon} from './listing-action-menu';
import type { SupabaseClient } from '@supabase/supabase-js';
import { loadNotifications } from './notifications';
import { tidy, toast } from './ui';
import { listingPage, listingRange } from './listing-pagination';
import { renderListingPagination } from './listing-pagination-ui';
type Row = Record<string, any>;
const $ = (id: string) => document.getElementById(id)!;
const peso = (n: any) => (n == null ? '—' : '₱' + Number(n).toLocaleString());
const hhmm = (t: any) => (t ? String(t).slice(0, 5) : '—');
const LABEL: Record<string, string> = { hotel: 'Hotel', restaurant: 'Restaurant', attraction: 'Attraction' };
function h(tag: string, cls = '', text = '') { const e = document.createElement(tag); if (cls) e.className = cls; if (text) e.textContent = text; return e; }
function list(items: string[], empty: string) { const ul = h('ul', 'o-items'); for (const t of items) ul.append(h('li', '', t)); if (!items.length) ul.append(h('li', 'muted', empty)); return ul; }

/**
 * Administrator review of business listings (Business Processes 3, 4, 5).
 * Reads go through admin_review_queue() / admin_reviewed_listings(), writes through admin_decide_listing();
 * all three check the admin role in the database (database/09 and 10), so hiding this page is only a convenience.
 */
export function initAdmin(client: SupabaseClient) {
  const db = client.schema('public');
  let readiness='all', currentPage = 1;
  let queue: Row[] = [], filter = 'all', search = '', refreshVersion = 0;
  const say = (m: string, err = false) => { const n = $('a-notice'); n.textContent = m; n.classList.toggle('error', err); if(m&&!m.endsWith('…'))toast(m,err); };
  const fail = (e: any) => say(/admin_review_queue|admin_reviewed_listings|admin_review_listing|PGRST202/i.test(String(e?.message) + String(e?.code))
    ? 'Listing reviews are temporarily unavailable. Please refresh or contact your administrator.'
    : (e?.message ?? String(e)), true);

  let deciding = false;
  async function decide(l: Row, approve: boolean, reason: string, buttons: HTMLButtonElement[]) {
    if (deciding) return;
    if (!approve && !reason.trim()) return say('Write a reason so the owner knows what to fix.', true);
    say('');
    deciding = true;
    const disabled = buttons.map(b => b.disabled);
    buttons.forEach(b => (b.disabled = true));
    try {
      if (!await confirmAction(approve ? 'Approve listing?' : 'Reject listing?',
        approve ? `Approve “${l.name}”? It will become visible to travelers and the owner will be notified.`
          : `Reject “${l.name}”? It stays hidden. The owner will receive this reason: ${reason.trim()}`,
        approve ? 'Approve listing' : 'Reject listing')) return;
      const x = await db.rpc('admin_decide_listing', { p_listing: l.id, p_approve: approve, p_reason: approve ? null : reason.trim(), p_expected_updated_at: l.submitted });
      if (x.error) { say(x.error.code === 'PGRST202' ? 'Listing reviews are temporarily unavailable. Please contact your administrator.' : x.error.message, true); await refresh(); return; }
      say(approve ? `“${l.name}” approved. The owner has been notified.` : `“${l.name}” rejected. The owner has been notified.`);
      await refresh();
    } catch (e) { fail(e); } finally {
      buttons.forEach((b, i) => (b.disabled = disabled[i])); deciding = false;
    }
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
    box.append(h('p', 'muted', 'Loading photos…'));
    const x = await db.rpc('admin_listing_photos', { p_listing: id });
    box.replaceChildren();
    if (x.error) { box.append(h('p', 'muted', 'Photos unavailable. Close and reopen the details to try again.')); return false; }
    const rows = (x.data ?? []) as Row[]; if (!rows.length) { box.append(h('p', 'muted', 'No photos uploaded.')); return; }
    for (const p of rows) {
      const img = document.createElement('img'); img.alt = 'Business listing photo'; img.loading = 'lazy'; box.append(img);
      void client.storage.from('travelmate-listings').createSignedUrl(p.object_path, 3600).then(s => { if (s.data) img.src = s.data.signedUrl; else img.alt = 'Photo could not be loaded'; });
    }
  }
  function card(l: Row) {
    const c = h('article', 'a-card'), problems = (l.problems ?? []) as string[];
    const top = h('div', 'a-card-top');
    const readinessBadge=h('span',problems.length?'a-readiness a-needs':'a-readiness a-ready');labelAction(readinessBadge,problems.length?'alert':'check',problems.length?'Needs attention':'Ready for approval');top.append(h('span','a-type',LABEL[l.type]??String(l.type)),readinessBadge);
    c.append(top, h('h3', '', l.name), h('p', 'a-location', l.destination || 'Destination not provided'));
    const review = document.createElement('details'); review.className = 'a-review-expanded';
    const reviewSummary = h('summary', '', 'Review listing'); reviewSummary.setAttribute('aria-label', 'Review ' + l.name); review.append(reviewSummary);
    labelAction(reviewSummary,'eye','Review listing');reviewSummary.append(actionIcon('more'));
    const reviewBody = h('div', 'a-review-body'); review.append(reviewBody);
    reviewBody.append(h('p', '', l.address || 'No address'), h('p', 'a-owner', `Submitted by ${l.owner ?? '—'}${l.owner_email ? ' · ' + l.owner_email : ''}`));
    if (problems.length) { const panel = h('div', 'a-blockers'), w = h('ul', 'a-problems'); for (const p of problems) w.append(h('li', '', p)); panel.append(h('strong', '', 'Changes needed before approval'), w); reviewBody.append(panel); }
    const disclosure = document.createElement('details'), content = h('div', 'a-detail-content'); disclosure.className = 'a-details';
    const detailSummary=h('summary');labelAction(detailSummary,'eye','View listing details & photos');detailSummary.append(actionIcon('more'));disclosure.append(detailSummary, content);
    if (l.description) content.append(h('p', 'a-description', l.description));
    details(content, l);
    const contacts=h('div');content.append(contacts);const photos = h('div'); content.append(photos); let photosLoaded = false;
    disclosure.addEventListener('toggle', () => { if (disclosure.open && !photosLoaded) { photosLoaded = true; contacts.replaceChildren(h('h4','','Public contact details'),h('p','muted','Loading contact details…'));void db.rpc('admin_listing_contact',{p_listing:l.id}).then(r=>{contacts.replaceChildren(h('h4','','Public contact details'));if(r.error){contacts.append(h('p','muted','Contact details could not be loaded. Refresh the queue before approving.'));return;}const values=r.data??{};for(const [key,label] of [['phone','Phone'],['email','Email'],['website','Website']])contacts.append(h('p','',label+': '+(values[key]||'Not provided')));});photos.replaceChildren(); void photoStrip(photos, l.id).then(result => { if (result === false) photosLoaded = false; }); } });
    reviewBody.append(disclosure);
    const reason = document.createElement('textarea'); reason.id = `a-reason-${l.id}`; reason.placeholder = 'Explain what the owner needs to fix…'; reason.maxLength = 300; reason.rows = 2;
    const reasonLabel = h('label', '', 'Reason for rejection'); reasonLabel.setAttribute('for', reason.id);
    const rejectPanel = document.createElement('details'); rejectPanel.className = 'a-reject-panel';const rejectSummary=h('summary');labelAction(rejectSummary,'alert','Request corrections');rejectSummary.append(actionIcon('more'));rejectPanel.append(rejectSummary, reasonLabel, reason, h('small', '', 'Required to reject · up to 300 characters. The owner will receive this reason.'));
    const ok = h('button', 'primary', 'Approve listing') as HTMLButtonElement, no = h('button', 'quiet a-reject-button', 'Reject listing') as HTMLButtonElement; ok.type = no.type = 'button';
    labelAction(ok,'check','Approve listing');labelAction(no,'alert','Reject listing');
    ok.disabled = problems.length > 0; ok.title = problems.length ? 'Fix the listed problems first, or reject with a reason.' : '';
    ok.addEventListener('click', () => void decide(l, true, '', [ok, no]));
    no.addEventListener('click', () => { if (!reason.value.trim()) { reason.setAttribute('aria-invalid', 'true'); reason.focus(); } void decide(l, false, reason.value, [ok, no]); });
    reason.addEventListener('input', () => reason.removeAttribute('aria-invalid'));
    rejectPanel.append(no);
    const acts = h('div', 'a-acts'); acts.append(h('small', '', problems.length ? 'Resolve the issues above before approving.' : 'Approval makes this listing visible to travelers.'), ok); reviewBody.append(acts, rejectPanel); c.append(review);
    return c;
  }

  function renderQueue() {
    const count = (t: string) => (t === 'all' ? queue.length : queue.filter(l => l.type === t).length);
    document.querySelectorAll<HTMLButtonElement>('#a-filter button').forEach(b => {
      const t = b.dataset.type!, base = b.textContent!.replace(/ \(\d+\)$/, '');
      b.textContent = count(t) ? `${base} (${count(t)})` : base;
      b.className = t === filter ? 'primary' : 'quiet'; b.setAttribute('aria-pressed', String(t === filter));
    });
    document.querySelectorAll<HTMLButtonElement>('[data-readiness]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.readiness===readiness)));
    const rows = queue.filter(l => (readiness==='all'||(readiness==='ready'?!(l.problems??[]).length:(l.problems??[]).length>0)) && (filter === 'all' || l.type === filter) && (!search || [l.name, l.destination, l.address, l.owner, l.owner_email].some(value => String(value ?? '').toLowerCase().includes(search))));
    $('a-total').textContent = String(queue.length);
    $('a-ready').textContent = String(queue.filter(l => !(l.problems ?? []).length).length);
    $('a-blocked').textContent = String(queue.filter(l => (l.problems ?? []).length).length);
    const page = listingPage(rows, currentPage); currentPage = page.page;
    $('a-results').textContent = listingRange(page);
    renderListingPagination($('a-pagination'), page, 'review queue', next => { currentPage = next; renderQueue(); });
    $('a-count').textContent = queue.length ? `(${queue.length})` : '';
    const empty = h('div', 'a-empty'); empty.append(h('strong', '', queue.length ? 'No matching listings' : 'You’re all caught up'), h('p', '', queue.length ? 'Try a different search or listing type.' : 'New submissions will appear here when owners send them for review.'));
    $('a-list').replaceChildren(...(rows.length ? page.items.map(card) : [empty]));
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
    if(location.hash.split('?')[0]==='#/admin'){const query=new URLSearchParams(location.hash.split('?')[1]).get('search');if(query!==null){search=query.slice(0,120).trim().toLowerCase();($('a-search') as HTMLInputElement).value=query.slice(0,120);filter='all';readiness='all';currentPage=1;}}
    const version = ++refreshVersion, button = $('a-refresh') as HTMLButtonElement; button.disabled = true; button.textContent = 'Refreshing…';
    try {
      const [x, y] = await Promise.all([db.rpc('admin_review_queue'), db.rpc('admin_reviewed_listings', { p_limit: 15 })]);
      if (version !== refreshVersion) return;
      if (x.error) { fail(x.error); $('a-list').replaceChildren(h('p', 'muted', 'Could not load the review queue. Use Refresh queue to try again.')); } else { queue = (x.data ?? []) as Row[]; renderQueue(); }
      if (y.error) $('a-history').replaceChildren(h('p', 'muted', 'Recent decisions could not be loaded. Please refresh to try again.')); else renderHistory((y.data ?? []) as Row[]);
      void loadNotifications(client, $('a-notes'));
    } catch (e) { if (version === refreshVersion) fail(e); } finally { if (version === refreshVersion) { button.disabled = false; labelAction(button,'refresh','Refresh queue'); } }
  }

  document.querySelectorAll<HTMLButtonElement>('#a-filter button').forEach(b => b.addEventListener('click', () => { filter = b.dataset.type!; currentPage = 1; renderQueue(); }));
  document.querySelectorAll<HTMLButtonElement>('[data-readiness]').forEach(b=>b.addEventListener('click',()=>{readiness=b.dataset.readiness!;currentPage=1;renderQueue();$('a-list').scrollIntoView({behavior:'smooth',block:'start'});}));
  $('a-search').addEventListener('input', e => { search = (e.target as HTMLInputElement).value.trim().toLowerCase(); currentPage = 1; renderQueue(); });
  $('a-refresh').addEventListener('click', () => void refresh());
  window.addEventListener('hashchange', () => { if (location.hash.split('?')[0] === '#/admin') void refresh(); });
  return { refresh };
}
