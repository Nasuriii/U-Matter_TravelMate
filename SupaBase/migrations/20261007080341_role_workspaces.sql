-- Additive SQL deployment script for role workspaces. No existing records are removed.
-- Private functions are deliberately privileged: they aggregate across RLS for an
-- explicitly verified admin/owner, or atomically reserve inventory for auth.uid().
-- Public Data API wrappers run as invoker. No direct booking/table writes are granted.
create schema if not exists travelmate_ui;
revoke all on schema travelmate_ui from public, anon;
grant usage on schema travelmate_ui to authenticated;
create table if not exists travelmate_ui.events (
  id bigint generated always as identity primary key,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null check(kind in ('page_view','listing_view','api_timing')),
  target text not null check(length(target)<=160),
  duration_ms integer check(duration_ms between 0 and 120000),
  created_at timestamptz not null default now()
);
alter table travelmate_ui.events enable row level security;
revoke all on travelmate_ui.events from public, anon, authenticated;
create index if not exists ui_events_kind_time on travelmate_ui.events(kind,created_at);
create index if not exists ui_events_target_time on travelmate_ui.events(target,created_at);
create index if not exists ui_events_profile_time on travelmate_ui.events(profile_id,created_at);

create or replace function travelmate_ui.record_event(p_kind text,p_target text,p_duration_ms integer default null)
returns void language plpgsql security definer set search_path='' as $$
declare u uuid := public.tm_active_profile_id();
begin
  if u is null then raise exception 'Sign in to an active account'; end if;
  if p_kind is null or p_kind not in ('page_view','listing_view','api_timing') or p_target is null or length(p_target)>160 or length(p_target)=0 then raise exception 'Invalid event'; end if;
  if p_duration_ms is not null and (p_duration_ms<0 or p_duration_ms>120000) then raise exception 'Invalid duration'; end if;
  if p_kind='listing_view' and not exists(select 1 from public.business_listings where id::text=p_target and status='approved') then return; end if;
  -- Coalesce repeat clicks from the same user within ten seconds.
  perform pg_advisory_xact_lock(hashtextextended(u::text || p_kind || p_target,0));
  if exists(select 1 from travelmate_ui.events where profile_id=u and kind=p_kind and target=p_target and created_at>now()-interval '10 seconds') then return; end if;
  insert into travelmate_ui.events(profile_id,kind,target,duration_ms) values(u,p_kind,p_target,p_duration_ms);
end $$;
create or replace function public.record_ui_event(p_kind text,p_target text,p_duration_ms integer default null)
returns void language sql security invoker set search_path='' as $$ select travelmate_ui.record_event(p_kind,p_target,p_duration_ms); $$;

create or replace function travelmate_ui.overview()
returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); o uuid; admin boolean; result jsonb;
begin
  if u is null then raise exception 'Sign in to an active account'; end if;
  admin:=public.tm_is_admin();
  if not admin then
    if not public.tm_has_role('business_owner') then raise exception 'Business owner or administrator access required'; end if;
    select id into o from public.business_owners where profile_id=u;
    if o is null then raise exception 'Your business profile is not ready'; end if;
  end if;
  select jsonb_build_object(
    'role',case when admin then 'admin' else 'owner' end,
    'users',case when admin then (select count(*) from public.profiles) else null end,
    'owners',case when admin then (select count(*) from public.business_owners) else null end,
    'listings',(select count(*) from public.business_listings where admin or owner_id=o),
    'approved',(select count(*) from public.business_listings where (admin or owner_id=o) and status='approved'),
    'pending',(select count(*) from public.business_listings where (admin or owner_id=o) and status='pending'),
    'rejected',(select count(*) from public.business_listings where (admin or owner_id=o) and status='rejected'),
    'page_views',case when admin then (select count(*) from travelmate_ui.events where kind='page_view' and created_at>=now()-interval '30 days') else null end,
    'active_users',case when admin then (select count(distinct profile_id) from travelmate_ui.events where kind='page_view' and created_at>=now()-interval '30 days') else null end,
    'listing_views',(select count(*) from travelmate_ui.events e where e.kind='listing_view' and e.created_at>=now()-interval '30 days' and (admin or exists(select 1 from public.business_listings l where l.id::text=e.target and l.owner_id=o))),
    'bookings',(select count(*) from public.bookings b where admin or exists(select 1 from public.hotel_bookings h join public.business_listings l on l.id=h.hotel_id where h.booking_id=b.id and l.owner_id=o) or exists(select 1 from public.restaurant_bookings r join public.restaurant_slots s on s.id=r.slot_id join public.business_listings l on l.id=s.restaurant_id where r.booking_id=b.id and l.owner_id=o)),
    'paid_total',(select coalesce(sum(b.total_amount),0) from public.bookings b where b.payment_status='paid' and (admin or exists(select 1 from public.hotel_bookings h join public.business_listings l on l.id=h.hotel_id where h.booking_id=b.id and l.owner_id=o) or exists(select 1 from public.restaurant_bookings r join public.restaurant_slots s on s.id=r.slot_id join public.business_listings l on l.id=s.restaurant_id where r.booking_id=b.id and l.owner_id=o))),
    'avg_api_ms',case when admin then (select round(avg(duration_ms)) from travelmate_ui.events where kind='api_timing' and created_at>=now()-interval '30 days') else null end,
    'tracking_since',(select min(created_at) from travelmate_ui.events),
    'daily',(select jsonb_agg(jsonb_build_object('date',day::date,'views',(select count(*) from travelmate_ui.events e where e.created_at>=day and e.created_at<day+interval '1 day' and e.kind=case when admin then 'page_view' else 'listing_view' end and (admin or exists(select 1 from public.business_listings l where l.id::text=e.target and l.owner_id=o)))) order by day) from generate_series(date_trunc('day',now())-interval '13 days',date_trunc('day',now()),interval '1 day') day),
    'businesses',(select coalesce(jsonb_agg(x),'[]'::jsonb) from (select l.id,l.name,l.listing_type,l.status,
      (select count(*) from travelmate_ui.events e where e.target=l.id::text and e.kind='listing_view' and e.created_at>=now()-interval '30 days') views,
      (select count(*) from public.bookings b where exists(select 1 from public.hotel_bookings h where h.booking_id=b.id and h.hotel_id=l.id) or exists(select 1 from public.restaurant_bookings r join public.restaurant_slots s on s.id=r.slot_id where r.booking_id=b.id and s.restaurant_id=l.id)) bookings
      from public.business_listings l where admin or l.owner_id=o order by l.created_at desc limit 200) x)
  ) into result;
  return result;
end $$;
create or replace function public.workspace_overview() returns jsonb language sql security invoker set search_path='' as $$ select travelmate_ui.overview(); $$;

create or replace function travelmate_ui.reserve(p_listing uuid,p_room uuid,p_slot uuid,p_check_in date,p_check_out date,p_guests integer,p_name text,p_email text,p_phone text,p_key text)
returns uuid language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); l public.business_listings; r public.rooms; s public.restaurant_slots; b public.bookings; bid uuid; amount numeric; used integer; fee numeric;
begin
  if u is null or not public.tm_has_role('traveler') or public.tm_is_admin() or public.tm_has_role('business_owner') then raise exception 'An active traveler account is required'; end if;
  if p_key is null or length(p_key)<16 or length(p_key)>100 then raise exception 'Invalid reservation reference'; end if;
  if p_guests is null or p_guests<1 or p_guests>100 or p_name is null or length(trim(p_name))<2 or length(p_name)>150 or p_email is null or p_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' or length(p_email)>150 or length(coalesce(p_phone,''))>30 then raise exception 'Check guest details'; end if;
  perform pg_advisory_xact_lock(hashtextextended(p_key,0));
  select * into b from public.bookings where idempotency_key=p_key;
  if found then
    if b.profile_id<>u or b.guest_count<>p_guests or b.guest_name<>trim(p_name) or b.guest_email<>trim(p_email) then raise exception 'Reservation reference already used'; end if;
    if b.booking_type='hotel' and exists(select 1 from public.hotel_bookings h join public.booking_rooms br on br.booking_id=h.booking_id where h.booking_id=b.id and h.hotel_id=p_listing and br.room_id=p_room and h.check_in=p_check_in and h.check_out=p_check_out) then return b.id;
    elsif b.booking_type='restaurant' and exists(select 1 from public.restaurant_bookings rb join public.restaurant_slots rs on rs.id=rb.slot_id where rb.booking_id=b.id and rb.slot_id=p_slot and rs.restaurant_id=p_listing) then return b.id;
    else raise exception 'Reservation reference already used for different details'; end if;
  end if;
  select * into l from public.business_listings where id=p_listing and status='approved' for share;
  if not found then raise exception 'This listing is not currently available'; end if;
  if l.listing_type='hotel' then
    if p_check_in is null or p_check_out is null or p_check_in<current_date or p_check_out<=p_check_in or p_check_out-p_check_in>90 then raise exception 'Choose valid dates, up to 90 nights'; end if;
    select * into r from public.rooms where id=p_room and hotel_id=l.id and operational_status='available' for update;
    if not found or r.max_guests<p_guests then raise exception 'Choose an available room with space for all guests'; end if;
    if exists(select 1 from public.booking_rooms br join public.hotel_bookings h on h.booking_id=br.booking_id join public.bookings bk on bk.id=h.booking_id where br.room_id=r.id and h.check_in<p_check_out and h.check_out>p_check_in and (bk.status in ('confirmed','completed') or (bk.status='pending' and (bk.hold_expires_at>now() or bk.stripe_session_id is not null)))) then raise exception 'This room is already reserved for those dates'; end if;
    amount:=r.base_nightly_rate*(p_check_out-p_check_in);
  elsif l.listing_type='restaurant' then
    select * into s from public.restaurant_slots where id=p_slot and restaurant_id=l.id and is_open=1 and starts_at>now() for update;
    if not found then raise exception 'Select an upcoming reservation slot'; end if;
    select coalesce(sum(bk.guest_count),0) into used from public.restaurant_bookings rb join public.bookings bk on bk.id=rb.booking_id where rb.slot_id=s.id and (bk.status in ('confirmed','completed') or (bk.status='pending' and (bk.hold_expires_at>now() or bk.stripe_session_id is not null)));
    if used+p_guests>s.capacity then raise exception 'This time slot does not have enough seats'; end if;
    select reservation_fee into fee from public.restaurants where restaurant_id=l.id; amount:=coalesce(fee,0);
  else raise exception 'Attractions are included in itineraries; ticket inventory is not configured'; end if;
  insert into public.bookings(profile_id,booking_type,guest_name,guest_email,guest_phone,guest_count,total_amount,status,hold_expires_at,idempotency_key,payment_status)
  values(u,l.listing_type,trim(p_name),trim(p_email),nullif(trim(p_phone),''),p_guests,amount,case when amount=0 then 'confirmed' else 'pending' end,case when amount>0 then now()+interval '35 minutes' else null end,p_key,'unpaid') returning id into bid;
  if l.listing_type='hotel' then
    insert into public.hotel_bookings(booking_id,hotel_id,check_in,check_out) values(bid,l.id,p_check_in,p_check_out);
    insert into public.booking_rooms(booking_id,room_id,nightly_rate) values(bid,r.id,r.base_nightly_rate);
  else insert into public.restaurant_bookings(booking_id,slot_id) values(bid,s.id); end if;
  return bid;
end $$;
create or replace function public.reserve_my_booking(p_listing uuid,p_room uuid,p_slot uuid,p_check_in date,p_check_out date,p_guests integer,p_name text,p_email text,p_phone text,p_key text)
returns uuid language sql security invoker set search_path='' as $$ select travelmate_ui.reserve(p_listing,p_room,p_slot,p_check_in,p_check_out,p_guests,p_name,p_email,p_phone,p_key); $$;

create or replace function travelmate_ui.reservations()
returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); o uuid; a boolean;
begin
  if u is null then raise exception 'Sign in to an active account'; end if;
  a:=public.tm_is_admin(); select id into o from public.business_owners where profile_id=u and public.tm_has_role('business_owner');
  return (select coalesce(jsonb_agg(row),'[]'::jsonb) from (select b.id,b.booking_type,b.guest_name,b.guest_email,b.guest_phone,b.guest_count,b.total_amount,b.status,b.payment_status,b.created_at,b.hold_expires_at,
    coalesce(h.check_in::text,s.starts_at::text) starts_at,h.check_out ends_at,coalesce(lh.name,lr.name) listing_name,coalesce(lh.id,lr.id) listing_id,
    r.room_type,r.room_number from public.bookings b left join public.hotel_bookings h on h.booking_id=b.id left join public.booking_rooms br on br.booking_id=b.id left join public.rooms r on r.id=br.room_id left join public.business_listings lh on lh.id=h.hotel_id left join public.restaurant_bookings rb on rb.booking_id=b.id left join public.restaurant_slots s on s.id=rb.slot_id left join public.business_listings lr on lr.id=s.restaurant_id
    where a or (o is not null and (lh.owner_id=o or lr.owner_id=o)) or (o is null and not a and b.profile_id=u) order by b.created_at desc limit 200) row);
end $$;
create or replace function public.workspace_reservations() returns jsonb language sql security invoker set search_path='' as $$ select travelmate_ui.reservations(); $$;

create or replace function travelmate_ui.cancel_reservation(p_booking uuid)
returns void language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); b public.bookings;
begin
  if u is null then raise exception 'Sign in to an active account'; end if;
  select * into b from public.bookings where id=p_booking and profile_id=u for update;
  if not found then raise exception 'Reservation not found'; end if;
  -- Stripe sessions must expire naturally. Releasing their inventory early could
  -- allow a second reservation while the original checkout is still payable.
  if b.payment_status='paid' or b.status<>'pending' or b.stripe_session_id is not null then raise exception 'Paid or checkout-active reservations cannot be cancelled here. Contact the business for assistance.'; end if;
  update public.bookings set status='cancelled' where id=b.id;
end $$;
create or replace function public.cancel_my_booking(p_booking uuid) returns void language sql security invoker set search_path='' as $$ select travelmate_ui.cancel_reservation(p_booking); $$;

create or replace function travelmate_ui.add_slot(p_listing uuid,p_start timestamptz,p_end timestamptz,p_capacity integer)
returns uuid language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); sid uuid;
begin
  if u is null or not public.tm_has_role('business_owner') or not public.tm_owns_listing(p_listing) then raise exception 'This is not your restaurant'; end if;
  if not exists(select 1 from public.restaurants where restaurant_id=p_listing) then raise exception 'Select a restaurant'; end if;
  if p_start is null or p_end is null or p_start<=now() or p_end<=p_start or p_end>p_start+interval '12 hours' or p_capacity is null or p_capacity<1 or p_capacity>500 then raise exception 'Check dates and capacity (1–500 seats, up to 12 hours)'; end if;
  insert into public.restaurant_slots(restaurant_id,starts_at,ends_at,capacity,is_open) values(p_listing,p_start,p_end,p_capacity,1) returning id into sid; return sid;
end $$;
create or replace function public.owner_add_reservation_slot(p_listing uuid,p_start timestamptz,p_end timestamptz,p_capacity integer) returns uuid language sql security invoker set search_path='' as $$ select travelmate_ui.add_slot(p_listing,p_start,p_end,p_capacity); $$;

revoke all on all functions in schema travelmate_ui from public,anon;
grant execute on all functions in schema travelmate_ui to authenticated;
revoke all on function public.record_ui_event(text,text,integer),public.workspace_overview(),public.reserve_my_booking(uuid,uuid,uuid,date,date,integer,text,text,text,text),public.workspace_reservations(),public.cancel_my_booking(uuid),public.owner_add_reservation_slot(uuid,timestamptz,timestamptz,integer) from public,anon;
grant execute on function public.record_ui_event(text,text,integer),public.workspace_overview(),public.reserve_my_booking(uuid,uuid,uuid,date,date,integer,text,text,text,text),public.workspace_reservations(),public.cancel_my_booking(uuid),public.owner_add_reservation_slot(uuid,timestamptz,timestamptz,integer) to authenticated;

-- Only a signature-verified Stripe webhook may confirm payment. The payment
-- ledger and booking status change together, once, in the same transaction.
create or replace function travelmate_ui.settle_payment(p_booking uuid,p_session text,p_amount_cents bigint,p_intent text)
returns void language plpgsql security definer set search_path='' as $$
declare b public.bookings;
begin
  select * into b from public.bookings where id=p_booking for update;
  if not found or b.stripe_session_id is distinct from p_session or round(b.total_amount*100)::bigint<>p_amount_cents then raise exception 'Payment does not match the reservation'; end if;
  if b.payment_status='paid' then return; end if;
  if b.status<>'pending' then raise exception 'Reservation is no longer payable'; end if;
  insert into public.payments(booking_id,method,provider,provider_reference,idempotency_key,amount,status,is_demo,paid_at)
  values(b.id,'card','stripe',p_session,'stripe_'||p_session,b.total_amount,'succeeded',0,now());
  update public.bookings set payment_status='paid',status='confirmed',stripe_payment_intent_id=p_intent where id=b.id;
end $$;
create or replace function public.settle_booking_payment(p_booking uuid,p_session text,p_amount_cents bigint,p_intent text)
returns void language sql security invoker set search_path='' as $$ select travelmate_ui.settle_payment(p_booking,p_session,p_amount_cents,p_intent); $$;
revoke all on function travelmate_ui.settle_payment(uuid,text,bigint,text),public.settle_booking_payment(uuid,text,bigint,text) from public,anon,authenticated;
grant usage on schema travelmate_ui to service_role;
grant execute on function travelmate_ui.settle_payment(uuid,text,bigint,text),public.settle_booking_payment(uuid,text,bigint,text) to service_role;
