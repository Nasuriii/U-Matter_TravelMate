import {catalogLabel} from './catalog-label';
import {mountOwnerListingPickers,mountOwnerDetailTimes,mountOwnerSlotTimes} from './trip-pickers';
import {reservationSlotInput,reservationSlotLabel} from './owner-slot-logic';
import {ownerWorkspaceDialog,markOwnerFormSaved} from './owner-workspace-dialog';
import {saveOwnerChanges} from './owner-save-batch';
import {installPlacePreviews,placePreviewAttributes,clearPlacePreviewCache} from './place-hover-preview';
import {ownerListingDraft} from './owner-listing-draft';
import {listingActionMenu,labelAction,type ActionIcon} from './listing-action-menu';
import { confirmAction } from './action-confirm';
import type { SupabaseClient } from '@supabase/supabase-js';
import { loadNotifications } from './notifications';
import { accordion, checkImage, filePicker, tidy, toast, IMAGE_TYPES } from './ui';
import { listingPage, listingRange } from './listing-pagination';
import { renderListingPagination } from './listing-pagination-ui';
type Row = Record<string, any>;
const $ = (id: string) => document.getElementById(id)!;
const val = (id: string) => ($(id) as HTMLInputElement).value.trim();
const one = (v: any) => (Array.isArray(v) ? v[0] : v);
const peso = (n: any) => (n == null ? '—' : '₱' + Number(n).toLocaleString());
function h(tag: string, cls = '', text = '') { const e = document.createElement(tag); if (cls) e.className = cls; if (text) e.textContent = text; return e; }
/** Plain-language help for hotel owners (shown in the Add form and in Hotel details). */
const t12 = (t: string) => { const [H, M] = t.split(':').map(Number); return `${((H + 11) % 12) + 1}:${String(M).padStart(2, '0')} ${H >= 12 ? 'PM' : 'AM'}`; };
const mins = (t: string) => Number(t.slice(0, 2)) * 60 + Number(t.slice(3, 5));
function timeHint(ci: string, co: string): { text: string; ok: boolean } {
  if (!ci && !co) return { text: 'Pick both times to see what travelers will be told.', ok: true };
  if (!ci || !co) return { text: 'Pick the other time too.', ok: true };
  if (co >= ci) return { text: `Check-out (${t12(co)}) must be earlier on the clock than check-in (${t12(ci)}), because check-out happens the next morning. Example: check-in 2:00 PM, check-out 11:00 AM.`, ok: false };
  const gap = mins(ci) - mins(co), gh = Math.floor(gap / 60), gm = gap % 60;
  return { text: `Guests can arrive from ${t12(ci)} and must leave by ${t12(co)} on the day they depart. You have ${gh ? gh + ' h' : ''}${gh && gm ? ' ' : ''}${gm ? gm + ' min' : ''} to clean between check-out and the next check-in.`, ok: true };
}
function applyHint(p: HTMLElement, ci: string, co: string) { const r = timeHint(ci, co); p.textContent = r.text; p.classList.toggle('bad', !r.ok); }
function timeGuide(): HTMLElement {
  const d = document.createElement('details'); d.className = 'o-guide';
  d.innerHTML = `<summary>Guide: how check-in and check-out times work</summary>
<ul><li><strong>Check-in time</strong> is the earliest time a guest can get their room, for example <em>2:00 PM</em>.</li>
<li><strong>Check-out time</strong> is the time guests must leave on the morning they depart, for example <em>11:00 AM</em>.</li>
<li>TravelMate needs the check-out time to be <strong>earlier on the clock</strong> than the check-in time. The gap between them is your cleaning window.</li>
<li><strong>Example:</strong> a guest books 2 nights and arrives Monday at 2:00 PM. They leave Wednesday by 11:00 AM.</li></ul>
<table><thead><tr><th>Hotel style</th><th>Check-in</th><th>Check-out</th></tr></thead><tbody>
<tr><td>Standard hotel</td><td>2:00 PM</td><td>11:00 AM</td></tr><tr><td>Resort</td><td>3:00 PM</td><td>12:00 PM (noon)</td></tr><tr><td>Budget stay</td><td>12:00 PM</td><td>10:00 AM</td></tr></tbody></table>
<p>Travelers see these times on your listing. Changing them later sends the hotel back to the administrator for approval. Early arrival or late departure is arranged with you directly.</p>
<p>Restaurants and attractions do not use check-in or check-out. They use operating hours and schedules instead.</p>
<p class="muted">If your hotel works differently (for example check-in 7:00 AM and check-out 7:00 PM the next day), tell your administrator. This rule does not allow it yet.</p>`;
  return d;
}
const LABEL: Record<string, string> = { pending: 'Awaiting review', approved: 'Live', rejected: 'Needs changes', inactive: 'Inactive' };
const TYPES: Record<string, string> = { hotel: 'Hotel', restaurant: 'Restaurant', attraction: 'Attraction' };
const TYPE_PATHS: Record<string, string> = { hotel: '<path d="M3 18v-7h18v7M3 15h18M5 11V6h14v5M7 8h3M14 8h3M3 18v3M21 18v3"/>', restaurant: '<path d="M5 3v7a3 3 0 0 0 6 0V3M8 3v18M19 3c-3 2-4 5-4 9h4M19 3v18"/>', attraction: '<circle cx="12" cy="12" r="9"/><path d="m16 8-3 5-5 3 3-5 5-3Z"/>' };

/** Business-owner dashboard. All writes go through RLS (database/06_owner_listings.sql). */
export function initOwner(client: SupabaseClient) {
  installPlacePreviews();
  const db = client.schema('public');
  const confirmChange = async (title: string, message: string, label: string) => { const user=activeUser,epoch=ownerEpoch; return await confirmAction(title,message,label) && user!==null && user===activeUser && epoch===ownerEpoch; };
  let ownerId: string | null = null, destsLoaded = false, wired = false;
  let createWorkspace:ReturnType<typeof ownerWorkspaceDialog>|null=null,manageWorkspace:ReturnType<typeof ownerWorkspaceDialog>|null=null;
  let draft:ReturnType<typeof ownerListingDraft>|null=null,createdListingId:string|null=null;
  let slotTimesCleanup:(()=>void)|null=null;
  let after: (() => void) | null = null; // re-checks the hotel checklist after a save
  const say = (m: string, err = false) => { m = tidy(m); for (const id of ['o-notice', 'o-manage-notice']) { const n = document.getElementById(id); if (n) { n.textContent = m; n.classList.toggle('error', err); } } if (m && !/…$/.test(m)) toast(m, err); };
  const failBase = (e: any) => say(/owner_[a-z_]+|PGRST202|permission denied|row-level security/i.test(String(e?.message) + String(e?.code))
    ? 'The database is not ready for owners yet. Run database/06 to 11 in the Supabase SQL Editor, in order. (' + (e?.message ?? e) + ')' : (e?.message ?? String(e)), true);

  const dupText = (m: string) => /tm_listing_name_unique/.test(m) ? 'A listing with this name and type already exists in this destination. Choose a different name or open the existing listing.'
    : /tm_menu_item_name_unique/.test(m) ? 'That dish or drink is already on this menu.' : /tm_schedule_unique/.test(m) ? 'That schedule row already exists.' : '';
  const fail = (e: any) => { const d = dupText(String(e?.message ?? '')); return d ? say(d, true) : failBase(e); };

  type FormSave={label:string;prepare:()=>()=>Promise<void>;confirm:()=>Promise<boolean>;success:string;afterSave?:()=>Promise<void>;changed?:()=>boolean};
  const formSaves=new WeakMap<HTMLFormElement,FormSave>();
  async function saveForms(forms:HTMLFormElement[],all=false){
    const workspace=manageWorkspace;if(!workspace||workspace.busy)return;
    if(!forms.length){say('All changes are already saved.');return;}
    const user=activeUser,epoch=ownerEpoch,stillOwner=()=>user!==null&&user===activeUser&&epoch===ownerEpoch;
    let current=forms[0],completed=0;workspace.setBusy(true);
    try{
      const jobs=forms.map(form=>{const action=formSaves.get(form)!;return {
        prepare:()=>{current=form;if(!form.checkValidity())throw new Error('Check the highlighted fields before saving.');const save=action.prepare();return async()=>{current=form;await save();};},
        saved:()=>{markOwnerFormSaved(form);completed++;},afterSave:action.afterSave
      };});
      const saved=await saveOwnerChanges(jobs,all?()=>confirmChange('Save all business changes?',forms.map(form=>'• '+formSaves.get(form)!.label).join('\n')+'\n\nChanges to a live listing may return it to administrator review.','Save all changes'):formSaves.get(forms[0])!.confirm,stillOwner);
      if(saved&&stillOwner())say(all?'All changes saved.':formSaves.get(forms[0])!.success);
    }catch(error){
      if(stillOwner()){workspace.setBusy(false);workspace.reveal(current);current.reportValidity();fail(completed?new Error(`${completed===forms.length?'Your changes were saved, but the editor could not refresh.':`${completed} ${completed===1?'section was':'sections were'} saved. Remaining edits are still here.`} ${(error as Error).message??String(error)}`):error);}
    }finally{workspace.setBusy(false);}
  }
  function bindSave(form:HTMLFormElement,action:FormSave){
    formSaves.set(form,action);form.addEventListener('submit',event=>{event.preventDefault();void saveForms([form]);});
  }
  function saveAllChanges(){
    const forms=Array.from($('o-manage').querySelectorAll('form')).filter(form=>{const action=formSaves.get(form);return action&&(manageWorkspace?.hasChanges(form)||action.changed?.());});
    return saveForms(forms,true);
  }

  function addForm(fields: [string, string, string?][], prepare: (v: Record<string, string>, file: File | null) => ()=>Promise<void>, withPhoto = false,afterSave?:()=>Promise<void>) {
    const f = h('form', 'o-inline') as HTMLFormElement; f.noValidate = true;
    for (const [n, l, t] of fields) { const w = h('label', '', l); const i = document.createElement('input'); i.name = n; i.type = t || 'text'; if (t === 'number') { i.min = '0'; i.step = '0.01'; } w.append(i); f.append(w); }
    const pick = withPhoto ? filePicker() : null;
    if (pick) { const w = h('div', 'o-wide'); w.append(h('span', 'lbl', 'Dish photo (required)'), pick.el); f.append(w); }
    const b = h('button', 'primary', 'Add') as HTMLButtonElement; b.type = 'submit'; f.append(b);
    const values=()=>Object.fromEntries(fields.map(([name])=>[name,(f.elements.namedItem(name) as HTMLInputElement).value.trim()]));
    bindSave(f,{label:withPhoto?'New menu item':'New room / schedule',prepare:()=>{const file=pick?.file()??null;if(withPhoto&&!file)throw new Error('Choose a photo for this dish before saving.');if(file){const bad=checkImage(file);if(bad)throw new Error(bad);}const save=prepare(values(),file);return async()=>{await save();f.reset();pick?.clear();};},confirm:()=>confirmChange('Add this information?',fields.map(([n,l])=>`${l}: ${values()[n]||'Not set'}`).join('\n')+(pick?.file()?`\nPhoto: ${pick.file()!.name}`:''),'Add information'),success:'Saved.',changed:()=>!!pick?.file(),afterSave});
    return f;
  }
  async function children(box: HTMLElement, title: string, table: string, fk: string, id: string, line: (r: Row) => string,
    fields: [string, string, string?][], toRow: (v: Record<string, string>) => Row, addFn: string, delFn: string, delArg: string, editFn: string, extra?: [string, string, [string, string][], (r: Row) => string]) {
    const redo = () => children(box, title, table, fk, id, line, fields, toRow, addFn, delFn, delArg, editFn, extra);
    const isMenu = extra?.[0] === 'p_available';
    box.replaceChildren(h('h3', '', title));
    const { data, error } = await db.from(table).select('*').eq(fk, id);
    if (error) return fail(error);
    const dish = new Map<string, { path: string; status: string }>();
    if (isMenu) { const dp = await client.rpc('owner_list_dish_photos', { p_listing: id }); if (!dp.error) for (const p of (dp.data ?? []) as Row[]) dish.set(p.menu_item_id, { path: p.object_path, status: p.status }); }
    const sign = (path: string, then: (url: string | null) => void) => void client.storage.from(BUCKET).createSignedUrl(path, 3600).then(s => then(s.data?.signedUrl ?? null));
    const editForm = (r: Row) => {
      const f = h('form', 'o-inline') as HTMLFormElement; f.noValidate = true;
      for (const [n, l, t] of fields) { const w = h('label', '', l), i = document.createElement('input'); i.name = n; i.type = t || 'text'; if (t === 'number') { i.min = '0'; i.step = '0.01'; } i.value = r[n] ?? ''; w.append(i); f.append(w); }
      let sel: HTMLSelectElement | null = null;
      if (extra) { const w = h('label', '', extra[1]); sel = document.createElement('select'); for (const [v, t] of extra[2]) sel.append(new Option(t, v)); sel.value = extra[3](r); w.append(sel); f.append(w); }
      const cur = dish.get(r.id), pick = isMenu ? filePicker() : null;let hasPhoto=!!cur;
      if (pick) { const w = h('div', 'o-wide'); w.append(h('span', 'lbl', 'Photo'), pick.el); f.append(w); if (cur) sign(cur.path, u => pick.setCurrent(u)); }
      const save = h('button', 'primary', 'Save') as HTMLButtonElement, cancel = h('button', 'quiet', 'Cancel') as HTMLButtonElement; save.type = 'submit'; cancel.type = 'button';
      cancel.addEventListener('click', () => void redo()); f.append(save, cancel);
      const values=()=>Object.fromEntries(fields.map(([name])=>[name,(f.elements.namedItem(name) as HTMLInputElement).value.trim()]));
      bindSave(f,{label:title+': '+(r.name??r.room_number??r.operating_day),prepare:()=>{const v=values();
          const args = toRow(v); delete args[Object.keys(args)[0]]; args[delArg] = r.id;
          if (extra && sel) args[extra[0]] = extra[0] === 'p_available' ? Number(sel.value) : sel.value;
          const file=pick?.file(),removed=pick?.removed();if(isMenu&&!file&&(!hasPhoto||removed))throw new Error('Each menu item needs a dish photo. Choose a replacement before saving.');if(file){const bad=checkImage(file);if(bad)throw new Error(bad);}
          return async()=>{const x=await client.rpc(editFn,args);if(x.error)throw x.error;if(file){const path=await saveDish(id,r.id,file);hasPhoto=true;pick?.clear();sign(path,url=>pick?.setCurrent(url));}};
        },confirm:()=>confirmChange('Save these changes?',fields.map(([n,l])=>`${l}: ${values()[n]||'Not set'}`).join('\n')+(extra&&sel?`\n${extra[1]}: ${sel.selectedOptions[0].text}`:''),'Save changes'),success:'Saved.',changed:()=>!!pick?.file()||!!pick?.removed(),afterSave:redo});
      return f;
    };
    const ul = h('ul', 'o-items tm-owner-inventory');
    for (const r of (data ?? []) as Row[]) {
      const li = h('li'), cur = dish.get(r.id);
      if (isMenu) { const th = h('span', 'o-thumb' + (cur ? '' : ' empty')); if (cur) { const img = document.createElement('img'); img.alt = ''; th.append(img); sign(cur.path, u => { if (u) img.src = u; }); } li.append(th); }
      li.append(h('span', 'o-line', line(r)));
      if (cur?.status === 'pending') li.append(h('span', 'status s-pending', 'Photo awaiting review'));
      const del = h('button', 'quiet', 'Remove') as HTMLButtonElement; del.type = 'button';
      del.addEventListener('click', async () => {
        if(!await confirmChange('Remove this item?',line(r)+'\nThis removes the item from your listing.','Remove item'))return;
        if (isMenu && cur) { try { await dropDish(r.id); } catch { /* the delete below still removes the row */ } }
        const x = await client.rpc(delFn, { [delArg]: r.id }); if (x.error) return fail(x.error); say('Removed.'); await redo();
      });
      const ed = h('button', 'quiet', 'Edit') as HTMLButtonElement; ed.type = 'button';
      ed.addEventListener('click', () => li.replaceChildren(editForm(r)));
      const acts = h('div', 'o-acts');
      if (isMenu) {
        const soldOut = !r.is_available, t = h('button', 'quiet', soldOut ? 'Back in stock' : 'Mark sold out') as HTMLButtonElement; t.type = 'button';
        t.addEventListener('click', async () => {
          if(!await confirmChange(soldOut?'Make this item available?':'Mark this item sold out?',r.name,soldOut?'Make available':'Mark sold out'))return;
          const x = await client.rpc(editFn, { p_item: r.id, p_name: r.name, p_category: r.category, p_price: r.price, p_description: r.description, p_available: soldOut ? 1 : 0 });
          if (x.error) return fail(x.error); say(soldOut ? 'Back in stock. Travelers can see this dish again.' : 'Marked sold out. Travelers no longer see this dish.'); await redo();
        });
        acts.append(t);
      }
      acts.append(ed, del); li.append(acts); ul.append(li);
    }
    if (!ul.children.length) ul.append(h('li', 'muted', 'Nothing added yet.'));
    let addedItemId:string|null=null;
    const editor=h('section','tm-owner-item-editor');editor.append(h('h4','',isMenu?'Add a menu item':table==='rooms'?'Add a room':'Add a schedule'));
    editor.append(addForm(fields, (v,file)=>{const args=toRow(v);return async()=>{
      if(addedItemId){const update={...args};delete update[Object.keys(update)[0]];update[delArg]=addedItemId;if(extra)update[extra[0]]=extra[0]==='p_available'?Number(extra[2][0][0]):extra[2][0][0];const r=await client.rpc(editFn,update);if(r.error)throw r.error;}
      else{const x=await client.rpc(addFn,args);if(x.error)throw x.error;addedItemId=x.data?String(x.data):null;}
      if(isMenu&&file){if(!addedItemId)throw new Error('The dish was created without a reference. Reopen the menu to add its photo.');await saveDish(id,addedItemId,file);}
      addedItemId=null;
    };},isMenu,redo));box.append(ul,editor);
  }
  const money = (s: string, what: string) => { const n = Number(s); if (s === '' || !Number.isFinite(n) || n < 0) throw new Error(`${what} must be 0 or more.`); return n; };

  function manage(l: Row) {
    slotTimesCleanup?.();slotTimesCleanup=null;
    const box = $('o-manage'); box.hidden = false; box.replaceChildren(h('h2', '', 'Manage: ' + catalogLabel(l.name)), Object.assign(h('p', 'o-notice'), { id: 'o-manage-notice' }));
    const f = h('form', 'o-inline') as HTMLFormElement; f.noValidate = true;
    const fld = (n: string, label: string, v: string) => { const w = h('label', '', label), i = document.createElement('input'); i.name = n; i.value = v ?? ''; w.append(i); f.append(w); };
    fld('name', 'Name', l.name); fld('address', 'Address', l.address); fld('description', 'Description', l.description);
    const save = h('button', 'primary', 'Save changes') as HTMLButtonElement; save.type = 'submit'; f.append(save);
    const g=(n:string)=>(f.elements.namedItem(n) as HTMLInputElement).value.trim();
    bindSave(f,{label:'Basic information',prepare:()=>{if(!g('name'))throw new Error('Name is required.');const args={p_listing:l.id,p_name:g('name'),p_address:g('address')||null,p_description:g('description')||null};return async()=>{const x=await client.rpc('owner_update_listing',args);if(x.error)throw x.error;manageWorkspace?.show('Manage '+catalogLabel(args.p_name));};},confirm:()=>confirmChange('Save listing changes?',`${g('name')}\n${g('address')}\n${g('description')}\nAn edited live listing returns to administrator review.`,'Save changes'),success:l.status==='rejected'?'Saved. This listing is still rejected. Press Resubmit when you are ready to send it for review.':l.status==='inactive'?'Saved. This listing is inactive.':'Saved. Edited listings go back to review before travelers see the changes.',afterSave:refresh});
    const sub = h('div', 'o-sub'), dh = h('div', 'o-sub'), ph = h('div', 'o-sub'); after = null;
    const typeName = l.listing_type === 'hotel' ? 'Hotel' : l.listing_type === 'restaurant' ? 'Restaurant' : 'Attraction';
    const subTitle = l.listing_type === 'hotel' ? 'Rooms' : l.listing_type === 'restaurant' ? 'Menu' : 'Operating schedule';
    if (l.listing_type === 'hotel') { const ck = h('div', 'o-sub'); box.append(ck); after = () => void checklist(ck, l); void checklist(ck, l); }
    const contact=h('form','o-inline') as HTMLFormElement;contact.append(h('p','muted','These contact details will be visible to travelers.'));for(const [key,label,type] of [['contact_phone','Business phone','tel'],['contact_email','Public email','email'],['contact_website','Website','url']]){const wrap=h('label','',label),input=document.createElement('input');input.name=key;input.type=type;input.value=l[key]??'';wrap.append(input);contact.append(wrap);}const contactSave=h('button','primary','Save contact details') as HTMLButtonElement;contactSave.type='submit';contact.append(contactSave);
    bindSave(contact,{label:'Contact details',prepare:()=>{const get=(key:string)=>(contact.elements.namedItem(key) as HTMLInputElement).value.trim();const args={p_listing:l.id,p_phone:get('contact_phone')||null,p_email:get('contact_email')||null,p_website:get('contact_website')||null};return async()=>{const r=await client.rpc('owner_set_listing_contact',args);if(r.error)throw r.error;};},confirm:()=>confirmChange('Save public contact details?',l.name+'\nThese details will be reviewed before publication.','Save contact details'),success:'Contact details saved for review.',afterSave:refresh});box.append(accordion('Contact details',contact));
    box.append(accordion('Basic information', f, { open: true }), accordion(typeName + ' details', dh), accordion(subTitle, sub, { count: '.o-items li:not(.muted)' }));
    if (l.listing_type === 'hotel') { const am = h('div', 'o-sub'); box.append(accordion('Amenities', am, { count: 'input:checked' })); void amenities(am, l); }
    if (l.listing_type === 'restaurant') { const cu = h('div', 'o-sub'); box.append(accordion('Cuisine type', cu, { count: 'input:checked' })); void cuisines(cu, l); }
    if(l.listing_type==='restaurant'){const slots=h('div','o-sub');box.append(accordion('Reservation slots',slots));void reservationSlots(slots,l);}
    box.append(accordion('Photos', ph, { count: '.o-photo' }));
    void details(dh, l); void photos(ph, l);
    if (l.listing_type === 'restaurant') void children(sub, 'Menu', 'menu_items', 'restaurant_id', l.id, r => `${r.name}${r.category ? ' (' + r.category + ')' : ''} — ${peso(r.price)}${r.is_available ? '' : ' · sold out'}`,
      [['name', 'Dish / drink'], ['category', 'Category (e.g. Mains)'], ['price', 'Price (₱)', 'number'], ['description', 'Description']],
      v => { if (!v.name) throw new Error('Enter a name.'); return { p_restaurant: l.id, p_name: v.name, p_category: v.category || null, p_price: money(v.price, 'Price'), p_description: v.description || null }; }, 'owner_add_menu_item', 'owner_delete_menu_item', 'p_item', 'owner_update_menu_item', ['p_available', 'Availability', [['1', 'Available'], ['0', 'Sold out']], r => String(r.is_available)]);
    else if (l.listing_type === 'hotel') void children(sub, 'Rooms', 'rooms', 'hotel_id', l.id, r => `Room ${r.room_number} · ${r.room_type} · ${r.max_guests} guests · ${peso(r.base_nightly_rate)}/night · ${r.operational_status}`,
      [['room_number', 'Room number'], ['room_type', 'Type (Standard, Deluxe…)'], ['max_guests', 'Max guests', 'number'], ['base_nightly_rate', 'Nightly rate (₱)', 'number']],
      v => { if (!v.room_number || !v.room_type) throw new Error('Room number and type are required.'); const g = Math.floor(money(v.max_guests, 'Max guests')); if (g < 1) throw new Error('Max guests must be at least 1.'); const rate = money(v.base_nightly_rate, 'Nightly rate'); if (rate <= 0) throw new Error('Nightly rate must be above 0.'); return { p_hotel: l.id, p_room_number: v.room_number, p_room_type: v.room_type, p_max_guests: g, p_rate: rate }; }, 'owner_add_room', 'owner_delete_room', 'p_room', 'owner_update_room', ['p_status', 'Status', [['available', 'Available'], ['maintenance', 'Maintenance'], ['unavailable', 'Unavailable']], r => r.operational_status]);
    else void children(sub, 'Operating schedule', 'attraction_schedules', 'attraction_id', l.id, r => `${r.operating_day}: ${r.schedule_text}`,
      [['operating_day', 'Day (e.g. Daily)'], ['schedule_text', 'Time slot']],
      v => { if (!v.operating_day || !v.schedule_text) throw new Error('Day and time slot are required.'); return { p_attraction: l.id, p_day: v.operating_day, p_text: v.schedule_text }; }, 'owner_add_schedule', 'owner_delete_schedule', 'p_schedule', 'owner_update_schedule');
    manageWorkspace??=ownerWorkspaceDialog(box,'Manage listing');manageWorkspace.organize();manageWorkspace.configureSaveAll(saveAllChanges);manageWorkspace.configureDraft(()=>Array.from(box.querySelectorAll('form')).some(form=>formSaves.get(form)?.changed?.()),()=>{});manageWorkspace.show('Manage '+catalogLabel(l.name));
  }

  async function reservationSlots(box:HTMLElement,l:Row){
    slotTimesCleanup?.();slotTimesCleanup=null;box.replaceChildren(h('h3','','Reservation slots'),h('p','muted','Add table availability now, including while this listing awaits approval. All dates and times use Philippine time. Travelers can reserve after approval.'));
    const list=h('div','tm-owner-slot-list'),form=h('form','o-inline') as HTMLFormElement;form.noValidate=true;
    const start=document.createElement('input'),end=document.createElement('input'),capacity=document.createElement('input');start.type=end.type='hidden';start.name='start';end.name='end';capacity.name='capacity';capacity.type='number';capacity.min='1';capacity.max='500';capacity.step='1';capacity.defaultValue='20';const label=h('label','','Seat capacity');label.append(capacity);const button=h('button','primary','Add time slot') as HTMLButtonElement;button.type='submit';form.append(start,end,label,button);box.append(list,form);slotTimesCleanup=mountOwnerSlotTimes(form,start,end);
    bindSave(form,{label:'Reservation slots',prepare:()=>{const args={p_listing:l.id,...reservationSlotInput(start.value,end.value,capacity.value)};return async()=>{const result=await client.rpc('owner_add_reservation_slot',args);if(result.error)throw result.error;form.reset();form.dispatchEvent(new Event('input',{bubbles:true}));};},confirm:()=>confirmChange('Add reservation availability?',l.name+'\n'+reservationSlotLabel(reservationSlotInput(start.value,end.value,capacity.value).p_start,reservationSlotInput(start.value,end.value,capacity.value).p_end)+'\n'+capacity.value+' seats','Add time slot'),success:'Reservation slot added.',afterSave:()=>reservationSlots(box,l)});
    const result=await db.from('restaurant_slots').select('id,starts_at,ends_at,capacity,is_open').eq('restaurant_id',l.id).gt('starts_at',new Date().toISOString()).order('starts_at').limit(100);if(!box.isConnected)return;
    if(result.error){list.append(h('p','error','Availability could not be loaded. Reopen this section to retry.'));return;}
    for(const slot of (result.data??[]) as Row[]){const row=h('div','tm-owner-slot-row');row.append(h('strong','',reservationSlotLabel(slot.starts_at,slot.ends_at)),h('span','muted',slot.capacity+' seats · '+(slot.is_open?'Open':'Closed')));list.append(row);}if(!list.children.length)list.append(h('p','muted','No upcoming reservation slots. Add your first time below.'));
  }

 async function details(box: HTMLElement, l: Row) {
    const t = l.listing_type, tbl = t === 'hotel' ? 'hotels' : t === 'restaurant' ? 'restaurants' : 'attractions', key = t === 'hotel' ? 'hotel_id' : t === 'restaurant' ? 'restaurant_id' : 'attraction_id';
    const { data, error } = await db.from(tbl).select('*').eq(key, l.id).maybeSingle(); if (error) return fail(error);
    const d: Row = data ?? {}, f = h('form', 'o-inline') as HTMLFormElement; f.noValidate = true;
    const fld = (n: string, label: string, v: string, type = 'text') => { const w = h('label', '', label), i = document.createElement('input'); i.name = n; i.type = type; if (type === 'number') { i.min = '0'; i.step = '0.01'; } i.value = v; w.append(i); f.append(w); };
    if (t === 'hotel') { fld('ci', 'Check-in time', String(d.check_in_time ?? '').slice(0, 5), 'time'); fld('co', 'Check-out time', String(d.check_out_time ?? '').slice(0, 5), 'time'); }
    else if (t === 'restaurant') { fld('hours', 'Operating hours (required)', d.operating_hours ?? ''); (f.elements.namedItem('hours') as HTMLInputElement).required=true;fld('rf', 'Reservation fee (₱)', String(d.reservation_fee ?? 0), 'number'); }
    else fld('fee', 'Entrance fee (₱)', String(d.entrance_fee ?? ''), 'number');
    const b = h('button', 'primary', 'Save details') as HTMLButtonElement; b.type = 'submit'; f.append(b);
    const g=(n:string)=>(f.elements.namedItem(n) as HTMLInputElement|null)?.value.trim()??'';
    bindSave(f,{label:t==='hotel'?'Hotel details':t==='restaurant'?'Restaurant details':'Attraction details',prepare:()=>{
        if (t === 'hotel') timesOk(g('ci'), g('co'));
        if(t==='restaurant'&&!g('hours'))throw new Error('Enter the restaurant operating hours.');
        const args={p_listing:l.id,p_check_in:g('ci')||null,p_check_out:g('co')||null,p_hours:g('hours')||null,p_resfee:t==='restaurant'?money(g('rf')||'0','Reservation fee'):null,p_fee:t==='attraction'&&g('fee')!==''?money(g('fee'),'Entrance fee'):null};
        return async()=>{const x=await client.rpc('owner_update_details',args);if(x.error)throw x.error;};
      },confirm:()=>confirmChange('Save business details?',`${l.name}\n${t==='hotel'?`Check-in ${g('ci')} · Check-out ${g('co')}`:t==='restaurant'?`Hours: ${g('hours')}\nReservation fee: ₱${g('rf')||0}`:`Entrance fee: ₱${g('fee')||'Not set'}`}`,'Save details'),success:'Details saved.'});
    box.replaceChildren(h('h3', '', t === 'hotel' ? 'Hotel details' : t === 'restaurant' ? 'Restaurant details' : 'Attraction details'), f);
    if (t === 'hotel') {
      const hint = h('p', 'time-hint'), upd = () => applyHint(hint, g0('ci'), g0('co')), g0 = (n: string) => (f.elements.namedItem(n) as HTMLInputElement).value;
      f.addEventListener('input', upd); upd(); box.append(hint, timeGuide());mountOwnerDetailTimes(f);
    }
  }
  /** Hotels turn rooms over, so check-out must be earlier than check-in (e.g. in 14:00, out 11:00). */
  function timesOk(ci: string, co: string) {
    if (!ci || !co) throw new Error('Set both the check-in and check-out time.');
    if (co >= ci) throw new Error('Check-out time must be earlier than check-in time (for example check-in 14:00, check-out 11:00).');
  }
  async function checklist(box: HTMLElement, l: Row) {
    const x = await client.schema('public').rpc('owner_hotel_checklist', { p_hotel: l.id });
    if (x.error) { box.replaceChildren(); return; } // 09 not installed yet: stay quiet, fail() explains on the next save
    const items = (x.data ?? []) as string[];
    box.replaceChildren(h('h3', '', items.length ? 'Before this hotel can be approved' : 'Ready for review'));
    if (!items.length) { box.append(h('p', 'muted', 'Times and rooms look complete. An administrator reviews the listing before travelers see it.')); return; }
    const ul = h('ul', 'a-problems'); for (const t of items) ul.append(h('li', '', t)); box.append(ul);
  }
  async function amenities(box: HTMLElement, l: Row) {
    const x = await client.schema('public').rpc('owner_get_hotel_amenities', { p_hotel: l.id });
    if (x.error) { box.replaceChildren(); return; }
    const list = (x.data ?? []) as Row[], f = h('form', 'o-amen') as HTMLFormElement; f.noValidate = true;
    box.replaceChildren(h('h3', '', 'Amenities'));
    for (const a of list) { const w = h('label'), c = document.createElement('input'); c.type = 'checkbox'; c.value = a.id; c.checked = !!a.selected; w.append(c, document.createTextNode(' ' + a.name)); f.append(w); }
    const b = h('button', 'primary', 'Save amenities') as HTMLButtonElement; b.type = 'submit'; f.append(b);
    bindSave(f,{label:'Amenities',prepare:()=>{const ids=[...f.querySelectorAll<HTMLInputElement>('input:checked')].map(i=>i.value);return async()=>{const r=await client.schema('public').rpc('owner_set_hotel_amenities',{p_hotel:l.id,p_amenities:ids});if(r.error)throw r.error;};},confirm:()=>confirmChange('Update hotel amenities?',`${l.name}\n${f.querySelectorAll('input:checked').length} selected amenities`,'Save amenities'),success:'Saved. Amenities updated.'});
    box.append(f);
  }
  async function cuisines(box: HTMLElement, l: Row) {
    const x = await client.schema('public').rpc('owner_get_restaurant_cuisines', { p_restaurant: l.id });
    if (x.error) { box.replaceChildren(); return; }
    const f = h('form', 'o-amen') as HTMLFormElement; f.noValidate = true; box.replaceChildren(h('h3', '', 'Cuisine type'));
    for (const a of (x.data ?? []) as Row[]) { const w = h('label'), c = document.createElement('input'); c.type = 'checkbox'; c.value = a.id; c.checked = !!a.selected; w.append(c, document.createTextNode(' ' + a.name)); f.append(w); }
    const b = h('button', 'primary', 'Save cuisines') as HTMLButtonElement; b.type = 'submit'; f.append(b);
    bindSave(f,{label:'Cuisine type',prepare:()=>{const ids=[...f.querySelectorAll<HTMLInputElement>('input:checked')].map(i=>i.value);return async()=>{const r=await client.schema('public').rpc('owner_set_restaurant_cuisines',{p_restaurant:l.id,p_cuisines:ids});if(r.error)throw r.error;};},confirm:()=>confirmChange('Update restaurant cuisines?',`${l.name}\n${f.querySelectorAll('input:checked').length} selected cuisines`,'Save cuisines'),success:'Saved. Cuisines updated.'});
    box.append(f);
  }
  const BUCKET = 'travelmate-listings', MAX_PHOTOS = 6, EXT: Record<string, string> = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' };
  async function saveDish(listingId: string, itemId: string, file: File) {
    const bad = checkImage(file); if (bad) throw new Error(bad);
    const uid = (await client.auth.getUser()).data.user?.id; if (!uid) throw new Error('Please log in again.');
    const path = `${uid}/${listingId}/dish-${crypto.randomUUID()}.${IMAGE_TYPES[file.type]}`;
    const up = await client.storage.from(BUCKET).upload(path, file, { contentType: file.type, upsert: false });
    if (up.error) throw new Error('Upload failed: ' + up.error.message);
    const r = await client.rpc('owner_set_dish_photo', { p_item: itemId, p_path: path });
    if (r.error) { await client.storage.from(BUCKET).remove([path]); throw r.error; }
    if (r.data) await client.storage.from(BUCKET).remove([String(r.data)]);
    void refresh();return path;
  }
  async function dropDish(itemId: string) {
    const r = await client.rpc('owner_delete_dish_photo', { p_item: itemId }); if (r.error) throw r.error;
    if (r.data) await client.storage.from(BUCKET).remove([String(r.data)]);
  }
  async function photos(box: HTMLElement, l: Row) {
    const x = await client.rpc('owner_list_photos', { p_listing: l.id });
    if (x.error) { box.replaceChildren(); return fail(x.error); }
    const rows = (x.data ?? []) as Row[], grid = h('div', 'o-photos');
    box.replaceChildren(h('h3', '', 'Photos'), h('p', 'muted', `Up to ${MAX_PHOTOS} photos (JPEG, PNG or WebP, 5 MB each). New photos are reviewed with your listing, and adding one to a live listing sends it back to review.`));
    for (const p of rows) {
      const fig = h('figure', 'o-photo'), img = document.createElement('img'); img.alt = ''; img.loading = 'lazy';
      void client.storage.from(BUCKET).createSignedUrl(p.object_path, 3600).then(s => { if (s.data) img.src = s.data.signedUrl; });
      const del = h('button', 'quiet', 'Remove') as HTMLButtonElement; del.type = 'button';
      del.addEventListener('click', async () => {
        if(!await confirmChange('Remove this listing photo?',l.name+'\nThe photo will be removed from this listing.','Remove photo'))return;
        const r = await client.rpc('owner_delete_photo', { p_photo: p.id }); if (r.error) return fail(r.error);
        if (r.data) await client.storage.from(BUCKET).remove([String(r.data)]); say('Photo removed.'); await photos(box, l);
      });
      fig.append(img, h('figcaption', '', p.status === 'approved' ? 'Live' : 'Awaiting review'), del); grid.append(fig);
    }
    box.append(grid);
    if (rows.length >= MAX_PHOTOS) return;
    const f=h('form','o-inline') as HTMLFormElement,w=h('label','o-wide','Add gallery photos'),input=document.createElement('input'),previews=h('div','o-batch-photos');input.type='file';input.multiple=true;input.accept='image/jpeg,image/png,image/webp';w.append(input,previews);f.append(w);
    const b=h('button','primary','Upload selected photos') as HTMLButtonElement;b.type='submit';f.append(b);let urls:string[]=[];const savedFiles=new Set<File>();
    const cleanup=()=>{urls.forEach(URL.revokeObjectURL);urls=[];};
    input.addEventListener('change',()=>{cleanup();previews.replaceChildren();for(const file of Array.from(input.files??[]).slice(0,MAX_PHOTOS-rows.length)){const img=document.createElement('img');const url=URL.createObjectURL(file);urls.push(url);img.src=url;img.alt=file.name;previews.append(img);}});
    bindSave(f,{label:'Gallery photos',prepare:()=>{const files=Array.from(input.files??[]).filter(file=>!savedFiles.has(file));if(!files.length)throw new Error('Choose photos first.');if(files.length+savedFiles.size+rows.length>MAX_PHOTOS)throw new Error('You can add '+(MAX_PHOTOS-rows.length-savedFiles.size)+' more photos to this gallery.');for(const file of files){const bad=checkImage(file);if(bad)throw new Error(bad);}const epoch=ownerEpoch,user=activeUser;
      return async()=>{const uid=(await client.auth.getUser()).data.user?.id;if(!uid||uid!==user)throw new Error('Please log in again.');for(const file of files){if(activeUser!==user||ownerEpoch!==epoch)throw new Error('Your account changed. Reopen your listing.');const path=uid+'/'+l.id+'/'+crypto.randomUUID()+'.'+EXT[file.type];const up=await client.storage.from(BUCKET).upload(path,file,{contentType:file.type,upsert:false});if(up.error)throw up.error;const row=await client.rpc('owner_add_photo',{p_listing:l.id,p_path:path});if(row.error){await client.storage.from(BUCKET).remove([path]);throw row.error;}savedFiles.add(file);}cleanup();f.reset();previews.replaceChildren();};
    },confirm:()=>confirmChange('Upload these gallery photos?',l.name+'\n'+Array.from(input.files??[]).filter(file=>!savedFiles.has(file)).map(file=>file.name).join('\n')+'\nPhotos require administrator approval.','Upload photos'),success:'Photos saved for approval.',afterSave:async()=>{await photos(box,l);await refresh();}});
    box.append(f);
  }
  let changingStatus = false;
  async function setStatus(l: Row, status: string, msg: string) {
    if (changingStatus) return;
    changingStatus = true;
    try {
      const resubmit = status === 'pending';
      if (!await confirmAction(resubmit ? 'Submit for review?' : 'Deactivate listing?',
        resubmit ? `Submit “${l.name}” for administrator review? It will remain hidden from travelers until approved.`
          : `Deactivate “${l.name}”? It will be hidden from travelers. Existing bookings are not cancelled.`,
        resubmit ? 'Submit for review' : 'Deactivate')) return;
      const x = await client.rpc('owner_transition_listing', { p_listing: l.id, p_status: status, p_expected_updated_at: l.updated_at });
      if (x.error) { say(x.error.code === 'PGRST202' ? 'Run database/19_listing_actions.sql, then reload this page.' : x.error.message, true); await refresh(); return; }
      manageWorkspace?.hide();$('o-manage').hidden = true; say(msg); await refresh();
    } catch (e) { fail(e); } finally { changingStatus = false; }
  }
  let displayedRows: Row[] = [], currentPage = 1, notificationOpen=false;
  window.addEventListener('travelmate:notification-open',event=>{notificationOpen=(event as CustomEvent<{path:string}>).detail.path.startsWith('/owner');});
  let menuCleanups: (()=>void)[]=[];
  function render(rows: Row[]) {
    menuCleanups.forEach(cleanup=>cleanup());menuCleanups=[];
    displayedRows = rows;
    $('o-total').textContent = String(rows.length);
    $('o-active').textContent = String(rows.filter(r => r.status === 'approved').length);
    $('o-pending').textContent = String(rows.filter(r => r.status === 'pending').length);
    const box = $('o-list'); box.replaceChildren();
    const query = ($('o-search') as HTMLInputElement).value.toLowerCase().trim();
    const status = ($('o-status') as HTMLSelectElement).value;
    const type = ($('o-type') as HTMLSelectElement).value;
    const filtered = rows.filter(l => [catalogLabel(l.name), one(l.destinations)?.name].some(value => String(value ?? '').toLowerCase().includes(query)) && (status === 'all' || l.status === status) && (type === 'all' || l.listing_type === type));
    const page = listingPage(filtered, currentPage); currentPage = page.page;
    $('o-results').textContent = listingRange(page);
    document.querySelectorAll<HTMLButtonElement>('[data-listing-status]').forEach(button => button.setAttribute('aria-pressed', String(button.dataset.listingStatus === status)));
    renderListingPagination($('o-pagination'), page, 'my listings', next => { currentPage = next; render(displayedRows); });
    if (!filtered.length) box.append(h('p', 'o-listing-empty', rows.length ? 'No matching listings. Try another search or filter.' : 'Your first listing belongs here. Select Add a listing to get started.'));
    for (const l of page.items) {
      const row = h('article', 'o-row o-listing-row'), d = one(l.destinations), info = h('div', 'o-listing-info'), icon = h('span', 'o-listing-icon type-' + l.listing_type);
      row.dataset.status=l.status;
      icon.setAttribute('aria-hidden', 'true'); icon.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">${TYPE_PATHS[l.listing_type] ?? TYPE_PATHS.attraction}</svg>`;
      info.append(h('strong', '', catalogLabel(l.name)), h('span', 'o-listing-meta', `${TYPES[l.listing_type] ?? l.listing_type} · ${d?.name ?? 'Destination not set'}`));
      if (l.status === 'rejected' && l.rejection_reason) { const reason = document.createElement('details'); reason.className = 'o-listing-reason'; reason.append(h('summary', '', 'View requested changes'), h('p', '', l.rejection_reason)); info.append(reason); }
      const badge = h('span', 'status s-' + l.status, LABEL[l.status] ?? l.status), acts = h('div', 'o-acts');
      const m = h('button', 'quiet o-manage-button', 'Manage'); m.setAttribute('aria-label', 'Manage ' + catalogLabel(l.name)); m.addEventListener('click', () => manage(l)); acts.append(m);
      labelAction(m,'edit','Manage');
      const actions: {label:string;icon:ActionIcon;danger?:boolean;run:()=>void}[]=[];
      if (l.status === 'inactive' || l.status === 'rejected') actions.push({label:'Resubmit for review',icon:'send',run:()=>void setStatus(l,'pending','Resubmitted for review.')});
      else if (l.status === 'approved' || l.status === 'pending') actions.push({label:'Deactivate listing',icon:'power',run:()=>void setStatus(l,'inactive','Listing deactivated.')});
      if (l.status !== 'approved') {
        actions.push({label:'Delete listing',icon:'trash',danger:true,run:()=>{void (async()=>{if(await confirmChange('Delete this listing permanently?',`${l.name}\nIts rooms, menu, schedules and photos are removed too. This cannot be undone.`,'Delete listing'))void removeListing(l);})();}});
      }
      const help: Record<string, string> = { pending: 'Awaiting administrator review. Hidden from travelers.', approved: 'Live: travelers can discover this listing.', rejected: 'Changes requested. Edit your details, then resubmit.', inactive: 'Hidden from travelers. Resubmit when ready to reopen.' };
      badge.title = help[l.status] ?? 'Unknown status. Contact an administrator.';
      if (actions.length) menuCleanups.push(listingActionMenu(acts,catalogLabel(l.name),actions));
      placePreviewAttributes(row,'listing',l.id,catalogLabel(l.name),[d?.name,d?.province].filter(Boolean).join(', '));
      const main = h('div', 'o-listing-main'); main.append(icon, info); row.append(main, badge, acts); box.append(row);
    }
  }
  async function loadDests() {
    if (destsLoaded) return; destsLoaded = true;
    const d = await db.from('destinations').select('id,name,province').eq('is_active', 1).order('name');
    const sel = $('ol-dest') as HTMLSelectElement;
    if (d.error) { destsLoaded = false; sel.replaceChildren(new Option('Could not load destinations. Reload the page.', '')); return; }
    sel.replaceChildren(new Option('Choose a destination…', ''));
    for (const x of (d.data ?? []) as Row[]) sel.append(new Option(`${x.name}, ${x.province}`, x.id));
  }
  async function removeListing(l: Row) {
    const x = await client.rpc('owner_delete_listing', { p_listing: l.id }); if (x.error) return fail(x.error);
    const paths = (x.data ?? []) as string[]; if (paths.length) await client.storage.from('travelmate-listings').remove(paths);
    manageWorkspace?.hide();$('o-manage').hidden = true; say(`"${l.name}" was deleted.`); await refresh();
  }
  let inflight: Promise<void> | null = null;
  const refresh = (): Promise<void> => (inflight ??= refreshNow().finally(() => { inflight = null; }));
  let activeUser: string | null = null, ownerEpoch = 0;
  async function refreshNow() {
    if (!activeUser) return;
    const epoch = ownerEpoch;
    void loadDests();
    if (!ownerId) {
      const o = await db.from('business_owners').select('id').eq('profile_id', activeUser).limit(1);
      if (epoch !== ownerEpoch) return;
      if (o.error || !o.data?.[0]) { say('No business owner record found for this account.', true); return; }
      ownerId = o.data[0].id;
    }
    const cols = 'id,name,is_sample,listing_type,status,updated_at,description,address,contact_phone,contact_email,contact_website,destination_id,destinations(name,province)';
    let l: { data: any; error: any } = await db.from('business_listings').select(cols + ',rejection_reason').eq('owner_id', ownerId).order('created_at', { ascending: false });
    if (l.error && /rejection_reason/.test(String(l.error.message))) l = await db.from('business_listings').select(cols).eq('owner_id', ownerId).order('created_at', { ascending: false }); // 09 not run yet
    if (epoch !== ownerEpoch) return;
    if (l.error) return fail(l.error);
    clearPlacePreviewCache();render((l.data ?? []) as Row[]);
    if(notificationOpen&&location.hash.split('?')[0]==='#/owner'){
      notificationOpen=false;const query=new URLSearchParams(location.hash.split('?')[1]).get('search')?.toLowerCase();
      const match=(l.data as Row[]).find(row=>query&&row.name.toLowerCase()===query);
      if(match)manage(match);else $('o-list').scrollIntoView({block:'center',behavior:'smooth'});
    }
    void loadNotifications(client, $('o-notes'));
  }
  document.querySelectorAll<HTMLButtonElement>('[data-listing-status]').forEach(b=>b.addEventListener('click',()=>{($('o-status') as HTMLSelectElement).value=b.dataset.listingStatus!;($('o-search') as HTMLInputElement).value='';($('o-type') as HTMLSelectElement).value='all';currentPage=1;render(displayedRows);$('o-list').scrollIntoView({behavior:'smooth',block:'start'});}));
  const filterListings = () => { currentPage = 1; render(displayedRows); };
  const incomingFilters=()=>{if(location.hash.split('?')[0]!=='#/owner')return;const params=new URLSearchParams(location.hash.split('?')[1]);if(params.has('search')){($('o-search') as HTMLInputElement).value=(params.get('search')||'').slice(0,120);($('o-status') as HTMLSelectElement).value='all';($('o-type') as HTMLSelectElement).value='all';}if(['all','approved','pending','rejected','inactive'].includes(params.get('status')||''))($('o-status') as HTMLSelectElement).value=params.get('status')!;currentPage=1;};
  $('o-search').addEventListener('input', filterListings);
  $('o-status').addEventListener('change', filterListings);
  $('o-type').addEventListener('change', filterListings);
  function wire() {
    if (wired) return; wired = true;
    const typeSel = $('ol-type') as HTMLSelectElement;
    const form=$('ol-form') as HTMLFormElement;
    const basics=document.createElement('section'),content=document.createElement('div');basics.append(form);content.id='owner-create-workspace';
    createWorkspace=ownerWorkspaceDialog(content,'Add a listing');draft=ownerListingDraft(form,()=>typeSel.value);
    createWorkspace.sections([{label:'Basic information',content:basics},{label:'Rooms / menu / schedules',content:draft.inventory},{label:'Reservation slots',content:draft.slots},{label:'Photos',content:draft.photos}]);
    const submit=$('ol-submit') as HTMLButtonElement;submit.setAttribute('form','ol-form');createWorkspace.footer.append(submit);
    const unlock=()=>form.querySelectorAll<HTMLInputElement|HTMLTextAreaElement|HTMLSelectElement>('input,textarea,select').forEach(field=>field.disabled=false);
    createWorkspace.configureDraft(()=>!!draft?.hasChanges(),()=>{unlock();form.reset();draft?.reset();createdListingId=null;submit.textContent='Create listing';sync();});
    $('o-create-listing').onclick=()=>createWorkspace?.show();
    const sync = () => {document.querySelectorAll<HTMLElement>('#ol-form [data-type]').forEach(n=>{n.hidden=n.dataset.type!==typeSel.value;});($('ol-hours') as HTMLInputElement).required=typeSel.value==='restaurant';if(createWorkspace?.nav.children[1])createWorkspace.nav.children[1].textContent=typeSel.value==='restaurant'?'Menu & dish photos':typeSel.value==='hotel'?'Rooms':'Operating schedules';if(createWorkspace?.nav.children[2])(createWorkspace.nav.children[2] as HTMLElement).hidden=typeSel.value!=='restaurant';};
    typeSel.addEventListener('change', sync); sync();
    mountOwnerListingPickers(form);
    $('ol-guide-slot').append(timeGuide());
    const hint = () => applyHint($('ol-time-hint'), val('ol-checkin'), val('ol-checkout'));
    $('ol-checkin').addEventListener('input', hint); $('ol-checkout').addEventListener('input', hint); hint();
    let submitting = false;
    $('ol-form').addEventListener('submit', async e => {
      e.preventDefault(); if (submitting) return; const type = typeSel.value;
      submitting = true;createWorkspace?.setBusy(true);const epoch=ownerEpoch,user=activeUser;
      try {
        if (!val('ol-name')) throw new Error('Enter the business name.');
        if (!val('ol-dest')) throw new Error('Choose a destination.');
        if (type === 'hotel') timesOk(val('ol-checkin'), val('ol-checkout'));
        if(type==='restaurant'&&!val('ol-hours')){createWorkspace?.reveal($('ol-hours'));throw new Error('Enter the restaurant operating hours before submitting.');}
        try{draft?.validate();}catch(error){if(draft)createWorkspace?.reveal(draft.validationPanel());throw error;}draft?.setBusy(true);form.querySelectorAll<HTMLInputElement|HTMLTextAreaElement|HTMLSelectElement>('input,textarea,select').forEach(field=>field.disabled=true);
        const fee = val('ol-fee') === '' ? null : money(val('ol-fee'), 'Entrance fee');
        const resfee = type === 'restaurant' ? money(val('ol-resfee') || '0', 'Reservation fee') : 0;
        if(!await confirmChange(createdListingId?'Finish this listing?':'Create this business listing?',`${val('ol-name')} · ${type}\n${($('ol-dest') as HTMLSelectElement).selectedOptions[0]?.text}\n${val('ol-address')}\n${val('ol-desc')}\n${draft?.summary()}\nAn administrator will review it before travelers can see it.`,createdListingId?'Finish listing':'Create listing'))return;
        say('Submitting…');
        if(!createdListingId){const x = await client.rpc('owner_create_listing', { p_type: type, p_destination: val('ol-dest'), p_name: val('ol-name'), p_description: val('ol-desc') || null, p_address: val('ol-address') || null,
          p_check_in: val('ol-checkin') || null, p_check_out: val('ol-checkout') || null, p_operating_hours: val('ol-hours') || null, p_reservation_fee: resfee,
          p_entrance_fee: type === 'attraction' ? fee : null, p_schedule_day: val('ol-day') || null, p_schedule_text: val('ol-slot') || null });
        if (x.error) throw x.error;if(epoch!==ownerEpoch||user!==activeUser)return;createdListingId=String(x.data);form.querySelectorAll<HTMLInputElement|HTMLTextAreaElement|HTMLSelectElement>('input,textarea,select').forEach(field=>field.disabled=true);submit.textContent='Finish listing';}
        await draft?.save(client,createdListingId,user!,()=>epoch===ownerEpoch&&user===activeUser);if(epoch!==ownerEpoch||user!==activeUser)return;
        const id=createdListingId,newListing={id,name:val('ol-name'),listing_type:type,destination_id:val('ol-dest'),description:val('ol-desc'),address:val('ol-address'),status:'pending'};
        unlock();form.reset();draft?.reset();createdListingId=null;submit.textContent='Create listing';currentPage=1;sync();createWorkspace?.markSaved(content);createWorkspace?.hide();say('Listing and details saved for review.');await refresh();manage(displayedRows.find(listing=>listing.id===id)??newListing);
      } catch (err) { if(epoch===ownerEpoch&&user===activeUser){fail(err);if(createdListingId){say('Your listing was created. Retry Finish listing to save remaining details and photos; the listing will not be created twice.',true);void refresh();}} } finally { submitting = false;draft?.setBusy(false);if(!createdListingId)unlock();form.dispatchEvent(new Event('input',{bubbles:true}));createWorkspace?.setBusy(false); }
    });
    window.addEventListener('hashchange', () => { if (location.hash.split('?')[0] === '#/owner') {incomingFilters();void refresh();} });
  }
  void loadDests();
  return { setUser(id: string | null) { if (activeUser === id) return;createWorkspace?.hide();manageWorkspace?.hide();draft?.reset();createdListingId=null;const form=$('ol-form') as HTMLFormElement;form.querySelectorAll<HTMLInputElement|HTMLTextAreaElement|HTMLSelectElement>('input,textarea,select').forEach(field=>field.disabled=false);form.reset();$('ol-submit').textContent='Create listing';menuCleanups.forEach(cleanup=>cleanup());menuCleanups=[];activeUser = id; ownerEpoch++; ownerId = null; inflight = null; displayedRows = []; currentPage = 1; $('o-list').replaceChildren(); $('o-pagination').replaceChildren(); $('o-results').textContent = ''; $('o-manage').hidden = true; $('o-notes').replaceChildren(); }, refresh: () => { wire();incomingFilters();return refresh(); } };
}
