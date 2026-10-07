-- Purpose-specific signup. Metadata is accepted only as an allowlisted, one-time
-- self-enrollment request. Authorization always uses persistent profile_roles.
CREATE TABLE travelmate_ui.signup_enrollments (
 profile_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
 finalized boolean NOT NULL DEFAULT false,
 created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE travelmate_ui.signup_enrollments ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON travelmate_ui.signup_enrollments FROM PUBLIC, anon, authenticated;
CREATE TABLE public.traveler_settings (
 profile_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
 interests text[] NOT NULL DEFAULT '{}',
 travel_pace text NOT NULL DEFAULT 'balanced' CHECK(travel_pace IN ('relaxed','balanced','active')),
 onboarding_completed_at timestamptz,
 CHECK(interests <@ ARRAY['beaches','mountains','nature','food','history','adventure','relaxation','shopping']::text[])
);
ALTER TABLE public.traveler_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY own_settings ON public.traveler_settings FOR SELECT TO authenticated USING(profile_id=(SELECT auth.uid()));
REVOKE ALL ON public.traveler_settings FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.traveler_settings TO authenticated;
GRANT ALL ON public.traveler_settings TO service_role;
INSERT INTO public.preferences(category,name)
 SELECT 'Travel interests',name FROM (VALUES('Adventure activities'),('Shopping')) AS v(name)
 WHERE NOT EXISTS(SELECT 1 FROM public.preferences p WHERE p.category='Travel interests' AND p.name=v.name);

CREATE OR REPLACE FUNCTION public.tm_provision_profile(p_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE a auth.users%ROWTYPE; added integer; requested text; chosen text;
BEGIN
 SELECT * INTO a FROM auth.users WHERE id=p_id;
 IF NOT FOUND OR a.email_confirmed_at IS NULL OR a.email IS NULL THEN RETURN; END IF;
 INSERT INTO public.profiles(id,full_name)
 VALUES(a.id,left(coalesce(nullif(btrim(a.raw_user_meta_data->>'full_name'),''),nullif(btrim(a.raw_user_meta_data->>'name'),''),'Traveler'),150))
 ON CONFLICT(id) DO NOTHING;
 GET DIAGNOSTICS added=ROW_COUNT;
 -- Never reassign an existing profile when metadata or confirmation changes.
 IF added=0 THEN RETURN; END IF;
 requested:=a.raw_user_meta_data->>'signup_account_type';
 chosen:=CASE WHEN requested='business_owner' THEN 'business_owner' ELSE 'traveler' END;
 INSERT INTO public.profile_roles(profile_id,role_id) SELECT a.id,id FROM public.roles WHERE name=chosen;
 INSERT INTO travelmate_ui.signup_enrollments(profile_id,finalized) VALUES(a.id,coalesce(requested IN ('traveler','business_owner'),false));
 IF chosen='business_owner' THEN
  INSERT INTO public.business_owners(profile_id,contact_name,contact_email)
  SELECT a.id,p.full_name,a.email FROM public.profiles p WHERE p.id=a.id ON CONFLICT(profile_id) DO NOTHING;
 ELSE INSERT INTO public.traveler_settings(profile_id) VALUES(a.id); END IF;
END $$;
REVOKE ALL ON FUNCTION public.tm_provision_profile(uuid) FROM PUBLIC,anon,authenticated;

CREATE FUNCTION travelmate_ui.finish_signup(p_account_type text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid:=auth.uid(); finalized boolean; actual text; fresh boolean:=false;
BEGIN
 IF uid IS NULL OR NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=uid AND account_status='active') THEN RAISE EXCEPTION 'An active account is required'; END IF;
 IF p_account_type IS NULL OR p_account_type NOT IN ('traveler','business_owner') THEN RAISE EXCEPTION 'Invalid signup type'; END IF;
 SELECT s.finalized INTO finalized FROM travelmate_ui.signup_enrollments s WHERE profile_id=uid FOR UPDATE;
 IF FOUND AND NOT finalized THEN
  -- Only new OAuth enrollment may replace its provisional traveler role.
  IF NOT EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=uid AND r.name<>'traveler') THEN
   IF p_account_type='business_owner' THEN
    DELETE FROM public.profile_roles pr USING public.roles r WHERE pr.profile_id=uid AND pr.role_id=r.id AND r.name='traveler';
    INSERT INTO public.profile_roles(profile_id,role_id) SELECT uid,id FROM public.roles WHERE name='business_owner' ON CONFLICT DO NOTHING;
    INSERT INTO public.business_owners(profile_id,contact_name,contact_email)
    SELECT uid,p.full_name,a.email FROM public.profiles p JOIN auth.users a ON a.id=p.id WHERE p.id=uid ON CONFLICT(profile_id) DO NOTHING;
    DELETE FROM public.traveler_settings WHERE profile_id=uid;
   END IF;
  END IF;
  UPDATE travelmate_ui.signup_enrollments SET finalized=true WHERE profile_id=uid;
  fresh:=true;
 END IF;
 SELECT r.name INTO actual FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=uid
 ORDER BY CASE r.name WHEN 'admin' THEN 0 WHEN 'business_owner' THEN 1 WHEN 'traveler' THEN 2 ELSE 3 END LIMIT 1;
 RETURN jsonb_build_object('role',actual,'new_account',fresh,'onboarding_needed',actual='traveler' AND EXISTS(SELECT 1 FROM public.traveler_settings WHERE profile_id=uid AND onboarding_completed_at IS NULL));
END $$;
REVOKE ALL ON FUNCTION travelmate_ui.finish_signup(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION travelmate_ui.finish_signup(text) TO authenticated;
CREATE FUNCTION public.finish_my_signup(p_account_type text) RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$ SELECT travelmate_ui.finish_signup(p_account_type); $$;
REVOKE ALL ON FUNCTION public.finish_my_signup(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.finish_my_signup(text) TO authenticated;
-- Retire the old repeatable role-switching path while preserving its signature.
CREATE OR REPLACE FUNCTION public.set_my_account_type(p_account_type text) RETURNS void LANGUAGE plpgsql SECURITY INVOKER SET search_path='' AS $$ BEGIN PERFORM travelmate_ui.finish_signup(p_account_type); END $$;
REVOKE ALL ON FUNCTION public.set_my_account_type(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.set_my_account_type(text) TO authenticated;

CREATE FUNCTION travelmate_ui.save_preferences(p_interests text[],p_pace text,p_skip boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid:=auth.uid();
BEGIN
 IF uid IS NULL OR NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=uid AND account_status='active')
 OR NOT EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=uid AND r.name='traveler')
 OR EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=uid AND r.name IN ('admin','business_owner')) THEN RAISE EXCEPTION 'Traveler account required'; END IF;
 IF p_skip IS NULL OR p_interests IS NULL OR NOT p_interests <@ ARRAY['beaches','mountains','nature','food','history','adventure','relaxation','shopping']::text[] OR p_pace IS NULL OR p_pace NOT IN ('relaxed','balanced','active') THEN RAISE EXCEPTION 'Invalid preferences'; END IF;
 IF p_skip THEN
  INSERT INTO public.traveler_settings(profile_id,onboarding_completed_at) VALUES(uid,now()) ON CONFLICT(profile_id) DO UPDATE SET onboarding_completed_at=coalesce(traveler_settings.onboarding_completed_at,now());
  RETURN;
 END IF;
 INSERT INTO public.traveler_settings(profile_id,interests,travel_pace,onboarding_completed_at)
 VALUES(uid,ARRAY(SELECT DISTINCT unnest(p_interests)),p_pace,now())
 ON CONFLICT(profile_id) DO UPDATE SET interests=excluded.interests,travel_pace=excluded.travel_pace,onboarding_completed_at=excluded.onboarding_completed_at;
 DELETE FROM public.profile_preferences pp USING public.preferences p WHERE pp.profile_id=uid AND pp.preference_id=p.id AND p.category='Travel interests' AND p.name IN ('Coastal visits','Mountain scenery','Nature walks','Local cuisine','Heritage walks','Adventure activities','Quiet stays','Shopping');
 INSERT INTO public.profile_preferences(profile_id,preference_id)
 SELECT uid,p.id FROM public.preferences p JOIN (VALUES('beaches','Coastal visits'),('mountains','Mountain scenery'),('nature','Nature walks'),('food','Local cuisine'),('history','Heritage walks'),('adventure','Adventure activities'),('relaxation','Quiet stays'),('shopping','Shopping')) AS m(code,name) ON p.name=m.name AND p.category='Travel interests' WHERE m.code=ANY(p_interests) ON CONFLICT DO NOTHING;
END $$;
REVOKE ALL ON FUNCTION travelmate_ui.save_preferences(text[],text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION travelmate_ui.save_preferences(text[],text,boolean) TO authenticated;
CREATE FUNCTION public.save_my_travel_preferences(p_interests text[],p_pace text,p_skip boolean DEFAULT false) RETURNS void LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$ SELECT travelmate_ui.save_preferences(p_interests,p_pace,p_skip); $$;
REVOKE ALL ON FUNCTION public.save_my_travel_preferences(text[],text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.save_my_travel_preferences(text[],text,boolean) TO authenticated;
ALTER TABLE public.trips DROP CONSTRAINT trip_brief_valid;
ALTER TABLE public.trips ADD CONSTRAINT trip_brief_valid CHECK(
 (budget_currency IS NULL OR budget_currency IN ('PHP','HKD','USD')) AND
 (party_size IS NULL OR party_size BETWEEN 1 AND 20) AND
 (travel_pace IS NULL OR travel_pace IN ('relaxed','balanced','active')) AND
 (interests IS NULL OR interests <@ ARRAY['food','nature','history','shopping','beaches','mountains','adventure','relaxation']::text[]) AND
 (arrival_time IS NULL OR start_date IS NOT NULL) AND (departure_time IS NULL OR end_date IS NOT NULL) AND
 (start_date IS DISTINCT FROM end_date OR arrival_time IS NULL OR departure_time IS NULL OR departure_time>arrival_time));
NOTIFY pgrst,'reload schema';
