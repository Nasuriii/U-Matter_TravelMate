import type { SupabaseClient } from '@supabase/supabase-js';
type Row = Record<string, any>;
const $ = (id: string) => document.getElementById(id)!;
const one = (v: any) => (Array.isArray(v) ? v[0] : v);
function mk(tag: string, cls: string, text?: string) { const e = document.createElement(tag); e.className = cls; if (text !== undefined) e.textContent = text; return e; }

/** Fills the public landing sections from Supabase. Every query uses the public tm_read policies, so it also works for guests. */
export function loadLanding(client: SupabaseClient) {
  const db = client.schema('public');
  const head = (t: string) => db.from(t).select('*', { count: 'exact', head: true });
  const setStat = (id: string, n: number | null | undefined) => { $(id).textContent = n == null ? '–' : n.toLocaleString(); };

  void (async () => {
    const [d, h, r] = await Promise.all([
      head('destinations').eq('is_active', 1),
      head('business_listings').eq('listing_type', 'hotel'),
      head('business_listings').eq('listing_type', 'restaurant'),
    ]);
    if (d.error && h.error && r.error) return;
    setStat('st-dest', d.count); setStat('st-stay', h.count); setStat('st-eat', r.count);
    $('stats').hidden = false;
  })();

  async function listings(type: string, gridId: string, sectionId: string, label: string) {
    const { data, error } = await db.from('business_listings')
      .select('id,name,description,address,destinations(name,province)').eq('listing_type', type).order('name').limit(6);
    if (error || !data?.length) return;
    const grid = $(gridId); grid.replaceChildren();
    for (const l of data as Row[]) {
      const dest = one(l.destinations), card = mk('article', 'l-card');
      const art = mk('div', 'l-art', label); art.setAttribute('aria-hidden', 'true');
      const body = mk('div', 'l-body');
      body.append(mk('p', 'eyebrow', dest ? `${dest.name} · ${dest.province}` : label), mk('h3', '', l.name),
        mk('p', 'l-desc', l.description || l.address || 'Details coming soon.'));
      card.append(art, body); grid.append(card);
    }
    $(sectionId).hidden = false;
  }
  void listings('hotel', 'stay-grid', 'stay', 'Hotel');
  void listings('restaurant', 'eat-grid', 'eat', 'Restaurant');

  void (async () => {
    const { data, error } = await db.from('reviews')
      .select('rating,review_text,destinations(name),business_listings(name)').order('created_at', { ascending: false }).limit(100);
    if (error || !data?.length) return;
    const rows = data as Row[];
    setStat('st-rate', null); $('st-rate').textContent = (rows.reduce((s, r) => s + r.rating, 0) / rows.length).toFixed(1) + '★';
    $('stats').hidden = false;
    const grid = $('review-grid'); grid.replaceChildren();
    for (const r of rows.filter(x => (x.review_text || '').length > 20).slice(0, 3)) {
      const card = mk('blockquote', 'r-card'), place = one(r.business_listings)?.name || one(r.destinations)?.name || 'TravelMate';
      card.append(mk('p', 'stars', '★'.repeat(r.rating) + '☆'.repeat(5 - r.rating)), mk('p', '', r.review_text), mk('footer', '', `About ${place}`));
      grid.append(card);
    }
    if (grid.children.length) $('reviews').hidden = false;
  })();
}
