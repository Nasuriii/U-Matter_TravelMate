-- Synthetic itinerary only; all changes are rolled back.
begin;
select set_config('request.jwt.claims',jsonb_build_object('sub',(select p.id from public.profiles p where p.account_status='active' and p.full_name like '%(Demo)%' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) order by p.full_name limit 1),'role','authenticated')::text,true);
select set_config('test.foreign_trip',coalesce((select id::text from public.trips where profile_id<>(current_setting('request.jwt.claims')::jsonb->>'sub')::uuid limit 1),''),true);
set local role authenticated;
do $$ declare tid uuid; forbidden boolean:=false; begin
 insert into public.trips(profile_id,name,start_date,end_date,status) values(public.tm_active_profile_id(),'Deletion test only','2026-11-01','2026-11-02','draft') returning id into tid;
 insert into public.trip_items(trip_id,activity,sequence_number,planned_date,planned_time,planned_end_time) values(tid,'Test stop',1,'2026-11-01','10:00','11:00');
 insert into public.trip_day_notes(trip_id,planned_date,title,notes) values(tid,'2026-11-01','Test day','Test notes');
 insert into public.search_history(profile_id,trip_id,keyword) values(public.tm_active_profile_id(),tid,'Test search');
 begin perform public.delete_my_trip(gen_random_uuid());exception when others then if sqlerrm='Trip not found or no longer available' then forbidden:=true;else raise;end if;end;
 if not forbidden then raise exception 'Unknown trip accepted';end if;
 if current_setting('test.foreign_trip')<>'' then
  forbidden:=false;
  begin perform public.delete_my_trip(current_setting('test.foreign_trip')::uuid);exception when others then if sqlerrm='Trip not found or no longer available' then forbidden:=true;else raise;end if;end;
  if not forbidden then raise exception 'Another traveler trip accepted';end if;
 end if;
 perform public.delete_my_trip(tid);
 if exists(select 1 from public.trips where id=tid) or exists(select 1 from public.trip_items where trip_id=tid) or exists(select 1 from public.trip_day_notes where trip_id=tid) or exists(select 1 from public.search_history where trip_id=tid) then raise exception 'Trip deletion incomplete';end if;
end $$;
rollback;
select 'Atomic trip deletion, unknown-trip rejection and child cleanup passed' result;
