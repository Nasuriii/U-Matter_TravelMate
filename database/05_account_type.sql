-- TravelMate: let a signed-in user choose Traveler or Business Owner.
-- REVIEW FIRST, then run once in Supabase > SQL Editor on the existing project.
-- Why: profile_roles and business_owners only allow SELECT for users (RLS), so the
-- browser cannot assign roles itself. This function is the only write path and it can
-- only grant 'traveler' or 'business_owner' -- never admin/moderator/analyst/support.
-- No tables, policies or existing functions are changed.
BEGIN;
CREATE OR REPLACE FUNCTION public.set_my_account_type(p_account_type text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_profile uuid; v_name text; v_role uuid; v_email text;
BEGIN
  IF p_account_type NOT IN ('traveler','business_owner') THEN
    RAISE EXCEPTION 'Invalid account type';
  END IF;
  SELECT id, full_name INTO v_profile, v_name FROM public.profiles
   WHERE id = (SELECT auth.uid()) AND account_status = 'active';
  IF v_profile IS NULL THEN RAISE EXCEPTION 'No active profile for this user'; END IF;
  SELECT id INTO v_role FROM public.roles WHERE name = p_account_type;
  IF v_role IS NULL THEN RAISE EXCEPTION 'Role % is missing from public.roles', p_account_type; END IF;
  INSERT INTO public.profile_roles(profile_id, role_id) VALUES (v_profile, v_role) ON CONFLICT DO NOTHING;
  IF p_account_type = 'business_owner' THEN
    SELECT email INTO v_email FROM auth.users WHERE id = v_profile;
    INSERT INTO public.business_owners(profile_id, contact_name, contact_email)
    VALUES (v_profile, v_name, v_email) ON CONFLICT (profile_id) DO NOTHING;
  END IF;
END $$;
REVOKE ALL ON FUNCTION public.set_my_account_type(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_my_account_type(text) TO authenticated;
COMMIT;
