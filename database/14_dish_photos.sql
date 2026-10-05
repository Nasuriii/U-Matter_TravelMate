-- TravelMate: photos for menu dishes. Run once in the Supabase SQL Editor after 05-13. Safe to re-run.
-- Dish photos are stored in the same bucket and the same `photos` table as listing photos (so the existing
-- storage rules apply), linked to the dish through the new column photos.menu_item_id.
-- Like listing photos they are 'pending' until an administrator approves the restaurant.
BEGIN;
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS menu_item_id uuid REFERENCES public.menu_items(id) ON DELETE CASCADE;
CREATE UNIQUE INDEX IF NOT EXISTS photos_one_per_dish ON public.photos (menu_item_id) WHERE menu_item_id IS NOT NULL;

-- Listing-level photo functions now ignore dish photos (so dishes do not use up the 6-photo limit).
CREATE OR REPLACE FUNCTION public.owner_list_photos(p_listing uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', p.id, 'object_path', p.object_path, 'status', p.status) ORDER BY p.sort_order, p.created_at)
                   FROM public.photos p WHERE p.listing_id = p_listing AND p.menu_item_id IS NULL), '[]'::jsonb);
END $$;

CREATE OR REPLACE FUNCTION public.owner_add_photo(p_listing uuid, p_path text, p_caption text DEFAULT NULL) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_id uuid; v_n int; v_uid text := (SELECT public.tm_active_profile_id())::text;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF p_path IS NULL OR p_path NOT LIKE v_uid || '/' || p_listing::text || '/%' OR p_path LIKE '%..%' THEN RAISE EXCEPTION 'Invalid photo path'; END IF;
  SELECT count(*) INTO v_n FROM public.photos WHERE listing_id = p_listing AND menu_item_id IS NULL;
  IF v_n >= 6 THEN RAISE EXCEPTION 'A listing can have up to 6 photos'; END IF;
  INSERT INTO public.photos(listing_id, bucket_id, object_path, caption, sort_order, status)
  VALUES (p_listing, 'travelmate-listings', p_path, nullif(btrim(coalesce(p_caption,'')),''), v_n, 'pending') RETURNING id INTO v_id;
  UPDATE public.business_listings SET status = 'pending' WHERE id = p_listing AND status = 'approved';
  RETURN v_id;
END $$;

-- Dish photos: one per dish.
CREATE OR REPLACE FUNCTION public.owner_list_dish_photos(p_listing uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('menu_item_id', p.menu_item_id, 'object_path', p.object_path, 'status', p.status))
                   FROM public.photos p WHERE p.listing_id = p_listing AND p.menu_item_id IS NOT NULL), '[]'::jsonb);
END $$;

-- Sets (or replaces) a dish photo. Returns the previous file path so the app can delete the old file.
CREATE OR REPLACE FUNCTION public.owner_set_dish_photo(p_item uuid, p_path text) RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_listing uuid; v_old text; v_uid text := (SELECT public.tm_active_profile_id())::text;
BEGIN
  SELECT restaurant_id INTO v_listing FROM public.menu_items WHERE id = p_item;
  IF v_listing IS NULL OR NOT public.tm_owns_listing(v_listing) THEN RAISE EXCEPTION 'Menu item not found'; END IF;
  IF p_path IS NULL OR p_path NOT LIKE v_uid || '/' || v_listing::text || '/%' OR p_path LIKE '%..%' THEN RAISE EXCEPTION 'Invalid photo path'; END IF;
  SELECT object_path INTO v_old FROM public.photos WHERE menu_item_id = p_item;
  DELETE FROM public.photos WHERE menu_item_id = p_item;
  INSERT INTO public.photos(listing_id, bucket_id, object_path, sort_order, status, menu_item_id)
  VALUES (v_listing, 'travelmate-listings', p_path, 100, 'pending', p_item);
  UPDATE public.business_listings SET status = 'pending' WHERE id = v_listing AND status = 'approved';
  RETURN v_old;
END $$;

CREATE OR REPLACE FUNCTION public.owner_delete_dish_photo(p_item uuid) RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_listing uuid; v_old text;
BEGIN
  SELECT restaurant_id INTO v_listing FROM public.menu_items WHERE id = p_item;
  IF v_listing IS NULL OR NOT public.tm_owns_listing(v_listing) THEN RAISE EXCEPTION 'Menu item not found'; END IF;
  SELECT object_path INTO v_old FROM public.photos WHERE menu_item_id = p_item;
  DELETE FROM public.photos WHERE menu_item_id = p_item;
  RETURN v_old;
END $$;

DO $$
DECLARE f record;
BEGIN
  FOR f IN SELECT p.oid::regprocedure AS sig FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
           WHERE n.nspname = 'public' AND p.proname IN ('owner_list_photos','owner_add_photo','owner_list_dish_photos','owner_set_dish_photo','owner_delete_dish_photo') LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon', f.sig);
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated', f.sig);
  END LOOP;
END $$;
COMMIT;
NOTIFY pgrst, 'reload schema';
