-- TravelMate: owner write actions as functions (no table GRANTs are changed).
-- Why: role 'authenticated' only has SELECT on business_listings, rooms, menu_items, hotels and
-- attraction_schedules, so direct INSERT/UPDATE/DELETE from the browser is refused. These
-- SECURITY DEFINER functions do the write after checking the caller owns the listing.
-- Run once in Supabase > SQL Editor AFTER 06_owner_listings.sql. Safe to re-run.
BEGIN;

CREATE OR REPLACE FUNCTION public.tm_owns_listing(p_listing uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT 1 FROM public.business_listings l JOIN public.business_owners o ON o.id = l.owner_id
                 WHERE l.id = p_listing AND o.profile_id = (SELECT public.tm_active_profile_id()));
$$;

-- Edit details. Approved/pending/rejected listings go back to 'pending' for re-approval; inactive stays inactive.
CREATE OR REPLACE FUNCTION public.owner_update_listing(p_listing uuid, p_name text, p_address text, p_description text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF btrim(coalesce(p_name,'')) = '' THEN RAISE EXCEPTION 'Name is required'; END IF;
  UPDATE public.business_listings SET name = btrim(p_name), address = nullif(btrim(coalesce(p_address,'')),''),
         description = nullif(btrim(coalesce(p_description,'')),''),
         status = CASE WHEN status = 'inactive' THEN 'inactive' ELSE 'pending' END
   WHERE id = p_listing;
END $$;

-- Deactivate (any state) or resubmit (only from inactive/rejected). Owners can never set 'approved'.
CREATE OR REPLACE FUNCTION public.owner_set_listing_status(p_listing uuid, p_status text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_cur text;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF p_status NOT IN ('pending','inactive') THEN RAISE EXCEPTION 'Owners can only deactivate or resubmit a listing'; END IF;
  SELECT status INTO v_cur FROM public.business_listings WHERE id = p_listing;
  IF p_status = 'pending' AND v_cur NOT IN ('inactive','rejected') THEN RAISE EXCEPTION 'Only inactive or rejected listings can be resubmitted'; END IF;
  UPDATE public.business_listings SET status = p_status WHERE id = p_listing;
END $$;

CREATE OR REPLACE FUNCTION public.owner_add_room(p_hotel uuid, p_room_number text, p_room_type text, p_max_guests int, p_rate numeric)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_id uuid;
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.hotels WHERE hotel_id = p_hotel) THEN RAISE EXCEPTION 'This listing is not a hotel'; END IF;
  INSERT INTO public.rooms(hotel_id,room_number,room_type,max_guests,base_nightly_rate,operational_status)
  VALUES (p_hotel,btrim(p_room_number),btrim(p_room_type),p_max_guests,p_rate,'available') RETURNING id INTO v_id;
  RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION public.owner_delete_room(p_room uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_hotel uuid;
BEGIN
  SELECT hotel_id INTO v_hotel FROM public.rooms WHERE id = p_room;
  IF v_hotel IS NULL OR NOT public.tm_owns_listing(v_hotel) THEN RAISE EXCEPTION 'Room not found'; END IF;
  DELETE FROM public.rooms WHERE id = p_room;
END $$;

CREATE OR REPLACE FUNCTION public.owner_add_menu_item(p_restaurant uuid, p_name text, p_category text, p_price numeric, p_description text)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_id uuid;
BEGIN
  IF NOT public.tm_owns_listing(p_restaurant) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.restaurants WHERE restaurant_id = p_restaurant) THEN RAISE EXCEPTION 'This listing is not a restaurant'; END IF;
  INSERT INTO public.menu_items(restaurant_id,name,category,price,description)
  VALUES (p_restaurant,btrim(p_name),nullif(btrim(coalesce(p_category,'')),''),p_price,nullif(btrim(coalesce(p_description,'')),'')) RETURNING id INTO v_id;
  RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION public.owner_delete_menu_item(p_item uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_r uuid;
BEGIN
  SELECT restaurant_id INTO v_r FROM public.menu_items WHERE id = p_item;
  IF v_r IS NULL OR NOT public.tm_owns_listing(v_r) THEN RAISE EXCEPTION 'Menu item not found'; END IF;
  DELETE FROM public.menu_items WHERE id = p_item;
END $$;

CREATE OR REPLACE FUNCTION public.owner_add_schedule(p_attraction uuid, p_day text, p_text text)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_id uuid;
BEGIN
  IF NOT public.tm_owns_listing(p_attraction) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.attractions WHERE attraction_id = p_attraction) THEN RAISE EXCEPTION 'This listing is not an attraction'; END IF;
  INSERT INTO public.attraction_schedules(attraction_id,operating_day,schedule_text) VALUES (p_attraction,btrim(p_day),btrim(p_text)) RETURNING id INTO v_id;
  RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION public.owner_delete_schedule(p_schedule uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_a uuid;
BEGIN
  SELECT attraction_id INTO v_a FROM public.attraction_schedules WHERE id = p_schedule;
  IF v_a IS NULL OR NOT public.tm_owns_listing(v_a) THEN RAISE EXCEPTION 'Schedule not found'; END IF;
  DELETE FROM public.attraction_schedules WHERE id = p_schedule;
END $$;

-- Only signed-in users may call them.
DO $$
DECLARE f record;
BEGIN
  FOR f IN SELECT p.oid::regprocedure AS sig FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
           WHERE n.nspname = 'public' AND p.proname IN ('tm_owns_listing','owner_update_listing','owner_set_listing_status','owner_add_room','owner_delete_room',
                 'owner_add_menu_item','owner_delete_menu_item','owner_add_schedule','owner_delete_schedule') LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon', f.sig);
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated', f.sig);
  END LOOP;
END $$;
COMMIT;
NOTIFY pgrst, 'reload schema';
