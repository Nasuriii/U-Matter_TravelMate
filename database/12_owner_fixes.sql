-- TravelMate: owner fixes. Run once in the Supabase SQL Editor after 05-11. Safe to re-run. No table or GRANT changes.
--  1. Saving changes to a REJECTED listing no longer resubmits it. The owner must press "Resubmit" on purpose.
--  2. Owners can permanently delete a listing that is not live and has no bookings, reviews, trips or reports.
BEGIN;

-- 1a. text edits: rejected / inactive stay as they are, everything else goes back to review
CREATE OR REPLACE FUNCTION public.owner_update_listing(p_listing uuid, p_name text, p_address text, p_description text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF btrim(coalesce(p_name,'')) = '' THEN RAISE EXCEPTION 'Name is required'; END IF;
  UPDATE public.business_listings SET name = btrim(p_name), address = nullif(btrim(coalesce(p_address,'')),''),
         description = nullif(btrim(coalesce(p_description,'')),''),
         status = CASE WHEN status IN ('inactive','rejected') THEN status ELSE 'pending' END
   WHERE id = p_listing;
END $$;

-- 1b. hotel time edits: same rule (body identical to 09 except the status CASE)
CREATE OR REPLACE FUNCTION public.owner_update_details(p_listing uuid, p_check_in time, p_check_out time, p_hours text, p_resfee numeric, p_fee numeric)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
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
      UPDATE public.business_listings SET status = CASE WHEN status IN ('inactive','rejected') THEN status ELSE 'pending' END WHERE id = p_listing;
    END IF;
  ELSIF v_type = 'restaurant' THEN
    UPDATE public.restaurants SET operating_hours = nullif(btrim(coalesce(p_hours, '')), ''), reservation_fee = coalesce(p_resfee, 0) WHERE restaurant_id = p_listing;
  ELSE
    UPDATE public.attractions SET entrance_fee = p_fee WHERE attraction_id = p_listing;
  END IF;
END $$;

-- 2. delete a listing (returns the photo file paths so the app can remove the files too)
CREATE OR REPLACE FUNCTION public.owner_delete_listing(p_listing uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_status text; v_paths jsonb;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  SELECT status INTO v_status FROM public.business_listings WHERE id = p_listing;
  IF v_status = 'approved' THEN RAISE EXCEPTION 'This listing is live. Deactivate it first, then delete it.'; END IF;
  SELECT coalesce(jsonb_agg(object_path), '[]'::jsonb) INTO v_paths FROM public.photos WHERE listing_id = p_listing;
  BEGIN
    DELETE FROM public.photos WHERE listing_id = p_listing;
    DELETE FROM public.hotel_amenities WHERE hotel_id = p_listing;
    DELETE FROM public.rooms WHERE hotel_id = p_listing;
    DELETE FROM public.menu_items WHERE restaurant_id = p_listing;
    DELETE FROM public.restaurant_cuisines WHERE restaurant_id = p_listing;
    DELETE FROM public.restaurant_slots WHERE restaurant_id = p_listing;
    DELETE FROM public.attraction_schedules WHERE attraction_id = p_listing;
    DELETE FROM public.hotels WHERE hotel_id = p_listing;
    DELETE FROM public.restaurants WHERE restaurant_id = p_listing;
    DELETE FROM public.attractions WHERE attraction_id = p_listing;
    DELETE FROM public.business_listings WHERE id = p_listing;
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'This listing has bookings, reviews, trip plans or reports attached, so it cannot be deleted. Deactivate it instead.';
  END;
  RETURN v_paths;
END $$;
REVOKE ALL ON FUNCTION public.owner_delete_listing(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.owner_delete_listing(uuid) TO authenticated;
COMMIT;
NOTIFY pgrst, 'reload schema';
