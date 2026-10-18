-- Owner-only inventory summaries. Guest identities and payment details are never returned.
create function travelmate_ui.owner_availability(p_listing uuid,p_start date,p_end date) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare kind text;
begin
 if public.tm_active_profile_id() is null or not public.tm_has_role('business_owner') or not public.tm_owns_listing(p_listing) then
  raise exception 'Choose one of your own listings' using errcode='42501';
 end if;
 select listing_type::text into kind from public.business_listings where id=p_listing;
 if kind not in ('hotel','restaurant') then raise exception 'Choose a hotel or restaurant';end if;
 if kind='hotel' and (p_start is null or p_end is null or p_start<(now() at time zone 'Asia/Manila')::date or p_end<=p_start or p_end>p_start+90) then
  raise exception 'Choose a future stay of 1–90 nights';
 end if;
 return jsonb_build_object(
  'rooms',case when kind='hotel' then (select coalesce(jsonb_agg(x order by x.room_number),'[]'::jsonb) from (
   select r.id,r.room_number,r.room_type,r.max_guests,r.base_nightly_rate,r.operational_status,
    r.operational_status='available' and not exists(
     select 1 from public.booking_rooms br join public.hotel_bookings h on h.booking_id=br.booking_id join public.bookings b on b.id=h.booking_id
     where br.room_id=r.id and h.check_in<p_end and h.check_out>p_start
      and (b.status in ('confirmed','completed') or (b.status='pending' and (b.hold_expires_at>now() or b.stripe_session_id is not null)))) as available
   from public.rooms r where r.hotel_id=p_listing
  ) x) else '[]'::jsonb end,
  'slots',case when kind='restaurant' then (select coalesce(jsonb_agg(x order by x.starts_at),'[]'::jsonb) from (
   select s.id,s.starts_at,s.ends_at,s.capacity,s.is_open,
    greatest(0,s.capacity-coalesce((select sum(b.guest_count) from public.restaurant_bookings rb join public.bookings b on b.id=rb.booking_id
      where rb.slot_id=s.id and (b.status in ('confirmed','completed') or (b.status='pending' and (b.hold_expires_at>now() or b.stripe_session_id is not null)))),0)) as remaining
   from public.restaurant_slots s where s.restaurant_id=p_listing and s.starts_at>now() order by s.starts_at limit 100
  ) x) else '[]'::jsonb end);
end $$;
create function public.owner_availability(p_listing uuid,p_start date default null,p_end date default null) returns jsonb
language sql stable security invoker set search_path='' as $$select travelmate_ui.owner_availability(p_listing,p_start,p_end)$$;
revoke all on function travelmate_ui.owner_availability(uuid,date,date),public.owner_availability(uuid,date,date) from public,anon;
grant execute on function travelmate_ui.owner_availability(uuid,date,date),public.owner_availability(uuid,date,date) to authenticated;
notify pgrst,'reload schema';
