-- TravelMate: listing photos (BP3/4/5 "images"), restaurant cuisines (BP4), admin photo preview.
-- Run once in the Supabase SQL Editor AFTER 05-10. Safe to re-run. No table or GRANT changes.
-- Photo flow: owner uploads to storage bucket 'travelmate-listings' under <ownerId>/<listingId>/<file>
-- (existing policies allow this), then owner_add_photo records it as 'pending'. Pending photos become
-- 'approved' automatically when an admin approves the listing; admins can SEE them first (policy below).
BEGIN;

-- ---- cuisines (same pattern as hotel amenities) ----
CREATE OR REPLACE FUNCTION public.owner_get_restaurant_cuisines(p_restaurant uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_restaurant) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', c.id, 'name', c.name,
            'selected', EXISTS (SELECT 1 FROM public.restaurant_cuisines rc WHERE rc.restaurant_id = p_restaurant AND rc.cuisine_id = c.id)) ORDER BY c.name)
          FROM public.cuisines c), '[]'::jsonb);
END $$;

CREATE OR REPLACE FUNCTION public.owner_set_restaurant_cuisines(p_restaurant uuid, p_cuisines uuid[]) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_restaurant) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.restaurants WHERE restaurant_id = p_restaurant) THEN RAISE EXCEPTION 'This listing is not a restaurant'; END IF;
  DELETE FROM public.restaurant_cuisines WHERE restaurant_id = p_restaurant;
  INSERT INTO public.restaurant_cuisines(restaurant_id, cuisine_id)
  SELECT p_restaurant, c.id FROM public.cuisines c WHERE c.id = ANY (coalesce(p_cuisines, '{}'::uuid[]));
END $$;

-- ---- photos ----
CREATE OR REPLACE FUNCTION public.owner_list_photos(p_listing uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', p.id, 'object_path', p.object_path, 'status', p.status) ORDER BY p.sort_order, p.created_at)
                   FROM public.photos p WHERE p.listing_id = p_listing), '[]'::jsonb);
END $$;

CREATE OR REPLACE FUNCTION public.owner_add_photo(p_listing uuid, p_path text, p_caption text DEFAULT NULL) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_id uuid; v_n int; v_uid text := (SELECT public.tm_active_profile_id())::text;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF p_path IS NULL OR p_path NOT LIKE v_uid || '/' || p_listing::text || '/%' OR p_path LIKE '%..%' THEN RAISE EXCEPTION 'Invalid photo path'; END IF;
  SELECT count(*) INTO v_n FROM public.photos WHERE listing_id = p_listing;
  IF v_n >= 6 THEN RAISE EXCEPTION 'A listing can have up to 6 photos'; END IF;
  INSERT INTO public.photos(listing_id, bucket_id, object_path, caption, sort_order, status)
  VALUES (p_listing, 'travelmate-listings', p_path, nullif(btrim(coalesce(p_caption,'')),''), v_n, 'pending') RETURNING id INTO v_id;
  -- new content on a live listing goes back to review (same rule as editing its text)
  UPDATE public.business_listings SET status = 'pending' WHERE id = p_listing AND status = 'approved';
  RETURN v_id;
END $$;

-- returns the storage path so the app can remove the file too
CREATE OR REPLACE FUNCTION public.owner_delete_photo(p_photo uuid) RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_listing uuid; v_path text;
BEGIN
  SELECT listing_id, object_path INTO v_listing, v_path FROM public.photos WHERE id = p_photo;
  IF v_listing IS NULL OR NOT public.tm_owns_listing(v_listing) THEN RAISE EXCEPTION 'Photo not found'; END IF;
  DELETE FROM public.photos WHERE id = p_photo;
  RETURN v_path;
END $$;

CREATE OR REPLACE FUNCTION public.admin_listing_photos(p_listing uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', p.id, 'object_path', p.object_path, 'status', p.status) ORDER BY p.sort_order, p.created_at)
                   FROM public.photos p WHERE p.listing_id = p_listing), '[]'::jsonb);
END $$;

-- Pending photos go live together with their listing.
CREATE OR REPLACE FUNCTION public.tm_approve_listing_photos() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status IS DISTINCT FROM 'approved' THEN
    UPDATE public.photos SET status = 'approved' WHERE listing_id = NEW.id AND status = 'pending';
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tm_approve_listing_photos ON public.business_listings;
CREATE TRIGGER tm_approve_listing_photos AFTER UPDATE OF status ON public.business_listings
  FOR EACH ROW EXECUTE FUNCTION public.tm_approve_listing_photos();
REVOKE ALL ON FUNCTION public.tm_approve_listing_photos() FROM PUBLIC, anon, authenticated;

-- ---- storage: admins can view pending photos; owners can delete their own files ----
DROP POLICY IF EXISTS tm_listing_admin_read ON storage.objects;
CREATE POLICY tm_listing_admin_read ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'travelmate-listings' AND public.tm_is_admin());
DROP POLICY IF EXISTS tm_listing_owner_delete ON storage.objects;
CREATE POLICY tm_listing_owner_delete ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'travelmate-listings' AND public.tm_owns_listing_path(name));

DO $$
DECLARE f record;
BEGIN
  FOR f IN SELECT p.oid::regprocedure AS sig FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
           WHERE n.nspname = 'public' AND p.proname IN ('owner_get_restaurant_cuisines','owner_set_restaurant_cuisines','owner_list_photos',
                 'owner_add_photo','owner_delete_photo','admin_listing_photos') LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon', f.sig);
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated', f.sig);
  END LOOP;
END $$;
COMMIT;
NOTIFY pgrst, 'reload schema';
