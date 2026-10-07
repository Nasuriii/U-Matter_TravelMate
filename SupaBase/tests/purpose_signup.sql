BEGIN;
CREATE TEMP TABLE signup_qa AS SELECT gen_random_uuid() traveler,gen_random_uuid() owner,gen_random_uuid() oauth,gen_random_uuid() legacy;
CREATE TEMP TABLE signup_checks(label text);
GRANT SELECT ON signup_qa TO authenticated; GRANT INSERT ON signup_checks TO authenticated;
INSERT INTO auth.users(id,email,email_confirmed_at,raw_user_meta_data)
SELECT traveler,'qa-'||traveler||'@example.invalid',now(),'{"full_name":"QA Traveler","signup_account_type":"traveler"}'::jsonb FROM signup_qa
UNION ALL SELECT owner,'qa-'||owner||'@example.invalid',now(),'{"full_name":"QA Owner","signup_account_type":"business_owner"}'::jsonb FROM signup_qa
UNION ALL SELECT oauth,'qa-'||oauth||'@example.invalid',now(),'{"full_name":"QA OAuth"}'::jsonb FROM signup_qa
UNION ALL SELECT legacy,'qa-'||legacy||'@example.invalid',now(),'{"full_name":"QA Existing"}'::jsonb FROM signup_qa;
DELETE FROM travelmate_ui.signup_enrollments WHERE profile_id=(SELECT legacy FROM signup_qa);
DELETE FROM public.traveler_settings WHERE profile_id=(SELECT legacy FROM signup_qa);
DO $$ BEGIN
 IF (SELECT count(*) FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=(SELECT owner FROM signup_qa) AND r.name='business_owner')<>1 OR EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=(SELECT owner FROM signup_qa) AND r.name='traveler') THEN RAISE EXCEPTION 'Email owner role failed'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.business_owners WHERE profile_id=(SELECT owner FROM signup_qa)) THEN RAISE EXCEPTION 'Owner profile missing'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.traveler_settings WHERE profile_id=(SELECT traveler FROM signup_qa) AND onboarding_completed_at IS NULL) THEN RAISE EXCEPTION 'Traveler onboarding missing'; END IF;
 INSERT INTO signup_checks VALUES('Email signup creates exactly the requested nonprivileged role and onboarding');
END $$;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub',(SELECT traveler::text FROM signup_qa),true);
DO $$ BEGIN
 IF public.finish_my_signup('business_owner')->>'role'<>'traveler' THEN RAISE EXCEPTION 'Existing email role switched'; END IF;
 PERFORM public.save_my_travel_preferences(ARRAY['beaches','mountains'],'relaxed',false);
 IF NOT EXISTS(SELECT 1 FROM public.traveler_settings WHERE interests @> ARRAY['beaches','mountains'] AND travel_pace='relaxed' AND onboarding_completed_at IS NOT NULL) THEN RAISE EXCEPTION 'Preferences not saved'; END IF;
 IF (SELECT count(*) FROM public.profile_preferences WHERE profile_id=auth.uid())<>2 THEN RAISE EXCEPTION 'Catalog preference sync failed'; END IF;
 PERFORM public.save_my_travel_preferences('{}','balanced',true);
 IF NOT EXISTS(SELECT 1 FROM public.traveler_settings WHERE travel_pace='relaxed' AND interests @> ARRAY['beaches']) THEN RAISE EXCEPTION 'Skip erased preferences'; END IF;
 INSERT INTO signup_checks VALUES('Finalized role immutable'),('Preferences persist and sync with catalog'),('Skip preserves prior defaults');
END $$;
SELECT set_config('request.jwt.claim.sub',(SELECT oauth::text FROM signup_qa),true);
DO $$ BEGIN
 IF public.finish_my_signup('business_owner')->>'role'<>'business_owner' THEN RAISE EXCEPTION 'OAuth owner enrollment failed'; END IF;
 IF public.finish_my_signup('traveler')->>'role'<>'business_owner' THEN RAISE EXCEPTION 'OAuth role switched later'; END IF;
 IF EXISTS(SELECT 1 FROM public.traveler_settings) THEN RAISE EXCEPTION 'Cross-account preferences exposed'; END IF;
 BEGIN PERFORM public.save_my_travel_preferences(ARRAY['nature'],'balanced',false); RAISE EXCEPTION 'Owner saved traveler preferences'; EXCEPTION WHEN raise_exception THEN IF SQLERRM='Owner saved traveler preferences' THEN RAISE; END IF; END;
 BEGIN PERFORM public.finish_my_signup('admin'); RAISE EXCEPTION 'Admin self enrollment allowed'; EXCEPTION WHEN raise_exception THEN IF SQLERRM='Admin self enrollment allowed' THEN RAISE; END IF; END;
 INSERT INTO signup_checks VALUES('OAuth role chosen once'),('Preference RLS isolates accounts'),('Owner preferences denied'),('Admin self-enrollment denied');
END $$;
SELECT set_config('request.jwt.claim.sub',(SELECT legacy::text FROM signup_qa),true);
DO $$ BEGIN
 IF public.finish_my_signup('business_owner')->>'role'<>'traveler' THEN RAISE EXCEPTION 'Legacy user switched'; END IF;
 INSERT INTO signup_checks VALUES('Existing account role retained');
 IF has_function_privilege('anon','public.finish_my_signup(text)','execute') OR has_table_privilege('authenticated','public.traveler_settings','update') THEN RAISE EXCEPTION 'Unsafe grants'; END IF;
 INSERT INTO signup_checks VALUES('Anonymous enrollment and direct settings writes denied');
END $$;
RESET ROLE;
SELECT jsonb_build_object('passed',count(*),'checks',jsonb_agg(label),'fixtures','All fixtures rolled back') AS verification FROM signup_checks;
ROLLBACK;
