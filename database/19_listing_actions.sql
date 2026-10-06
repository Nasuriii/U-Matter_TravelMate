-- Overhaul 04. Run AFTER existing migrations 05-18. No records removed.
-- Version checks cover business_listings.updated_at, not every child-table edit.
BEGIN;
CREATE OR REPLACE FUNCTION public.owner_transition_listing(
  p_listing uuid, p_status text, p_expected_updated_at timestamptz
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_status text; v_updated timestamptz;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  SELECT status, updated_at INTO v_status, v_updated FROM public.business_listings WHERE id = p_listing FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Listing not found'; END IF;
  IF p_expected_updated_at IS NULL OR v_updated IS DISTINCT FROM p_expected_updated_at THEN
    RAISE EXCEPTION 'This listing changed. Refresh the page and try again.';
  END IF;
  IF p_status IS NULL OR NOT ((p_status = 'pending' AND v_status IN ('inactive','rejected'))
    OR (p_status = 'inactive' AND v_status IN ('pending','approved'))) THEN
    RAISE EXCEPTION 'This action is not available for the current listing status';
  END IF;
  PERFORM public.owner_set_listing_status(p_listing, p_status);
  UPDATE public.business_listings SET updated_at = clock_timestamp() WHERE id = p_listing;
END $$;
CREATE OR REPLACE FUNCTION public.admin_decide_listing(
  p_listing uuid, p_approve boolean, p_reason text, p_expected_updated_at timestamptz
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_status text; v_updated timestamptz;
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  SELECT status, updated_at INTO v_status, v_updated FROM public.business_listings WHERE id = p_listing FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Listing not found'; END IF;
  IF p_expected_updated_at IS NULL OR v_updated IS DISTINCT FROM p_expected_updated_at THEN
    RAISE EXCEPTION 'This listing changed. Refresh the review queue before deciding.';
  END IF;
  IF v_status <> 'pending' OR p_approve IS NULL THEN RAISE EXCEPTION 'Only pending listings can be reviewed'; END IF;
  PERFORM public.admin_review_listing(p_listing, p_approve, p_reason);
END $$;
REVOKE ALL ON FUNCTION public.owner_transition_listing(uuid,text,timestamptz) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.admin_decide_listing(uuid,boolean,text,timestamptz) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.owner_transition_listing(uuid,text,timestamptz) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_decide_listing(uuid,boolean,text,timestamptz) TO authenticated;
COMMIT;
NOTIFY pgrst, 'reload schema';
