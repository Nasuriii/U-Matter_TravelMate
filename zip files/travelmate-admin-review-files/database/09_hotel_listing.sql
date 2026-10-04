-- TravelMate: Business Process 3 - Hotel Listing Management (approval, validation, amenities, notifications).
-- REVIEW FIRST, then run once in Supabase > SQL Editor AFTER 05, 06, 07 and 08. Safe to re-run.
-- Same pattern as 06-08: no table GRANTs change; every write is a SECURITY DEFINER function that checks who is calling.
--
-- What this adds (matches the revised Process 3 in TravelMate_Business_Process_Revised.docx):
--   1. Review details on listings: who reviewed, when, and the rejection reason.
--   2. Data rules: check-out earlier than check-in, room rate above zero, at least 1 guest, one room number per hotel.
--   3. Administrator approval: admin_pending_listings(), admin_review_listing() (approve, or reject WITH a reason).
--   4. Edited check-in/check-out times send an approved hotel back to 'pending' (re-approval).
--   5. Hotel amenities for owners, and a "what is still missing" checklist for owners.
--   6. Notifications: admins are told when a listing is submitted or edited; owners when it is approved or rejected.
--
-- NOT included yet: hotel photo upload and photo approval (needs Storage policies - separate file).
BEGIN;

-- 1. Review details ---------------------------------------------------------------------------------------------
ALTER TABLE public.business_listings
  ADD COLUMN IF NOT EXISTS reviewed_by uuid REFERENCES public.profiles(id),
  ADD COLUMN IF NOT EXISTS reviewed_at timestamptz,
  ADD COLUMN IF NOT EXISTS rejection_reason text;

-- 2. Data rules (NOT VALID = enforced for new and edited rows; existing rows are not rejected) -----------------------
-- Hotels turn rooms over, so check-out is EARLIER than check-in on the same day (sample hotels: in 14:00, out 11:00).
ALTER TABLE public.hotels DROP CONSTRAINT IF EXISTS hotels_times_valid;
ALTER TABLE public.hotels ADD CONSTRAINT hotels_times_valid
  CHECK (check_in_time IS NOT NULL AND check_out_time IS NOT NULL AND check_out_time < check_in_time) NOT VALID;
ALTER TABLE public.rooms DROP CONSTRAINT IF EXISTS rooms_rate_positive;
ALTER TABLE public.rooms ADD CONSTRAINT rooms_rate_positive CHECK (base_nightly_rate > 0) NOT VALID;
ALTER TABLE public.rooms DROP CONSTRAINT IF EXISTS rooms_guests_positive;
ALTER TABLE public.rooms ADD CONSTRAINT rooms_guests_positive CHECK (max_guests >= 1) NOT VALID;
CREATE UNIQUE INDEX IF NOT EXISTS rooms_hotel_room_number_uidx ON public.rooms (hotel_id, room_number);

-- 3. Who is an administrator --------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tm_is_admin() RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id = pr.role_id
                 WHERE pr.profile_id = (SELECT public.tm_active_profile_id()) AND r.name = 'admin');
$$;

-- What still blocks a hotel from going live (empty list = ready).
CREATE OR REPLACE FUNCTION public.tm_hotel_problems(p_hotel uuid) RETURNS text[]
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
DECLARE h record; v text[] := '{}';
BEGIN
  SELECT check_in_time, check_out_time INTO h FROM public.hotels WHERE hotel_id = p_hotel;
  IF NOT FOUND THEN RETURN ARRAY['This listing has no hotel details']; END IF;
  IF h.check_in_time IS NULL OR h.check_out_time IS NULL THEN v := array_append(v, 'Set the check-in and check-out times');
  ELSIF h.check_out_time >= h.check_in_time THEN v := array_append(v, 'Check-out time must be earlier than check-in time'); END IF;
  IF NOT EXISTS (SELECT 1 FROM public.rooms WHERE hotel_id = p_hotel AND operational_status = 'available') THEN
    v := array_append(v, 'Add at least one available room');
  END IF;
  RETURN v;
END $$;

CREATE OR REPLACE FUNCTION public.owner_hotel_checklist(p_hotel uuid) RETURNS text[]
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN public.tm_hotel_problems(p_hotel);
END $$;

-- 4. Administrator review -------------------------------------------------------------------------------------------
-- Queue of listings awaiting review, with everything the administrator needs to judge a hotel.
CREATE OR REPLACE FUNCTION public.admin_pending_listings(p_type text DEFAULT 'hotel') RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((
    SELECT jsonb_agg(x.j ORDER BY x.created) FROM (
      SELECT l.created_at AS created, jsonb_build_object(
        'id', l.id, 'name', l.name, 'type', l.listing_type, 'address', l.address, 'description', l.description,
        'destination', d.name || ', ' || d.province, 'owner', o.contact_name, 'owner_email', o.contact_email,
        'submitted', l.updated_at, 'check_in', h.check_in_time, 'check_out', h.check_out_time,
        'problems', CASE WHEN l.listing_type = 'hotel' THEN to_jsonb(public.tm_hotel_problems(l.id)) ELSE '[]'::jsonb END,
        'rooms', (SELECT coalesce(jsonb_agg(jsonb_build_object('room_number', r.room_number, 'room_type', r.room_type,
                    'max_guests', r.max_guests, 'rate', r.base_nightly_rate, 'status', r.operational_status) ORDER BY r.room_number), '[]'::jsonb)
                  FROM public.rooms r WHERE r.hotel_id = l.id),
        'amenities', (SELECT coalesce(jsonb_agg(a.name ORDER BY a.name), '[]'::jsonb)
                      FROM public.hotel_amenities ha JOIN public.amenities a ON a.id = ha.amenity_id WHERE ha.hotel_id = l.id)
      ) AS j
      FROM public.business_listings l
      JOIN public.business_owners o ON o.id = l.owner_id
      JOIN public.destinations d ON d.id = l.destination_id
      LEFT JOIN public.hotels h ON h.hotel_id = l.id
      WHERE l.status = 'pending' AND l.listing_type = p_type
    ) x), '[]'::jsonb);
END $$;

-- Approve, or reject with a reason. Always tells the owner. A hotel cannot be approved while it has blockers.
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
    IF l.listing_type = 'hotel' THEN
      v_problems := public.tm_hotel_problems(p_listing);
      IF cardinality(v_problems) > 0 THEN RAISE EXCEPTION 'Cannot approve yet: %', array_to_string(v_problems, '; '); END IF;
    END IF;
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

-- 5. Notify administrators when a listing is submitted, or goes back to review after an edit -------------------------
CREATE OR REPLACE FUNCTION public.tm_notify_admins_listing_pending() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  INSERT INTO public.notifications(id, profile_id, message, created_at)
  SELECT gen_random_uuid(), pr.profile_id, format('%s listing "%s" is awaiting review.', initcap(NEW.listing_type), NEW.name), now()
    FROM public.profile_roles pr JOIN public.roles r ON r.id = pr.role_id WHERE r.name = 'admin';
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tm_listing_submitted ON public.business_listings;
CREATE TRIGGER tm_listing_submitted AFTER INSERT ON public.business_listings
  FOR EACH ROW WHEN (NEW.status = 'pending') EXECUTE FUNCTION public.tm_notify_admins_listing_pending();
DROP TRIGGER IF EXISTS tm_listing_resubmitted ON public.business_listings;
CREATE TRIGGER tm_listing_resubmitted AFTER UPDATE OF status ON public.business_listings
  FOR EACH ROW WHEN (NEW.status = 'pending' AND OLD.status IS DISTINCT FROM 'pending') EXECUTE FUNCTION public.tm_notify_admins_listing_pending();

-- Everyone reads only their own notifications through these two functions.
CREATE OR REPLACE FUNCTION public.my_notifications(p_limit int DEFAULT 20) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', n.id, 'message', n.message, 'read', n.read_at IS NOT NULL, 'created_at', n.created_at)
                            ORDER BY n.created_at DESC), '[]'::jsonb)
    FROM (SELECT * FROM public.notifications WHERE profile_id = (SELECT public.tm_active_profile_id())
          ORDER BY created_at DESC LIMIT least(greatest(coalesce(p_limit, 20), 1), 50)) n;
$$;
CREATE OR REPLACE FUNCTION public.mark_my_notifications_read() RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = '' AS $$
  UPDATE public.notifications SET read_at = now()
   WHERE profile_id = (SELECT public.tm_active_profile_id()) AND read_at IS NULL;
$$;

-- 6. Rooms with friendly validation (replaces the versions in 07 and 08; same signatures) ----------------------------
CREATE OR REPLACE FUNCTION public.owner_add_room(p_hotel uuid, p_room_number text, p_room_type text, p_max_guests int, p_rate numeric)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_id uuid;
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.hotels WHERE hotel_id = p_hotel) THEN RAISE EXCEPTION 'This listing is not a hotel'; END IF;
  IF btrim(coalesce(p_room_number, '')) = '' OR btrim(coalesce(p_room_type, '')) = '' THEN RAISE EXCEPTION 'Room number and type are required'; END IF;
  IF coalesce(p_max_guests, 0) < 1 THEN RAISE EXCEPTION 'Max guests must be at least 1'; END IF;
  IF coalesce(p_rate, 0) <= 0 THEN RAISE EXCEPTION 'Nightly rate must be above 0'; END IF;
  IF EXISTS (SELECT 1 FROM public.rooms WHERE hotel_id = p_hotel AND room_number = btrim(p_room_number)) THEN
    RAISE EXCEPTION 'Room % already exists in this hotel', btrim(p_room_number);
  END IF;
  INSERT INTO public.rooms(hotel_id, room_number, room_type, max_guests, base_nightly_rate, operational_status)
  VALUES (p_hotel, btrim(p_room_number), btrim(p_room_type), p_max_guests, p_rate, 'available') RETURNING id INTO v_id;
  RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION public.owner_update_room(p_room uuid, p_room_number text, p_room_type text, p_max_guests int, p_rate numeric, p_status text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_hotel uuid;
BEGIN
  SELECT hotel_id INTO v_hotel FROM public.rooms WHERE id = p_room;
  IF v_hotel IS NULL OR NOT public.tm_owns_listing(v_hotel) THEN RAISE EXCEPTION 'Room not found'; END IF;
  IF p_status NOT IN ('available', 'maintenance', 'unavailable') THEN RAISE EXCEPTION 'Invalid room status'; END IF;
  IF btrim(coalesce(p_room_number, '')) = '' OR btrim(coalesce(p_room_type, '')) = '' THEN RAISE EXCEPTION 'Room number and type are required'; END IF;
  IF coalesce(p_max_guests, 0) < 1 THEN RAISE EXCEPTION 'Max guests must be at least 1'; END IF;
  IF coalesce(p_rate, 0) <= 0 THEN RAISE EXCEPTION 'Nightly rate must be above 0'; END IF;
  IF EXISTS (SELECT 1 FROM public.rooms WHERE hotel_id = v_hotel AND room_number = btrim(p_room_number) AND id <> p_room) THEN
    RAISE EXCEPTION 'Room % already exists in this hotel', btrim(p_room_number);
  END IF;
  UPDATE public.rooms SET room_number = btrim(p_room_number), room_type = btrim(p_room_type), max_guests = p_max_guests,
         base_nightly_rate = p_rate, operational_status = p_status WHERE id = p_room;
END $$;

-- 7. Details: hotel times are validated, and changing them sends the hotel back for re-approval -------------------------
-- (restaurant and attraction branches are unchanged from 08)
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
      UPDATE public.business_listings SET status = CASE WHEN status = 'inactive' THEN 'inactive' ELSE 'pending' END WHERE id = p_listing;
    END IF;
  ELSIF v_type = 'restaurant' THEN
    UPDATE public.restaurants SET operating_hours = nullif(btrim(coalesce(p_hours, '')), ''), reservation_fee = coalesce(p_resfee, 0) WHERE restaurant_id = p_listing;
  ELSE
    UPDATE public.attractions SET entrance_fee = p_fee WHERE attraction_id = p_listing;
  END IF;
END $$;

-- 8. Amenities ---------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.owner_get_hotel_amenities(p_hotel uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', a.id, 'name', a.name,
            'selected', EXISTS (SELECT 1 FROM public.hotel_amenities ha WHERE ha.hotel_id = p_hotel AND ha.amenity_id = a.id)) ORDER BY a.name)
          FROM public.amenities a), '[]'::jsonb);
END $$;

CREATE OR REPLACE FUNCTION public.owner_set_hotel_amenities(p_hotel uuid, p_amenities uuid[]) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.hotels WHERE hotel_id = p_hotel) THEN RAISE EXCEPTION 'This listing is not a hotel'; END IF;
  DELETE FROM public.hotel_amenities WHERE hotel_id = p_hotel;
  INSERT INTO public.hotel_amenities(hotel_id, amenity_id)
  SELECT p_hotel, a.id FROM public.amenities a WHERE a.id = ANY (coalesce(p_amenities, '{}'::uuid[]));
END $$;

-- 9. Who may call what -----------------------------------------------------------------------------------------------
DO $$
DECLARE f record;
BEGIN
  FOR f IN SELECT p.oid::regprocedure AS sig, p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
           WHERE n.nspname = 'public' AND p.proname IN ('tm_is_admin','tm_hotel_problems','owner_hotel_checklist','admin_pending_listings','admin_review_listing',
                 'tm_notify_admins_listing_pending','my_notifications','mark_my_notifications_read','owner_add_room','owner_update_room','owner_update_details',
                 'owner_get_hotel_amenities','owner_set_hotel_amenities') LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon', f.sig);
    IF f.proname NOT IN ('tm_hotel_problems', 'tm_notify_admins_listing_pending') THEN
      EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated', f.sig);
    END IF;
  END LOOP;
END $$;
COMMIT;
NOTIFY pgrst, 'reload schema';

-- ---------------------------------------------------------------------------------------------------------------
-- ADMIN ROLE: nobody has the 'admin' role until you assign it. 10_admin_review.sql does this for the project's two administrators.
-- To give it to someone else (they must have signed in once so a profile exists):
--
--   INSERT INTO public.profile_roles (profile_id, role_id)
--   SELECT u.id, r.id FROM auth.users u, public.roles r
--    WHERE u.email = 'ADMIN_EMAIL_HERE' AND r.name = 'admin' ON CONFLICT DO NOTHING;
--
-- NOTE: the pending listing BOOLABOLA (check-in 06:00, check-out 18:01, no check-out-before-check-in) cannot be approved
-- until its owner corrects the times; the administrator can also reject it with a reason.
-- ---------------------------------------------------------------------------------------------------------------
