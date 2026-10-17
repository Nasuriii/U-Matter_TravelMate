// Continue the attachment fixture in the same isolated database. reserve() below
// is the real inventory function; plan persistence is a narrow concurrency stub.
export async function verifyItineraryReservations(db,{uid,login,catalog,deny}){
 const fs=await import('node:fs/promises'),{default:assert}=await import('node:assert/strict');
 await db.exec(`reset role;
 alter table trips add column updated_at timestamptz default '2026-10-14T00:00:00Z',add column saved_items jsonb;
 alter table bookings alter column id set default gen_random_uuid();
 alter table bookings add column guest_name text,add column guest_email text,add column guest_phone text,add column idempotency_key text unique,add column hold_expires_at timestamptz,add column stripe_session_id text;
 alter table business_listings add column listing_type text,add column status text default 'approved',add column is_sample boolean default false;
 alter table rooms add column hotel_id uuid,add column operational_status text default 'available',add column max_guests int default 4,add column base_nightly_rate numeric default 1500;
 alter table restaurant_slots add column capacity int default 4,add column is_open int default 1;
 create table restaurants(restaurant_id uuid,reservation_fee numeric);
 create function public.tm_active_profile_id() returns uuid language sql stable security definer as $$select id from public.profiles where id=auth.uid() and account_status='active'$$;
 create function public.tm_has_role(text) returns boolean language sql stable security definer as $$select coalesce((select role=$1 from public.profiles where id=auth.uid()),false)$$;
 create function public.tm_is_admin() returns boolean language sql stable security definer as $$select public.tm_has_role('admin')$$;
 create function public.save_my_trip_plan(p_trip uuid,p_expected_updated_at timestamptz,p_items jsonb,p_days jsonb) returns timestamptz language plpgsql security invoker set search_path='' as $$declare t public.trips;saved timestamptz;begin
 select * into t from public.trips where id=p_trip and profile_id=public.tm_browsing_profile_id() for update;
 if not found or t.updated_at is distinct from p_expected_updated_at then raise exception 'Trip changed';end if;
 update public.trips set updated_at=clock_timestamp(),saved_items=p_items where id=p_trip returning updated_at into saved;return saved;end$$;
 `);
 const base=await fs.readFile(new URL('../../SupaBase/migrations/20261010065216_travel_catalog_booking_moderation.sql',import.meta.url),'utf8');
 await db.exec(base.slice(base.indexOf('create or replace function travelmate_ui.reserve('),base.indexOf('create or replace function travelmate_ui.reservations()')));
 await db.exec(await fs.readFile(new URL('../../SupaBase/migrations/20261014124912_itinerary_reservations.sql',import.meta.url),'utf8'));
 await db.query("insert into trips(id,profile_id,name,start_date,end_date,status) values($1,$2,'Popup trip','2026-11-01','2026-11-04','draft')",[uid(70),uid(1)]);
 await db.query("update business_listings set listing_type=case when id=$1 then 'hotel' else 'restaurant' end",[uid(20)]);
 await db.query('update rooms set hotel_id=$1 where id in ($2,$3)',[uid(20),uid(30),uid(31)]);
 await db.query('insert into restaurants values($1,100)',[uid(21)]);
 let checks=0;
 const original='2026-10-14T00:00:00Z',item={planned_date:'2026-11-01',planned_time:'10:00',planned_end_time:'11:00',listing_id:uid(20),activity:'Stay',notes:'Unsaved note'};
 const args=(key,overrides={})=>({trip:uid(70),day:'2026-11-01',updated:original,items:[item],listing:uid(20),room:uid(30),slot:null,start:'2026-11-01',end:'2026-11-03',guests:2,name:'Test Guest',email:'guest@example.test',phone:null,key,...overrides});
 const sql='select reserve_my_trip_booking($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) as value';
 const values=a=>[a.trip,a.day,a.updated,a.items,[],a.listing,a.room,a.slot,a.start,a.end,a.guests,a.name,a.email,a.phone,a.key];
 const reserve=async a=>(await db.query(sql,values(a))).rows[0].value;
 await login(1);
 await deny(sql,values(args('outside-trip-0001',{trip:uid(12)})),/own editable/);checks++;
 await deny(sql,values(args('outside-trip-0002',{day:'2026-12-01'})),/within/);checks++;
 await deny(sql,values(args('outside-trip-0003',{end:'2026-11-06'})),/dates must/);checks++;
 await db.exec('reset role');assert.equal((await db.query('select saved_items from trips where id=$1',[uid(70)])).rows[0].saved_items,null);assert.equal((await db.query('select count(*)::int n from bookings where idempotency_key is not null')).rows[0].n,0);checks++;
 await login(1);const first=await reserve(args('hotel-popup-00001'));assert.equal(first.status,'pending');assert.equal(first.amount,3000);checks++;
 const retry=await reserve(args('hotel-popup-00001'));assert.equal(retry.booking_id,first.booking_id);assert.equal((await catalog(uid(70))).attachments.length,1);checks++;
 await deny(sql,values(args('hotel-popup-00001',{guests:3})),/reference already/);checks++;
 await deny(sql,values(args('hotel-popup-00001',{trip:uid(11)})),/outside this trip/);checks++;
 await deny(sql,values(args('hotel-popup-00002',{updated:first.updated_at})),/already reserved/);checks++;
 const availability=await db.query('select my_trip_reservation_options($1,$2,$3) value',[uid(20),'2026-11-01','2026-11-03']);assert.ok(!availability.rows[0].value.rooms.includes(uid(30)));assert.ok(availability.rows[0].value.rooms.includes(uid(31)));checks++;
 await deny(sql,values(args('stale-version-0001',{room:uid(31)})),/Trip changed/);checks++;
 await login(2);await deny(sql,values(args('suspended-000001',{trip:uid(12)})),/active traveler/);await deny('select my_trip_reservation_options($1,$2,$3)',[uid(20),'2026-11-01','2026-11-03'],/active traveler/);checks+=2;
 await db.exec('reset role');await db.query("update bookings set status='confirmed',payment_status='paid' where id=$1",[first.booking_id]);await login(1);let attached=(await catalog(uid(70))).attachments.find(x=>x.booking_id===first.booking_id);assert.equal(attached.payment_status,'paid');assert.equal(attached.is_test,false);checks++;
 const meal={...item,listing_id:uid(21),activity:'Lunch',planned_date:'2026-11-02',planned_time:'12:00',planned_end_time:'13:00'};
 await deny(sql,values(args('bad-meal-time-001',{updated:first.updated_at,listing:uid(21),room:null,slot:uid(50),start:null,end:null,day:'2026-11-02',items:[{...meal,planned_time:'11:00'}]})),/reserved table time/);checks++;
 const table=await reserve(args('meal-popup-00001',{updated:first.updated_at,listing:uid(21),room:null,slot:uid(50),start:null,end:null,day:'2026-11-02',items:[meal]}));assert.equal(table.status,'pending');checks++;
 const seats=(await db.query('select my_trip_reservation_options($1,null,null) value',[uid(21)])).rows[0].value.slots.find(x=>x.id===uid(50));assert.equal(seats.remaining,0);checks++;
 await db.exec('reset role');await db.query('update business_listings set is_sample=true where id=$1',[uid(20)]);await login(1);
 const test=await reserve(args('test-popup-00001',{updated:table.updated_at,room:uid(31)}));assert.equal(test.status,'confirmed');assert.equal(test.is_test,true);attached=(await catalog(uid(70))).attachments.find(x=>x.booking_id===test.booking_id);assert.equal(attached.payment_status,'unpaid');assert.equal(attached.is_test,true);checks++;
 await db.exec('reset role;set role anon');await deny('select my_trip_reservation_options($1,null,null)',[uid(20)],/permission denied/);checks++;
 await db.exec('reset role');assert.equal((await db.query('select saved_items from trips where id=$1',[uid(70)])).rows[0].saved_items[0].notes,'Unsaved note');checks++;
 console.log(JSON.stringify({itineraryDatabaseChecks:checks,atomicSave:true,idempotent:true,realInventoryChecks:true,suspensionGuard:true,automaticAttachment:true},null,2));
}
