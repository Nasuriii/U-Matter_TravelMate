import type { SupabaseClient } from '@supabase/supabase-js';
type Row = Record<string, any>;
const $ = (id: string) => document.getElementById(id)!;
const val = (id: string) => ($(id) as HTMLInputElement).value.trim();
const one = (v: any) => (Array.isArray(v) ? v[0] : v);
const peso = (n: any) => (n == null ? '—' : '₱' + Number(n).toLocaleString());
function h(tag: string, cls = '', text = '') { const e = document.createElement(tag); if (cls) e.className = cls; if (text) e.textContent = text; return e; }
const LABEL: Record<string, string> = { pending: 'Awaiting review', approved: 'Live', rejected: 'Rejected', inactive: 'Inactive' };

/** Business-owner dashboard. All writes go through RLS (database/06_owner_listings.sql). */
export function initOwner(client: SupabaseClient) {
  const db = client.schema('public');
  let ownerId: string | null = null, destsLoaded = false, wired = false;
  const say = (m: string, err = false) => { for (const id of ['o-notice', 'o-manage-notice']) { const n = document.getElementById(id); if (n) { n.textContent = m; n.classList.toggle('error', err); } } };
  const fail = (e: any) => say(/owner_[a-z_]+|PGRST202|permission denied|row-level security/i.test(String(e?.message) + String(e?.code))
    ? 'The database is not ready for owners yet. Run database/06_owner_listings.sql and then database/07_owner_actions.sql in the Supabase SQL Editor. (' + (e?.message ?? e) + ')' : (e?.message ?? String(e)), true);

  function addForm(fields: [string, string, string?][], submit: (v: Record<string, string>) => Promise<void>) {
    const f = h('form', 'o-inline') as HTMLFormElement; f.noValidate = true;
    for (const [n, l, t] of fields) { const w = h('label', '', l); const i = document.createElement('input'); i.name = n; i.type = t || 'text'; if (t === 'number') { i.min = '0'; i.step = '0.01'; } w.append(i); f.append(w); }
    const b = h('button', 'primary', 'Add') as HTMLButtonElement; b.type = 'submit'; f.append(b);
    f.addEventListener('submit', async e => {
      e.preventDefault(); const v: Record<string, string> = {};
      for (const [n] of fields) v[n] = (f.elements.namedItem(n) as HTMLInputElement).value.trim();
      try { await submit(v); f.reset(); } catch (x) { fail(x); }
    });
    return f;
  }
  async function children(box: HTMLElement, title: string, table: string, fk: string, id: string, line: (r: Row) => string,
    fields: [string, string, string?][], toRow: (v: Record<string, string>) => Row, addFn: string, delFn: string, delArg: string, editFn: string, extra?: [string, string, [string, string][], (r: Row) => string]) {
    const redo = () => children(box, title, table, fk, id, line, fields, toRow, addFn, delFn, delArg, editFn, extra);
    box.replaceChildren(h('h3', '', title));
    const { data, error } = await db.from(table).select('*').eq(fk, id);
    if (error) return fail(error);
 const editForm = (r: Row) => {
      const f = h('form', 'o-inline') as HTMLFormElement; f.noValidate = true;
      for (const [n, l, t] of fields) { const w = h('label', '', l), i = document.createElement('input'); i.name = n; i.type = t || 'text'; if (t === 'number') { i.min = '0'; i.step = '0.01'; } i.value = r[n] ?? ''; w.append(i); f.append(w); }
      let sel: HTMLSelectElement | null = null;
      if (extra) { const w = h('label', '', extra[1]); sel = document.createElement('select'); for (const [v, t] of extra[2]) sel.append(new Option(t, v)); sel.value = extra[3](r); w.append(sel); f.append(w); }
      const save = h('button', 'primary', 'Save') as HTMLButtonElement, cancel = h('button', 'quiet', 'Cancel') as HTMLButtonElement; save.type = 'submit'; cancel.type = 'button';
      cancel.addEventListener('click', () => void redo()); f.append(save, cancel);
      f.addEventListener('submit', async e => {
        e.preventDefault(); const v: Record<string, string> = {};
        for (const [n] of fields) v[n] = (f.elements.namedItem(n) as HTMLInputElement).value.trim();
        try {
          const args = toRow(v); delete args[Object.keys(args)[0]]; args[delArg] = r.id;
          if (extra && sel) args[extra[0]] = extra[0] === 'p_available' ? Number(sel.value) : sel.value;
          const x = await client.rpc(editFn, args); if (x.error) throw x.error; say('Saved.'); await redo();
        } catch (err) { fail(err); }
      });
      return f;
    };
    const ul = h('ul', 'o-items');
    for (const r of (data ?? []) as Row[]) {
      const li = h('li', '', line(r)), del = h('button', 'quiet', 'Remove'); (del as HTMLButtonElement).type = 'button';
      del.addEventListener('click', async () => { const x = await client.rpc(delFn, { [delArg]: r.id }); if (x.error) return fail(x.error); say('Removed.'); await redo(); });
      const ed = h('button', 'quiet', 'Edit') as HTMLButtonElement; ed.type = 'button';
      ed.addEventListener('click', () => li.replaceChildren(editForm(r)));
      const acts = h('div', 'o-acts'); acts.append(ed, del); li.append(acts); ul.append(li);
    }
    if (!ul.children.length) ul.append(h('li', 'muted', 'Nothing added yet.'));
    box.append(ul, addForm(fields, async v => { const x = await client.rpc(addFn, toRow(v)); if (x.error) throw x.error; say('Saved.'); await redo(); }));
  }
  const money = (s: string, what: string) => { const n = Number(s); if (s === '' || !Number.isFinite(n) || n < 0) throw new Error(`${what} must be 0 or more.`); return n; };

  function manage(l: Row) {
    const box = $('o-manage'); box.hidden = false; box.replaceChildren(h('h2', '', 'Manage: ' + l.name), Object.assign(h('p', 'o-notice'), { id: 'o-manage-notice' }));
    const f = h('form', 'o-inline') as HTMLFormElement; f.noValidate = true;
    const fld = (n: string, label: string, v: string) => { const w = h('label', '', label), i = document.createElement('input'); i.name = n; i.value = v ?? ''; w.append(i); f.append(w); };
    fld('name', 'Name', l.name); fld('address', 'Address', l.address); fld('description', 'Description', l.description);
    const save = h('button', 'primary', 'Save changes') as HTMLButtonElement; save.type = 'submit'; f.append(save);
    f.addEventListener('submit', async e => {
      e.preventDefault(); const g = (n: string) => (f.elements.namedItem(n) as HTMLInputElement).value.trim();
      if (!g('name')) return say('Name is required.', true);
      const x = await client.rpc('owner_update_listing', { p_listing: l.id, p_name: g('name'), p_address: g('address') || null, p_description: g('description') || null });
      if (x.error) return fail(x.error); say('Saved. Edited listings go back to review before travelers see the changes.'); await refresh();
    });
    const sub = h('div', 'o-sub'), dh = h('div', 'o-sub'); box.append(f, dh, sub); void details(dh, l);
    if (l.listing_type === 'restaurant') void children(sub, 'Menu', 'menu_items', 'restaurant_id', l.id, r => `${r.name}${r.category ? ' (' + r.category + ')' : ''} — ${peso(r.price)}${r.is_available ? '' : ' · sold out'}`,
      [['name', 'Dish / drink'], ['category', 'Category (e.g. Mains)'], ['price', 'Price (₱)', 'number'], ['description', 'Description']],
      v => { if (!v.name) throw new Error('Enter a name.'); return { p_restaurant: l.id, p_name: v.name, p_category: v.category || null, p_price: money(v.price, 'Price'), p_description: v.description || null }; }, 'owner_add_menu_item', 'owner_delete_menu_item', 'p_item', 'owner_update_menu_item', ['p_available', 'Availability', [['1', 'Available'], ['0', 'Sold out']], r => String(r.is_available)]);
    else if (l.listing_type === 'hotel') void children(sub, 'Rooms', 'rooms', 'hotel_id', l.id, r => `Room ${r.room_number} · ${r.room_type} · ${r.max_guests} guests · ${peso(r.base_nightly_rate)}/night · ${r.operational_status}`,
      [['room_number', 'Room number'], ['room_type', 'Type (Standard, Deluxe…)'], ['max_guests', 'Max guests', 'number'], ['base_nightly_rate', 'Nightly rate (₱)', 'number']],
      v => { if (!v.room_number || !v.room_type) throw new Error('Room number and type are required.'); const g = Math.floor(money(v.max_guests, 'Max guests')); if (g < 1) throw new Error('Max guests must be at least 1.'); return { p_hotel: l.id, p_room_number: v.room_number, p_room_type: v.room_type, p_max_guests: g, p_rate: money(v.base_nightly_rate, 'Nightly rate') }; }, 'owner_add_room', 'owner_delete_room', 'p_room', 'owner_update_room', ['p_status', 'Status', [['available', 'Available'], ['maintenance', 'Maintenance'], ['unavailable', 'Unavailable']], r => r.operational_status]);
    else void children(sub, 'Operating schedule', 'attraction_schedules', 'attraction_id', l.id, r => `${r.operating_day}: ${r.schedule_text}`,
      [['operating_day', 'Day (e.g. Daily)'], ['schedule_text', 'Time slot']],
      v => { if (!v.operating_day || !v.schedule_text) throw new Error('Day and time slot are required.'); return { p_attraction: l.id, p_day: v.operating_day, p_text: v.schedule_text }; }, 'owner_add_schedule', 'owner_delete_schedule', 'p_schedule', 'owner_update_schedule');
    box.scrollIntoView({ behavior: 'smooth' });
  }

 async function details(box: HTMLElement, l: Row) {
    const t = l.listing_type, tbl = t === 'hotel' ? 'hotels' : t === 'restaurant' ? 'restaurants' : 'attractions', key = t === 'hotel' ? 'hotel_id' : t === 'restaurant' ? 'restaurant_id' : 'attraction_id';
    const { data, error } = await db.from(tbl).select('*').eq(key, l.id).maybeSingle(); if (error) return fail(error);
    const d: Row = data ?? {}, f = h('form', 'o-inline') as HTMLFormElement; f.noValidate = true;
    const fld = (n: string, label: string, v: string, type = 'text') => { const w = h('label', '', label), i = document.createElement('input'); i.name = n; i.type = type; if (type === 'number') { i.min = '0'; i.step = '0.01'; } i.value = v; w.append(i); f.append(w); };
    if (t === 'hotel') { fld('ci', 'Check-in time', String(d.check_in_time ?? '').slice(0, 5), 'time'); fld('co', 'Check-out time', String(d.check_out_time ?? '').slice(0, 5), 'time'); }
    else if (t === 'restaurant') { fld('hours', 'Operating hours', d.operating_hours ?? ''); fld('rf', 'Reservation fee (₱)', String(d.reservation_fee ?? 0), 'number'); }
    else fld('fee', 'Entrance fee (₱)', String(d.entrance_fee ?? ''), 'number');
    const b = h('button', 'primary', 'Save details') as HTMLButtonElement; b.type = 'submit'; f.append(b);
    f.addEventListener('submit', async e => {
      e.preventDefault(); const g = (n: string) => (f.elements.namedItem(n) as HTMLInputElement | null)?.value.trim() ?? '';
      try {
        const x = await client.rpc('owner_update_details', { p_listing: l.id, p_check_in: g('ci') || null, p_check_out: g('co') || null, p_hours: g('hours') || null,
          p_resfee: t === 'restaurant' ? money(g('rf') || '0', 'Reservation fee') : null, p_fee: t === 'attraction' && g('fee') !== '' ? money(g('fee'), 'Entrance fee') : null });
        if (x.error) throw x.error; say('Details saved.');
      } catch (err) { fail(err); }
    });
    box.replaceChildren(h('h3', '', t === 'hotel' ? 'Hotel details' : t === 'restaurant' ? 'Restaurant details' : 'Attraction details'), f);
  }
  async function setStatus(l: Row, status: string, msg: string) {
    const x = await client.rpc('owner_set_listing_status', { p_listing: l.id, p_status: status }); if (x.error) return fail(x.error); say(msg); await refresh();
  }
  function render(rows: Row[]) {
    $('o-total').textContent = String(rows.length);
    $('o-active').textContent = String(rows.filter(r => r.status === 'approved').length);
    $('o-pending').textContent = String(rows.filter(r => r.status === 'pending').length);
    const box = $('o-list'); box.replaceChildren();
    if (!rows.length) { box.append(h('p', 'muted', 'No listings yet. Use the form to add your first one.')); return; }
    for (const l of rows) {
      const row = h('div', 'o-row'), d = one(l.destinations), info = h('div');
      info.append(h('strong', '', l.name), h('span', 'muted', ` ${l.listing_type} · ${d ? d.name : ''}`));
      const badge = h('span', 'status s-' + l.status, LABEL[l.status] ?? l.status), acts = h('div', 'o-acts');
      const m = h('button', 'quiet', 'Manage'); m.addEventListener('click', () => manage(l)); acts.append(m);
      if (l.status === 'inactive' || l.status === 'rejected') { const b = h('button', 'quiet', 'Resubmit'); b.addEventListener('click', () => void setStatus(l, 'pending', 'Resubmitted for review.')); acts.append(b); }
      else { const b = h('button', 'quiet', 'Deactivate'); b.addEventListener('click', () => { if (confirm(`Deactivate "${l.name}"? Travelers will no longer see it.`)) void setStatus(l, 'inactive', 'Listing deactivated.'); }); acts.append(b); }
      row.append(info, badge, acts); box.append(row);
    }
  }
  async function refresh() {
    const o = await db.from('business_owners').select('id').limit(1);
    if (o.error || !o.data?.[0]) { say('No business owner record found for this account.', true); return; }
    ownerId = o.data[0].id;
    if (!destsLoaded) {
      const d = await db.from('destinations').select('id,name,province').eq('is_active', 1).order('name');
      const sel = $('ol-dest') as HTMLSelectElement; sel.replaceChildren(new Option('Choose a destination…', ''));
      for (const x of (d.data ?? []) as Row[]) sel.append(new Option(`${x.name}, ${x.province}`, x.id)); destsLoaded = true;
    }
    const l = await db.from('business_listings').select('id,name,listing_type,status,description,address,destinations(name,province)').eq('owner_id', ownerId).order('created_at', { ascending: false });
    if (l.error) return fail(l.error);
    render((l.data ?? []) as Row[]);
  }
  function wire() {
    if (wired) return; wired = true;
    const typeSel = $('ol-type') as HTMLSelectElement;
    const sync = () => document.querySelectorAll<HTMLElement>('#ol-form [data-type]').forEach(n => { n.hidden = n.dataset.type !== typeSel.value; });
    typeSel.addEventListener('change', sync); sync();
    $('ol-form').addEventListener('submit', async e => {
      e.preventDefault(); const type = typeSel.value;
      try {
        if (!val('ol-name')) throw new Error('Enter the business name.');
        if (!val('ol-dest')) throw new Error('Choose a destination.');
        const fee = val('ol-fee') === '' ? null : money(val('ol-fee'), 'Entrance fee');
        const resfee = type === 'restaurant' ? money(val('ol-resfee') || '0', 'Reservation fee') : 0;
        say('Submitting…');
        const x = await client.rpc('owner_create_listing', { p_type: type, p_destination: val('ol-dest'), p_name: val('ol-name'), p_description: val('ol-desc') || null, p_address: val('ol-address') || null,
          p_check_in: val('ol-checkin') || null, p_check_out: val('ol-checkout') || null, p_operating_hours: val('ol-hours') || null, p_reservation_fee: resfee,
          p_entrance_fee: type === 'attraction' ? fee : null, p_schedule_day: val('ol-day') || null, p_schedule_text: val('ol-slot') || null });
        if (x.error) throw x.error;
        ($('ol-form') as HTMLFormElement).reset(); sync(); say('Listing submitted. It will appear to travelers once an administrator approves it.'); await refresh();
      } catch (err) { fail(err); }
    });
    window.addEventListener('hashchange', () => { if (location.hash === '#/owner') void refresh(); });
  }
  return { refresh: () => { wire(); return refresh(); } };
}
