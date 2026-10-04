-- TravelMate: prevent duplicate listings, menu items and schedule rows (business challenge in the project document).
-- Run once in the Supabase SQL Editor after 05-12. Safe to re-run. No data is changed or deleted by this file.
-- If duplicates already exist it STOPS and lists them. Remove the extra copies first:
--   * duplicate listings: Business Dashboard > Delete on the extra copy
--   * duplicate menu items / schedule rows: Manage > Remove on the extra copy
-- then run this file again.
BEGIN;

DO $$
DECLARE d text;
BEGIN
  SELECT string_agg(format('%s "%s" x%s', listing_type, name, c), '; ') INTO d FROM (
    SELECT listing_type, min(name) AS name, count(*) AS c FROM public.business_listings
    GROUP BY destination_id, listing_type, lower(btrim(name)) HAVING count(*) > 1) x;
  IF d IS NOT NULL THEN RAISE EXCEPTION 'Duplicate listings exist (same destination, type and name): %. Delete the extra copies in the Business Dashboard, then run this file again.', d; END IF;

  SELECT string_agg(format('"%s" x%s', name, c), '; ') INTO d FROM (
    SELECT min(name) AS name, count(*) AS c FROM public.menu_items
    GROUP BY restaurant_id, lower(btrim(name)) HAVING count(*) > 1) x;
  IF d IS NOT NULL THEN RAISE EXCEPTION 'Duplicate menu items exist (same restaurant and name): %. Remove the extra copies under Manage > Menu, then run this file again.', d; END IF;

  SELECT string_agg(format('%s %s x%s', day, hrs, c), '; ') INTO d FROM (
    SELECT min(operating_day) AS day, min(schedule_text) AS hrs, count(*) AS c FROM public.attraction_schedules
    GROUP BY attraction_id, lower(btrim(operating_day)), lower(btrim(schedule_text)) HAVING count(*) > 1) x;
  IF d IS NOT NULL THEN RAISE EXCEPTION 'Duplicate schedule rows exist: %. Remove the extra copies under Manage > Operating schedule, then run this file again.', d; END IF;
END $$;

-- One business per destination, type and name (ignores capital letters and extra spaces).
CREATE UNIQUE INDEX IF NOT EXISTS tm_listing_name_unique ON public.business_listings (destination_id, listing_type, (lower(btrim(name))));
-- One dish per restaurant and name.
CREATE UNIQUE INDEX IF NOT EXISTS tm_menu_item_name_unique ON public.menu_items (restaurant_id, (lower(btrim(name))));
-- One identical schedule row per attraction.
CREATE UNIQUE INDEX IF NOT EXISTS tm_schedule_unique ON public.attraction_schedules (attraction_id, (lower(btrim(operating_day))), (lower(btrim(schedule_text))));
COMMIT;
