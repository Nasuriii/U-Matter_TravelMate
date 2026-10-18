-- Complete restaurant submissions: preserve existing role and ownership guards.
BEGIN;

CREATE OR REPLACE FUNCTION public.owner_create_listing(p_type text, p_destination uuid, p_name text, p_description text, p_address text, p_check_in time without time zone DEFAULT NULL::time without time zone, p_check_out time without time zone DEFAULT NULL::time without time zone, p_operating_hours text DEFAULT NULL::text, p_reservation_fee numeric DEFAULT 0, p_entrance_fee numeric DEFAULT NULL::numeric, p_schedule_day text DEFAULT NULL::text, p_schedule_text text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE v_owner uuid; v_id uuid; v_slug text;
BEGIN
  IF p_type NOT IN ('hotel','restaurant','attraction') THEN RAISE EXCEPTION 'Invalid listing type'; END IF;
  IF btrim(coalesce(p_name,'')) = '' THEN RAISE EXCEPTION 'Name is required'; END IF;
  SELECT o.id INTO v_owner FROM public.business_owners o WHERE o.profile_id = (SELECT public.tm_active_profile_id());
  IF v_owner IS NULL THEN RAISE EXCEPTION 'Only business owners can create listings'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.destinations WHERE id = p_destination AND is_active = 1) THEN RAISE EXCEPTION 'Unknown destination'; END IF;
  IF p_type = 'restaurant' AND btrim(coalesce(p_operating_hours,'')) = '' THEN RAISE EXCEPTION 'Restaurant operating hours are required'; END IF;
  v_slug := trim(both '-' from regexp_replace(lower(btrim(p_name)), '[^a-z0-9]+', '-', 'g')) || '-' || substr(replace(gen_random_uuid()::text,'-',''),1,6);
  INSERT INTO public.business_listings(owner_id,destination_id,name,slug,listing_type,description,address,status)
  VALUES (v_owner,p_destination,btrim(p_name),v_slug,p_type,nullif(btrim(coalesce(p_description,'')),''),nullif(btrim(coalesce(p_address,'')),''),'pending')
  RETURNING id INTO v_id;
  IF p_type = 'hotel' THEN
    INSERT INTO public.hotels(hotel_id,check_in_time,check_out_time) VALUES (v_id,p_check_in,p_check_out);
  ELSIF p_type = 'restaurant' THEN
    INSERT INTO public.restaurants(restaurant_id,operating_hours,reservation_fee) VALUES (v_id,p_operating_hours,coalesce(p_reservation_fee,0));
  ELSE
    INSERT INTO public.attractions(attraction_id,entrance_fee) VALUES (v_id,p_entrance_fee);
    IF btrim(coalesce(p_schedule_text,'')) <> '' THEN
      INSERT INTO public.attraction_schedules(attraction_id,operating_day,schedule_text)
      VALUES (v_id,coalesce(nullif(p_schedule_day,''),'Daily'),btrim(p_schedule_text));
    END IF;
  END IF;
  RETURN v_id;
END $function$;

CREATE OR REPLACE FUNCTION public.owner_update_details(p_listing uuid, p_check_in time without time zone, p_check_out time without time zone, p_hours text, p_resfee numeric, p_fee numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE v_type text;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  SELECT listing_type INTO v_type FROM public.business_listings WHERE id = p_listing;
  IF v_type = 'hotel' THEN
    IF p_check_in IS NULL OR p_check_out IS NULL THEN RAISE EXCEPTION 'Check-in and check-out times are required'; END IF;
    IF p_check_out >= p_check_in THEN RAISE EXCEPTION 'Check-out time must be earlier than check-in time (for example check-in 14:00, check-out 11:00)'; END IF;
    UPDATE public.hotels SET check_in_time = p_check_in, check_out_time = p_check_out
     WHERE hotel_id = p_listing AND (check_in_time IS DISTINCT FROM p_check_in OR check_out_time IS DISTINCT FROM p_check_out);
    IF FOUND THEN
      UPDATE public.business_listings SET status = CASE WHEN status = 'inactive' THEN 'inactive' ELSE 'pending' END WHERE id = p_listing;
    END IF;
  ELSIF v_type = 'restaurant' THEN
    IF btrim(coalesce(p_hours,'')) = '' THEN RAISE EXCEPTION 'Restaurant operating hours are required'; END IF;
    UPDATE public.restaurants SET operating_hours = nullif(btrim(coalesce(p_hours, '')), ''), reservation_fee = coalesce(p_resfee, 0) WHERE restaurant_id = p_listing;
  ELSE
    UPDATE public.attractions SET entrance_fee = p_fee WHERE attraction_id = p_listing;
  END IF;
END $function$;

CREATE OR REPLACE FUNCTION public.tm_listing_problems(p_listing uuid)
 RETURNS text[]
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE t text; v text[] := '{}'; r record; a record;
BEGIN
  SELECT listing_type INTO t FROM public.business_listings WHERE id = p_listing;
  IF t IS NULL THEN RETURN ARRAY['Listing not found']; END IF;
  IF t = 'hotel' THEN
    RETURN public.tm_hotel_problems(p_listing);
  ELSIF t = 'restaurant' THEN
    SELECT operating_hours INTO r FROM public.restaurants WHERE restaurant_id = p_listing;
    IF NOT FOUND THEN RETURN ARRAY['This listing has no restaurant details']; END IF;
    IF btrim(coalesce(r.operating_hours, '')) = '' THEN v := array_append(v, 'Add the operating hours'); END IF;
    IF NOT EXISTS (SELECT 1 FROM public.menu_items WHERE restaurant_id = p_listing AND is_available = 1) THEN
      v := array_append(v, 'Add at least one available menu item');
    END IF;
    IF EXISTS (SELECT 1 FROM public.menu_items m WHERE m.restaurant_id = p_listing
               AND NOT EXISTS (SELECT 1 FROM public.photos p WHERE p.menu_item_id = m.id AND p.status IN ('pending','approved'))) THEN
      v := array_append(v, 'Add a dish photo for every menu item');
    END IF;
  ELSIF t = 'attraction' THEN
    SELECT entrance_fee INTO a FROM public.attractions WHERE attraction_id = p_listing;
    IF NOT FOUND THEN RETURN ARRAY['This listing has no attraction details']; END IF;
    IF a.entrance_fee IS NULL THEN v := array_append(v, 'Set the entrance fee (0 means free entry)'); END IF;
    IF NOT EXISTS (SELECT 1 FROM public.attraction_schedules WHERE attraction_id = p_listing) THEN
      v := array_append(v, 'Add at least one operating day');
    END IF;
  END IF;
  RETURN v;
END $function$;

CREATE OR REPLACE FUNCTION public.admin_review_queue()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((
    SELECT jsonb_agg(x.j ORDER BY x.created) FROM (
      SELECT l.created_at AS created,
        jsonb_build_object(
          'id', l.id, 'name', l.name, 'type', l.listing_type, 'address', l.address, 'description', l.description,
          'destination', d.name || ', ' || d.province, 'owner', o.contact_name, 'owner_email', o.contact_email,
          'submitted', l.updated_at, 'problems', to_jsonb(public.tm_listing_problems(l.id)))
        || CASE l.listing_type
          WHEN 'hotel' THEN jsonb_build_object(
            'check_in', h.check_in_time, 'check_out', h.check_out_time,
            'rooms', (SELECT coalesce(jsonb_agg(jsonb_build_object('room_number', r.room_number, 'room_type', r.room_type,
                        'max_guests', r.max_guests, 'rate', r.base_nightly_rate, 'status', r.operational_status) ORDER BY r.room_number), '[]'::jsonb)
                      FROM public.rooms r WHERE r.hotel_id = l.id),
            'amenities', (SELECT coalesce(jsonb_agg(a.name ORDER BY a.name), '[]'::jsonb)
                          FROM public.hotel_amenities ha JOIN public.amenities a ON a.id = ha.amenity_id WHERE ha.hotel_id = l.id))
          WHEN 'restaurant' THEN jsonb_build_object(
            'operating_hours', rs.operating_hours, 'reservation_fee', rs.reservation_fee,
            'slots', (SELECT coalesce(jsonb_agg(jsonb_build_object('id', s.id, 'starts_at', s.starts_at, 'ends_at', s.ends_at, 'capacity', s.capacity, 'is_open', s.is_open = 1) ORDER BY s.starts_at), '[]'::jsonb)
                      FROM (SELECT id, starts_at, ends_at, capacity, is_open FROM public.restaurant_slots WHERE restaurant_id=l.id AND starts_at>now() ORDER BY starts_at LIMIT 100) s),
            'menu', (SELECT coalesce(jsonb_agg(jsonb_build_object('id', m.id, 'name', m.name, 'category', m.category, 'description', m.description, 'price', m.price, 'has_photo', EXISTS (SELECT 1 FROM public.photos p WHERE p.menu_item_id = m.id AND p.status IN ('pending','approved')),
                        'available', m.is_available = 1) ORDER BY m.name), '[]'::jsonb)
                     FROM public.menu_items m WHERE m.restaurant_id = l.id),
            'cuisines', (SELECT coalesce(jsonb_agg(c.name ORDER BY c.name), '[]'::jsonb)
                         FROM public.restaurant_cuisines rc JOIN public.cuisines c ON c.id = rc.cuisine_id WHERE rc.restaurant_id = l.id))
          WHEN 'attraction' THEN jsonb_build_object(
            'entrance_fee', at.entrance_fee,
            'schedule', (SELECT coalesce(jsonb_agg(jsonb_build_object('day', s.operating_day, 'hours', s.schedule_text) ORDER BY s.operating_day), '[]'::jsonb)
                         FROM public.attraction_schedules s WHERE s.attraction_id = l.id))
          ELSE '{}'::jsonb END AS j
      FROM public.business_listings l
      JOIN public.business_owners o ON o.id = l.owner_id
      JOIN public.destinations d ON d.id = l.destination_id
      LEFT JOIN public.hotels h ON h.hotel_id = l.id
      LEFT JOIN public.restaurants rs ON rs.restaurant_id = l.id
      LEFT JOIN public.attractions at ON at.attraction_id = l.id
      WHERE l.status = 'pending'
    ) x), '[]'::jsonb);
END $function$;

CREATE OR REPLACE FUNCTION public.admin_listing_photos(p_listing uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', p.id, 'object_path', p.object_path, 'status', p.status, 'menu_item_id', p.menu_item_id, 'menu_name', (SELECT m.name FROM public.menu_items m WHERE m.id = p.menu_item_id)) ORDER BY p.sort_order, p.created_at)
                   FROM public.photos p WHERE p.listing_id = p_listing), '[]'::jsonb);
END $function$;

NOTIFY pgrst, 'reload schema';
COMMIT;
