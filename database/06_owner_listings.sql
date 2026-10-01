-- TravelMate: business-owner listing management (Business Processes 3, 4 and 5).
-- REVIEW FIRST, then run once in Supabase > SQL Editor. Safe to re-run.
-- Today owners have NO write access and cannot even see their own pending listings
-- (tm_read only exposes approved ones). This file adds, for owners only:
--   * read own listings in any status            * edit own listings (never set 'approved')
--   * add/edit/remove menu items, rooms, schedules for own listings
--   * owner_create_listing(): one atomic function that creates a PENDING listing + its hotel/restaurant/attraction row
-- Admin approval (pending -> approved) is NOT included; use your existing admin/reviewer path.
BEGIN;

CREATE OR REPLACE FUNCTION public.tm_owns_listing(p_listing uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT 1 FROM public.business_listings l
                 JOIN public.business_owners o ON o.id = l.owner_id
                 WHERE l.id = p_listing AND o.profile_id = (SELECT public.tm_active_profile_id()));
$$;
REVOKE ALL ON FUNCTION public.tm_owns_listing(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.tm_owns_listing(uuid) TO authenticated;

-- Listings: owners read their own (any status) and update them, but can only leave them pending/inactive.
DROP POLICY IF EXISTS tm_owner_listings_read ON public.business_listings;
CREATE POLICY tm_owner_listings_read ON public.business_listings FOR SELECT TO authenticated
  USING (public.tm_owns_listing(id));
DROP POLICY IF EXISTS tm_owner_listings_update ON public.business_listings;
CREATE POLICY tm_owner_listings_update ON public.business_listings FOR UPDATE TO authenticated
  USING (public.tm_owns_listing(id))
  WITH CHECK (status IN ('pending','inactive') AND EXISTS (
     SELECT 1 FROM public.business_owners o WHERE o.id = owner_id AND o.profile_id = (SELECT public.tm_active_profile_id())));

-- Children of a listing: menu items, rooms, attraction schedules.
DO $$
DECLARE t record;
BEGIN
  FOR t IN SELECT * FROM (VALUES ('menu_items','restaurant_id'),('rooms','hotel_id'),('attraction_schedules','attraction_id')) v(tbl,fk) LOOP
    EXECUTE format('DROP POLICY IF EXISTS tm_owner_%1$s_ins ON public.%1$s', t.tbl);
    EXECUTE format('CREATE POLICY tm_owner_%1$s_ins ON public.%1$s FOR INSERT TO authenticated WITH CHECK (public.tm_owns_listing(%2$s))', t.tbl, t.fk);
    EXECUTE format('DROP POLICY IF EXISTS tm_owner_%1$s_upd ON public.%1$s', t.tbl);
    EXECUTE format('CREATE POLICY tm_owner_%1$s_upd ON public.%1$s FOR UPDATE TO authenticated USING (public.tm_owns_listing(%2$s)) WITH CHECK (public.tm_owns_listing(%2$s))', t.tbl, t.fk);
    EXECUTE format('DROP POLICY IF EXISTS tm_owner_%1$s_del ON public.%1$s', t.tbl);
    EXECUTE format('CREATE POLICY tm_owner_%1$s_del ON public.%1$s FOR DELETE TO authenticated USING (public.tm_owns_listing(%2$s))', t.tbl, t.fk);
  END LOOP;
END $$;
-- hotels / restaurants / attractions detail rows: owners may update their own.
DO $$
DECLARE t record;
BEGIN
  FOR t IN SELECT * FROM (VALUES ('hotels','hotel_id'),('restaurants','restaurant_id'),('attractions','attraction_id')) v(tbl,fk) LOOP
    EXECUTE format('DROP POLICY IF EXISTS tm_owner_%1$s_upd ON public.%1$s', t.tbl);
    EXECUTE format('CREATE POLICY tm_owner_%1$s_upd ON public.%1$s FOR UPDATE TO authenticated USING (public.tm_owns_listing(%2$s)) WITH CHECK (public.tm_owns_listing(%2$s))', t.tbl, t.fk);
  END LOOP;
END $$;

-- Atomic create: listing + type-specific row, always status 'pending' (BR-031: approval before visibility).
CREATE OR REPLACE FUNCTION public.owner_create_listing(
  p_type text, p_destination uuid, p_name text, p_description text, p_address text,
  p_check_in time DEFAULT NULL, p_check_out time DEFAULT NULL,
  p_operating_hours text DEFAULT NULL, p_reservation_fee numeric DEFAULT 0,
  p_entrance_fee numeric DEFAULT NULL, p_schedule_day text DEFAULT NULL, p_schedule_text text DEFAULT NULL)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_owner uuid; v_id uuid; v_slug text;
BEGIN
  IF p_type NOT IN ('hotel','restaurant','attraction') THEN RAISE EXCEPTION 'Invalid listing type'; END IF;
  IF btrim(coalesce(p_name,'')) = '' THEN RAISE EXCEPTION 'Name is required'; END IF;
  SELECT o.id INTO v_owner FROM public.business_owners o WHERE o.profile_id = (SELECT public.tm_active_profile_id());
  IF v_owner IS NULL THEN RAISE EXCEPTION 'Only business owners can create listings'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.destinations WHERE id = p_destination AND is_active = 1) THEN RAISE EXCEPTION 'Unknown destination'; END IF;
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
END $$;
REVOKE ALL ON FUNCTION public.owner_create_listing(text,uuid,text,text,text,time,time,text,numeric,numeric,text,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.owner_create_listing(text,uuid,text,text,text,time,time,text,numeric,numeric,text,text) TO authenticated;
COMMIT;
