-- Run AFTER 16 and 17. Additive; preserves existing rows and policies.
BEGIN;
ALTER TABLE public.trip_items
 ADD COLUMN IF NOT EXISTS planned_end_time time,
 ADD COLUMN IF NOT EXISTS recommendation_reason text;
ALTER TABLE public.trip_items ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, DELETE ON public.trip_items TO authenticated;
CREATE OR REPLACE FUNCTION public.save_my_itinerary(
 p_trip uuid, p_expected_updated_at timestamptz, p_items jsonb
) RETURNS timestamptz
LANGUAGE plpgsql SECURITY INVOKER SET search_path = '' AS $$
DECLARE t public.trips%ROWTYPE; s record; previous_end timestamp; current_start timestamp; current_end timestamp; saved_at timestamptz;
BEGIN
 SELECT * INTO t FROM public.trips WHERE id=p_trip AND profile_id=(SELECT public.tm_active_profile_id()) FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Trip not found or not yours'; END IF;
 IF t.status <> 'draft' THEN RAISE EXCEPTION 'Only draft trips can replace an itinerary'; END IF;
 IF t.updated_at IS DISTINCT FROM p_expected_updated_at THEN RAISE EXCEPTION 'Trip changed. Reopen it before saving an itinerary.'; END IF;
 IF t.start_date IS NULL OR t.end_date IS NULL OR t.arrival_time IS NULL OR t.departure_time IS NULL OR t.destination_id IS NULL THEN RAISE EXCEPTION 'Complete the trip brief first'; END IF;
 IF p_items IS NULL OR jsonb_typeof(p_items)<>'array' THEN RAISE EXCEPTION 'Itinerary must be an array'; END IF;
 IF jsonb_array_length(p_items)<1 OR jsonb_array_length(p_items)>200 THEN RAISE EXCEPTION 'Itinerary needs 1 to 200 items'; END IF;
 FOR s IN SELECT value, ordinality FROM jsonb_array_elements(p_items) WITH ORDINALITY LOOP
  IF nullif(btrim(s.value->>'activity'),'') IS NULL OR length(s.value->>'activity')>255 THEN RAISE EXCEPTION 'Each item needs a title of 1 to 255 characters'; END IF;
  current_start:=(s.value->>'planned_date')::date+(s.value->>'planned_time')::time;
  current_end:=(s.value->>'planned_date')::date+(s.value->>'planned_end_time')::time;
  IF current_start IS NULL OR current_end IS NULL OR current_end<current_start OR current_start<t.start_date+t.arrival_time OR current_end>t.end_date+t.departure_time THEN RAISE EXCEPTION 'Item falls outside the trip window or has invalid times'; END IF;
  IF previous_end IS NOT NULL AND current_start<previous_end THEN RAISE EXCEPTION 'Items overlap or are out of order'; END IF;
  previous_end:=current_end;
  IF s.value->>'listing_id' IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public.business_listings b WHERE b.id=(s.value->>'listing_id')::uuid AND b.destination_id=t.destination_id AND b.status='approved') THEN RAISE EXCEPTION 'A suggested listing is unavailable or outside the destination. Regenerate the preview.'; END IF;
 END LOOP;
 DELETE FROM public.trip_items WHERE trip_id=p_trip;
 INSERT INTO public.trip_items(trip_id,listing_id,activity,sequence_number,planned_date,planned_time,planned_end_time,recommendation_reason,notes,status)
 SELECT p_trip,(value->>'listing_id')::uuid,value->>'activity',ordinality::integer,(value->>'planned_date')::date,(value->>'planned_time')::time,(value->>'planned_end_time')::time,left(value->>'recommendation_reason',2000),left(value->>'notes',4000),'planned'
 FROM jsonb_array_elements(p_items) WITH ORDINALITY;
 UPDATE public.trips SET updated_at=clock_timestamp() WHERE id=p_trip RETURNING updated_at INTO saved_at;
 RETURN saved_at;
END $$;
REVOKE ALL ON FUNCTION public.save_my_itinerary(uuid,timestamptz,jsonb) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.save_my_itinerary(uuid,timestamptz,jsonb) TO authenticated;
COMMIT;
NOTIFY pgrst,'reload schema';
