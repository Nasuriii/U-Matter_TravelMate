alter table public.business_listings add column is_sample boolean not null default false;
update public.business_listings l set is_sample=true from public.business_owners o join public.profiles p on p.id=o.profile_id where l.owner_id=o.id and l.name like '%(Demo)%' and p.full_name like '%(Demo)%';
create function travelmate_ui.protect_sample_flag() returns trigger language plpgsql security definer set search_path='' as $$ begin if auth.uid() is not null and ((TG_OP='INSERT' and new.is_sample) or (TG_OP='UPDATE' and new.is_sample is distinct from old.is_sample)) then raise exception 'Sample classification is managed by the catalog'; end if; return new; end $$;
revoke all on function travelmate_ui.protect_sample_flag() from public,anon,authenticated;
create trigger protect_sample_flag before insert or update of is_sample on public.business_listings for each row execute function travelmate_ui.protect_sample_flag();
alter table public.profiles add column sample_avatar_url text;
create table public.saved_places(id uuid primary key default gen_random_uuid(),profile_id uuid not null references public.profiles(id) on delete cascade,listing_id uuid references public.business_listings(id) on delete cascade,menu_item_id uuid references public.menu_items(id) on delete cascade,created_at timestamptz not null default now(),check ((listing_id is null)<>(menu_item_id is null)),unique(profile_id,listing_id),unique(profile_id,menu_item_id));
create index saved_places_menu_idx on public.saved_places(menu_item_id);
create index saved_places_listing_idx on public.saved_places(listing_id);
alter table public.saved_places enable row level security;
revoke all on public.saved_places from anon,authenticated;
grant select,insert,delete on public.saved_places to authenticated;
create policy own_favorites_read on public.saved_places for select to authenticated using(profile_id=(select public.tm_active_profile_id()) and (select public.tm_has_role('traveler')) and not (select public.tm_has_role('business_owner')) and not (select public.tm_is_admin()));
create policy own_favorites_delete on public.saved_places for delete to authenticated using(profile_id=(select public.tm_active_profile_id()) and (select public.tm_has_role('traveler')) and not (select public.tm_has_role('business_owner')) and not (select public.tm_is_admin()));
create policy own_favorites_insert on public.saved_places for insert to authenticated with check(profile_id=(select public.tm_active_profile_id()) and (select public.tm_has_role('traveler')) and not (select public.tm_has_role('business_owner')) and not (select public.tm_is_admin()) and (exists(select 1 from public.business_listings l where l.id=listing_id and l.status='approved') or exists(select 1 from public.menu_items m join public.business_listings l on l.id=m.restaurant_id where m.id=menu_item_id and m.is_available=1 and l.status='approved')));
create function public.set_saved_place(p_listing uuid,p_menu uuid,p_saved boolean) returns void language plpgsql security invoker set search_path='' as $$ declare u uuid:=public.tm_active_profile_id(); begin if u is null or not public.tm_has_role('traveler') or public.tm_has_role('business_owner') or public.tm_is_admin() then raise exception 'Traveler account required'; end if; if (p_listing is null)=(p_menu is null) or p_saved is null then raise exception 'Choose one place'; end if; if p_saved then insert into public.saved_places(profile_id,listing_id,menu_item_id) values(u,p_listing,p_menu) on conflict do nothing; else delete from public.saved_places where profile_id=u and (listing_id=p_listing or menu_item_id=p_menu); end if; end $$;
revoke all on function public.set_saved_place(uuid,uuid,boolean) from public,anon;
grant execute on function public.set_saved_place(uuid,uuid,boolean) to authenticated;
create table travelmate_ui.sample_business_metrics(listing_id uuid primary key references public.business_listings(id) on delete cascade,views integer not null check(views>=0),bookings integer not null check(bookings>=0),revenue numeric not null check(revenue>=0));
alter table travelmate_ui.sample_business_metrics enable row level security;
revoke all on travelmate_ui.sample_business_metrics from public,anon,authenticated;
create function travelmate_ui.sample_performance() returns jsonb language plpgsql stable security definer set search_path='' as $$ declare u uuid:=public.tm_active_profile_id(); begin if u is null or not (public.tm_is_admin() or public.tm_has_role('business_owner')) then raise exception 'Business workspace required'; end if; return (select jsonb_build_object('views',coalesce(sum(m.views),0),'bookings',coalesce(sum(m.bookings),0),'revenue',coalesce(sum(m.revenue),0),'businesses',coalesce(jsonb_agg(jsonb_build_object('id',l.id,'name',l.name,'views',m.views,'bookings',m.bookings,'revenue',m.revenue) order by l.name),'[]'::jsonb)) from travelmate_ui.sample_business_metrics m join public.business_listings l on l.id=m.listing_id join public.business_owners o on o.id=l.owner_id where l.is_sample and (o.profile_id=u or public.tm_is_admin())); end $$;
create function public.sample_performance() returns jsonb language sql stable security invoker set search_path='' as $$ select travelmate_ui.sample_performance(); $$;
revoke all on function travelmate_ui.sample_performance(),public.sample_performance() from public,anon;
grant execute on function travelmate_ui.sample_performance(),public.sample_performance() to authenticated;
-- Keep preview inventory out of real checkout; real booking validation is unchanged.
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
  if l.is_sample or l.name like '%(Demo)%' then raise exception 'This is a preview listing. No real reservation or payment is available'; end if;
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
-- Preview reviews are separate from authentic ratings. Existing review eligibility and grants remain intact.
create or replace function travelmate_ui.place_reviews(p_destination uuid,p_listing uuid,p_offset integer)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); kind text; allowed boolean:=false; booking uuid; own jsonb; result jsonb;
begin
 if (p_destination is null)=(p_listing is null) or p_offset is null or p_offset<0 then raise exception 'Choose one place and a valid page'; end if;
 if p_destination is not null then
  if not exists(select 1 from public.destinations where id=p_destination and is_active=1) then raise exception 'Destination unavailable'; end if;
  kind:='destination';
 else
  select listing_type into kind from public.business_listings where id=p_listing and status='approved';
  if not found then raise exception 'Listing unavailable'; end if;
 end if;
 if u is not null and public.tm_has_role('traveler') and not public.tm_has_role('business_owner') and not public.tm_has_role('admin') then
  booking:=travelmate_ui.review_booking(p_listing,u);
  allowed:=kind in ('destination','attraction') or booking is not null;
  select jsonb_build_object('rating',rating,'text',review_text,'status',status) into own from public.reviews where profile_id=u and (destination_id=p_destination or listing_id=p_listing);
  if own is not null and own->>'status'<>'published' then allowed:=false; end if;
 end if;
 select jsonb_build_object('total',count(*),'average',round(avg(rating),1)) into result from public.reviews r join public.profiles p on p.id=r.profile_id where r.status='published' and p.full_name not like '%(Demo)%' and (r.destination_id=p_destination or r.listing_id=p_listing);
 return result||jsonb_build_object('can_review',allowed,'verified_eligible',booking is not null,'mine',own,'kind',kind,'items',coalesce((
  select jsonb_agg(x.j order by x.created_at desc,x.id) from (
   select r.id,r.created_at,jsonb_build_object('id',r.id,'rating',r.rating,'text',r.review_text,'created_at',r.created_at,
    'author',coalesce(nullif(split_part(btrim(p.full_name),' ',1),''),'Traveler'),
    'verified',r.booking_id is not null and exists(select 1 from public.bookings b left join public.hotel_bookings h on h.booking_id=b.id left join public.restaurant_bookings rb on rb.booking_id=b.id left join public.restaurant_slots s on s.id=rb.slot_id where b.id=r.booking_id and b.profile_id=r.profile_id and b.status='completed' and (b.total_amount=0 or b.payment_status='paid') and travelmate_ui.booking_visit_end(b.id)<=now() and coalesce(h.hotel_id,s.restaurant_id)=r.listing_id)) j
   from public.reviews r join public.profiles p on p.id=r.profile_id where r.status='published' and p.full_name not like '%(Demo)%' and (r.destination_id=p_destination or r.listing_id=p_listing)
   order by r.created_at desc,r.id limit 10 offset p_offset
  )x),'[]'::jsonb),'sample_items',coalesce((
 select jsonb_agg(x.j order by x.created_at desc,x.id) from (
  select r.id,r.created_at,jsonb_build_object('id',r.id,'rating',r.rating,'text',r.review_text,'created_at',r.created_at,
   'author',coalesce(nullif(split_part(btrim(p.full_name),' ',1),''),'Traveler'),'verified',false,'sample',true,'avatar',p.sample_avatar_url) j
  from public.reviews r join public.profiles p on p.id=r.profile_id
  where r.status='published' and p.full_name like '%(Demo)%' and (r.destination_id=p_destination or r.listing_id=p_listing)
  order by r.created_at desc,r.id limit 3
 )x),'[]'::jsonb));
end $$;

notify pgrst,'reload schema';
