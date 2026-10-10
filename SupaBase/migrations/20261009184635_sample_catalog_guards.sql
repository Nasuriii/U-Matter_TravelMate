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
  if l.name like '%(Demo)%' and exists(select 1 from public.business_owners o join public.profiles p on p.id=o.profile_id where o.id=l.owner_id and p.full_name like '%(Demo)%') then raise exception 'This is a preview listing. No real reservation or payment is available'; end if;
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
create or replace function travelmate_ui.recent_traveler_reviews()
returns jsonb language sql stable security definer set search_path='' as $$
 select coalesce(jsonb_agg(x.j order by x.created_at desc),'[]'::jsonb) from (
  select r.created_at,jsonb_build_object('rating',r.rating,'review_text',r.review_text,
    'destinations',case when d.id is not null then jsonb_build_object('name',d.name) end,
    'business_listings',case when l.id is not null then jsonb_build_object('name',l.name) end) j
  from public.reviews r join public.profiles p on p.id=r.profile_id
  left join public.destinations d on d.id=r.destination_id
  left join public.business_listings l on l.id=r.listing_id
  where r.status='published' and p.full_name not like '%(Demo)%'
   and (d.is_active=1 or l.status='approved')
  order by r.created_at desc,r.id limit 100
 )x;
$$;
create or replace function public.recent_traveler_reviews()
returns jsonb language sql stable security invoker set search_path='' as $$ select travelmate_ui.recent_traveler_reviews(); $$;
revoke all on function travelmate_ui.recent_traveler_reviews(),public.recent_traveler_reviews() from public;
grant execute on function travelmate_ui.recent_traveler_reviews(),public.recent_traveler_reviews() to anon,authenticated;
notify pgrst,'reload schema';
