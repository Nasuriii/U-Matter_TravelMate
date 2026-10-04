-- TravelMate: Business Process 3 (and 4, 5) - administrator web UI support.
-- Run once in Supabase > SQL Editor AFTER 05 to 09. Safe to re-run.
--
-- What this does:
--   1. Gives the admin role to the two accounts listed in step 1 (they must have signed in to TravelMate at least once).
--   2. admin_review_queue(): every listing awaiting review (hotel, restaurant, attraction) with the details an admin needs.
--   3. admin_reviewed_listings(): recently approved / rejected listings, so admins can see what was decided and why.
--   4. tm_listing_problems(): what blocks approval, for all three listing types (hotels were already covered in 09).
--   5. admin_review_listing(): same function as in 09, now using the checks for every listing type.
BEGIN;

-- 1. Administrators ---------------------------------------------------------------------------------------------
-- Edit this list to add or change administrators, then re-run this file. NOTE: the repository is public, so anything
-- written here is public too; you can also run just this block in the SQL Editor without committing the emails.
DO $$
DECLARE e text; v_profile uuid; v_role uuid;
BEGIN
  SELECT id INTO v_role FROM public.roles WHERE name = 'admin';
  IF v_role IS NULL THEN RAISE EXCEPTION 'The admin role is missing from public.roles'; END IF;
  FOREACH e IN ARRAY ARRAY['delpilargian0@gmail.com', 'rasheedborja@gmail.com'] LOOP
    SELECT p.id INTO v_profile FROM auth.users u JOIN public.profiles p ON p.id = u.id WHERE lower(u.email) = lower(e);
    IF v_profile IS NULL THEN
      RAISE WARNING 'No TravelMate profile for %. Ask them to sign in once, then run this file again.', e;
    ELSE
      INSERT INTO public.profile_roles (profile_id, role_id) VALUES (v_profile, v_role) ON CONFLICT DO NOTHING;
      RAISE NOTICE 'Admin role granted: %', e;
    END IF;
  END LOOP;
END $$;

-- 2. What blocks approval, for any listing type -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tm_listing_problems(p_listing uuid) RETURNS text[]
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
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
  ELSIF t = 'attraction' THEN
    SELECT entrance_fee INTO a FROM public.attractions WHERE attraction_id = p_listing;
    IF NOT FOUND THEN RETURN ARRAY['This listing has no attraction details']; END IF;
    IF a.entrance_fee IS NULL THEN v := array_append(v, 'Set the entrance fee (0 means free entry)'); END IF;
    IF NOT EXISTS (SELECT 1 FROM public.attraction_schedules WHERE attraction_id = p_listing) THEN
      v := array_append(v, 'Add at least one operating day');
    END IF;
  END IF;
  RETURN v;
END $$;

-- 3. Review queue (all types) ---------------------------------------------------------------------------------------
-- Named differently from admin_pending_listings (09, hotels only) so the app can tell when this file has not been run.
CREATE OR REPLACE FUNCTION public.admin_review_queue() RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
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
            'menu', (SELECT coalesce(jsonb_agg(jsonb_build_object('name', m.name, 'category', m.category, 'price', m.price,
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
END $$;

-- 4. Recently decided listings ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.admin_reviewed_listings(p_limit int DEFAULT 20) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((
    SELECT jsonb_agg(jsonb_build_object('id', x.id, 'name', x.name, 'type', x.listing_type, 'status', x.status,
             'reviewed_at', x.reviewed_at, 'reviewer', x.reviewer, 'reason', x.rejection_reason) ORDER BY x.reviewed_at DESC)
    FROM (SELECT l.id, l.name, l.listing_type, l.status, l.reviewed_at, l.rejection_reason, p.full_name AS reviewer
            FROM public.business_listings l LEFT JOIN public.profiles p ON p.id = l.reviewed_by
           WHERE l.reviewed_at IS NOT NULL AND l.status IN ('approved', 'rejected')
           ORDER BY l.reviewed_at DESC LIMIT least(greatest(coalesce(p_limit, 20), 1), 100)) x), '[]'::jsonb);
END $$;

-- 5. Approve / reject (same signature as 09; now checks every listing type) ---------------------------------------------
CREATE OR REPLACE FUNCTION public.admin_review_listing(p_listing uuid, p_approve boolean, p_reason text DEFAULT NULL) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE l record; v_problems text[]; v_admin uuid := (SELECT public.tm_active_profile_id());
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  SELECT bl.id, bl.name, bl.listing_type, bl.status, o.profile_id AS owner_profile INTO l
    FROM public.business_listings bl JOIN public.business_owners o ON o.id = bl.owner_id
   WHERE bl.id = p_listing FOR UPDATE OF bl;
  IF NOT FOUND THEN RAISE EXCEPTION 'Listing not found'; END IF;
  IF l.status <> 'pending' THEN RAISE EXCEPTION 'Only listings awaiting review can be approved or rejected (this one is %)', l.status; END IF;
  IF p_approve THEN
    v_problems := public.tm_listing_problems(p_listing);
    IF cardinality(v_problems) > 0 THEN RAISE EXCEPTION 'Cannot approve yet: %', array_to_string(v_problems, '; '); END IF;
  ELSIF btrim(coalesce(p_reason, '')) = '' THEN
    RAISE EXCEPTION 'Give the owner a reason for rejecting this listing';
  END IF;
  UPDATE public.business_listings
     SET status = CASE WHEN p_approve THEN 'approved' ELSE 'rejected' END,
         reviewed_by = v_admin, reviewed_at = now(), updated_at = now(),
         rejection_reason = CASE WHEN p_approve THEN NULL ELSE btrim(p_reason) END
   WHERE id = p_listing;
  INSERT INTO public.notifications(id, profile_id, message, created_at)
  VALUES (gen_random_uuid(), l.owner_profile,
          CASE WHEN p_approve THEN format('Your %s listing "%s" was approved and is now visible to travelers.', l.listing_type, l.name)
               ELSE format('Your %s listing "%s" was not approved. Reason: %s', l.listing_type, l.name, btrim(p_reason)) END,
          now());
END $$;

-- 6. Who may call what ------------------------------------------------------------------------------------------------
DO $$
DECLARE f record;
BEGIN
  FOR f IN SELECT p.oid::regprocedure AS sig, p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
           WHERE n.nspname = 'public' AND p.proname IN ('tm_listing_problems', 'admin_review_queue', 'admin_reviewed_listings', 'admin_review_listing') LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon', f.sig);
    IF f.proname <> 'tm_listing_problems' THEN EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated', f.sig); END IF;
  END LOOP;
END $$;
COMMIT;
NOTIFY pgrst, 'reload schema';
