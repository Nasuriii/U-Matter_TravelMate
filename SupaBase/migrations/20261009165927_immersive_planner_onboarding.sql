-- First-login name setup is separate from authentication and role assignment.
create table travelmate_ui.profile_setup(profile_id uuid primary key references public.profiles(id) on delete cascade,first_name text not null,last_name text not null,completed_at timestamptz not null default now());
alter table travelmate_ui.profile_setup enable row level security;
revoke all on travelmate_ui.profile_setup from public,anon,authenticated;
grant all on travelmate_ui.profile_setup to service_role;
create policy server_setup on travelmate_ui.profile_setup to service_role using(true) with check(true);
create function travelmate_ui.my_setup_state() returns jsonb language plpgsql stable security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id();begin
 if u is null then raise exception 'Active account required';end if;
 return jsonb_build_object('name_needed',not exists(select 1 from travelmate_ui.profile_setup where profile_id=u),'preferences_needed',public.tm_has_role('traveler') and not public.tm_has_role('business_owner') and not public.tm_has_role('admin') and not exists(select 1 from public.traveler_settings where profile_id=u and onboarding_completed_at is not null));
end $$;
create function travelmate_ui.save_setup_name(p_first text,p_last text) returns text language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id();n text;
begin
 if u is null then raise exception 'Active account required';end if;
 if length(btrim(coalesce(p_first,''))) not between 1 and 70 or length(btrim(coalesce(p_last,''))) not between 1 and 70 then raise exception 'Enter your first and last name (up to 70 characters each)';end if;
 n:=btrim(p_first)||' '||btrim(p_last);
 update public.profiles set full_name=n,updated_at=now() where id=u;
 insert into travelmate_ui.profile_setup(profile_id,first_name,last_name) values(u,btrim(p_first),btrim(p_last)) on conflict(profile_id) do update set first_name=excluded.first_name,last_name=excluded.last_name;
 return n;
end $$;
create function public.my_setup_state() returns jsonb language sql stable security invoker set search_path='' as $$select travelmate_ui.my_setup_state();$$;
create function public.save_setup_name(p_first text,p_last text) returns text language sql security invoker set search_path='' as $$select travelmate_ui.save_setup_name(p_first,p_last);$$;
revoke all on function travelmate_ui.my_setup_state(),travelmate_ui.save_setup_name(text,text),public.my_setup_state(),public.save_setup_name(text,text) from public,anon;
grant execute on function travelmate_ui.my_setup_state(),travelmate_ui.save_setup_name(text,text),public.my_setup_state(),public.save_setup_name(text,text) to authenticated;

create table public.trip_day_notes(trip_id uuid references public.trips(id) on delete cascade,planned_date date not null,title text not null default '' check(length(title)<=120),notes text not null default '' check(length(notes)<=4000),primary key(trip_id,planned_date));
alter table public.trip_day_notes enable row level security;
revoke all on public.trip_day_notes from public,anon,authenticated;
grant select,insert,update,delete on public.trip_day_notes to authenticated;
grant all on public.trip_day_notes to service_role;
create policy own_day_read on public.trip_day_notes for select to authenticated using(exists(select 1 from public.trips t where t.id=trip_id and t.profile_id=(select public.tm_active_profile_id())));
create policy own_day_insert on public.trip_day_notes for insert to authenticated with check(exists(select 1 from public.trips t where t.id=trip_id and t.profile_id=(select public.tm_active_profile_id()) and t.status='draft' and planned_date between t.start_date and t.end_date));
create policy own_day_update on public.trip_day_notes for update to authenticated using(exists(select 1 from public.trips t where t.id=trip_id and t.profile_id=(select public.tm_active_profile_id()) and t.status='draft')) with check(exists(select 1 from public.trips t where t.id=trip_id and t.profile_id=(select public.tm_active_profile_id()) and t.status='draft' and planned_date between t.start_date and t.end_date));
create policy own_day_delete on public.trip_day_notes for delete to authenticated using(exists(select 1 from public.trips t where t.id=trip_id and t.profile_id=(select public.tm_active_profile_id()) and t.status='draft'));
create function public.save_my_trip_plan(p_trip uuid,p_expected_updated_at timestamptz,p_items jsonb,p_days jsonb) returns timestamptz language plpgsql security invoker set search_path='' as $$
declare t public.trips;d jsonb;saved timestamptz;
begin
 select * into t from public.trips where id=p_trip and profile_id=(select public.tm_active_profile_id()) for update;
 if not found or t.status<>'draft' then raise exception 'Editable trip not found';end if;
 if p_days is null or jsonb_typeof(p_days)<>'array' or jsonb_array_length(p_days)>14 then raise exception 'Choose up to 14 days';end if;
 if (select count(distinct x->>'planned_date') from jsonb_array_elements(p_days)x)<>jsonb_array_length(p_days) then raise exception 'Each day can appear only once';end if;
 for d in select value from jsonb_array_elements(p_days) loop
  if (d->>'planned_date') is null or (d->>'planned_date')::date not between t.start_date and t.end_date or length(coalesce(d->>'title',''))>120 or length(coalesce(d->>'notes',''))>4000 then raise exception 'Day notes are invalid or outside the trip dates';end if;
 end loop;
 saved:=public.save_my_itinerary(p_trip,p_expected_updated_at,p_items);
 delete from public.trip_day_notes where trip_id=p_trip;
 insert into public.trip_day_notes(trip_id,planned_date,title,notes) select p_trip,(value->>'planned_date')::date,coalesce(value->>'title',''),coalesce(value->>'notes','') from jsonb_array_elements(p_days);
 return saved;
end $$;
revoke all on function public.save_my_trip_plan(uuid,timestamptz,jsonb,jsonb) from public,anon;
grant execute on function public.save_my_trip_plan(uuid,timestamptz,jsonb,jsonb) to authenticated;
create function travelmate_ui.destination_transport_options(p_destination uuid) returns jsonb language plpgsql stable security definer set search_path='' as $$
begin
 if public.tm_active_profile_id() is null or not public.tm_has_role('traveler') or public.tm_has_role('admin') or public.tm_has_role('business_owner') then raise exception 'Traveler access required';end if;
 return coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'name',s.service_name,'type',s.transport_type,'provider',p.company_name,'description',p.description) order by s.service_name) from public.transportation_services s join public.transport_providers p on p.id=s.provider_id join public.destinations d on d.id=s.destination_id where s.destination_id=p_destination and s.status='approved' and d.is_active=1),'[]'::jsonb);
end $$;
create function public.destination_transport_options(p_destination uuid) returns jsonb language sql stable security invoker set search_path='' as $$select travelmate_ui.destination_transport_options(p_destination);$$;
revoke all on function travelmate_ui.destination_transport_options(uuid),public.destination_transport_options(uuid) from public,anon;
grant execute on function travelmate_ui.destination_transport_options(uuid),public.destination_transport_options(uuid) to authenticated;
notify pgrst,'reload schema';
