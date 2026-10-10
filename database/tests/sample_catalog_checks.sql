-- Run in Supabase SQL editor as a database administrator. Every check rolls back.
BEGIN;
SET LOCAL ROLE anon;
DO $$ DECLARE feed jsonb; BEGIN
 SELECT public.place_reviews(NULL,id,0) INTO feed FROM public.business_listings
 WHERE slug='sample-baguio-pine-haven';
 IF feed IS NULL OR jsonb_array_length(feed->'sample_items')<>3 THEN RAISE EXCEPTION 'Missing sample review previews'; END IF;
 IF (feed->>'total')::integer<>0 OR feed->>'average' IS NOT NULL THEN RAISE EXCEPTION 'Sample reviews leaked into authentic ratings'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(feed->'sample_items') s WHERE (s->>'verified')::boolean) THEN RAISE EXCEPTION 'Sample review marked verified'; END IF;
 IF jsonb_typeof(public.recent_traveler_reviews())<>'array' THEN RAISE EXCEPTION 'Public genuine-review feed unavailable'; END IF;
END $$;
ROLLBACK;

BEGIN;
-- Simulate the claims of an existing active, exclusive sample traveler for this transaction only.
SELECT set_config('request.jwt.claims',jsonb_build_object('sub',(
 SELECT p.id FROM public.profiles p WHERE p.account_status='active' AND p.full_name LIKE '%(Demo)%'
 AND EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=p.id AND r.name='traveler')
 AND NOT EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=p.id AND r.name IN ('admin','business_owner'))
 ORDER BY p.full_name LIMIT 1),'role','authenticated')::text,true);
SET LOCAL ROLE authenticated;
DO $$ DECLARE lid uuid; rid uuid; rejected boolean:=false; BEGIN
 SELECT l.id,r.id INTO lid,rid FROM public.business_listings l JOIN public.rooms r ON r.hotel_id=l.id WHERE l.slug='sample-baguio-pine-haven' LIMIT 1;
 BEGIN
  PERFORM public.reserve_my_booking(lid,rid,NULL,current_date+1,current_date+2,1,'Preview Guest','guest@example.com',NULL,'sample-guard-test-20261010');
 EXCEPTION WHEN OTHERS THEN
  IF SQLERRM='This is a preview listing. No real reservation or payment is available' THEN rejected:=true; ELSE RAISE; END IF;
 END;
 IF NOT rejected THEN RAISE EXCEPTION 'Sample booking guard failed'; END IF;
END $$;
ROLLBACK;
