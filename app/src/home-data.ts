import type { SupabaseClient } from '@supabase/supabase-js';
type Row = Record<string, any>;
const $ = (id: string) => document.getElementById(id)!;
const one = (v: any) => (Array.isArray(v) ? v[0] : v);
const peso = (n: any) => (n == null ? '—' : '₱' + Number(n).toLocaleString());
function mk(tag: string, cls: string, text?: string) { const e = document.createElement(tag); e.className = cls; if (text !== undefined) e.textContent = text; return e; }
const BUCKET_FALLBACK = 'travelmate-listings';
let wired = false;

/** Landing page: live numbers + latest reviews (public read policies, works for guests). */
export function loadLanding(client: SupabaseClient) {
  const db = client.schema('public');
  const head = (t: string) => db.from(t).select('*', { count: 'exact', head: true });
  const setStat = (id: string, n: number | null | undefined) => { $(id).textContent = n == null ? '–' : n.toLocaleString(); };
  void (async () => {
    const [d, h, r] = await Promise.all([head('destinations').eq('is_active', 1), head('business_listings').eq('listing_type', 'hotel'), head('business_listings').eq('listing_type', 'restaurant')]);
    if (d.error && h.error && r.error) return;
    setStat('st-dest', d.count); setStat('st-stay', h.count); setStat('st-eat', r.count); $('stats').hidden = false;
  })();
  void (async () => {
    const { data, error } = await db.from('reviews').select('rating,review_text,destinations(name),business_listings(name)').order('created_at', { ascending: false }).limit(100);
    if (error || !data?.length) return;
    const rows = data as Row[];
    $('st-rate').textContent = (rows.reduce((s, r) => s + r.rating, 0) / rows.length).toFixed(1) + '★'; $('stats').hidden = false;
    const grid = $('review-grid'); grid.replaceChildren();
    for (const r of rows.filter(x => (x.review_text || '').length > 20).slice(0, 3)) {
      const card = mk('blockquote', 'r-card'), place = one(r.business_listings)?.name || one(r.destinations)?.name || 'TravelMate';
      card.append(mk('p', 'stars', '★'.repeat(r.rating) + '☆'.repeat(5 - r.rating)), mk('p', '', r.review_text), mk('footer', '', `About ${place}`));
      grid.append(card);
    }
    if (grid.children.length) $('reviews').hidden = false;
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
    const { data } = await db.from('photos').select('listing_id,bucket_id,object_path').in('listing_id', ids).eq('status', 'approved').order('sort_order');
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
  async function openDetail(l: Row) {
    body.replaceChildren(mk('p', 'eyebrow', l.listing_type), mk('h2', '', l.name), mk('p', 'muted', l.address || ''), mk('p', '', l.description || ''));
    dlg.showModal();
    if (l.listing_type === 'hotel') {
      const [h, r] = await Promise.all([db.from('hotels').select('check_in_time,check_out_time').eq('hotel_id', l.id).maybeSingle(), db.from('rooms').select('room_type,max_guests,base_nightly_rate,operational_status').eq('hotel_id', l.id)]);
      if (h.data) body.append(mk('p', '', `Check-in ${String(h.data.check_in_time ?? '—').slice(0, 5)} · Check-out ${String(h.data.check_out_time ?? '—').slice(0, 5)}`));
      body.append(list('Rooms', (r.data ?? []).map((x: Row) => `${x.room_type} · up to ${x.max_guests} guests · ${peso(x.base_nightly_rate)}/night · ${x.operational_status}`)));
    } else if (l.listing_type === 'restaurant') {
      const [h, m] = await Promise.all([db.from('restaurants').select('operating_hours,reservation_fee').eq('restaurant_id', l.id).maybeSingle(), db.from('menu_items').select('name,category,price,is_available').eq('restaurant_id', l.id).order('category')]);
      if (h.data) body.append(mk('p', '', `Hours: ${h.data.operating_hours ?? '—'} · Reservation fee ${peso(h.data.reservation_fee)}`));
      body.append(list('Menu', (m.data ?? []).filter((x: Row) => x.is_available).map((x: Row) => `${x.name}${x.category ? ' (' + x.category + ')' : ''} — ${peso(x.price)}`)));
    } else {
      const [a, s] = await Promise.all([db.from('attractions').select('entrance_fee').eq('attraction_id', l.id).maybeSingle(), db.from('attraction_schedules').select('operating_day,schedule_text').eq('attraction_id', l.id)]);
      if (a.data) body.append(mk('p', '', `Entrance fee ${peso(a.data.entrance_fee)}`));
      body.append(list('Schedule', (s.data ?? []).map((x: Row) => `${x.operating_day}: ${x.schedule_text}`)));
    }
  }
  async function listings(type: string, gridId: string, label: string) {
    const grid = $(gridId);
    const { data, error } = await db.from('business_listings').select('id,name,description,address,listing_type,destinations(name,province)').eq('listing_type', type).order('name').limit(48);
    if (error) { grid.replaceChildren(mk('p', 'muted', 'Could not load listings: ' + error.message)); return; }
    if (!data?.length) { grid.replaceChildren(mk('p', 'muted', 'No approved listings yet.')); return; }
    const photos = await photoUrls((data as Row[]).map(l => l.id)); grid.replaceChildren();
    for (const l of data as Row[]) {
      const dest = one(l.destinations), card = mk('button', 'l-card l-click'); (card as HTMLButtonElement).type = 'button';
      const art = mk('div', 'l-art', label), url = photos.get(l.id);
      if (url) { const img = document.createElement('img'); img.alt = ''; img.loading = 'lazy'; img.src = url; img.onerror = () => img.remove(); art.append(img); }
      const b = mk('div', 'l-body');
      b.append(mk('p', 'eyebrow', dest ? `${dest.name} · ${dest.province}` : label), mk('h3', '', l.name), mk('p', 'l-desc', l.description || l.address || 'Details coming soon.'), mk('span', 'l-more', 'View details →'));
      card.append(art, b); card.addEventListener('click', () => void openDetail(l)); grid.append(card);
    }
  }
  void listings('hotel', 'stay-grid', 'Hotel'); void listings('restaurant', 'eat-grid', 'Restaurant');
}
