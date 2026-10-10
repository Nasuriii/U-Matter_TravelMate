begin;
alter table public.bookings add column is_test boolean not null default false;
alter table public.bookings add constraint test_bookings_no_payments check(not is_test or (payment_status='unpaid' and stripe_session_id is null and stripe_payment_intent_id is null));
alter table public.business_listings add column contact_phone text, add column contact_email text, add column contact_website text;
alter table public.destinations add column address text, add column contact_phone text, add column contact_email text, add column contact_website text;
create function public.protect_test_booking() returns trigger language plpgsql security invoker set search_path='' as $$ begin
 if current_user in ('anon','authenticated') and ((TG_OP='INSERT' and new.is_test) or (TG_OP='UPDATE' and new.is_test is distinct from old.is_test)) then raise exception 'Test booking classification is managed by reservations';end if;return new;end $$;
revoke all on function public.protect_test_booking() from public,anon,authenticated;
create trigger protect_test_booking before insert or update of is_test on public.bookings for each row execute function public.protect_test_booking();
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
  -- Seeded inventory uses the same availability mechanics, with charges disabled.
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
  insert into public.bookings(profile_id,booking_type,guest_name,guest_email,guest_phone,guest_count,total_amount,status,hold_expires_at,idempotency_key,payment_status,is_test)
  values(u,l.listing_type,trim(p_name),trim(p_email),nullif(trim(p_phone),''),p_guests,amount,case when amount=0 or l.is_sample then 'confirmed' else 'pending' end,case when amount>0 and not l.is_sample then now()+interval '35 minutes' else null end,p_key,'unpaid',l.is_sample) returning id into bid;
  if l.listing_type='hotel' then
    insert into public.hotel_bookings(booking_id,hotel_id,check_in,check_out) values(bid,l.id,p_check_in,p_check_out);
    insert into public.booking_rooms(booking_id,room_id,nightly_rate) values(bid,r.id,r.base_nightly_rate);
  else insert into public.restaurant_bookings(booking_id,slot_id) values(bid,s.id); end if;
  return bid;
end $$;
create or replace function travelmate_ui.reservations()
returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); o uuid; a boolean;
begin
  if u is null then raise exception 'Sign in to an active account'; end if;
  a:=public.tm_is_admin(); select id into o from public.business_owners where profile_id=u and public.tm_has_role('business_owner');
  return (select coalesce(jsonb_agg(row),'[]'::jsonb) from (select b.id,b.is_test,b.booking_type,b.guest_name,b.guest_email,b.guest_phone,b.guest_count,b.total_amount,b.status,b.payment_status,b.created_at,b.hold_expires_at,
    coalesce(h.check_in::text,s.starts_at::text) starts_at,h.check_out ends_at,regexp_replace(coalesce(lh.name,lr.name),'\s*\(Demo\)\s*','','gi') listing_name,coalesce(lh.id,lr.id) listing_id,
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
  if b.payment_status='paid' or (b.status<>'pending' and not (b.is_test and b.status='confirmed')) or b.stripe_session_id is not null then raise exception 'Paid or checkout-active reservations cannot be cancelled here. Contact the business for assistance.'; end if;
  update public.bookings set status='cancelled' where id=b.id;
end $$;
create or replace function public.cancel_my_booking(p_booking uuid) returns void language sql security invoker set search_path='' as $$ select travelmate_ui.cancel_reservation(p_booking); $$;

create or replace function travelmate_ui.complete_owner_booking(p_booking uuid)
returns void language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); b public.bookings; lid uuid;
begin
 if u is null or not public.tm_has_role('business_owner') or public.tm_has_role('admin') then raise exception 'Business owner access required'; end if;
 select * into b from public.bookings where id=p_booking for update;
 select coalesce(h.hotel_id,s.restaurant_id) into lid from public.bookings bk
 left join public.hotel_bookings h on h.booking_id=bk.id left join public.restaurant_bookings r on r.booking_id=bk.id
 left join public.restaurant_slots s on s.id=r.slot_id where bk.id=p_booking;
 if not exists(select 1 from public.business_listings l join public.business_owners o on o.id=l.owner_id where l.id=lid and o.profile_id=u) then raise exception 'Reservation not found for your business'; end if;
 if b.status='completed' then return; end if;
 if b.status<>'confirmed' or (not b.is_test and b.total_amount>0 and b.payment_status is distinct from 'paid') then raise exception 'Only a confirmed, paid reservation can be completed'; end if;
 if travelmate_ui.booking_visit_end(p_booking) is null or travelmate_ui.booking_visit_end(p_booking)>now() then raise exception 'Wait until the stay or reservation has ended'; end if;
 update public.bookings set status='completed',updated_at=now() where id=p_booking;
 insert into public.notifications(id,profile_id,message,created_at) values(gen_random_uuid(),b.profile_id,case when b.is_test then 'Your test reservation is complete. Open Bookings & tickets to see your record.' else 'Your visit is complete. Open Bookings & tickets to review your experience.' end,now());
end $$;
create or replace function travelmate_ui.review_booking(p_listing uuid,p_profile uuid)
returns uuid language sql stable security definer set search_path='' as $$
 select b.id from public.bookings b
 left join public.hotel_bookings h on h.booking_id=b.id
 left join public.restaurant_bookings r on r.booking_id=b.id left join public.restaurant_slots s on s.id=r.slot_id
 where not b.is_test and b.profile_id=p_profile and b.status='completed' and (b.total_amount=0 or b.payment_status='paid')
 and coalesce(h.hotel_id,s.restaurant_id)=p_listing and travelmate_ui.booking_visit_end(b.id)<=now()
 order by b.updated_at desc,b.id limit 1;
$$;

create function travelmate_ui.set_listing_contact(p_listing uuid,p_phone text,p_email text,p_website text) returns void language plpgsql security definer set search_path='' as $$
begin
 if public.tm_active_profile_id() is null or not public.tm_has_role('business_owner') or public.tm_is_admin() or not public.tm_owns_listing(p_listing) then raise exception 'Business owner access required';end if;
 if length(coalesce(p_phone,''))>30 or (nullif(trim(p_phone),'') is not null and p_phone !~ '^\+?[0-9 ()-]{7,30}$') or length(coalesce(p_email,''))>150 or (nullif(trim(p_email),'') is not null and p_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$') or length(coalesce(p_website,''))>500 or (nullif(trim(p_website),'') is not null and p_website !~ '^https?://[^[:space:]]+$') then raise exception 'Check the contact number, email and website';end if;
 update public.business_listings set contact_phone=nullif(trim(p_phone),''),contact_email=nullif(trim(p_email),''),contact_website=nullif(trim(p_website),''),status=case when status='approved' then 'pending' else status end where id=p_listing;
end $$;
create function public.owner_set_listing_contact(p_listing uuid,p_phone text,p_email text,p_website text) returns void language sql security invoker set search_path='' as $$ select travelmate_ui.set_listing_contact(p_listing,p_phone,p_email,p_website);$$;
revoke all on function travelmate_ui.set_listing_contact(uuid,text,text,text),public.owner_set_listing_contact(uuid,text,text,text) from public,anon;
grant execute on function travelmate_ui.set_listing_contact(uuid,text,text,text),public.owner_set_listing_contact(uuid,text,text,text) to authenticated;
create function travelmate_ui.listing_contact_for_admin(p_listing uuid) returns jsonb language plpgsql stable security definer set search_path='' as $$ begin
 if public.tm_active_profile_id() is null or not public.tm_is_admin() then raise exception 'Administrator access required';end if;
 return (select jsonb_build_object('phone',contact_phone,'email',contact_email,'website',contact_website) from public.business_listings where id=p_listing);
end $$;
create function public.admin_listing_contact(p_listing uuid) returns jsonb language sql stable security invoker set search_path='' as $$ select travelmate_ui.listing_contact_for_admin(p_listing);$$;
revoke all on function travelmate_ui.listing_contact_for_admin(uuid),public.admin_listing_contact(uuid) from public,anon;
grant execute on function travelmate_ui.listing_contact_for_admin(uuid),public.admin_listing_contact(uuid) to authenticated;
create function public.review_has_inappropriate_words(p_text text) returns boolean language sql immutable security invoker set search_path='' as $$
 select regexp_replace(lower(translate(normalize(coalesce(p_text,''),NFKD),'013457@$!','oieastasi')),'[̀-ͯ​-‍﻿]','','g') ~ '(^|[^a-z])(f+[^a-z]*u+[^a-z]*c+[^a-z]*k+|f+[^a-z]*u+[^a-z]*c+[^a-z]*k+[^a-z]*e+[^a-z]*r+|f+[^a-z]*u+[^a-z]*c+[^a-z]*k+[^a-z]*e+[^a-z]*r+[^a-z]*s+|f+[^a-z]*u+[^a-z]*c+[^a-z]*k+[^a-z]*i+[^a-z]*n+[^a-z]*g+|f+[^a-z]*u+[^a-z]*c+[^a-z]*k+[^a-z]*e+[^a-z]*d+|m+[^a-z]*o+[^a-z]*t+[^a-z]*h+[^a-z]*e+[^a-z]*r+[^a-z]*f+[^a-z]*u+[^a-z]*c+[^a-z]*k+[^a-z]*e+[^a-z]*r+|s+[^a-z]*h+[^a-z]*i+[^a-z]*t+|s+[^a-z]*h+[^a-z]*i+[^a-z]*t+[^a-z]*s+|s+[^a-z]*h+[^a-z]*i+[^a-z]*t+[^a-z]*t+[^a-z]*y+|b+[^a-z]*u+[^a-z]*l+[^a-z]*l+[^a-z]*s+[^a-z]*h+[^a-z]*i+[^a-z]*t+|b+[^a-z]*i+[^a-z]*t+[^a-z]*c+[^a-z]*h+|b+[^a-z]*i+[^a-z]*t+[^a-z]*c+[^a-z]*h+[^a-z]*e+[^a-z]*s+|c+[^a-z]*u+[^a-z]*n+[^a-z]*t+|c+[^a-z]*u+[^a-z]*n+[^a-z]*t+[^a-z]*s+|a+[^a-z]*s+[^a-z]*s+[^a-z]*h+[^a-z]*o+[^a-z]*l+[^a-z]*e+|a+[^a-z]*s+[^a-z]*s+[^a-z]*h+[^a-z]*o+[^a-z]*l+[^a-z]*e+[^a-z]*s+|b+[^a-z]*a+[^a-z]*s+[^a-z]*t+[^a-z]*a+[^a-z]*r+[^a-z]*d+|b+[^a-z]*a+[^a-z]*s+[^a-z]*t+[^a-z]*a+[^a-z]*r+[^a-z]*d+[^a-z]*s+|d+[^a-z]*i+[^a-z]*c+[^a-z]*k+[^a-z]*h+[^a-z]*e+[^a-z]*a+[^a-z]*d+|n+[^a-z]*i+[^a-z]*g+[^a-z]*g+[^a-z]*e+[^a-z]*r+|f+[^a-z]*a+[^a-z]*g+[^a-z]*g+[^a-z]*o+[^a-z]*t+|p+[^a-z]*u+[^a-z]*t+[^a-z]*a+[^a-z]*n+[^a-z]*g+[^a-z]*i+[^a-z]*n+[^a-z]*a+|t+[^a-z]*a+[^a-z]*n+[^a-z]*g+[^a-z]*i+[^a-z]*n+[^a-z]*a+[^a-z]*m+[^a-z]*o+|p+[^a-z]*u+[^a-z]*t+[^a-z]*a+[^a-z]*n+[^a-z]*g+[^a-z]*i+[^a-z]*n+[^a-z]*a+[^a-z]*m+[^a-z]*o+|p+[^a-z]*u+[^a-z]*t+[^a-z]*a+[^a-z]*h+[^a-z]*a+[^a-z]*n+[^a-z]*g+[^a-z]*i+[^a-z]*n+[^a-z]*a+|t+[^a-z]*a+[^a-z]*n+[^a-z]*g+[^a-z]*i+[^a-z]*n+[^a-z]*a+|t+[^a-z]*a+[^a-z]*n+[^a-z]*g+[^a-z]*i+[^a-z]*n+[^a-z]*a+[^a-z]*m+[^a-z]*o+|p+[^a-z]*u+[^a-z]*t+[^a-z]*a+|g+[^a-z]*a+[^a-z]*g+[^a-z]*o+|u+[^a-z]*l+[^a-z]*o+[^a-z]*l+|p+[^a-z]*a+[^a-z]*k+[^a-z]*y+[^a-z]*u+|h+[^a-z]*i+[^a-z]*n+[^a-z]*d+[^a-z]*u+[^a-z]*t+|u+[^a-z]*k+[^a-z]*i+[^a-z]*n+[^a-z]*n+[^a-z]*a+[^a-z]*m+)($|[^a-z])';
$$;
create function public.reject_inappropriate_review() returns trigger language plpgsql security invoker set search_path='' as $$ begin
 if new.status='published' and public.review_has_inappropriate_words(new.review_text) then raise exception 'REVIEW_INAPPROPRIATE_WORDS';end if;return new;end $$;
revoke all on function public.reject_inappropriate_review() from public,anon,authenticated;
create trigger reject_inappropriate_review before insert or update of review_text,status on public.reviews for each row execute function public.reject_inappropriate_review();
revoke all on function public.review_has_inappropriate_words(text) from public,anon;
grant execute on function public.review_has_inappropriate_words(text) to authenticated;
notify pgrst,'reload schema';
commit;
