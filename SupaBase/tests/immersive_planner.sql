begin;
create temporary table ui_test_results(check_name text);
create temporary table planner_qa as select
(select p.id from public.profiles p where p.account_status='active' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) order by p.id limit 1) traveler,
(select p.id from public.profiles p where p.account_status='active' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) order by p.id offset 1 limit 1) other_traveler,
(select p.id from public.profiles p join public.profile_roles pr on pr.profile_id=p.id join public.roles r on r.id=pr.role_id where p.account_status='active' and r.name='business_owner' limit 1) owner,
(select id from public.destinations where is_active=1 order by name limit 1) destination;
grant select on planner_qa to authenticated;
select set_config('request.jwt.claim.sub',(select traveler::text from planner_qa),true);
set local role authenticated;
do $$ declare t uuid;s timestamptz;saved timestamptz;items jsonb;bad boolean;begin
perform public.my_setup_state();
if public.save_setup_name('UI','Fixture')<>'UI Fixture' then raise exception 'Name save failed';end if;
if (public.my_setup_state()->>'name_needed')::boolean then raise exception 'Name marker failed';end if;
begin perform public.save_setup_name('','Fixture');raise exception 'Invalid name accepted';exception when others then if SQLERRM='Invalid name accepted' then raise;end if;end;
insert into public.trips(profile_id,name,destination_id,start_date,end_date,arrival_time,departure_time,budget,budget_currency,party_size,travel_pace,interests,status,updated_at) values(auth.uid(),'UI rollback test',(select destination from planner_qa),'2026-11-01','2026-11-02','09:00','18:00',1000,'PHP',1,'balanced',array['food'],'draft','2020-01-01'::timestamptz) returning id,updated_at into t,s;
items:='[{"activity":"Arrive at destination","planned_date":"2026-11-01","planned_time":"09:00","planned_end_time":"09:00","listing_id":null},{"activity":"Personal food stop","planned_date":"2026-11-01","planned_time":"12:00","planned_end_time":"13:00","listing_id":null}]';
saved:=public.save_my_trip_plan(t,s,items,'[{"planned_date":"2026-11-01","title":"Explore town","notes":"Go to place X; eat at restaurant X"}]');
if not exists(select 1 from public.trip_day_notes where trip_id=t and title='Explore town' and notes='Go to place X; eat at restaurant X') then raise exception 'Notes not saved';end if;
begin perform public.save_my_trip_plan(t,s,items,'[]');raise exception 'Stale save accepted';exception when others then if SQLERRM='Stale save accepted' then raise;end if;end;
begin perform public.save_my_trip_plan(t,saved,items,'[{"planned_date":"2026-11-03","title":"Bad"}]');raise exception 'Outside date accepted';exception when others then if SQLERRM='Outside date accepted' then raise;end if;end;
begin perform public.save_my_trip_plan(t,saved,items,'[{"planned_date":"2026-11-01"},{"planned_date":"2026-11-01"}]');raise exception 'Duplicate dates accepted';exception when others then if SQLERRM='Duplicate dates accepted' then raise;end if;end;
if not exists(select 1 from public.trip_day_notes where trip_id=t and title='Explore town') then raise exception 'Failed save changed notes';end if;
perform public.destination_transport_options((select destination from planner_qa));
perform set_config('request.jwt.claim.sub',(select other_traveler::text from planner_qa),true);
if exists(select 1 from public.trip_day_notes where trip_id=t) then raise exception 'Foreign notes leaked';end if;
begin perform public.save_my_trip_plan(t,saved,items,'[]');raise exception 'Foreign save accepted';exception when others then if SQLERRM='Foreign save accepted' then raise;end if;end;
begin insert into public.trip_day_notes(trip_id,planned_date) values(t,'2026-11-02');raise exception 'Foreign insert accepted';exception when others then if SQLERRM='Foreign insert accepted' then raise;end if;end;
perform set_config('request.jwt.claim.sub',(select owner::text from planner_qa),true);
begin perform public.destination_transport_options((select destination from planner_qa));raise exception 'Owner transport accepted';exception when others then if SQLERRM='Owner transport accepted' then raise;end if;end;
end $$;
reset role;
insert into ui_test_results values('Own name, own plan, atomic notes, stale save, invalid dates, duplicate dates, foreign RLS, traveler-only transport passed');
set local role anon;
do $$begin
if has_function_privilege('anon','public.save_setup_name(text,text)','execute') or has_function_privilege('anon','public.save_my_trip_plan(uuid,timestamptz,jsonb,jsonb)','execute') or has_function_privilege('anon','public.destination_transport_options(uuid)','execute') then raise exception 'Anonymous execute available';end if;
end $$;
reset role;
select * from ui_test_results;
rollback;
