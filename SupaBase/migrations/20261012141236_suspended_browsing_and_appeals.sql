-- Suspended people may browse, save favorites, and plan their own trips.
-- Booking, payment, review, business and administrator permissions still
-- use tm_active_profile_id()/tm_has_role(), which are deliberately unchanged.
create function travelmate_ui.browsing_profile_id() returns uuid
language sql stable security definer set search_path='' as $$
 select id from public.profiles where id=(select auth.uid()) and account_status in ('active','suspended');
$$;
create function public.tm_browsing_profile_id() returns uuid
language sql stable security invoker set search_path='' as $$select travelmate_ui.browsing_profile_id()$$;
create function travelmate_ui.can_plan() returns boolean
language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.profiles p where p.id=(select auth.uid()) and
  (p.account_status='suspended' or (p.account_status='active' and exists(
   select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler')
   and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')))));
$$;
create function public.tm_can_plan() returns boolean
language sql stable security invoker set search_path='' as $$select travelmate_ui.can_plan()$$;
revoke all on function travelmate_ui.browsing_profile_id(),public.tm_browsing_profile_id(),travelmate_ui.can_plan(),public.tm_can_plan() from public,anon;
grant execute on function travelmate_ui.browsing_profile_id(),public.tm_browsing_profile_id(),travelmate_ui.can_plan(),public.tm_can_plan() to authenticated;

-- Preserve every existing ownership/draft/date predicate; replace only the
-- identity lookup on personal planning tables. Never apply this to reviews.
do $$ declare p record; q text; c text; begin
 for p in select * from pg_policies where schemaname='public' and tablename in
  ('trips','trip_day_notes','search_history','saved_destinations','profile_preferences') loop
  q:=replace(p.qual,'tm_active_profile_id()','tm_browsing_profile_id()');
  c:=replace(p.with_check,'tm_active_profile_id()','tm_browsing_profile_id()');
  execute format('alter policy %I on public.%I%s%s',p.policyname,p.tablename,
   case when q is null then '' else ' using ('||q||')' end,
   case when c is null then '' else ' with check ('||c||')' end);
 end loop;
end $$;
alter policy own_favorites_read on public.saved_places using(profile_id=(select public.tm_browsing_profile_id()) and (select public.tm_can_plan()));
alter policy own_favorites_delete on public.saved_places using(profile_id=(select public.tm_browsing_profile_id()) and (select public.tm_can_plan()));
alter policy own_favorites_insert on public.saved_places with check(profile_id=(select public.tm_browsing_profile_id()) and (select public.tm_can_plan()) and
 (exists(select 1 from public.business_listings l where l.id=listing_id and l.status='approved') or
  exists(select 1 from public.menu_items m join public.business_listings l on l.id=m.restaurant_id where m.id=menu_item_id and m.is_available=1 and l.status='approved')));
create policy suspended_booking_history on public.bookings for select to authenticated using(profile_id=(select public.tm_browsing_profile_id()));
create policy suspended_preview_history on public.sample_reservations for select to authenticated using(profile_id=(select public.tm_browsing_profile_id()));

-- These are the only RPCs whose active-only identity is relaxed. Their existing
-- validation, optimistic concurrency, ownership, and RLS remain in place.
do $$ declare f record; definition text; begin
 for f in select p.oid from pg_proc p join pg_namespace n on n.oid=p.pronamespace where
  (n.nspname='public' and p.proname in ('save_my_itinerary','save_my_trip_plan')) or
  (n.nspname='travelmate_ui' and p.proname='reservations') loop
  definition:=replace(pg_get_functiondef(f.oid),'tm_active_profile_id()','tm_browsing_profile_id()');
  execute definition;
 end loop;
end $$;
create or replace function public.set_saved_place(p_listing uuid,p_menu uuid,p_saved boolean) returns void
language plpgsql security invoker set search_path='' as $$declare u uuid:=public.tm_browsing_profile_id();begin
 if u is null or not public.tm_can_plan() then raise exception 'Traveler account required';end if;
 if (p_listing is null)=(p_menu is null) or p_saved is null then raise exception 'Choose one place';end if;
 if p_saved then insert into public.saved_places(profile_id,listing_id,menu_item_id) values(u,p_listing,p_menu) on conflict do nothing;
 else delete from public.saved_places where profile_id=u and (listing_id=p_listing or menu_item_id=p_menu);end if;
end $$;
create or replace function public.delete_my_trip(p_trip uuid) returns void
language plpgsql security invoker set search_path='' as $$begin
 if not public.tm_can_plan() then raise exception 'Traveler workspace required';end if;
 perform 1 from public.trips where id=p_trip and profile_id=(select public.tm_browsing_profile_id()) for update;
 if not found then raise exception 'Trip not found or no longer available';end if;
 delete from public.search_history where trip_id=p_trip and profile_id=(select public.tm_browsing_profile_id());
 delete from public.trip_items where trip_id=p_trip;
 delete from public.trips where id=p_trip and profile_id=(select public.tm_browsing_profile_id());
 if not found then raise exception 'Trip could not be deleted';end if;
end $$;
do $$ declare definition text; begin
 select pg_get_functiondef('travelmate_ui.save_preferences(text[],text,boolean)'::regprocedure) into definition;
 definition:=regexp_replace(definition,'IF uid IS NULL OR NOT EXISTS\(SELECT 1 FROM public.profiles[\s\S]*?THEN RAISE EXCEPTION ''Traveler account required''; END IF;',
  'IF uid IS NULL OR NOT public.tm_can_plan() THEN RAISE EXCEPTION ''Traveler account required''; END IF;');
 if position('NOT public.tm_can_plan()' in definition)=0 then raise exception 'Preference guard was not replaced';end if;
 execute definition;
end $$;

create table travelmate_ui.account_appeals (
 id uuid primary key default gen_random_uuid(),
 profile_id uuid not null references public.profiles(id),
 suspension_version timestamptz not null,
 suspension_audit_id bigint not null default 0,
 message text not null check(char_length(message) between 20 and 2000),
 status text not null default 'pending' check(status in ('pending','approved','declined')),
 response text check(char_length(response)<=1000),
 reviewed_by uuid references public.profiles(id),
 reviewed_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
alter table travelmate_ui.account_appeals enable row level security;
revoke all on travelmate_ui.account_appeals from public,anon,authenticated;
create unique index account_appeals_one_pending on travelmate_ui.account_appeals(profile_id) where status='pending';
create index account_appeals_profile_time on travelmate_ui.account_appeals(profile_id,created_at desc);
create index account_appeals_reviewer on travelmate_ui.account_appeals(reviewed_by);
create index account_appeals_queue on travelmate_ui.account_appeals(status,created_at);

-- A suspended profile's status is visible to its owner without exposing other
-- accounts or treating it as active for protected operations.
create function travelmate_ui.account_access() returns jsonb
language plpgsql stable security definer set search_path='' as $$declare u uuid:=auth.uid();result jsonb;begin
 if u is null then raise exception 'Sign in required' using errcode='42501';end if;
 select jsonb_build_object('id',p.id,'full_name',p.full_name,'address',p.address,'avatar_object_path',p.avatar_object_path,
  'account_status',p.account_status,'updated_at',p.updated_at,
  'suspension_reason',case when p.account_status='suspended' then (select a.reason from travelmate_ui.account_status_audit a where a.profile_id=p.id and a.next_status='suspended' order by a.created_at desc,a.id desc limit 1) end)
 into result from public.profiles p where p.id=u;
 return result;
end $$;
create function travelmate_ui.my_appeals() returns jsonb
language plpgsql stable security definer set search_path='' as $$declare u uuid:=auth.uid();begin
 if u is null then raise exception 'Sign in required' using errcode='42501';end if;
 return coalesce((select jsonb_agg(to_jsonb(x)) from (
  select a.id,a.message,a.status,a.response,a.created_at,a.updated_at,a.reviewed_at,
   (p.account_status='suspended' and p.updated_at=a.suspension_version and a.suspension_audit_id=coalesce((select max(s.id) from travelmate_ui.account_status_audit s where s.profile_id=p.id and s.next_status='suspended'),0)) is_current
  from travelmate_ui.account_appeals a join public.profiles p on p.id=a.profile_id where a.profile_id=u order by a.created_at desc limit 10)x),'[]'::jsonb);
end $$;
create function travelmate_ui.submit_appeal(p_message text) returns uuid
language plpgsql security definer set search_path='' as $$declare u uuid:=auth.uid();p public.profiles;message text:=trim(coalesce(p_message,''));result uuid;audit_id bigint;begin
 if u is null then raise exception 'Sign in required' using errcode='42501';end if;
 select * into p from public.profiles where id=u for update;
 if not found or p.account_status<>'suspended' then raise exception 'Only suspended accounts can appeal';end if;
 if char_length(message) not between 20 and 2000 then raise exception 'Write an appeal between 20 and 2,000 characters';end if;
 select coalesce(max(id),0) into audit_id from travelmate_ui.account_status_audit where profile_id=u and next_status='suspended';
 -- Match the audit record as well as the timestamp, including same-transaction status changes.
 -- A pending request from an older suspension must not block the current one.
 update travelmate_ui.account_appeals set status='declined',response='Closed because the earlier suspension changed.',reviewed_at=now(),updated_at=clock_timestamp()
  where profile_id=u and status='pending' and (suspension_version<>p.updated_at or suspension_audit_id<>audit_id);
 if exists(select 1 from travelmate_ui.account_appeals where profile_id=u and status='pending') then raise exception 'An appeal is already awaiting review';end if;
 insert into travelmate_ui.account_appeals(profile_id,suspension_version,suspension_audit_id,message) values(u,p.updated_at,audit_id,message) returning id into result;
 return result;
end $$;
create function travelmate_ui.admin_appeals(p_status text,p_offset integer) returns jsonb
language plpgsql stable security definer set search_path='' as $$begin
 if not public.tm_is_admin() then raise exception 'Administrator access required' using errcode='42501';end if;
 if p_status not in ('pending','approved','declined','all') or p_status is null or p_offset is null or p_offset<0 then raise exception 'Invalid appeal filters';end if;
 return jsonb_build_object('pending',(select count(*) from travelmate_ui.account_appeals where status='pending'),
  'total',(select count(*) from travelmate_ui.account_appeals where p_status='all' or status=p_status),
  'items',coalesce((select jsonb_agg(to_jsonb(x)) from (
   select a.*,p.full_name,coalesce(u.email,'') email,p.account_status,
    (p.account_status='suspended' and p.updated_at=a.suspension_version and a.suspension_audit_id=coalesce((select max(s.id) from travelmate_ui.account_status_audit s where s.profile_id=p.id and s.next_status='suspended'),0)) is_current,
    (select reason from travelmate_ui.account_status_audit s where s.profile_id=p.id and s.next_status='suspended' order by s.created_at desc,s.id desc limit 1) suspension_reason
   from travelmate_ui.account_appeals a join public.profiles p on p.id=a.profile_id left join auth.users u on u.id=p.id
   where p_status='all' or a.status=p_status order by a.created_at,a.id offset p_offset limit 20)x),'[]'::jsonb));
end $$;
create function travelmate_ui.review_appeal(p_appeal uuid,p_approve boolean,p_response text,p_expected_updated_at timestamptz) returns void
language plpgsql security definer set search_path='' as $$declare actor uuid:=public.tm_active_profile_id();a travelmate_ui.account_appeals;p public.profiles;target uuid;decision_response text:=trim(coalesce(p_response,''));begin
 if actor is null or not public.tm_is_admin() then raise exception 'Administrator access required' using errcode='42501';end if;
 if p_approve is null or char_length(decision_response) not between 10 and 1000 then raise exception 'Write a response between 10 and 1,000 characters';end if;
 select profile_id into target from travelmate_ui.account_appeals where id=p_appeal;
 if target is null then raise exception 'Appeal not found';end if;
 -- Always lock the profile before the appeal, matching the submission order.
 select * into p from public.profiles where id=target for update;
 select * into a from travelmate_ui.account_appeals where id=p_appeal for update;
 if a.status<>'pending' or p_expected_updated_at is null or a.updated_at is distinct from p_expected_updated_at then raise exception 'Appeal changed. Refresh the queue before reviewing' using errcode='40001';end if;
 if p_approve then
  if p.account_status<>'suspended' or p.updated_at is distinct from a.suspension_version or a.suspension_audit_id<>coalesce((select max(s.id) from travelmate_ui.account_status_audit s where s.profile_id=p.id and s.next_status='suspended'),0) then raise exception 'The suspension changed. Refresh this account before reactivating' using errcode='40001';end if;
  if target=actor or exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=target and r.name='admin') then raise exception 'Administrator accounts are protected';end if;
  update public.profiles set account_status='active' where id=target;
  insert into travelmate_ui.account_status_audit(profile_id,actor_id,previous_status,next_status,reason) values(target,actor,'suspended','active',left('Appeal approved: '||decision_response,300));
 end if;
 update travelmate_ui.account_appeals set status=case when p_approve then 'approved' else 'declined' end,response=decision_response,reviewed_by=actor,reviewed_at=now(),updated_at=clock_timestamp() where id=p_appeal;
end $$;

create function public.my_account_access() returns jsonb language sql stable security invoker set search_path='' as $$select travelmate_ui.account_access()$$;
create function public.my_account_appeals() returns jsonb language sql stable security invoker set search_path='' as $$select travelmate_ui.my_appeals()$$;
create function public.submit_account_appeal(p_message text) returns uuid language sql security invoker set search_path='' as $$select travelmate_ui.submit_appeal(p_message)$$;
create function public.admin_account_appeals(p_status text default 'pending',p_offset integer default 0) returns jsonb language sql stable security invoker set search_path='' as $$select travelmate_ui.admin_appeals(p_status,p_offset)$$;
create function public.admin_review_account_appeal(p_appeal uuid,p_approve boolean,p_response text,p_expected_updated_at timestamptz) returns void language sql security invoker set search_path='' as $$select travelmate_ui.review_appeal(p_appeal,p_approve,p_response,p_expected_updated_at)$$;
revoke all on function travelmate_ui.account_access(),travelmate_ui.my_appeals(),travelmate_ui.submit_appeal(text),travelmate_ui.admin_appeals(text,integer),travelmate_ui.review_appeal(uuid,boolean,text,timestamptz),public.my_account_access(),public.my_account_appeals(),public.submit_account_appeal(text),public.admin_account_appeals(text,integer),public.admin_review_account_appeal(uuid,boolean,text,timestamptz) from public,anon;
grant execute on function travelmate_ui.account_access(),travelmate_ui.my_appeals(),travelmate_ui.submit_appeal(text),travelmate_ui.admin_appeals(text,integer),travelmate_ui.review_appeal(uuid,boolean,text,timestamptz),public.my_account_access(),public.my_account_appeals(),public.submit_account_appeal(text),public.admin_account_appeals(text,integer),public.admin_review_account_appeal(uuid,boolean,text,timestamptz) to authenticated;
