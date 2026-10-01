-- TravelMate: owner EDIT actions (Business Processes 3-5). Run once in the SQL Editor after 07. Safe to re-run.
-- Same pattern as 07: SECURITY DEFINER functions that check the caller owns the listing. No GRANT changes.
BEGIN;

CREATE OR REPLACE FUNCTION public.owner_update_room(p_room uuid, p_room_number text, p_room_type text, p_max_guests int, p_rate numeric, p_status text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_hotel uuid;
BEGIN
  SELECT hotel_id INTO v_hotel FROM public.rooms WHERE id = p_room;
  IF v_hotel IS NULL OR NOT public.tm_owns_listing(v_hotel) THEN RAISE EXCEPTION 'Room not found'; END IF;
  IF p_status NOT IN ('available','maintenance','unavailable') THEN RAISE EXCEPTION 'Invalid room status'; END IF;
  UPDATE public.rooms SET room_number = btrim(p_room_number), room_type = btrim(p_room_type), max_guests = p_max_guests,
         base_nightly_rate = p_rate, operational_status = p_status WHERE id = p_room;
END $$;

CREATE OR REPLACE FUNCTION public.owner_update_menu_item(p_item uuid, p_name text, p_category text, p_price numeric, p_description text, p_available int)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_r uuid;
BEGIN
  SELECT restaurant_id INTO v_r FROM public.menu_items WHERE id = p_item;
  IF v_r IS NULL OR NOT public.tm_owns_listing(v_r) THEN RAISE EXCEPTION 'Menu item not found'; END IF;
  UPDATE public.menu_items SET name = btrim(p_name), category = nullif(btrim(coalesce(p_category,'')),''), price = p_price,
         description = nullif(btrim(coalesce(p_description,'')),''), is_available = CASE WHEN p_available = 1 THEN 1 ELSE 0 END WHERE id = p_item;
END $$;

CREATE OR REPLACE FUNCTION public.owner_update_schedule(p_schedule uuid, p_day text, p_text text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_a uuid;
BEGIN
  SELECT attraction_id INTO v_a FROM public.attraction_schedules WHERE id = p_schedule;
  IF v_a IS NULL OR NOT public.tm_owns_listing(v_a) THEN RAISE EXCEPTION 'Schedule not found'; END IF;
  UPDATE public.attraction_schedules SET operating_day = btrim(p_day), schedule_text = btrim(p_text) WHERE id = p_schedule;
END $$;

-- Hotel check-in/out, restaurant hours + reservation fee, attraction entrance fee.
CREATE OR REPLACE FUNCTION public.owner_update_details(p_listing uuid, p_check_in time, p_check_out time, p_hours text, p_resfee numeric, p_fee numeric)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_type text;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  SELECT listing_type INTO v_type FROM public.business_listings WHERE id = p_listing;
  IF v_type = 'hotel' THEN UPDATE public.hotels SET check_in_time = p_check_in, check_out_time = p_check_out WHERE hotel_id = p_listing;
  ELSIF v_type = 'restaurant' THEN UPDATE public.restaurants SET operating_hours = nullif(btrim(coalesce(p_hours,'')),''), reservation_fee = coalesce(p_resfee,0) WHERE restaurant_id = p_listing;
  ELSE UPDATE public.attractions SET entrance_fee = p_fee WHERE attraction_id = p_listing; END IF;
END $$;

DO $$
DECLARE f record;
BEGIN
  FOR f IN SELECT p.oid::regprocedure AS sig FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
           WHERE n.nspname = 'public' AND p.proname IN ('owner_update_room','owner_update_menu_item','owner_update_schedule','owner_update_details') LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon', f.sig);
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated', f.sig);
  END LOOP;
END $$;
COMMIT;
NOTIFY pgrst, 'reload schema';
