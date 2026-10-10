-- Preview tickets persist separately from real bookings, inventory, payments and reviews.
create table public.sample_reservations (
 id uuid primary key default gen_random_uuid(),
 profile_id uuid not null references public.profiles(id) on delete cascade,
 listing_id uuid not null references public.business_listings(id),
 room_id uuid references public.rooms(id), slot_id uuid references public.restaurant_slots(id),
 check_in date, check_out date, guest_count integer not null check(guest_count between 1 and 100),
 guest_name text not null, guest_email text not null,
 request_key text not null check(length(request_key) between 16 and 100),
 listing_name text not null, booking_type text not null check(booking_type in ('hotel','restaurant')),
 room_label text, starts_at text not null, ends_at text,
 total_amount numeric not null check(total_amount>=0),
 status text not null default 'reserved' check(status in ('reserved','cancelled')),
 created_at timestamptz not null default now(),
 unique(profile_id,request_key)
);
create index sample_reservations_listing_idx on public.sample_reservations(listing_id);
create index sample_reservations_room_idx on public.sample_reservations(room_id);
create index sample_reservations_slot_idx on public.sample_reservations(slot_id);
alter table public.sample_reservations enable row level security;
revoke all on public.sample_reservations from public,anon,authenticated;
grant select on public.sample_reservations to authenticated;
grant insert(profile_id,listing_id,room_id,slot_id,check_in,check_out,guest_count,guest_name,guest_email,request_key) on public.sample_reservations to authenticated;
grant update(status) on public.sample_reservations to authenticated;
create policy own_sample_read on public.sample_reservations for select to authenticated using(profile_id=(select public.tm_active_profile_id()) and (select public.tm_has_role('traveler')) and not (select public.tm_has_role('business_owner')) and not (select public.tm_is_admin()));
create policy own_sample_insert on public.sample_reservations for insert to authenticated with check(profile_id=(select public.tm_active_profile_id()) and (select public.tm_has_role('traveler')) and not (select public.tm_has_role('business_owner')) and not (select public.tm_is_admin()));
create policy own_sample_cancel on public.sample_reservations for update to authenticated using(profile_id=(select public.tm_active_profile_id()) and status='reserved' and (select public.tm_has_role('traveler')) and not (select public.tm_has_role('business_owner')) and not (select public.tm_is_admin())) with check(profile_id=(select public.tm_active_profile_id()) and status='cancelled');

-- Every API insert is validated and its snapshot/estimate is calculated by the database.
create function public.validate_sample_reservation() returns trigger language plpgsql security invoker set search_path='' as $$
declare l public.business_listings; r public.rooms; s public.restaurant_slots;
begin
 if new.profile_id is distinct from public.tm_active_profile_id() or not public.tm_has_role('traveler') or public.tm_is_admin() or public.tm_has_role('business_owner') then raise exception 'Traveler account required';end if;
 if new.guest_name is null or length(trim(new.guest_name))<2 or length(new.guest_name)>150 or new.guest_email is null or new.guest_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' or length(new.guest_email)>150 then raise exception 'Check guest details';end if;
 select * into l from public.business_listings where id=new.listing_id and status='approved' and is_sample;
 if not found then raise exception 'Choose an available preview listing';end if;
 if l.listing_type='hotel' then
  if new.slot_id is not null or new.check_in is null or new.check_out is null or new.check_in<current_date or new.check_out<=new.check_in or new.check_out-new.check_in>90 then raise exception 'Choose valid dates, up to 90 nights';end if;
  select * into r from public.rooms where id=new.room_id and hotel_id=l.id and operational_status='available';
  if not found or r.max_guests<new.guest_count then raise exception 'Choose a room with space for all guests';end if;
  new.room_label:=r.room_type||' · Room '||r.room_number;
  new.starts_at:=new.check_in::text;new.ends_at:=new.check_out::text;
  new.total_amount:=r.base_nightly_rate*(new.check_out-new.check_in);
 elsif l.listing_type='restaurant' then
  if new.room_id is not null or new.check_in is not null or new.check_out is not null then raise exception 'Choose a restaurant time slot';end if;
  select * into s from public.restaurant_slots where id=new.slot_id and restaurant_id=l.id and is_open=1 and starts_at>now();
  if not found or s.capacity<new.guest_count then raise exception 'Choose an upcoming slot with enough seats';end if;
  new.starts_at:=s.starts_at::text;new.ends_at:=s.ends_at::text;
  select coalesce(reservation_fee,0) into new.total_amount from public.restaurants where restaurant_id=l.id;
 else raise exception 'Choose a hotel or restaurant';end if;
 new.listing_name:=regexp_replace(l.name,'\s*\(Demo\)\s*','','gi');new.booking_type:=l.listing_type;
 new.guest_name:=trim(new.guest_name);new.guest_email:=trim(new.guest_email);new.status:='reserved';
 return new;
end $$;
revoke all on function public.validate_sample_reservation() from public,anon,authenticated;
create trigger validate_sample_reservation before insert on public.sample_reservations for each row execute function public.validate_sample_reservation();

create function public.save_my_booking_preview(p_listing uuid,p_room uuid,p_slot uuid,p_check_in date,p_check_out date,p_guests integer,p_name text,p_email text,p_key text)
returns uuid language plpgsql security invoker set search_path='' as $$
declare b public.sample_reservations; u uuid:=public.tm_active_profile_id();
begin
 if u is null or not public.tm_has_role('traveler') or public.tm_is_admin() or public.tm_has_role('business_owner') then raise exception 'Traveler account required';end if;
 if p_key is null or length(p_key)<16 or length(p_key)>100 then raise exception 'Invalid reservation reference';end if;
 perform pg_advisory_xact_lock(hashtextextended(u::text||p_key,0));
 select * into b from public.sample_reservations where profile_id=u and request_key=p_key;
 if found then
  if b.listing_id is distinct from p_listing or b.room_id is distinct from p_room or b.slot_id is distinct from p_slot or b.check_in is distinct from p_check_in or b.check_out is distinct from p_check_out or b.guest_count is distinct from p_guests or b.guest_name is distinct from trim(p_name) or b.guest_email is distinct from trim(p_email) then raise exception 'Reference already used for different details';end if;
  if b.status='cancelled' then raise exception 'This preview was cancelled. Review new details to reserve again';end if;
  return b.id;
 end if;
 insert into public.sample_reservations(profile_id,listing_id,room_id,slot_id,check_in,check_out,guest_count,guest_name,guest_email,request_key)
 values(u,p_listing,p_room,p_slot,p_check_in,p_check_out,p_guests,p_name,p_email,p_key) returning id into b.id;
 return b.id;
end $$;
revoke all on function public.save_my_booking_preview(uuid,uuid,uuid,date,date,integer,text,text,text) from public,anon;
grant execute on function public.save_my_booking_preview(uuid,uuid,uuid,date,date,integer,text,text,text) to authenticated;
