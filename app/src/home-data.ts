import {mountSavedHeart,isSaved} from './experience/favorites';
import {samplePhoto} from './sample-photos';
import { catalogLabel, isPreview } from './catalog-label';
import type { SupabaseClient } from '@supabase/supabase-js';
import { navigate } from './experience/state';
type Row = Record<string, any>;
const $ = (id: string) => document.getElementById(id)!;
const one = (v: any) => (Array.isArray(v) ? v[0] : v);
const peso = (n: any) => (n == null ? '—' : '₱' + Number(n).toLocaleString());
function menuList(items: Row[], urls: Map<string, string>) {
  const box = mk('div', 'd-sec'); box.append(mk('h3', '', 'Menu'));
  if (!items.length) { box.append(mk('p', 'muted', 'Nothing listed yet.')); return box; }
  const ul = mk('ul', 'd-menu');
  for (const x of items) {
    const li = mk('li', ''), u = urls.get(x.id);
    if (u) { const i = document.createElement('img'); i.src = u; i.alt = ''; i.loading = 'lazy'; i.onerror = () => i.remove(); li.append(i); }
    const t = mk('div', 'dm-text'); t.append(mk('strong', '', x.name)); if (x.category) t.append(mk('span', 'muted', x.category)); t.append(mk('span', 'dm-price', peso(x.price)));
    li.append(t); ul.append(li);
  }
  box.append(ul); return box;
}
function mk(tag: string, cls: string, text?: string) { const e = document.createElement(tag); e.className = cls; if (text !== undefined) e.textContent = text; return e; }
const BUCKET_FALLBACK = 'travelmate-listings';
let wired = false;const browseCleanups=new Map<string,()=>void>();

/** Landing page: live numbers + latest reviews (public read policies, works for guests). */
export function loadLanding(client: SupabaseClient) {
  const db = client.schema('public');
  const head = (t: string) => db.from(t).select('*', { count: 'exact', head: true });
  const setStat = (id: string, n: number | null | undefined) => { $(id).textContent = n == null ? '–' : n.toLocaleString(); };
  void (async () => {
    const [d, h, r] = await Promise.all([head('destinations').eq('is_active', 1), head('business_listings').eq('status','approved').eq('listing_type', 'hotel'), head('business_listings').eq('status','approved').eq('listing_type', 'restaurant')]);
    if (d.error && h.error && r.error) return;
    setStat('st-dest', d.count); setStat('st-stay', h.count); setStat('st-eat', r.count); setStat('hm-dest', d.count); setStat('hm-stay', h.count); setStat('hm-eat', r.count); $('stats').hidden = false;
  })();
  void (async () => {
    const { data, error } = await db.rpc('recent_traveler_reviews');
    if (error || !data?.length) return;
    const rows = data as Row[];
    $('st-rate').textContent = (rows.reduce((s, r) => s + r.rating, 0) / rows.length).toFixed(1) + '★'; $('hm-rate').textContent = (rows.reduce((s, r) => s + r.rating, 0) / rows.length).toFixed(1); $('stats').hidden = false;
    const grid = $('review-grid'); grid.replaceChildren();
    for (const r of rows.filter(x => (x.review_text || '').length > 20).slice(0, 3)) {
      const card = mk('blockquote', 'r-card'), place = one(r.business_listings)?.name || one(r.destinations)?.name || 'TravelMate';
      card.append(mk('p', 'stars', '★'.repeat(r.rating) + '☆'.repeat(5 - r.rating)), mk('p', '', r.review_text), mk('footer', '', `About ${place}`));
      grid.append(card);
    }
    if (grid.children.length) $('reviews').hidden = false;
    const hg = $('home-review-grid'), rating = $('home-review-rating') as HTMLSelectElement;
    const renderReviews = () => {
      const matched = rows.filter(r => r.review_text && (rating.value === 'all' || Number(r.rating) === Number(rating.value))).slice(0,6);
      hg.replaceChildren();
      for(const r of matched){const card=mk('blockquote','r-card');card.append(mk('p','stars',`${r.rating} / 5 stars`),mk('p','',r.review_text),mk('footer','',`About ${one(r.business_listings)?.name || one(r.destinations)?.name || 'TravelMate'}`));hg.append(card);}
      if(!matched.length)hg.append(mk('p','empty','No recent reviews match this rating.'));
    };
    rating.onchange=renderReviews;renderReviews();$('home-reviews').hidden=false;
  })();
}

/** Stay / Eat pages (signed-in): approved listings with photos and a details popup. */
export function loadBrowse(client: SupabaseClient) {
  const db = client.schema('public');
  const dlg = $('listing-dialog') as HTMLDialogElement, body = $('listing-detail');
  if (!wired) { wired = true; $('close-listing').addEventListener('click', () => dlg.close()); dlg.addEventListener('click', e => { if (e.target === dlg) dlg.close(); }); }

  async function photoUrls(ids: string[]) {
    const out = new Map<string, string>();
    if (!ids.length) return out;
    let q: { data: any } = await db.from('photos').select('listing_id,bucket_id,object_path').in('listing_id', ids).eq('status', 'approved').is('menu_item_id', null).order('sort_order');
    if ((q as any).error) q = await db.from('photos').select('listing_id,bucket_id,object_path').in('listing_id', ids).eq('status', 'approved').order('sort_order'); // 14 not run yet
    const data = q.data;
    for (const p of (data ?? []) as Row[]) {
      if (out.has(p.listing_id)) continue;
      const signed = await client.storage.from(p.bucket_id || BUCKET_FALLBACK).createSignedUrl(p.object_path, 3600);
      out.set(p.listing_id, signed.data?.signedUrl || client.storage.from(p.bucket_id || BUCKET_FALLBACK).getPublicUrl(p.object_path).data.publicUrl);
    }
    return out;
  }
  function list(title: string, rows: string[]) {
    const box = mk('div', 'd-sec'); box.append(mk('h3', '', title));
    if (!rows.length) box.append(mk('p', 'muted', 'Nothing listed yet.'));
    else { const ul = mk('ul', 'd-list'); rows.forEach(r => ul.append(mk('li', '', r))); box.append(ul); }
    return box;
  }
  async function allPhotos(id: string) {
    let q: { data: any } = await db.from('photos').select('bucket_id,object_path').eq('listing_id', id).eq('status', 'approved').is('menu_item_id', null).order('sort_order');
    if ((q as any).error) q = await db.from('photos').select('bucket_id,object_path').eq('listing_id', id).eq('status', 'approved').order('sort_order');
    const data = q.data;
    const urls: string[] = [];
    for (const p of (data ?? []) as Row[]) { const s = await client.storage.from(p.bucket_id || BUCKET_FALLBACK).createSignedUrl(p.object_path, 3600); if (s.data?.signedUrl) urls.push(s.data.signedUrl); }
    return urls;
  }
  async function openDetail(l: Row) {
    body.replaceChildren(mk('p', 'eyebrow', l.listing_type), mk('h2', '', l.name), mk('p', 'muted', l.address || ''), mk('p', '', l.description || ''));
    dlg.showModal();
    const gal = mk('div', 'd-gallery'); body.append(gal);
    void allPhotos(l.id).then(us => us.forEach(u => { const i = document.createElement('img'); i.src = u; i.alt = ''; i.loading = 'lazy'; i.onerror = () => i.remove(); gal.append(i); }));
    if (l.listing_type === 'hotel') {
      const [h, r] = await Promise.all([db.from('hotels').select('check_in_time,check_out_time').eq('hotel_id', l.id).maybeSingle(), db.from('rooms').select('room_type,max_guests,base_nightly_rate,operational_status').eq('hotel_id', l.id)]);
      if (h.data) body.append(mk('p', '', `Check-in ${String(h.data.check_in_time ?? '—').slice(0, 5)} · Check-out ${String(h.data.check_out_time ?? '—').slice(0, 5)}`));
      body.append(list('Rooms', (r.data ?? []).map((x: Row) => `${x.room_type} · up to ${x.max_guests} guests · ${peso(x.base_nightly_rate)}/night · ${x.operational_status}`)));
      const am = await db.from('hotel_amenities').select('amenities(name)').eq('hotel_id', l.id);
      const amNames = ((am.data ?? []) as Row[]).map(x => one(x.amenities)?.name).filter(Boolean) as string[];
      if (amNames.length) body.append(list('Amenities', amNames));
    } else if (l.listing_type === 'restaurant') {
      const [h, m] = await Promise.all([db.from('restaurants').select('operating_hours,reservation_fee').eq('restaurant_id', l.id).maybeSingle(), db.from('menu_items').select('id,name,category,price,is_available').eq('restaurant_id', l.id).order('category')]);
      if (h.data) body.append(mk('p', '', `Hours: ${h.data.operating_hours ?? '—'} · Reservation fee ${peso(h.data.reservation_fee)}`));
      const cu = await db.from('restaurant_cuisines').select('cuisines(name)').eq('restaurant_id', l.id);
      const cuNames = ((cu.data ?? []) as Row[]).map(x => one(x.cuisines)?.name).filter(Boolean) as string[];
      if (cuNames.length) body.append(mk('p', '', 'Cuisine: ' + cuNames.join(', ')));
      const dp = await db.from('photos').select('menu_item_id,object_path').eq('listing_id', l.id).eq('status', 'approved').not('menu_item_id', 'is', null);
      const dishUrl = new Map<string, string>();
      if (!dp.error) await Promise.all(((dp.data ?? []) as Row[]).map(async p => { const s2 = await client.storage.from(BUCKET_FALLBACK).createSignedUrl(p.object_path, 3600); if (s2.data?.signedUrl) dishUrl.set(p.menu_item_id, s2.data.signedUrl); }));
      body.append(menuList(((m.data ?? []) as Row[]).filter(x => x.is_available), dishUrl));
    } else {
      const [a, s] = await Promise.all([db.from('attractions').select('entrance_fee').eq('attraction_id', l.id).maybeSingle(), db.from('attraction_schedules').select('operating_day,schedule_text').eq('attraction_id', l.id)]);
      if (a.data) body.append(mk('p', '', `Entrance fee ${peso(a.data.entrance_fee)}`));
      body.append(list('Schedule', (s.data ?? []).map((x: Row) => `${x.operating_day}: ${x.schedule_text}`)));
    }
  }
  async function listings(type: string, gridId: string, label: string) {
    const grid = $(gridId);browseCleanups.get(gridId)?.();const disposers:(()=>void)[]=[];
    const { data, error } = await db.from('business_listings').select('id,name,is_sample,description,address,listing_type,destinations(name,province)').eq('status', 'approved').eq('listing_type', type).order('name').limit(200);
    if (error) { grid.replaceChildren(mk('p', 'muted', 'Could not load listings: ' + error.message)); return; }
    if (!data?.length) { grid.replaceChildren(mk('p', 'muted', 'No approved listings yet.')); return; }
    const photos = await photoUrls((data as Row[]).map(l => l.id)); grid.replaceChildren();
    const cards: { node: HTMLElement; name: string; search: string }[] = [];
    for (const l of data as Row[]) {
      const dest = one(l.destinations), card = mk('article', 'l-card l-click');
      const art = mk('div', 'l-art', label), url = (l.is_sample||isPreview(l.name))?samplePhoto(type,l.id):photos.get(l.id);
      if (url) { const img = document.createElement('img'); img.alt = ''; img.loading = 'lazy'; img.src = url; img.onerror = () => img.remove(); art.append(img); }
      const b = mk('div', 'l-body');
      b.append(mk('p', 'eyebrow', dest ? `${dest.name} · ${dest.province}` : label), mk('h3', '', catalogLabel(l.name)), mk('p', 'l-desc', l.description || l.address || 'Details coming soon.'), mk('span', 'l-more', 'View details →'));
      if(isPreview(l.name))b.append(mk('span','tm-pill','Preview listing'));
      const heart=mk('div','tm-react');art.append(heart);disposers.push(mountSavedHeart(heart,l.id,catalogLabel(l.name)));card.append(art,b);card.addEventListener('click',e=>{if(!(e.target as HTMLElement).closest('.tm-save-position'))navigate('/listing/'+l.id);});card.dataset.listing=l.id;card.dataset.destination=dest?.name??''; cards.push({node:card,name:l.name,search:[l.name,l.address,dest?.name,dest?.province].join(' ').toLowerCase()});
    }
    const prefix = gridId.replace('-grid','');
    const search = $(prefix+'-search') as HTMLInputElement, sort = $(prefix+'-sort') as HTMLSelectElement;
    const region=mk('select','tm-location-filter') as HTMLSelectElement;region.setAttribute('aria-label','Filter by destination');const all=mk('option','','All destinations') as HTMLOptionElement;all.value='';region.append(all);[...new Set(cards.map(c=>c.node.dataset.destination).filter(Boolean))].sort().forEach(name=>{const option=mk('option','',name) as HTMLOptionElement;option.value=name!;region.append(option);});const saved=mk('button','tm-saved-filter','♡ Saved only') as HTMLButtonElement;saved.type='button';saved.setAttribute('aria-pressed','false');const filters=mk('div','tm-browse-extra');filters.append(region,saved);grid.before(filters);let onlySaved=false;
    const render = () => {
      const query=search.value.trim().toLowerCase(); const matched=cards.filter(c=>c.search.includes(query)&&(!region.value||c.node.dataset.destination===region.value)&&(!onlySaved||isSaved(c.node.dataset.listing!))).sort((a,b)=>a.name.localeCompare(b.name)*(sort.value==='za'?-1:1));
      grid.replaceChildren(...matched.map(c=>c.node));
      if(!matched.length)grid.append(mk('p','empty','No places match. Try another name or destination.'));
      $(prefix+'-results').textContent=`${matched.length} matching places · ${cards.length} loaded${cards.length===200?' (first 200 by name)':''}`;
    };
    search.oninput=render;sort.onchange=render;region.onchange=render;saved.onclick=()=>{onlySaved=!onlySaved;saved.setAttribute('aria-pressed',String(onlySaved));render();};window.addEventListener('travelmate:favorites',render);browseCleanups.set(gridId,()=>{window.removeEventListener('travelmate:favorites',render);filters.remove();disposers.forEach(fn=>fn());});render();
  }
  void listings('hotel', 'stay-grid', 'Hotel'); void listings('restaurant', 'eat-grid', 'Restaurant'); void listings('attraction', 'attr-grid', 'Attraction');
}
