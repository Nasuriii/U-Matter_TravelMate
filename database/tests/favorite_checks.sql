-- Each verification uses transactional identities and leaves no persisted test saves.
BEGIN;
SELECT set_config('request.jwt.claims',jsonb_build_object('sub',(SELECT p.id FROM public.profiles p WHERE p.account_status='active' AND p.full_name LIKE '%(Demo)%' AND EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=p.id AND r.name='traveler') AND NOT EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=p.id AND r.name IN ('admin','business_owner')) ORDER BY p.full_name LIMIT 1),'role','authenticated')::text,true);
SET LOCAL ROLE authenticated;
DO $$ DECLARE lid uuid; mid uuid; rejected boolean:=false; BEGIN
 SELECT id INTO lid FROM public.business_listings WHERE is_sample AND listing_type='hotel' AND status='approved' LIMIT 1;
 SELECT m.id INTO mid FROM public.menu_items m JOIN public.business_listings l ON l.id=m.restaurant_id WHERE l.is_sample AND l.status='approved' AND m.is_available=1 LIMIT 1;
 PERFORM public.set_saved_place(lid,NULL,true);PERFORM public.set_saved_place(lid,NULL,true);PERFORM public.set_saved_place(NULL,mid,true);
 IF (SELECT count(*) FROM public.saved_places WHERE listing_id=lid OR menu_item_id=mid)<>2 THEN RAISE EXCEPTION 'Save/idempotency failed'; END IF;
 BEGIN INSERT INTO public.saved_places(profile_id,listing_id) VALUES(gen_random_uuid(),lid);EXCEPTION WHEN insufficient_privilege THEN rejected:=true; END;
 IF NOT rejected THEN RAISE EXCEPTION 'Forged favorite allowed';END IF;
 rejected:=false;BEGIN PERFORM public.sample_performance();EXCEPTION WHEN OTHERS THEN IF SQLERRM='Business workspace required' THEN rejected:=true;ELSE RAISE;END IF;END;
 IF NOT rejected THEN RAISE EXCEPTION 'Traveler accessed business figures';END IF;
 PERFORM public.set_saved_place(lid,NULL,false);PERFORM public.set_saved_place(NULL,mid,false);
 IF EXISTS(SELECT 1 FROM public.saved_places WHERE listing_id=lid OR menu_item_id=mid) THEN RAISE EXCEPTION 'Unsave failed';END IF;
END $$;
ROLLBACK;
SELECT 'Favorite persistence, idempotency, ownership and role isolation passed' result;
