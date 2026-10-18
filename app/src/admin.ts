import { confirmAction } from './action-confirm';
import {labelAction,actionIcon} from './listing-action-menu';
import type { SupabaseClient } from '@supabase/supabase-js';
import { loadNotifications } from './notifications';
import { tidy, toast } from './ui';
import { listingPage, listingRange } from './listing-pagination';
import { renderListingPagination } from './listing-pagination-ui';
import {reservationSlotLabel} from './owner-slot-logic';
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
  let readiness='all', currentPage = 1, notificationOpen=false;
  window.addEventListener('travelmate:notification-open',event=>{notificationOpen=(event as CustomEvent<{path:string}>).detail.path.startsWith('/admin');});
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
    const facts=(values:[string,string][])=>{const dl=h('dl','a-review-facts');for(const [label,value]of values){const item=h('div');item.append(h('dt','',label),h('dd','',value));dl.append(item);}return dl;};
    if (l.type === 'hotel') {
      c.append(facts([['Check-in',hhmm(l.check_in)],['Check-out',hhmm(l.check_out)]]), h('h4', '', 'Rooms'),
        list(((l.rooms ?? []) as Row[]).map(r => `Room ${r.room_number} · ${r.room_type} · ${r.max_guests} guests · ${peso(r.rate)}/night · ${r.status}`), 'No rooms added.'),
        h('h4', '', 'Amenities'), h('p', '', (l.amenities ?? []).length ? (l.amenities as string[]).join(', ') : 'None selected.'));
    } else if (l.type === 'restaurant') {
      const menu=(l.menu??[]) as Row[],inventory=h('ul','a-review-menu');
      for(const item of menu){const row=h('li'),photo=h('div','a-menu-photo'),copy=h('div','a-menu-copy');photo.dataset.menuItem=String(item.id??'');photo.append(h('span','muted',item.has_photo?'Loading dish photo…':'No dish photo'));copy.append(h('h5','',item.name),h('p','a-menu-category',(item.category||'Uncategorized')+' · '+(item.available?'Available':'Unavailable')));if(item.description)copy.append(h('p','',item.description));row.append(photo,copy,h('strong','a-menu-price',peso(item.price)));inventory.append(row);}
      if(!menu.length)inventory.append(h('li','muted','No menu items added.'));
      c.append(facts([['Operating hours',l.operating_hours||'Not provided'],['Reservation fee',peso(l.reservation_fee)]]),h('h4','',`Menu · ${menu.length} ${menu.length===1?'item':'items'}`),inventory,h('h4','','Reservation slots · Philippine time'),list(((l.slots??[]) as Row[]).map(slot=>reservationSlotLabel(slot.starts_at,slot.ends_at)+' · '+slot.capacity+' seats · '+(slot.is_open?'Open':'Closed')),'No upcoming reservation slots.'),h('h4','','Cuisines'),h('p','',(l.cuisines??[]).length?(l.cuisines as string[]).join(', '):'None selected.'));
    } else if (l.type === 'attraction') {
      c.append(h('p', '', `Entrance fee: ${l.entrance_fee == null ? '—' : Number(l.entrance_fee) === 0 ? 'Free' : peso(l.entrance_fee)}`), h('h4', '', 'Operating schedule'),
        list(((l.schedule ?? []) as Row[]).map(s => `${s.day}: ${s.hours}`), 'No operating days added.'));
    }
  }

  function previewPhoto(path:string,label:string){
    const button=h('button','a-photo-preview') as HTMLButtonElement;button.type='button';button.disabled=true;button.setAttribute('aria-label','Enlarge '+label);const img=document.createElement('img');img.alt=label;img.loading='lazy';button.append(img,h('span','','Enlarge photo'));
    void client.storage.from('travelmate-listings').createSignedUrl(path,3600).then(result=>{if(!result.data){button.replaceChildren(h('span','muted','Photo could not be loaded'));return;}img.src=result.data.signedUrl;button.disabled=false;button.onclick=()=>{const dialog=document.createElement('dialog');dialog.className='a-review-photo-dialog';dialog.setAttribute('aria-label',label);const full=document.createElement('img');full.src=img.src;full.alt=label;const close=h('button','quiet','Close photo') as HTMLButtonElement;close.type='button';close.onclick=()=>dialog.close();dialog.append(close,full);dialog.addEventListener('click',event=>{if(event.target===dialog)dialog.close();});dialog.addEventListener('close',()=>dialog.remove(),{once:true});document.body.append(dialog);dialog.showModal();};});return button;
  }

  async function photoStrip(c: HTMLElement, id: string,menuRoot:HTMLElement) {
    const box = h('div', 'a-photos'); c.append(h('h4', '', 'Business photos'), box);
    box.append(h('p', 'muted', 'Loading photos…'));
    const x = await db.rpc('admin_listing_photos', { p_listing: id });
    box.replaceChildren();
    if (x.error) { box.append(h('p', 'muted', 'Photos unavailable. Close and reopen the details to try again.')); return false; }
    const rows = (x.data ?? []) as Row[]; if (!rows.length) { box.append(h('p', 'muted', 'No photos uploaded.')); return; }
    for (const p of rows) {const target=p.menu_item_id?Array.from(menuRoot.querySelectorAll<HTMLElement>('[data-menu-item]')).find(node=>node.dataset.menuItem===p.menu_item_id):undefined;const photo=previewPhoto(p.object_path,p.menu_name||'Business listing photo');if(target)target.replaceChildren(photo);else if(!p.menu_item_id)box.append(photo);}
    if(!box.children.length)box.append(h('p','muted','No separate business photos. Dish photos are shown with the menu above.'));
  }
  function card(l: Row) {
    const c = h('article', 'a-card'), problems = (l.problems ?? []) as string[];c.dataset.listingName=l.name;
    const top = h('div', 'a-card-top');
    const readinessBadge=h('span',problems.length?'a-readiness a-needs':'a-readiness a-ready');labelAction(readinessBadge,problems.length?'alert':'check',problems.length?'Needs attention':'Ready for approval');top.append(h('span','a-type',LABEL[l.type]??String(l.type)),readinessBadge);
    c.append(top, h('h3', '', l.name), h('p', 'a-location', l.destination || 'Destination not provided'));
    const review = document.createElement('details'); review.className = 'a-review-expanded';
    const reviewSummary = h('summary', '', 'Review listing'); reviewSummary.setAttribute('aria-label', 'Review ' + l.name); review.append(reviewSummary);
    labelAction(reviewSummary,'eye','Review listing');reviewSummary.append(actionIcon('more'));
    const reviewBody = h('div', 'a-review-body'); review.append(reviewBody);
    reviewBody.append(h('p', '', l.address || 'No address'), h('p', 'a-owner', `Submitted by ${l.owner ?? '—'}${l.owner_email ? ' · ' + l.owner_email : ''}`));
    if (problems.length) { const panel = h('div', 'a-blockers'), w = h('ul', 'a-problems'); for (const p of problems) w.append(h('li', '', p)); panel.append(h('strong', '', 'Changes needed before approval'), w); reviewBody.append(panel); }
    const disclosure = h('section','a-details'), content = h('div', 'a-detail-content');disclosure.append(h('h4','a-review-section-title','Business details'),content);
    if (l.description) content.append(h('p', 'a-description', l.description));
    details(content, l);
    const contacts=h('div','a-review-section');content.append(contacts);const photos = h('div','a-review-section'); content.append(photos); let photosLoaded = false;
    review.addEventListener('toggle', () => { if (review.open && !photosLoaded) { photosLoaded = true; contacts.replaceChildren(h('h4','','Public contact details'),h('p','muted','Loading contact details…'));void db.rpc('admin_listing_contact',{p_listing:l.id}).then(r=>{contacts.replaceChildren(h('h4','','Public contact details'));if(r.error){contacts.append(h('p','muted','Contact details could not be loaded. Refresh the queue before approving.'));return;}const values=r.data??{},facts=h('dl','a-review-facts');for(const [key,label]of [['phone','Phone'],['email','Email'],['website','Website']]){const item=h('div');item.append(h('dt','',label),h('dd','',values[key]||'Not provided'));facts.append(item);}contacts.append(facts);});photos.replaceChildren(); void photoStrip(photos, l.id,content).then(result => { if (result === false) photosLoaded = false; }); } });
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
      if(notificationOpen&&location.hash.split('?')[0]==='#/admin'){
        notificationOpen=false;const match=Array.from($('a-list').querySelectorAll<HTMLElement>('[data-listing-name]')).find(node=>node.dataset.listingName?.toLowerCase()===search);
        const target=match??$('a-list');const review=match?.querySelector<HTMLDetailsElement>('.a-review-expanded');if(review)review.open=true;
        target.tabIndex=-1;target.focus({preventScroll:true});target.scrollIntoView({block:'start',behavior:'smooth'});
      }
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
