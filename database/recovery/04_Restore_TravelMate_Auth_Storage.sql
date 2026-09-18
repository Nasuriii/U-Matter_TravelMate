-- TravelMate custom Auth / Storage recovery supplement.
-- Extracted from your uploaded auth-storage-schema.sql, 18 September 2026.
-- SAVE WITH THE BACKUP. Do not run against the existing source project.
-- Run once on a separate restore target AFTER application schema and data restore.
-- Requires Supabase-managed auth/storage schemas, anon/authenticated roles,
-- public profiles/photos and tm_* functions from schema.sql.
-- Does not restore Auth records, bucket settings, uploaded bytes or Google config.
-- Existing matching policies cause an error and roll back this transaction.
-- Do not replace this with the full managed auth-storage-schema.sql dump.

BEGIN;
DO $$ BEGIN
  IF to_regprocedure('public.tm_on_auth_profile_event()') IS NULL
    OR to_regprocedure('public.tm_active_profile_id()') IS NULL
    OR to_regprocedure('public.tm_owns_listing_path(text)') IS NULL
    OR to_regclass('public.photos') IS NULL THEN
    RAISE EXCEPTION 'Restore the TravelMate application schema first';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='storage' AND c.relname='objects' AND c.relrowsecurity
  ) THEN
    RAISE EXCEPTION 'Supabase storage.objects must exist with RLS enabled';
  END IF;
END $$;

CREATE OR REPLACE TRIGGER "travelmate_auth_profile_created" AFTER INSERT OR UPDATE OF "email_confirmed_at" ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."tm_on_auth_profile_event"();

CREATE POLICY "tm_avatar_delete" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = 'travelmate-avatars'::"text") AND (("storage"."foldername"("name"))[1] = (( SELECT "public"."tm_active_profile_id"() AS "tm_active_profile_id"))::"text")));

CREATE POLICY "tm_avatar_read" ON "storage"."objects" FOR SELECT TO "authenticated" USING ((("bucket_id" = 'travelmate-avatars'::"text") AND (("storage"."foldername"("name"))[1] = (( SELECT "public"."tm_active_profile_id"() AS "tm_active_profile_id"))::"text")));

CREATE POLICY "tm_avatar_update" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'travelmate-avatars'::"text") AND (("storage"."foldername"("name"))[1] = (( SELECT "public"."tm_active_profile_id"() AS "tm_active_profile_id"))::"text"))) WITH CHECK ((("bucket_id" = 'travelmate-avatars'::"text") AND (("storage"."foldername"("name"))[1] = (( SELECT "public"."tm_active_profile_id"() AS "tm_active_profile_id"))::"text")));

CREATE POLICY "tm_avatar_upload" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = 'travelmate-avatars'::"text") AND (("storage"."foldername"("name"))[1] = (( SELECT "public"."tm_active_profile_id"() AS "tm_active_profile_id"))::"text")));

CREATE POLICY "tm_listing_approved_read" ON "storage"."objects" FOR SELECT TO "authenticated", "anon" USING ((("bucket_id" = 'travelmate-listings'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."photos" "p"
  WHERE (("p"."bucket_id" = "objects"."bucket_id") AND ("p"."object_path" = "objects"."name") AND (("p"."status")::"text" = 'approved'::"text"))))));

CREATE POLICY "tm_listing_owner_read" ON "storage"."objects" FOR SELECT TO "authenticated" USING ((("bucket_id" = 'travelmate-listings'::"text") AND "public"."tm_owns_listing_path"("name")));

CREATE POLICY "tm_listing_upload" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK ((("bucket_id" = 'travelmate-listings'::"text") AND "public"."tm_owns_listing_path"("name")));

COMMIT;
SELECT 'Restored one TravelMate Auth trigger and seven Storage policies' AS result;
