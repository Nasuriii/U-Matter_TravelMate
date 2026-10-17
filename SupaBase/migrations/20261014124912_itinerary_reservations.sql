-- Save the current plan, reserve inventory and attach the booking atomically.
-- A trip link is visible during checkout; payment status still comes from bookings.
create function travelmate_ui.reserve_trip_booking(
 p_trip uuid,p_day date,p_expected_updated_at timestamptz,p_items jsonb,p_days jsonb,
 p_listing uuid,p_room uuid,p_slot uuid,p_check_in date,p_check_out date,
 p_guests integer,p_name text,p_email text,p_phone text,p_key text
) returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id();t public.trips;bid uuid;saved timestamptz;b record;a record;
begin
 if u is null or not public.tm_can_plan() then raise exception 'An active traveler account is required' using errcode='42501';end if;
 if p_key is null or length(p_key)<16 or length(p_key)>100 then raise exception 'Invalid reservation reference';end if;
 perform pg_advisory_xact_lock(hashtextextended(p_key,0));
 select * into t from public.trips where id=p_trip and profile_id=u for update;
 if not found or t.status<>'draft' then raise exception 'Your own editable trip is required' using errcode='42501';end if;
 if p_day is null or p_day not between t.start_date and t.end_date then raise exception 'Choose a day within your trip';end if;
 -- The underlying reservation checks the owner and exact details on every retry.
 select id into bid from public.bookings where idempotency_key=p_key;
 if bid is not null then
  bid:=travelmate_ui.reserve(p_listing,p_room,p_slot,p_check_in,p_check_out,p_guests,p_name,p_email,p_phone,p_key);
  select * into a from travelmate_ui.trip_booking_attachments where booking_id=bid;
  if not found or a.trip_id<>p_trip or a.profile_id<>u or a.planned_date<>p_day then raise exception 'Reservation reference already used outside this trip';end if;
  select * into b from public.bookings where id=bid and profile_id=u;
  return jsonb_build_object('booking_id',bid,'updated_at',t.updated_at,'status',b.status,'amount',b.total_amount,'is_test',b.is_test);
 end if;
 saved:=public.save_my_trip_plan(p_trip,p_expected_updated_at,p_items,p_days);
 bid:=travelmate_ui.reserve(p_listing,p_room,p_slot,p_check_in,p_check_out,p_guests,p_name,p_email,p_phone,p_key);
 select * into b from travelmate_ui.trip_booking_details where booking_id=bid and profile_id=u;
 if not found or b.start_date<t.start_date or b.end_date>t.end_date then raise exception 'Reservation dates must stay within this trip';end if;
 if b.booking_type='restaurant' and b.start_date<>p_day then raise exception 'Choose a table time on this trip day';end if;
 if not exists(select 1 from jsonb_array_elements(p_items) x where (x->>'listing_id')=p_listing::text and (x->>'planned_date')=p_day::text) then
  raise exception 'Include the selected place in this day plan';end if;
 if b.booking_type='restaurant' and not exists(select 1 from jsonb_array_elements(p_items) x where
  x->>'listing_id'=p_listing::text and x->>'planned_date'=p_day::text and
  (x->>'planned_time')::time=b.start_time and (x->>'planned_end_time')::time=b.end_time) then
  raise exception 'The planned stop must use the reserved table time';end if;
 insert into travelmate_ui.trip_booking_attachments(trip_id,profile_id,booking_id,planned_date) values(p_trip,u,bid,p_day);
 return jsonb_build_object('booking_id',bid,'updated_at',saved,'status',b.status,'amount',b.amount,'is_test',b.is_test);
end $$;
create function public.reserve_my_trip_booking(
 p_trip uuid,p_day date,p_expected_updated_at timestamptz,p_items jsonb,p_days jsonb,
 p_listing uuid,p_room uuid,p_slot uuid,p_check_in date,p_check_out date,
 p_guests integer,p_name text,p_email text,p_phone text,p_key text
) returns jsonb language sql security invoker set search_path='' as $$
 select travelmate_ui.reserve_trip_booking(p_trip,p_day,p_expected_updated_at,p_items,p_days,p_listing,p_room,p_slot,p_check_in,p_check_out,p_guests,p_name,p_email,p_phone,p_key)
$$;

-- Read availability for the chosen dates; reserve() locks and checks again.
create function travelmate_ui.trip_reservation_options(p_listing uuid,p_start date,p_end date) returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if public.tm_active_profile_id() is null or not public.tm_can_plan() then raise exception 'An active traveler account is required' using errcode='42501';end if;
 if not exists(select 1 from public.business_listings where id=p_listing and status='approved') then raise exception 'Listing unavailable';end if;
 return jsonb_build_object(
 'rooms',(select coalesce(jsonb_agg(r.id),'[]'::jsonb) from public.rooms r where r.hotel_id=p_listing and r.operational_status='available'
  and p_start is not null and p_end>p_start and not exists(
   select 1 from public.booking_rooms br join public.hotel_bookings h on h.booking_id=br.booking_id join public.bookings b on b.id=h.booking_id
   where br.room_id=r.id and h.check_in<p_end and h.check_out>p_start
    and (b.status in ('confirmed','completed') or (b.status='pending' and (b.hold_expires_at>now() or b.stripe_session_id is not null))))),
 'slots',(select coalesce(jsonb_agg(jsonb_build_object('id',s.id,'remaining',greatest(0,s.capacity-coalesce((select sum(b.guest_count) from public.restaurant_bookings rb join public.bookings b on b.id=rb.booking_id where rb.slot_id=s.id and (b.status in ('confirmed','completed') or (b.status='pending' and (b.hold_expires_at>now() or b.stripe_session_id is not null)))),0)))),'[]'::jsonb)
  from public.restaurant_slots s where s.restaurant_id=p_listing and s.is_open=1 and s.starts_at>now()));
end $$;
create function public.my_trip_reservation_options(p_listing uuid,p_start date,p_end date) returns jsonb
language sql stable security invoker set search_path='' as $$select travelmate_ui.trip_reservation_options(p_listing,p_start,p_end)$$;
revoke all on function travelmate_ui.reserve_trip_booking(uuid,date,timestamptz,jsonb,jsonb,uuid,uuid,uuid,date,date,integer,text,text,text,text),public.reserve_my_trip_booking(uuid,date,timestamptz,jsonb,jsonb,uuid,uuid,uuid,date,date,integer,text,text,text,text),travelmate_ui.trip_reservation_options(uuid,date,date),public.my_trip_reservation_options(uuid,date,date) from public,anon;
grant execute on function travelmate_ui.reserve_trip_booking(uuid,date,timestamptz,jsonb,jsonb,uuid,uuid,uuid,date,date,integer,text,text,text,text),public.reserve_my_trip_booking(uuid,date,timestamptz,jsonb,jsonb,uuid,uuid,uuid,date,date,integer,text,text,text,text),travelmate_ui.trip_reservation_options(uuid,date,date),public.my_trip_reservation_options(uuid,date,date) to authenticated;

-- Add hold and test labels without changing the paid-booking attachment picker.
do $$declare definition text;begin
 select pg_get_functiondef('travelmate_ui.trip_booking_catalog(uuid)'::regprocedure) into definition;
 if position('a.provider,coalesce(a.reference' in definition)=0 then raise exception 'Unexpected trip booking catalog definition';end if;
 definition:=replace(definition,'a.provider,coalesce(a.reference','coalesce(b.is_test,false) as is_test,(select bk.hold_expires_at from public.bookings bk where bk.id=a.booking_id) as hold_expires_at,a.provider,coalesce(a.reference');
 execute definition;
end $$;
notify pgrst,'reload schema';
