export async function verifyBookingChoices(db,{uid,login,catalog,deny}){
 const fs=await import('node:fs/promises'),{default:assert}=await import('node:assert/strict');let checks=0;
 await db.exec(`reset role;
 alter table trips add column destination_id uuid;
 alter table business_listings add column destination_id uuid;
 update trips set destination_id='00000000-0000-4000-8000-000000000003';update business_listings set destination_id='00000000-0000-4000-8000-000000000003';
 create table public.trip_items(trip_id uuid,listing_id uuid,activity text,sequence_number int,planned_date date,planned_time time,planned_end_time time,recommendation_reason text,notes text);
 create table public.trip_day_notes(trip_id uuid,planned_date date,title text,notes text);
 create or replace function public.save_my_trip_plan(p_trip uuid,p_expected_updated_at timestamptz,p_items jsonb,p_days jsonb) returns timestamptz language plpgsql security invoker set search_path='' as $$
 declare t public.trips;x jsonb;saved timestamptz;previous_end timestamp;begin
 select * into t from public.trips where id=p_trip and profile_id=public.tm_browsing_profile_id() for update;
 if not found or t.updated_at is distinct from p_expected_updated_at then raise exception 'Trip changed';end if;
 for x in select value from jsonb_array_elements(p_items) loop
 if (x->>'planned_date')::date not between t.start_date and t.end_date then raise exception 'Outside trip dates';end if;
 if previous_end is not null and (x->>'planned_date')::date+(x->>'planned_time')::time<previous_end then raise exception 'Items overlap';end if;
 previous_end:=(x->>'planned_date')::date+(x->>'planned_end_time')::time;
 end loop;
 delete from public.trip_items where trip_id=p_trip;
 insert into public.trip_items select p_trip,(value->>'listing_id')::uuid,value->>'activity',ordinality::int,(value->>'planned_date')::date,(value->>'planned_time')::time,(value->>'planned_end_time')::time,value->>'recommendation_reason',value->>'notes' from jsonb_array_elements(p_items) with ordinality;
 delete from public.trip_day_notes where trip_id=p_trip;
 insert into public.trip_day_notes select p_trip,(value->>'planned_date')::date,value->>'title',value->>'notes' from jsonb_array_elements(p_days);
 update public.trips set updated_at=clock_timestamp(),saved_items=p_items where id=p_trip returning updated_at into saved;return saved;end$$;
 `);
 await db.exec(await fs.readFile(new URL('../../SupaBase/migrations/20261015153837_booking_itinerary_choices.sql',import.meta.url),'utf8'));
 await db.query("insert into trips(id,profile_id,name,start_date,end_date,status,destination_id) values($1,$2,'Destination trip','2026-11-01','2026-11-04','draft',$3)",[uid(90),uid(1),uid(3)]);
 await db.query("insert into bookings(id,profile_id,booking_type,status,payment_status,is_test,total_amount,guest_count) values($1,$2,'hotel','confirmed','unpaid',false,0,2),($3,$2,'hotel','confirmed','unpaid',false,1200,2)",[uid(80),uid(1),uid(81)]);
 await db.query("insert into hotel_bookings values($1,$2,'2026-11-01','2026-11-03'),($3,$2,'2026-11-01','2026-11-03')",[uid(80),uid(20),uid(81)]);
 await login(1);const eligible=(await catalog(uid(90))).bookings;
 assert.ok(eligible.some(b=>b.booking_id===uid(44)&&b.is_test&&b.payment_status==='unpaid'));checks++;
 assert.ok(eligible.some(b=>b.booking_id===uid(80)&&Number(b.amount)===0));checks++;
 assert.ok(!eligible.some(b=>b.booking_id===uid(81)));checks++;
 assert.equal(eligible.find(b=>b.booking_id===uid(44)).destination_id,uid(3));checks++;
 const statement='select schedule_my_trip_booking($1,$2,$3,$4,$5,$6,$7,$8) value';
 const args=(overrides={})=>{const a={trip:uid(90),booking:uid(44),day:'2026-11-01',start:'14:00',end:'15:00',key:uid(901),allow:false,plan:null,...overrides};return[a.trip,a.booking,a.day,a.start,a.end,a.key,a.allow,a.plan];};
 const schedule=async overrides=>(await db.query(statement,args(overrides))).rows[0].value;
 await deny(statement,args({trip:uid(12)}),/own editable/);checks++;
 await deny(statement,args({booking:uid(43)}),/not found/);checks++;
 await deny(statement,args({booking:uid(81)}),/Only confirmed/);checks++;
 await deny(statement,args({end:'13:00'}),/start and end/);checks++;
 const first=await schedule();assert.equal(first.items.length,1);assert.equal(first.items[0].planned_time,'14:00:00');assert.equal((await catalog(uid(90))).attachments.length,1);checks++;
 const second=await schedule();assert.equal(second.attachment_id,first.attachment_id);assert.equal(second.items.length,1);checks++;
 await deny(statement,args({start:'13:00'}),/different itinerary/);checks++;
 await db.exec('reset role');await db.query("insert into trip_day_notes values($1,'2026-11-01','My day','Preserve saved notes')",[uid(90)]);await login(1);
 const third=await schedule({booking:uid(80),key:uid(902),start:'16:00',end:'17:00'});assert.equal(third.items.length,1);assert.equal(third.days[0].notes,'Preserve saved notes');checks++;
 const draft={updated_at:third.updated_at,items:[...third.items,{planned_date:'2026-11-02',planned_time:'09:00',planned_end_time:'10:00',listing_id:null,activity:'Unsaved museum stop',notes:'Draft note',recommendation_reason:'Personal'}],days:[{planned_date:'2026-11-01',title:'Edited title',notes:'Unsaved day notes'}]};
 const saved=await schedule({booking:uid(80),key:uid(903),start:'17:00',end:'18:00',plan:draft});assert.equal(saved.items.length,2);assert.equal(saved.items.find(i=>i.activity==='Unsaved museum stop').notes,'Draft note');assert.equal(saved.days[0].notes,'Unsaved day notes');checks++;
 await deny(statement,args({booking:uid(80),key:uid(904),plan:draft}),/Trip changed/);checks++;
 await db.exec('reset role');await db.query("insert into trip_items values($1,null,'Another stop',3,'2026-11-01','18:00','19:00','','')",[uid(90)]);await login(1);
 await deny(statement,args({booking:uid(80),key:uid(905),start:'18:00',end:'19:00'}),/overlap/);checks++;
 await db.exec('reset role');await db.query('update trips set destination_id=$1 where id=$2',[uid(4),uid(90)]);await login(1);
 await deny(statement,args({booking:uid(80),key:uid(906)}),/destination/);checks++;
 await login(2);await deny(statement,args({key:uid(907)}),/own editable/);checks++;
 await db.exec('reset role;set role anon');await deny(statement,args(),/permission denied/);checks++;
 await db.exec('reset role');assert.equal((await db.query('select count(*)::int n from bookings')).rows[0].n,11);checks++;
 console.log(JSON.stringify({bookingChoiceDatabaseChecks:checks,confirmedTestAndFreeVisible:true,unpaidHoldsExcluded:true,atomicScheduling:true,existingDraftPreserved:true,idempotentScheduling:true},null,2));
}
