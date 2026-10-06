-- Additive migration for the supplied public.trips schema. Run as postgres.
-- Existing rows remain compatible. Existing RLS policies remain in effect.
BEGIN;
ALTER TABLE public.trips
 ADD COLUMN IF NOT EXISTS destination_id uuid REFERENCES public.destinations(id) ON DELETE RESTRICT,
 ADD COLUMN IF NOT EXISTS arrival_time time,
 ADD COLUMN IF NOT EXISTS departure_time time,
 ADD COLUMN IF NOT EXISTS budget_currency text,
 ADD COLUMN IF NOT EXISTS party_size integer,
 ADD COLUMN IF NOT EXISTS travel_pace text,
 ADD COLUMN IF NOT EXISTS interests text[];
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='public.trips'::regclass AND conname='trip_brief_valid') THEN
 ALTER TABLE public.trips ADD CONSTRAINT trip_brief_valid CHECK (
 (budget_currency IS NULL OR budget_currency IN ('PHP','HKD','USD')) AND
 (party_size IS NULL OR party_size BETWEEN 1 AND 20) AND
 (travel_pace IS NULL OR travel_pace IN ('relaxed','balanced','active')) AND
 (interests IS NULL OR interests <@ ARRAY['food','nature','history','shopping']::text[]) AND
 (arrival_time IS NULL OR start_date IS NOT NULL) AND
 (departure_time IS NULL OR end_date IS NOT NULL) AND
 (start_date IS DISTINCT FROM end_date OR arrival_time IS NULL OR departure_time IS NULL OR departure_time > arrival_time)
 ); END IF;
END $$;
COMMIT;
NOTIFY pgrst, 'reload schema';
