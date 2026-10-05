--
-- PostgreSQL database dump
--

\restrict TFHbn4WGhZqcQ5nr8d4Wcp9EgJaLy0P0KlUgsCQqbXZjAuw2qa3py2SRKOy8f8D

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: api; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA api;


--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: travelmate; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA travelmate;


--
-- Name: travelmate_private; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA travelmate_private;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone',
    'recovery_code'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in',
    'like',
    'ilike',
    'is',
    'match',
    'imatch',
    'isdistinct'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text,
	negate boolean
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
    revoke trigger on cron.job_run_details from postgres;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $_$
begin
    if not exists (
        select 1
        from pg_catalog.pg_event_trigger_ddl_commands() ev
        join pg_catalog.pg_extension e on ev.objid = e.oid
        where e.extname = 'pg_graphql'
    ) then
        return;
    end if;

    drop function if exists graphql_public.graphql;
    create or replace function graphql_public.graphql(
        "operationName" text default null,
        query text default null,
        variables jsonb default null,
        extensions jsonb default null
    )
        returns jsonb
        language sql
    as $$
        select graphql.resolve(
            query := query,
            variables := coalesce(variables, '{}'),
            "operationName" := "operationName",
            extensions := extensions
        );
    $$;

    -- Attach the wrapper to the extension so DROP EXTENSION cascades to it,
    -- which in turn triggers set_graphql_placeholder to reinstall the "not enabled" stub.
    alter extension pg_graphql add function graphql_public.graphql(text, text, jsonb, jsonb);

    grant usage on schema graphql to postgres, anon, authenticated, service_role;
    grant execute on function graphql.resolve to postgres, anon, authenticated, service_role;
    grant usage on schema graphql to postgres with grant option;
    grant usage on schema graphql_public to postgres with grant option;
end;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8.0', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
            set search_path to ''
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: graphql(text, text, jsonb, jsonb); Type: FUNCTION; Schema: graphql_public; Owner: -
--

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: admin_listing_photos(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_listing_photos(p_listing uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', p.id, 'object_path', p.object_path, 'status', p.status) ORDER BY p.sort_order, p.created_at)
                   FROM public.photos p WHERE p.listing_id = p_listing), '[]'::jsonb);
END $$;


--
-- Name: admin_pending_listings(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_pending_listings(p_type text DEFAULT 'hotel'::text) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((
    SELECT jsonb_agg(x.j ORDER BY x.created) FROM (
      SELECT l.created_at AS created, jsonb_build_object(
        'id', l.id, 'name', l.name, 'type', l.listing_type, 'address', l.address, 'description', l.description,
        'destination', d.name || ', ' || d.province, 'owner', o.contact_name, 'owner_email', o.contact_email,
        'submitted', l.updated_at, 'check_in', h.check_in_time, 'check_out', h.check_out_time,
        'problems', CASE WHEN l.listing_type = 'hotel' THEN to_jsonb(public.tm_hotel_problems(l.id)) ELSE '[]'::jsonb END,
        'rooms', (SELECT coalesce(jsonb_agg(jsonb_build_object('room_number', r.room_number, 'room_type', r.room_type,
                    'max_guests', r.max_guests, 'rate', r.base_nightly_rate, 'status', r.operational_status) ORDER BY r.room_number), '[]'::jsonb)
                  FROM public.rooms r WHERE r.hotel_id = l.id),
        'amenities', (SELECT coalesce(jsonb_agg(a.name ORDER BY a.name), '[]'::jsonb)
                      FROM public.hotel_amenities ha JOIN public.amenities a ON a.id = ha.amenity_id WHERE ha.hotel_id = l.id)
      ) AS j
      FROM public.business_listings l
      JOIN public.business_owners o ON o.id = l.owner_id
      JOIN public.destinations d ON d.id = l.destination_id
      LEFT JOIN public.hotels h ON h.hotel_id = l.id
      WHERE l.status = 'pending' AND l.listing_type = p_type
    ) x), '[]'::jsonb);
END $$;


--
-- Name: admin_review_listing(uuid, boolean, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_review_listing(p_listing uuid, p_approve boolean, p_reason text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE l record; v_problems text[]; v_admin uuid := (SELECT public.tm_active_profile_id());
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  SELECT bl.id, bl.name, bl.listing_type, bl.status, o.profile_id AS owner_profile INTO l
    FROM public.business_listings bl JOIN public.business_owners o ON o.id = bl.owner_id
   WHERE bl.id = p_listing FOR UPDATE OF bl;
  IF NOT FOUND THEN RAISE EXCEPTION 'Listing not found'; END IF;
  IF l.status <> 'pending' THEN RAISE EXCEPTION 'Only listings awaiting review can be approved or rejected (this one is %)', l.status; END IF;
  IF p_approve THEN
    v_problems := public.tm_listing_problems(p_listing);
    IF cardinality(v_problems) > 0 THEN RAISE EXCEPTION 'Cannot approve yet: %', array_to_string(v_problems, '; '); END IF;
  ELSIF btrim(coalesce(p_reason, '')) = '' THEN
    RAISE EXCEPTION 'Give the owner a reason for rejecting this listing';
  END IF;
  UPDATE public.business_listings
     SET status = CASE WHEN p_approve THEN 'approved' ELSE 'rejected' END,
         reviewed_by = v_admin, reviewed_at = now(), updated_at = now(),
         rejection_reason = CASE WHEN p_approve THEN NULL ELSE btrim(p_reason) END
   WHERE id = p_listing;
  INSERT INTO public.notifications(id, profile_id, message, created_at)
  VALUES (gen_random_uuid(), l.owner_profile,
          CASE WHEN p_approve THEN format('Your %s listing "%s" was approved and is now visible to travelers.', l.listing_type, l.name)
               ELSE format('Your %s listing "%s" was not approved. Reason: %s', l.listing_type, l.name, btrim(p_reason)) END,
          now());
END $$;


--
-- Name: admin_review_queue(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_review_queue() RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((
    SELECT jsonb_agg(x.j ORDER BY x.created) FROM (
      SELECT l.created_at AS created,
        jsonb_build_object(
          'id', l.id, 'name', l.name, 'type', l.listing_type, 'address', l.address, 'description', l.description,
          'destination', d.name || ', ' || d.province, 'owner', o.contact_name, 'owner_email', o.contact_email,
          'submitted', l.updated_at, 'problems', to_jsonb(public.tm_listing_problems(l.id)))
        || CASE l.listing_type
          WHEN 'hotel' THEN jsonb_build_object(
            'check_in', h.check_in_time, 'check_out', h.check_out_time,
            'rooms', (SELECT coalesce(jsonb_agg(jsonb_build_object('room_number', r.room_number, 'room_type', r.room_type,
                        'max_guests', r.max_guests, 'rate', r.base_nightly_rate, 'status', r.operational_status) ORDER BY r.room_number), '[]'::jsonb)
                      FROM public.rooms r WHERE r.hotel_id = l.id),
            'amenities', (SELECT coalesce(jsonb_agg(a.name ORDER BY a.name), '[]'::jsonb)
                          FROM public.hotel_amenities ha JOIN public.amenities a ON a.id = ha.amenity_id WHERE ha.hotel_id = l.id))
          WHEN 'restaurant' THEN jsonb_build_object(
            'operating_hours', rs.operating_hours, 'reservation_fee', rs.reservation_fee,
            'menu', (SELECT coalesce(jsonb_agg(jsonb_build_object('name', m.name, 'category', m.category, 'price', m.price,
                        'available', m.is_available = 1) ORDER BY m.name), '[]'::jsonb)
                     FROM public.menu_items m WHERE m.restaurant_id = l.id),
            'cuisines', (SELECT coalesce(jsonb_agg(c.name ORDER BY c.name), '[]'::jsonb)
                         FROM public.restaurant_cuisines rc JOIN public.cuisines c ON c.id = rc.cuisine_id WHERE rc.restaurant_id = l.id))
          WHEN 'attraction' THEN jsonb_build_object(
            'entrance_fee', at.entrance_fee,
            'schedule', (SELECT coalesce(jsonb_agg(jsonb_build_object('day', s.operating_day, 'hours', s.schedule_text) ORDER BY s.operating_day), '[]'::jsonb)
                         FROM public.attraction_schedules s WHERE s.attraction_id = l.id))
          ELSE '{}'::jsonb END AS j
      FROM public.business_listings l
      JOIN public.business_owners o ON o.id = l.owner_id
      JOIN public.destinations d ON d.id = l.destination_id
      LEFT JOIN public.hotels h ON h.hotel_id = l.id
      LEFT JOIN public.restaurants rs ON rs.restaurant_id = l.id
      LEFT JOIN public.attractions at ON at.attraction_id = l.id
      WHERE l.status = 'pending'
    ) x), '[]'::jsonb);
END $$;


--
-- Name: admin_reviewed_listings(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_reviewed_listings(p_limit integer DEFAULT 20) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_is_admin() THEN RAISE EXCEPTION 'Administrator access required'; END IF;
  RETURN coalesce((
    SELECT jsonb_agg(jsonb_build_object('id', x.id, 'name', x.name, 'type', x.listing_type, 'status', x.status,
             'reviewed_at', x.reviewed_at, 'reviewer', x.reviewer, 'reason', x.rejection_reason) ORDER BY x.reviewed_at DESC)
    FROM (SELECT l.id, l.name, l.listing_type, l.status, l.reviewed_at, l.rejection_reason, p.full_name AS reviewer
            FROM public.business_listings l LEFT JOIN public.profiles p ON p.id = l.reviewed_by
           WHERE l.reviewed_at IS NOT NULL AND l.status IN ('approved', 'rejected')
           ORDER BY l.reviewed_at DESC LIMIT least(greatest(coalesce(p_limit, 20), 1), 100)) x), '[]'::jsonb);
END $$;


--
-- Name: mark_my_notifications_read(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_my_notifications_read() RETURNS void
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO ''
    AS $$
  UPDATE public.notifications SET read_at = now()
   WHERE profile_id = (SELECT public.tm_active_profile_id()) AND read_at IS NULL;
$$;


--
-- Name: my_notifications(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.my_notifications(p_limit integer DEFAULT 20) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', n.id, 'message', n.message, 'read', n.read_at IS NOT NULL, 'created_at', n.created_at)
                            ORDER BY n.created_at DESC), '[]'::jsonb)
    FROM (SELECT * FROM public.notifications WHERE profile_id = (SELECT public.tm_active_profile_id())
          ORDER BY created_at DESC LIMIT least(greatest(coalesce(p_limit, 20), 1), 50)) n;
$$;


--
-- Name: owner_add_menu_item(uuid, text, text, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_add_menu_item(p_restaurant uuid, p_name text, p_category text, p_price numeric, p_description text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_id uuid;
BEGIN
  IF NOT public.tm_owns_listing(p_restaurant) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.restaurants WHERE restaurant_id = p_restaurant) THEN RAISE EXCEPTION 'This listing is not a restaurant'; END IF;
  INSERT INTO public.menu_items(restaurant_id,name,category,price,description)
  VALUES (p_restaurant,btrim(p_name),nullif(btrim(coalesce(p_category,'')),''),p_price,nullif(btrim(coalesce(p_description,'')),'')) RETURNING id INTO v_id;
  RETURN v_id;
END $$;


--
-- Name: owner_add_photo(uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_add_photo(p_listing uuid, p_path text, p_caption text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_id uuid; v_n int; v_uid text := (SELECT public.tm_active_profile_id())::text;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF p_path IS NULL OR p_path NOT LIKE v_uid || '/' || p_listing::text || '/%' OR p_path LIKE '%..%' THEN RAISE EXCEPTION 'Invalid photo path'; END IF;
  SELECT count(*) INTO v_n FROM public.photos WHERE listing_id = p_listing;
  IF v_n >= 6 THEN RAISE EXCEPTION 'A listing can have up to 6 photos'; END IF;
  INSERT INTO public.photos(listing_id, bucket_id, object_path, caption, sort_order, status)
  VALUES (p_listing, 'travelmate-listings', p_path, nullif(btrim(coalesce(p_caption,'')),''), v_n, 'pending') RETURNING id INTO v_id;
  -- new content on a live listing goes back to review (same rule as editing its text)
  UPDATE public.business_listings SET status = 'pending' WHERE id = p_listing AND status = 'approved';
  RETURN v_id;
END $$;


--
-- Name: owner_add_room(uuid, text, text, integer, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_add_room(p_hotel uuid, p_room_number text, p_room_type text, p_max_guests integer, p_rate numeric) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_id uuid;
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.hotels WHERE hotel_id = p_hotel) THEN RAISE EXCEPTION 'This listing is not a hotel'; END IF;
  IF btrim(coalesce(p_room_number, '')) = '' OR btrim(coalesce(p_room_type, '')) = '' THEN RAISE EXCEPTION 'Room number and type are required'; END IF;
  IF coalesce(p_max_guests, 0) < 1 THEN RAISE EXCEPTION 'Max guests must be at least 1'; END IF;
  IF coalesce(p_rate, 0) <= 0 THEN RAISE EXCEPTION 'Nightly rate must be above 0'; END IF;
  IF EXISTS (SELECT 1 FROM public.rooms WHERE hotel_id = p_hotel AND room_number = btrim(p_room_number)) THEN
    RAISE EXCEPTION 'Room % already exists in this hotel', btrim(p_room_number);
  END IF;
  INSERT INTO public.rooms(hotel_id, room_number, room_type, max_guests, base_nightly_rate, operational_status)
  VALUES (p_hotel, btrim(p_room_number), btrim(p_room_type), p_max_guests, p_rate, 'available') RETURNING id INTO v_id;
  RETURN v_id;
END $$;


--
-- Name: owner_add_schedule(uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_add_schedule(p_attraction uuid, p_day text, p_text text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_id uuid;
BEGIN
  IF NOT public.tm_owns_listing(p_attraction) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.attractions WHERE attraction_id = p_attraction) THEN RAISE EXCEPTION 'This listing is not an attraction'; END IF;
  INSERT INTO public.attraction_schedules(attraction_id,operating_day,schedule_text) VALUES (p_attraction,btrim(p_day),btrim(p_text)) RETURNING id INTO v_id;
  RETURN v_id;
END $$;


--
-- Name: owner_create_listing(text, uuid, text, text, text, time without time zone, time without time zone, text, numeric, numeric, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_create_listing(p_type text, p_destination uuid, p_name text, p_description text, p_address text, p_check_in time without time zone DEFAULT NULL::time without time zone, p_check_out time without time zone DEFAULT NULL::time without time zone, p_operating_hours text DEFAULT NULL::text, p_reservation_fee numeric DEFAULT 0, p_entrance_fee numeric DEFAULT NULL::numeric, p_schedule_day text DEFAULT NULL::text, p_schedule_text text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_owner uuid; v_id uuid; v_slug text;
BEGIN
  IF p_type NOT IN ('hotel','restaurant','attraction') THEN RAISE EXCEPTION 'Invalid listing type'; END IF;
  IF btrim(coalesce(p_name,'')) = '' THEN RAISE EXCEPTION 'Name is required'; END IF;
  SELECT o.id INTO v_owner FROM public.business_owners o WHERE o.profile_id = (SELECT public.tm_active_profile_id());
  IF v_owner IS NULL THEN RAISE EXCEPTION 'Only business owners can create listings'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.destinations WHERE id = p_destination AND is_active = 1) THEN RAISE EXCEPTION 'Unknown destination'; END IF;
  v_slug := trim(both '-' from regexp_replace(lower(btrim(p_name)), '[^a-z0-9]+', '-', 'g')) || '-' || substr(replace(gen_random_uuid()::text,'-',''),1,6);
  INSERT INTO public.business_listings(owner_id,destination_id,name,slug,listing_type,description,address,status)
  VALUES (v_owner,p_destination,btrim(p_name),v_slug,p_type,nullif(btrim(coalesce(p_description,'')),''),nullif(btrim(coalesce(p_address,'')),''),'pending')
  RETURNING id INTO v_id;
  IF p_type = 'hotel' THEN
    INSERT INTO public.hotels(hotel_id,check_in_time,check_out_time) VALUES (v_id,p_check_in,p_check_out);
  ELSIF p_type = 'restaurant' THEN
    INSERT INTO public.restaurants(restaurant_id,operating_hours,reservation_fee) VALUES (v_id,p_operating_hours,coalesce(p_reservation_fee,0));
  ELSE
    INSERT INTO public.attractions(attraction_id,entrance_fee) VALUES (v_id,p_entrance_fee);
    IF btrim(coalesce(p_schedule_text,'')) <> '' THEN
      INSERT INTO public.attraction_schedules(attraction_id,operating_day,schedule_text)
      VALUES (v_id,coalesce(nullif(p_schedule_day,''),'Daily'),btrim(p_schedule_text));
    END IF;
  END IF;
  RETURN v_id;
END $$;


--
-- Name: owner_delete_dish_photo(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_delete_dish_photo(p_item uuid) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_listing uuid; v_old text;
BEGIN
  SELECT restaurant_id INTO v_listing FROM public.menu_items WHERE id = p_item;
  IF v_listing IS NULL OR NOT public.tm_owns_listing(v_listing) THEN RAISE EXCEPTION 'Menu item not found'; END IF;
  SELECT object_path INTO v_old FROM public.photos WHERE menu_item_id = p_item;
  DELETE FROM public.photos WHERE menu_item_id = p_item;
  RETURN v_old;
END $$;


--
-- Name: owner_delete_listing(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_delete_listing(p_listing uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_status text; v_paths jsonb;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  SELECT status INTO v_status FROM public.business_listings WHERE id = p_listing;
  IF v_status = 'approved' THEN RAISE EXCEPTION 'This listing is live. Deactivate it first, then delete it.'; END IF;
  SELECT coalesce(jsonb_agg(object_path), '[]'::jsonb) INTO v_paths FROM public.photos WHERE listing_id = p_listing;
  BEGIN
    DELETE FROM public.photos WHERE listing_id = p_listing;
    DELETE FROM public.hotel_amenities WHERE hotel_id = p_listing;
    DELETE FROM public.rooms WHERE hotel_id = p_listing;
    DELETE FROM public.menu_items WHERE restaurant_id = p_listing;
    DELETE FROM public.restaurant_cuisines WHERE restaurant_id = p_listing;
    DELETE FROM public.restaurant_slots WHERE restaurant_id = p_listing;
    DELETE FROM public.attraction_schedules WHERE attraction_id = p_listing;
    DELETE FROM public.hotels WHERE hotel_id = p_listing;
    DELETE FROM public.restaurants WHERE restaurant_id = p_listing;
    DELETE FROM public.attractions WHERE attraction_id = p_listing;
    DELETE FROM public.business_listings WHERE id = p_listing;
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'This listing has bookings, reviews, trip plans or reports attached, so it cannot be deleted. Deactivate it instead.';
  END;
  RETURN v_paths;
END $$;


--
-- Name: owner_delete_menu_item(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_delete_menu_item(p_item uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_r uuid;
BEGIN
  SELECT restaurant_id INTO v_r FROM public.menu_items WHERE id = p_item;
  IF v_r IS NULL OR NOT public.tm_owns_listing(v_r) THEN RAISE EXCEPTION 'Menu item not found'; END IF;
  DELETE FROM public.menu_items WHERE id = p_item;
END $$;


--
-- Name: owner_delete_photo(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_delete_photo(p_photo uuid) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_listing uuid; v_path text;
BEGIN
  SELECT listing_id, object_path INTO v_listing, v_path FROM public.photos WHERE id = p_photo;
  IF v_listing IS NULL OR NOT public.tm_owns_listing(v_listing) THEN RAISE EXCEPTION 'Photo not found'; END IF;
  DELETE FROM public.photos WHERE id = p_photo;
  RETURN v_path;
END $$;


--
-- Name: owner_delete_room(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_delete_room(p_room uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_hotel uuid;
BEGIN
  SELECT hotel_id INTO v_hotel FROM public.rooms WHERE id = p_room;
  IF v_hotel IS NULL OR NOT public.tm_owns_listing(v_hotel) THEN RAISE EXCEPTION 'Room not found'; END IF;
  DELETE FROM public.rooms WHERE id = p_room;
END $$;


--
-- Name: owner_delete_schedule(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_delete_schedule(p_schedule uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_a uuid;
BEGIN
  SELECT attraction_id INTO v_a FROM public.attraction_schedules WHERE id = p_schedule;
  IF v_a IS NULL OR NOT public.tm_owns_listing(v_a) THEN RAISE EXCEPTION 'Schedule not found'; END IF;
  DELETE FROM public.attraction_schedules WHERE id = p_schedule;
END $$;


--
-- Name: owner_get_hotel_amenities(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_get_hotel_amenities(p_hotel uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', a.id, 'name', a.name,
            'selected', EXISTS (SELECT 1 FROM public.hotel_amenities ha WHERE ha.hotel_id = p_hotel AND ha.amenity_id = a.id)) ORDER BY a.name)
          FROM public.amenities a), '[]'::jsonb);
END $$;


--
-- Name: owner_get_restaurant_cuisines(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_get_restaurant_cuisines(p_restaurant uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_restaurant) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', c.id, 'name', c.name,
            'selected', EXISTS (SELECT 1 FROM public.restaurant_cuisines rc WHERE rc.restaurant_id = p_restaurant AND rc.cuisine_id = c.id)) ORDER BY c.name)
          FROM public.cuisines c), '[]'::jsonb);
END $$;


--
-- Name: owner_hotel_checklist(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_hotel_checklist(p_hotel uuid) RETURNS text[]
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN public.tm_hotel_problems(p_hotel);
END $$;


--
-- Name: owner_list_dish_photos(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_list_dish_photos(p_listing uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('menu_item_id', p.menu_item_id, 'object_path', p.object_path, 'status', p.status))
                   FROM public.photos p WHERE p.listing_id = p_listing AND p.menu_item_id IS NOT NULL), '[]'::jsonb);
END $$;


--
-- Name: owner_list_photos(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_list_photos(p_listing uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('id', p.id, 'object_path', p.object_path, 'status', p.status) ORDER BY p.sort_order, p.created_at)
                   FROM public.photos p WHERE p.listing_id = p_listing), '[]'::jsonb);
END $$;


--
-- Name: owner_set_dish_photo(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_set_dish_photo(p_item uuid, p_path text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_listing uuid; v_old text; v_uid text := (SELECT public.tm_active_profile_id())::text;
BEGIN
  SELECT restaurant_id INTO v_listing FROM public.menu_items WHERE id = p_item;
  IF v_listing IS NULL OR NOT public.tm_owns_listing(v_listing) THEN RAISE EXCEPTION 'Menu item not found'; END IF;
  IF p_path IS NULL OR p_path NOT LIKE v_uid || '/' || v_listing::text || '/%' OR p_path LIKE '%..%' THEN RAISE EXCEPTION 'Invalid photo path'; END IF;
  SELECT object_path INTO v_old FROM public.photos WHERE menu_item_id = p_item;
  DELETE FROM public.photos WHERE menu_item_id = p_item;
  INSERT INTO public.photos(listing_id, bucket_id, object_path, sort_order, status, menu_item_id)
  VALUES (v_listing, 'travelmate-listings', p_path, 100, 'pending', p_item);
  UPDATE public.business_listings SET status = 'pending' WHERE id = v_listing AND status = 'approved';
  RETURN v_old;
END $$;


--
-- Name: owner_set_hotel_amenities(uuid, uuid[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_set_hotel_amenities(p_hotel uuid, p_amenities uuid[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_hotel) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.hotels WHERE hotel_id = p_hotel) THEN RAISE EXCEPTION 'This listing is not a hotel'; END IF;
  DELETE FROM public.hotel_amenities WHERE hotel_id = p_hotel;
  INSERT INTO public.hotel_amenities(hotel_id, amenity_id)
  SELECT p_hotel, a.id FROM public.amenities a WHERE a.id = ANY (coalesce(p_amenities, '{}'::uuid[]));
END $$;


--
-- Name: owner_set_listing_status(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_set_listing_status(p_listing uuid, p_status text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_cur text;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF p_status NOT IN ('pending','inactive') THEN RAISE EXCEPTION 'Owners can only deactivate or resubmit a listing'; END IF;
  SELECT status INTO v_cur FROM public.business_listings WHERE id = p_listing;
  IF p_status = 'pending' AND v_cur NOT IN ('inactive','rejected') THEN RAISE EXCEPTION 'Only inactive or rejected listings can be resubmitted'; END IF;
  UPDATE public.business_listings SET status = p_status WHERE id = p_listing;
END $$;


--
-- Name: owner_set_restaurant_cuisines(uuid, uuid[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_set_restaurant_cuisines(p_restaurant uuid, p_cuisines uuid[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_restaurant) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.restaurants WHERE restaurant_id = p_restaurant) THEN RAISE EXCEPTION 'This listing is not a restaurant'; END IF;
  DELETE FROM public.restaurant_cuisines WHERE restaurant_id = p_restaurant;
  INSERT INTO public.restaurant_cuisines(restaurant_id, cuisine_id)
  SELECT p_restaurant, c.id FROM public.cuisines c WHERE c.id = ANY (coalesce(p_cuisines, '{}'::uuid[]));
END $$;


--
-- Name: owner_update_details(uuid, time without time zone, time without time zone, text, numeric, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_update_details(p_listing uuid, p_check_in time without time zone, p_check_out time without time zone, p_hours text, p_resfee numeric, p_fee numeric) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_type text;
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  SELECT listing_type INTO v_type FROM public.business_listings WHERE id = p_listing;
  IF v_type = 'hotel' THEN
    IF p_check_in IS NULL OR p_check_out IS NULL THEN RAISE EXCEPTION 'Check-in and check-out times are required'; END IF;
    IF p_check_out >= p_check_in THEN RAISE EXCEPTION 'Check-out time must be earlier than check-in time (for example check-in 14:00, check-out 11:00)'; END IF;
    UPDATE public.hotels SET check_in_time = p_check_in, check_out_time = p_check_out
     WHERE hotel_id = p_listing AND (check_in_time IS DISTINCT FROM p_check_in OR check_out_time IS DISTINCT FROM p_check_out);
    IF FOUND THEN
      UPDATE public.business_listings SET status = CASE WHEN status = 'inactive' THEN 'inactive' ELSE 'pending' END WHERE id = p_listing;
    END IF;
  ELSIF v_type = 'restaurant' THEN
    UPDATE public.restaurants SET operating_hours = nullif(btrim(coalesce(p_hours, '')), ''), reservation_fee = coalesce(p_resfee, 0) WHERE restaurant_id = p_listing;
  ELSE
    UPDATE public.attractions SET entrance_fee = p_fee WHERE attraction_id = p_listing;
  END IF;
END $$;


--
-- Name: owner_update_listing(uuid, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_update_listing(p_listing uuid, p_name text, p_address text, p_description text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NOT public.tm_owns_listing(p_listing) THEN RAISE EXCEPTION 'This is not your listing'; END IF;
  IF btrim(coalesce(p_name,'')) = '' THEN RAISE EXCEPTION 'Name is required'; END IF;
  UPDATE public.business_listings SET name = btrim(p_name), address = nullif(btrim(coalesce(p_address,'')),''),
         description = nullif(btrim(coalesce(p_description,'')),''),
         status = CASE WHEN status = 'inactive' THEN 'inactive' ELSE 'pending' END
   WHERE id = p_listing;
END $$;


--
-- Name: owner_update_menu_item(uuid, text, text, numeric, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_update_menu_item(p_item uuid, p_name text, p_category text, p_price numeric, p_description text, p_available integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_r uuid;
BEGIN
  SELECT restaurant_id INTO v_r FROM public.menu_items WHERE id = p_item;
  IF v_r IS NULL OR NOT public.tm_owns_listing(v_r) THEN RAISE EXCEPTION 'Menu item not found'; END IF;
  UPDATE public.menu_items SET name = btrim(p_name), category = nullif(btrim(coalesce(p_category,'')),''), price = p_price,
         description = nullif(btrim(coalesce(p_description,'')),''), is_available = CASE WHEN p_available = 1 THEN 1 ELSE 0 END WHERE id = p_item;
END $$;


--
-- Name: owner_update_room(uuid, text, text, integer, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_update_room(p_room uuid, p_room_number text, p_room_type text, p_max_guests integer, p_rate numeric, p_status text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_hotel uuid;
BEGIN
  SELECT hotel_id INTO v_hotel FROM public.rooms WHERE id = p_room;
  IF v_hotel IS NULL OR NOT public.tm_owns_listing(v_hotel) THEN RAISE EXCEPTION 'Room not found'; END IF;
  IF p_status NOT IN ('available', 'maintenance', 'unavailable') THEN RAISE EXCEPTION 'Invalid room status'; END IF;
  IF btrim(coalesce(p_room_number, '')) = '' OR btrim(coalesce(p_room_type, '')) = '' THEN RAISE EXCEPTION 'Room number and type are required'; END IF;
  IF coalesce(p_max_guests, 0) < 1 THEN RAISE EXCEPTION 'Max guests must be at least 1'; END IF;
  IF coalesce(p_rate, 0) <= 0 THEN RAISE EXCEPTION 'Nightly rate must be above 0'; END IF;
  IF EXISTS (SELECT 1 FROM public.rooms WHERE hotel_id = v_hotel AND room_number = btrim(p_room_number) AND id <> p_room) THEN
    RAISE EXCEPTION 'Room % already exists in this hotel', btrim(p_room_number);
  END IF;
  UPDATE public.rooms SET room_number = btrim(p_room_number), room_type = btrim(p_room_type), max_guests = p_max_guests,
         base_nightly_rate = p_rate, operational_status = p_status WHERE id = p_room;
END $$;


--
-- Name: owner_update_schedule(uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owner_update_schedule(p_schedule uuid, p_day text, p_text text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE v_a uuid;
BEGIN
  SELECT attraction_id INTO v_a FROM public.attraction_schedules WHERE id = p_schedule;
  IF v_a IS NULL OR NOT public.tm_owns_listing(v_a) THEN RAISE EXCEPTION 'Schedule not found'; END IF;
  UPDATE public.attraction_schedules SET operating_day = btrim(p_day), schedule_text = btrim(p_text) WHERE id = p_schedule;
END $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: business_listings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business_listings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id uuid NOT NULL,
    destination_id uuid NOT NULL,
    name character varying(150) NOT NULL,
    slug character varying(180) NOT NULL,
    listing_type character varying(24) NOT NULL,
    description text,
    address character varying(255) DEFAULT NULL::character varying,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reviewed_by uuid,
    reviewed_at timestamp with time zone,
    rejection_reason text,
    CONSTRAINT ck_business_listings_1 CHECK (((listing_type)::text = ANY (ARRAY[('hotel'::character varying)::text, ('restaurant'::character varying)::text, ('attraction'::character varying)::text]))),
    CONSTRAINT ck_business_listings_2 CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('rejected'::character varying)::text, ('inactive'::character varying)::text])))
);


--
-- Name: destinations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.destinations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_id uuid NOT NULL,
    name character varying(150) NOT NULL,
    province character varying(100) NOT NULL,
    slug character varying(180) NOT NULL,
    description text,
    latitude numeric(10,7) DEFAULT NULL::numeric,
    longitude numeric(10,7) DEFAULT NULL::numeric,
    is_active smallint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_destinations_1 CHECK ((is_active = ANY (ARRAY[0, 1]))),
    CONSTRAINT ck_destinations_2 CHECK ((((latitude IS NULL) AND (longitude IS NULL)) OR ((latitude IS NOT NULL) AND (longitude IS NOT NULL)))),
    CONSTRAINT ck_destinations_3 CHECK (((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric))),
    CONSTRAINT ck_destinations_4 CHECK (((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric)))
);


--
-- Name: v_public_listings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_public_listings WITH (security_invoker='true') AS
 SELECT b.id AS listing_id,
    b.name AS listing_name,
    b.listing_type,
    d.name AS destination_name,
    d.province,
    b.address,
    b.status
   FROM (public.business_listings b
     JOIN public.destinations d ON ((d.id = b.destination_id)))
  WHERE (((b.status)::text = 'approved'::text) AND (d.is_active = 1));


--
-- Name: public_listings_by_province(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.public_listings_by_province(p_province text) RETURNS SETOF public.v_public_listings
    LANGUAGE sql STABLE
    SET search_path TO ''
    AS $$ SELECT * FROM public.v_public_listings WHERE lower(province)=lower(p_province); $$;


--
-- Name: set_my_account_type(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_my_account_type(p_account_type text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
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


--
-- Name: sp_public_listings_by_province(text, refcursor); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_public_listings_by_province(IN p_province text, INOUT p_results refcursor DEFAULT 'travelmate_listings'::refcursor)
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$ BEGIN OPEN p_results FOR SELECT * FROM public.public_listings_by_province(p_province); END $$;


--
-- Name: tm_active_profile_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_active_profile_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
 SELECT id FROM public.profiles WHERE id=(SELECT auth.uid()) AND account_status='active'; $$;


--
-- Name: tm_approve_listing_photos(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_approve_listing_photos() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status IS DISTINCT FROM 'approved' THEN
    UPDATE public.photos SET status = 'approved' WHERE listing_id = NEW.id AND status = 'pending';
  END IF;
  RETURN NEW;
END $$;


--
-- Name: tm_has_role(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_has_role(p_role text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
 SELECT EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id JOIN public.profiles p ON p.id=pr.profile_id WHERE p.id=(SELECT auth.uid()) AND p.account_status='active' AND r.name=p_role); $$;


--
-- Name: tm_hotel_problems(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_hotel_problems(p_hotel uuid) RETURNS text[]
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE h record; v text[] := '{}';
BEGIN
  SELECT check_in_time, check_out_time INTO h FROM public.hotels WHERE hotel_id = p_hotel;
  IF NOT FOUND THEN RETURN ARRAY['This listing has no hotel details']; END IF;
  IF h.check_in_time IS NULL OR h.check_out_time IS NULL THEN v := array_append(v, 'Set the check-in and check-out times');
  ELSIF h.check_out_time >= h.check_in_time THEN v := array_append(v, 'Check-out time must be earlier than check-in time'); END IF;
  IF NOT EXISTS (SELECT 1 FROM public.rooms WHERE hotel_id = p_hotel AND operational_status = 'available') THEN
    v := array_append(v, 'Add at least one available room');
  END IF;
  RETURN v;
END $$;


--
-- Name: tm_is_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_is_admin() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  SELECT EXISTS (SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id = pr.role_id
                 WHERE pr.profile_id = (SELECT public.tm_active_profile_id()) AND r.name = 'admin');
$$;


--
-- Name: tm_listing_problems(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_listing_problems(p_listing uuid) RETURNS text[]
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE t text; v text[] := '{}'; r record; a record;
BEGIN
  SELECT listing_type INTO t FROM public.business_listings WHERE id = p_listing;
  IF t IS NULL THEN RETURN ARRAY['Listing not found']; END IF;
  IF t = 'hotel' THEN
    RETURN public.tm_hotel_problems(p_listing);
  ELSIF t = 'restaurant' THEN
    SELECT operating_hours INTO r FROM public.restaurants WHERE restaurant_id = p_listing;
    IF NOT FOUND THEN RETURN ARRAY['This listing has no restaurant details']; END IF;
    IF btrim(coalesce(r.operating_hours, '')) = '' THEN v := array_append(v, 'Add the operating hours'); END IF;
    IF NOT EXISTS (SELECT 1 FROM public.menu_items WHERE restaurant_id = p_listing AND is_available = 1) THEN
      v := array_append(v, 'Add at least one available menu item');
    END IF;
  ELSIF t = 'attraction' THEN
    SELECT entrance_fee INTO a FROM public.attractions WHERE attraction_id = p_listing;
    IF NOT FOUND THEN RETURN ARRAY['This listing has no attraction details']; END IF;
    IF a.entrance_fee IS NULL THEN v := array_append(v, 'Set the entrance fee (0 means free entry)'); END IF;
    IF NOT EXISTS (SELECT 1 FROM public.attraction_schedules WHERE attraction_id = p_listing) THEN
      v := array_append(v, 'Add at least one operating day');
    END IF;
  END IF;
  RETURN v;
END $$;


--
-- Name: tm_notify_admins_listing_pending(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_notify_admins_listing_pending() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
  INSERT INTO public.notifications(id, profile_id, message, created_at)
  SELECT gen_random_uuid(), pr.profile_id, format('%s listing "%s" is awaiting review.', initcap(NEW.listing_type), NEW.name), now()
    FROM public.profile_roles pr JOIN public.roles r ON r.id = pr.role_id WHERE r.name = 'admin';
  RETURN NEW;
END $$;


--
-- Name: tm_notify_listing_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_notify_listing_status() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$ BEGIN IF NEW.status IS DISTINCT FROM OLD.status THEN INSERT INTO public.notifications(profile_id,message) SELECT profile_id,'Listing "'||NEW.name||'" status changed to '||NEW.status FROM public.business_owners WHERE id=NEW.owner_id; END IF; RETURN NEW; END $$;


--
-- Name: tm_on_auth_profile_event(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_on_auth_profile_event() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$ BEGIN PERFORM public.tm_provision_profile(NEW.id); RETURN NEW; END $$;


--
-- Name: tm_owns_listing(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_owns_listing(p_listing uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  SELECT EXISTS (SELECT 1 FROM public.business_listings l JOIN public.business_owners o ON o.id = l.owner_id
                 WHERE l.id = p_listing AND o.profile_id = (SELECT public.tm_active_profile_id()));
$$;


--
-- Name: tm_owns_listing_path(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_owns_listing_path(p_path text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
 SELECT split_part(p_path,'/',1)=(SELECT auth.uid())::text AND length(split_part(p_path,'/',3))>0 AND EXISTS(SELECT 1 FROM public.business_listings b JOIN public.business_owners o ON o.id=b.owner_id JOIN public.profiles p ON p.id=o.profile_id WHERE b.id::text=split_part(p_path,'/',2) AND p.id=(SELECT auth.uid()) AND p.account_status='active'); $$;


--
-- Name: tm_provision_profile(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_provision_profile(p_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE a auth.users%ROWTYPE;
BEGIN
 SELECT * INTO a FROM auth.users WHERE id=p_id;
 IF NOT FOUND OR a.email_confirmed_at IS NULL OR a.email IS NULL THEN RETURN; END IF;
 INSERT INTO public.profiles(id,full_name) VALUES(a.id,left(coalesce(nullif(btrim(a.raw_user_meta_data->>'full_name'),''),nullif(btrim(a.raw_user_meta_data->>'name'),''),'Traveler'),150)) ON CONFLICT(id) DO NOTHING;
 INSERT INTO public.profile_roles(profile_id,role_id) SELECT a.id,id FROM public.roles WHERE name='traveler' ON CONFLICT DO NOTHING;
END $$;


--
-- Name: tm_touch_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tm_touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$ BEGIN NEW.updated_at=now(); RETURN NEW; END $$;


--
-- Name: update_my_profile(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_my_profile(p_full_name text, p_address text, p_avatar_object_path text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
BEGIN
 IF p_full_name IS NULL OR length(btrim(p_full_name)) NOT BETWEEN 1 AND 150 THEN RAISE EXCEPTION 'Name must contain 1 to 150 characters'; END IF;
 UPDATE public.profiles SET full_name=btrim(p_full_name),address=p_address,avatar_object_path=p_avatar_object_path WHERE id=(SELECT auth.uid()) AND account_status='active';
 IF NOT FOUND THEN RAISE EXCEPTION 'Active profile required'; END IF;
END $$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
    -- Regclass of the table e.g. public.notes
    entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

    -- I, U, D, T: insert, update ...
    action realtime.action = (
        case wal ->> 'action'
            when 'I' then 'INSERT'
            when 'U' then 'UPDATE'
            when 'D' then 'DELETE'
            else 'ERROR'
        end
    );

    -- Is row level security enabled for the table
    is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

    subscriptions realtime.subscription[] = array_agg(subs)
        from
            realtime.subscription subs
        where
            subs.entity = entity_
            -- Filter by action early - only get subscriptions interested in this action
            -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
            and (subs.action_filter = '*' or subs.action_filter = action::text);

    -- Subscription vars
    working_role regrole;
    working_selected_columns text[];
    claimed_role regrole;
    claims jsonb;

    subscription_id uuid;
    subscription_has_access bool;
    visible_to_subscription_ids uuid[] = '{}';

    -- structured info for wal's columns
    columns realtime.wal_column[];
    -- previous identity values for update/delete
    old_columns realtime.wal_column[];

    error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

    -- Primary jsonb output for record
    output jsonb;

    -- Loop record for iterating unique roles (outer loop)
    role_record record;
    -- Loop record for iterating unique selected_columns within a role (inner loop)
    cols_record record;
    -- Subscription ids visible at the role level (before fanning out by selected_columns)
    visible_role_sub_ids uuid[] = '{}';

begin
    perform set_config('role', null, true);

    columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'columns') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    old_columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'identity') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    for role_record in
        select claims_role
        from (select distinct claims_role from unnest(subscriptions)) t
        order by claims_role::text
    loop
        working_role := role_record.claims_role;

        -- Update `is_selectable` for columns and old_columns (once per role)
        columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(columns) c;

        old_columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(old_columns) c;

        if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
            -- Fan out 400 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;
            end loop;

        -- The claims role does not have SELECT permission to the primary key of entity
        elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
            -- Fan out 401 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;
            end loop;

        else
            -- Create the prepared statement (once per role)
            if is_rls_enabled and action <> 'DELETE' then
                if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                    deallocate walrus_rls_stmt;
                end if;
                execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
            end if;

            -- Collect all visible subscription IDs for this role (filter check + RLS check)
            visible_role_sub_ids = '{}';

            for subscription_id, claims in (
                    select
                        subs.subscription_id,
                        subs.claims
                    from
                        unnest(subscriptions) subs
                    where
                        subs.entity = entity_
                        and subs.claims_role = working_role
                        and (
                            realtime.is_visible_through_filters(columns, subs.filters)
                            or (
                              action = 'DELETE'
                              and realtime.is_visible_through_filters(old_columns, subs.filters)
                            )
                        )
            ) loop

                if not is_rls_enabled or action = 'DELETE' then
                    visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                else
                    -- Check if RLS allows the role to see the record
                    perform
                        -- Trim leading and trailing quotes from working_role because set_config
                        -- doesn't recognize the role as valid if they are included
                        set_config('role', trim(both '"' from working_role::text), true),
                        set_config('request.jwt.claims', claims::text, true);

                    execute 'execute walrus_rls_stmt' into subscription_has_access;

                    -- Reset the role on every FOR..LOOP batch execution.
                    -- The first batch of 10 rows is pre-fetched using the current connection role (PG internal behaviour)
                    -- then we have to reset it again otherwise it would use the role defined in the `set_config` above
                    -- to fetch the remaining rows when rows>10, which could be a user-defined role that lacks execution grants.
                    -- The flow is:
                    --   1. run batch with conn role
                    --   2. set_config working_role
                    --   3. execute walrus
                    --   4. reset role (revert)
                    --   5. repeat
                    perform set_config('role', null, true);

                    if subscription_has_access then
                        visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                    end if;
                end if;
            end loop;

            perform set_config('role', null, true);

            -- Inner loop: per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;

                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                            left join (
                                select unnest(conkey) as pkey_attnum
                                from pg_constraint
                                where conrelid = entity_ and contype = 'p'
                            ) pk on pk.pkey_attnum = pa.attnum
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                            and (working_selected_columns is null or pa.attname = any(working_selected_columns) or pk.pkey_attnum is not null)
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and (working_selected_columns is null or coalesce((c).name, (oc).name) = any(working_selected_columns) or coalesce((c).is_pkey, (oc).is_pkey))
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Filter visible_role_sub_ids to those matching the current selected_columns group
                visible_to_subscription_ids = coalesce(
                    (
                        select array_agg(s.subscription_id)
                        from unnest(subscriptions) s
                        where s.claims_role = working_role
                          and (s.selected_columns is not distinct from working_selected_columns)
                          and s.subscription_id = any(visible_role_sub_ids)
                    ),
                    '{}'::uuid[]
                );

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;
            end loop;

        end if;
    end loop;

    perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*
Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
*/
declare
    op_symbol text = (
        case
            when op = 'eq' then '='
            when op = 'neq' then '!='
            when op = 'lt' then '<'
            when op = 'lte' then '<='
            when op = 'gt' then '>'
            when op = 'gte' then '>='
            when op = 'in' then '= any'
            else 'UNKNOWN OP'
        end
    );
    res boolean;
begin
    execute format(
        'select %L::'|| type_::text || ' ' || op_symbol
        || ' ( %L::'
        || (
            case
                when op = 'in' then type_::text || '[]'
                else type_::text end
        )
        || ')', val_1, val_2) into res;
    return res;
end;
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
declare
    op_symbol text;
    res boolean;
begin
    -- IS DISTINCT FROM / IS NOT DISTINCT FROM: infix, both sides typed literals
    if op = 'isdistinct' then
        execute format(
            'select %L::%s %s %L::%s',
            val_1,
            type_::text,
            case when negate then 'IS NOT DISTINCT FROM' else 'IS DISTINCT FROM' end,
            val_2,
            type_::text
        ) into res;
        return res;
    end if;

    -- IS requires a keyword RHS (NULL, TRUE, FALSE, UNKNOWN), not a typed literal
    if op = 'is' then
        if val_2 not in ('null', 'true', 'false', 'unknown') then
            raise exception 'invalid value for is filter: must be null, true, false, or unknown';
        end if;
        execute format(
            'select %L::%s %s %s',
            val_1,
            type_::text,
            case when negate then 'IS NOT' else 'IS' end,
            upper(val_2)
        ) into res;
        return res;
    end if;

    op_symbol = case
        when op = 'eq'    then '='
        when op = 'neq'   then '!='
        when op = 'lt'    then '<'
        when op = 'lte'   then '<='
        when op = 'gt'    then '>'
        when op = 'gte'   then '>='
        when op = 'in'    then '= any'
        when op = 'like'   then 'LIKE'
        when op = 'ilike'  then 'ILIKE'
        when op = 'match'  then '~'
        when op = 'imatch' then '~*'
        else null
    end;

    if op_symbol is null then
        raise exception 'unsupported equality operator: %', op::text;
    end if;

    execute format(
        'select %L::%s %s (%L::%s)',
        val_1,
        type_::text,
        op_symbol,
        val_2,
        case when op = 'in' then type_::text || '[]' else type_::text end
    ) into res;

    return case when negate then not res else res end;
end;
$$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    select
        filters is null
        or array_length(filters, 1) is null
        or coalesce(
            count(col.name) = count(1)
            and sum(
                realtime.check_equality_op(
                    op:=f.op,
                    type_:=coalesce(col.type_oid::regtype, col.type_name::regtype),
                    val_1:=col.value #>> '{}',
                    val_2:=f.value,
                    negate:=coalesce(f.negate, false)
                )::int
            ) filter (where col.name is not null) = count(col.name),
            false
        )
    from
        unnest(filters) f
        left join unnest(columns) col
            on f.column_name = col.name;
$$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: list_changes_sync(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes_sync(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures the slot is read exactly once.
  consumed AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         realtime.settled_changes(
           slot_name, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM consumed
    WHERE consumed.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM consumed,
         realtime.apply_rls(
           wal := consumed.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE consumed.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT
    realtime.wal2json_escape_identifier(nsp.nspname::text)
    || '.'
    || realtime.wal2json_escape_identifier(pc.relname::text)
  FROM pg_class pc
  JOIN pg_namespace nsp ON pc.relnamespace = nsp.oid
  WHERE pc.oid = entity
$$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: send_binary(bytea, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, binary_payload, event, topic, private, extension)
    VALUES (generated_id, payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: settled_changes(name, integer, text[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.settled_changes(slot_name name, max_changes integer, VARIADIC opts text[]) RETURNS TABLE(lsn pg_lsn, xid xid, data text)
    LANGUAGE plpgsql
    AS $$
declare
  upto pg_lsn;
  total bigint;
  xids xid[];
  starts bigint[];
  snapshot pg_snapshot;
  running_xids xid[];
  xmax_age int;
  cut bigint;
begin
  -- Each statement in a volatile function takes its own snapshot, which is what lets the
  -- check below see a writer that was still in flight when the peek ran. Under REPEATABLE
  -- READ the snapshot never advances, so a deferred change would never be released.
  if current_setting('transaction_isolation') <> 'read committed' then
    raise exception 'realtime.settled_changes requires READ COMMITTED';
  end if;

  -- The peek and the read below cover the same WAL, so the read cannot reach a commit the
  -- check never saw.
  upto := pg_current_wal_flush_lsn();

  -- One entry per transaction, in commit order: its xid and the position of its first
  -- change. The peek uses the caller's own options, so max_changes counts exactly what the
  -- read counts. A non-transactional logical message is emitted as soon as it is decoded,
  -- tagged with the xid of whatever transaction wrote it, so it does not mark where that
  -- transaction starts.
  select coalesce(sum(g.n), 0),
         array_agg(g.x order by g.first) filter (where g.first is not null),
         array_agg(g.first order by g.first) filter (where g.first is not null)
    into total, xids, starts
    from (
      select p.xid as x, count(*) as n,
             min(p.ord) filter (where not case
               when starts_with(p.data, '{"action":"M"') then (p.data::jsonb->>'transactional')::boolean is false
               else false
             end) as first
      from pg_logical_slot_peek_changes(slot_name, upto, max_changes, variadic opts)
           with ordinality as p(lsn, xid, data, ord)
      group by p.xid
    ) g;

  -- Nothing for the caller, but the slot still has to move past what the peek covered.
  if total = 0 then
    perform pg_replication_slot_advance(slot_name, upto);
    return;
  end if;

  if xids is not null then
    -- Taken after the peek is materialized, so a writer that was still in flight during
    -- decoding is guaranteed to show up here.
    snapshot := pg_current_snapshot();

    -- A commit record reaches the WAL before the writer leaves the proc array, so a change
    -- can be decoded while its row is invisible. apply_rls would resolve a policy against a
    -- row it cannot see and authorize it for nobody, while the read consumed it regardless.
    --
    -- xip lists transactions running when the snapshot was taken. It does not cover a writer
    -- whose xid sits at or beyond xmax, which never appears there, so the horizon is checked
    -- too. age() counts backwards from the current xid and so compares correctly across
    -- wraparound.
    select coalesce(array_agg(running.x::xid), array[]::xid[])
      into running_xids
      from pg_snapshot_xip(snapshot) running(x);
    xmax_age := age(pg_snapshot_xmax(snapshot)::xid);

    select min(u.s) into cut
      from unnest(xids, starts) as u(x, s)
      where u.x = any(running_xids) or age(u.x) <= xmax_age;
  end if;

  -- The read stops right after the commit that brings its count to upto_nchanges, so the
  -- count of changes in front of the first unsettled transaction stops it just before that
  -- transaction.
  if cut is null then
    return query
      select p.* from pg_logical_slot_get_changes(slot_name, upto, max_changes, variadic opts) p;
  elsif cut > 1 then
    return query
      select p.* from pg_logical_slot_get_changes(slot_name, upto, (cut - 1)::int, variadic opts) p;
  end if;
end;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    col_names text[] = coalesce(
            array_agg(a.attname order by a.attnum),
            '{}'::text[]
        )
        from
            pg_catalog.pg_attribute a
        where
            a.attrelid = new.entity
            and a.attnum > 0
            and not a.attisdropped
            and pg_catalog.has_column_privilege(
                (new.claims ->> 'role'),
                a.attrelid,
                a.attnum,
                'SELECT'
            );
    filter realtime.user_defined_filter;
    col_type regtype;
    in_val jsonb;
    selected_col text;
begin
    for filter in select * from unnest(new.filters) loop
        if not filter.column_name = any(col_names) then
            raise exception 'invalid column for filter %', filter.column_name;
        end if;

        col_type = (
            select atttypid::regtype
            from pg_catalog.pg_attribute
            where attrelid = new.entity
                  and attname = filter.column_name
        );
        if col_type is null then
            raise exception 'failed to lookup type for column %', filter.column_name;
        end if;

        if filter.op = 'in'::realtime.equality_op then
            in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
            if coalesce(jsonb_array_length(in_val), 0) > 100 then
                raise exception 'too many values for `in` filter. Maximum 100';
            end if;
        elsif filter.op = 'is'::realtime.equality_op then
            -- `is` requires a keyword RHS rather than a typed literal
            if filter.value not in ('null', 'true', 'false', 'unknown') then
                raise exception 'invalid value for is filter: must be null, true, false, or unknown';
            end if;
            -- IS NULL works for any type, but IS TRUE/FALSE/UNKNOWN require a boolean
            -- operand. Reject the non-null keywords on non-boolean columns here so they
            -- don't abort apply_rls at WAL time.
            if filter.value <> 'null' and col_type <> 'boolean'::regtype then
                raise exception 'is % filter requires a boolean column, got %', filter.value, col_type::text;
            end if;
        elsif filter.op in ('like'::realtime.equality_op, 'ilike'::realtime.equality_op) then
            -- like/ilike apply the text pattern operator (~~); reject column types that
            -- have no such operator instead of failing at WAL time
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = '~~' and oprleft = col_type
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
        elsif filter.op in ('match'::realtime.equality_op, 'imatch'::realtime.equality_op) then
            -- match/imatch apply the regex operators ~ / ~*; reject column types that have
            -- no such operator (e.g. integer) instead of failing at WAL time, mirroring the
            -- like/ilike guard above.
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = case when filter.op = 'imatch'::realtime.equality_op then '~*' else '~' end
                  and oprleft = col_type
                  and oprright = col_type
                  and oprresult = 'boolean'::regtype
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
            -- validate the regex eagerly so a bad pattern is rejected here, not inside
            -- apply_rls where it would abort the WAL stream for the entity
            begin
                perform '' ~ filter.value;
            exception when others then
                raise exception 'invalid regular expression for % filter: %', filter.op::text, sqlerrm;
            end;
        else
            -- eq/neq/lt/lte/gt/gte: value must be coercable to the type
            perform realtime.cast(filter.value, col_type);
        end if;
    end loop;

    if new.selected_columns is not null then
        for selected_col in select * from unnest(new.selected_columns) loop
            if not selected_col = any(col_names) then
                raise exception 'invalid column for select %', selected_col;
            end if;
        end loop;
    end if;

    -- Apply consistent order to filters so the unique constraint can't be tricked by a
    -- different filter order. negate is part of the sort key.
    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value, f.negate),
        '{}'
    ) from unnest(new.filters) f;

    -- Normalize selected_columns order so ARRAY['a','b'] and ARRAY['b','a'] are treated
    -- as the same subscription group in apply_rls. Preserve an empty array as '{}'
    -- ("primary keys only") so it stays distinct from NULL ("all columns"); array_agg
    -- over an empty set would otherwise collapse '{}' back to NULL.
    if new.selected_columns is not null then
        new.selected_columns = coalesce(
            (
                select array_agg(c order by c)
                from unnest(new.selected_columns) c
            ),
            '{}'::text[]
        );
    end if;

    return new;
end;
$$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: wal2json_escape_identifier(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.wal2json_escape_identifier(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- Prefix `\`, `,`, `.`, and any whitespace with `\`
  SELECT regexp_replace(name, '([\\,.[:space:]])', '\\\1', 'g')
$$;


--
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


--
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: enforce_bucket_lifecycle_service_role(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_lifecycle_service_role() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
  IF current_user::text IS DISTINCT FROM TG_ARGV[0]
     AND (
       OLD.lifecycle_configuration IS DISTINCT FROM NEW.lifecycle_configuration
       OR OLD.lifecycle_configuration_generation IS DISTINCT FROM NEW.lifecycle_configuration_generation
     ) THEN
    -- AFTER runs only after caller RLS has accepted the proposed row. The API
    -- recognizes this specific error after rolling back its permission probe;
    -- direct non-service writes still fail and cannot persist the change.
    RAISE EXCEPTION 'bucket control columns may only be changed by the configured storage service role'
      USING ERRCODE = 'PST01',
            SCHEMA = TG_TABLE_SCHEMA,
            TABLE = TG_TABLE_NAME,
            CONSTRAINT = TG_NAME;
  END IF;

  RETURN NULL;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    RETURN _parts[array_length(_parts, 1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN p_delimiter <> ''
         AND position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(
        p_key,
        length(p_prefix)
            + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1))
            + length(p_delimiter) - 1
    )
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket(noncurrent_versions text DEFAULT 'include'::text, delete_markers text DEFAULT 'include'::text) RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'include');
    delete_markers := COALESCE(delete_markers, 'include');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'include';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'include';
    END IF;

    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        where (noncurrent_versions != 'exclude' OR obj.archived_at IS NULL)
          and (noncurrent_versions != 'only' OR obj.archived_at IS NOT NULL)
          and (delete_markers != 'exclude' OR NOT obj.is_delete_marker)
          and (delete_markers != 'only' OR obj.is_delete_marker)
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text, raw_prefix_param text DEFAULT NULL::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE sql STABLE
    AS $_$
WITH candidates AS (
    SELECT
        upload.key AS object_key,
        CASE
            WHEN position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1)) > 0
            THEN left(
                upload.key,
                length(coalesce($7, $2))
                    + position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1))
                    + length($3) - 1
            )
            ELSE upload.key
        END AS result_key,
        upload.id,
        upload.created_at,
        position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1)) > 0 AS is_common_prefix
    FROM storage.s3_multipart_uploads AS upload
    WHERE upload.bucket_id = $1
      AND upload.key COLLATE "C" LIKE $2 || '%'
), filtered AS (
    SELECT candidate.*
    FROM candidates AS candidate
    WHERE $5 = ''
       OR candidate.result_key COLLATE "C" > $5
       OR (
           candidate.result_key COLLATE "C" = $5
           AND NOT candidate.is_common_prefix
           AND $6 <> ''
           -- A completed or aborted marker repeats the remaining same-key uploads.
           AND COALESCE(
               (candidate.created_at, candidate.id COLLATE "C") > (
                   SELECT marker.created_at, marker.id COLLATE "C"
                   FROM storage.s3_multipart_uploads AS marker
                   WHERE marker.bucket_id = $1
                     AND marker.key COLLATE "C" = $5
                     AND marker.id = $6
               ),
               TRUE
           )
       )
), ranked AS (
    SELECT
        filtered.*,
        row_number() OVER (
            PARTITION BY filtered.result_key COLLATE "C"
            ORDER BY filtered.created_at, filtered.id COLLATE "C"
        ) AS prefix_rank
    FROM filtered
)
SELECT ranked.result_key, ranked.id, ranked.created_at
FROM ranked
WHERE NOT ranked.is_common_prefix OR ranked.prefix_rank = 1
ORDER BY ranked.result_key COLLATE "C", ranked.created_at, ranked.id COLLATE "C"
LIMIT $4;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text, text, text, timestamp with time zone, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, next_token_archived_at timestamp with time zone DEFAULT NULL::timestamp with time zone, next_token_version text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_start_relative TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;
    v_version_filter TEXT;

    -- true when noncurrent_versions can return >1 row per name; keeps them
    -- ordered most-recent-first and lets pagination resume mid-key
    v_multi_row BOOLEAN;
    v_name_order TEXT;
    v_exact_range_predicate TEXT;
    v_strict_range_predicate TEXT;
    v_inclusive_range_predicate TEXT;

    -- Seek state for the current name. archived_at is normalized to JavaScript's
    -- millisecond precision and version breaks ties within the same millisecond.
    -- Current rows use 'infinity'; NULL means no tiebreak has been established.
    v_next_seek TEXT;
    v_next_seek_at TIMESTAMPTZ;
    v_next_seek_version TEXT;
    v_next_seek_strict BOOLEAN := false;
    v_cursor_is_folder BOOLEAN;
    v_count INT := 0;
    v_previous_seek TEXT;
    v_previous_seek_at TIMESTAMPTZ;
    v_previous_seek_version TEXT;
    v_previous_count INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;
    v_batch_query_strict TEXT;
    v_delete_marker_peek_query TEXT;
    v_delete_marker_peek_query_strict TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);
    v_next_seek_at := NULL;
    v_next_seek_version := '';

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    v_multi_row := noncurrent_versions IN ('only', 'include');
    v_name_order := CASE WHEN v_is_asc THEN 'ASC' ELSE 'DESC' END;

    v_version_filter := '';
    IF noncurrent_versions = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NULL';
    ELSIF noncurrent_versions = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NOT NULL';
    END IF;
    IF delete_markers = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND NOT o.is_delete_marker';
    ELSIF delete_markers = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.is_delete_marker';
    END IF;

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Keep caller-provided cursors inside the requested prefix range.
    IF v_start <> '' AND v_upper_bound IS NOT NULL THEN
        IF v_is_asc THEN
            IF v_start COLLATE "C" < v_prefix COLLATE "C" THEN
                v_start := '';
            ELSIF v_start COLLATE "C" >= v_upper_bound COLLATE "C" THEN
                RETURN;
            END IF;
        ELSE
            IF v_start COLLATE "C" < v_prefix COLLATE "C" THEN
                RETURN;
            ELSIF v_start COLLATE "C" >= v_upper_bound COLLATE "C" THEN
                v_start := '';
            END IF;
        END IF;
    END IF;

    v_start_relative := substring(v_start FROM length(v_prefix) + 1);

    -- Direction affects only the indexed name range and its ordering. Cursor
    -- state transitions and within-key version ordering stay shared.
    IF v_is_asc THEN
        v_exact_range_predicate := 'TRUE';
        v_strict_range_predicate := 'o.name COLLATE "C" > $2';
        v_inclusive_range_predicate := 'o.name COLLATE "C" >= $2';
        IF v_upper_bound IS NOT NULL THEN
            v_exact_range_predicate := 'o.name COLLATE "C" < $3';
            v_strict_range_predicate := v_strict_range_predicate || ' AND o.name COLLATE "C" < $3';
            v_inclusive_range_predicate := v_inclusive_range_predicate || ' AND o.name COLLATE "C" < $3';
        END IF;
    ELSE
        v_exact_range_predicate := 'TRUE';
        v_strict_range_predicate := 'o.name COLLATE "C" < $2';
        v_inclusive_range_predicate := 'o.name COLLATE "C" < $2';
        IF v_prefix <> '' THEN
            v_exact_range_predicate := 'o.name COLLATE "C" >= $3';
            v_strict_range_predicate := v_strict_range_predicate || ' AND o.name COLLATE "C" >= $3';
            v_inclusive_range_predicate := v_inclusive_range_predicate || ' AND o.name COLLATE "C" >= $3';
        END IF;
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    -- The multi-row order matches the externally serialized cursor exactly:
    -- archived_at at millisecond precision, then version as the final tiebreak.
    --
    -- When v_multi_row, the seek is a keyset tuple comparison ("name > $2 OR
    -- (name = $2 AND tiebreak)") - Postgres won't split that OR into indexable
    -- form (confirmed even with fully literal values), so as one WHERE clause
    -- it forces a full bucket scan filtered row-by-row. Splitting it into two
    -- independently-indexable branches (exact name match with the tiebreak
    -- filter, vs. strictly-past names) combined with UNION ALL lets each
    -- branch keep name as a real index condition; the outer ORDER BY/LIMIT
    -- re-merges them into the same page the single query used to produce.
    IF v_multi_row THEN
        v_batch_query := format(
            $sql$
            SELECT *
            FROM (
                (
                    SELECT o.name, o.id, o.updated_at, o.created_at,
                           o.last_accessed_at, o.metadata, o.version,
                           o.archived_at, o.is_delete_marker, o.is_versioned
                    FROM storage.objects o
                    WHERE o.bucket_id = $1
                      AND o.name COLLATE "C" = $2
                      AND %s
                      AND NOT $7::boolean
                      AND (
                          $5::timestamptz IS NULL
                          OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < $5
                          OR (
                              COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = $5
                              AND COALESCE(o.version, '') > $6
                          )
                      )
                      %s
                    ORDER BY
                        COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC,
                        COALESCE(o.version, '') ASC
                    LIMIT $4
                )
                UNION ALL
                (
                    SELECT o.name, o.id, o.updated_at, o.created_at,
                           o.last_accessed_at, o.metadata, o.version,
                           o.archived_at, o.is_delete_marker, o.is_versioned
                    FROM storage.objects o
                    WHERE o.bucket_id = $1
                      AND %s
                      %s
                    ORDER BY
                        o.name COLLATE "C" %s,
                        COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC,
                        COALESCE(o.version, '') ASC
                    LIMIT $4
                )
            ) sub
            ORDER BY
                sub.name COLLATE "C" %s,
                COALESCE(date_trunc('milliseconds', sub.archived_at), 'infinity'::timestamptz) DESC,
                COALESCE(sub.version, '') ASC
            LIMIT $4
            $sql$,
            v_exact_range_predicate,
            v_version_filter,
            v_strict_range_predicate,
            v_version_filter,
            v_name_order,
            v_name_order
        );
    ELSE
        v_batch_query := format(
            $sql$
            SELECT o.name, o.id, o.updated_at, o.created_at,
                   o.last_accessed_at, o.metadata, o.version,
                   o.archived_at, o.is_delete_marker, o.is_versioned
            FROM storage.objects o
            WHERE o.bucket_id = $1
              AND %s
              %s
            ORDER BY o.name COLLATE "C" %s, o.archived_at DESC
            LIMIT $4
            $sql$,
            v_inclusive_range_predicate,
            v_version_filter,
            v_name_order
        );

        -- Strict counterpart of the query above: used once the single-row
        -- ASC batch advance (below) has left v_next_seek pointing at the
        -- last row already emitted, so an inclusive predicate would
        -- re-match it forever. Only single-row mode ever sets strict mode,
        -- so this variant is never needed when v_multi_row.
        v_batch_query_strict := format(
            $sql$
            SELECT o.name, o.id, o.updated_at, o.created_at,
                   o.last_accessed_at, o.metadata, o.version,
                   o.archived_at, o.is_delete_marker, o.is_versioned
            FROM storage.objects o
            WHERE o.bucket_id = $1
              AND %s
              %s
            ORDER BY o.name COLLATE "C" %s, o.archived_at DESC
            LIMIT $4
            $sql$,
            v_strict_range_predicate,
            v_version_filter,
            v_name_order
        );
    END IF;

    -- The static peek predicates cannot use the partial delete-marker index
    -- once PL/pgSQL switches to a generic plan because whether
    -- is_delete_marker is required remains parameter-dependent. Reuse the
    -- already-specialized batch query with a one-row limit for this sparse
    -- filter so the plan sees a literal `o.is_delete_marker` predicate.
    IF delete_markers = 'only' THEN
        v_delete_marker_peek_query :=
            'SELECT marker_page.name FROM (' || v_batch_query || ') marker_page LIMIT 1';
        IF NOT v_multi_row THEN
            v_delete_marker_peek_query_strict :=
                'SELECT marker_page.name FROM (' || v_batch_query_strict || ') marker_page LIMIT 1';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor performs one specialized initial seek so
            -- partial current-version and delete-marker indexes remain available.
            EXECUTE format(
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1%s%s ORDER BY o.name COLLATE "C" DESC LIMIT 1',
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND o.name COLLATE "C" >= $2 AND o.name COLLATE "C" < $3'
                    ELSE ''
                END,
                v_version_filter
            )
            INTO v_next_seek
            USING _bucket_id, v_prefix, v_upper_bound;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Folder continuation tokens retain their trailing delimiter. A
        -- delimiter-less startAfter is always a literal key boundary.
        v_cursor_is_folder := delimiter_param <> ''
            AND v_start_relative <> ''
            AND right(v_start_relative, length(delimiter_param)) = delimiter_param;

        IF v_cursor_is_folder THEN
            v_next_seek := CASE
                WHEN right(v_start, length(delimiter_param)) = delimiter_param
                    THEN v_start
                ELSE v_start || delimiter_param
            END;
            IF v_is_asc THEN
                v_next_seek := left(v_next_seek, -1)
                    || chr(ascii(right(v_next_seek, 1)) + 1);
            END IF;
            v_next_seek_strict := NOT v_is_asc;
        ELSE
            -- leaf object: when v_multi_row, stay on v_start with the
            -- caller-supplied tiebreak so a page boundary mid-key resumes
            -- that key's remaining rows instead of skipping them. Truncate
            -- to milliseconds like every other v_next_seek_at assignment -
            -- harmless today since object.ts's cursor always round-trips
            -- through JS Date first, but this shouldn't rely on that.
            IF v_multi_row THEN
                v_next_seek := v_start;
                v_next_seek_at := date_trunc('milliseconds', next_token_archived_at);
                v_next_seek_version := coalesce(next_token_version, '');
                v_next_seek_strict := coalesce(next_token, '') = '';
            ELSIF v_is_asc THEN
                v_next_seek := v_start;
                v_next_seek_strict := true;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        v_previous_seek := v_next_seek;
        v_previous_seek_at := v_next_seek_at;
        v_previous_seek_version := v_next_seek_version;
        v_previous_count := v_count;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        -- v_multi_row is branched here (rather than folded into the WHERE
        -- clause as a bound parameter) so each concrete query keeps an
        -- unconditional seek predicate - once PL/pgSQL switches to its
        -- cached generic plan (after 5 calls), a parameter-gated
        -- "(NOT v_multi_row AND name >= $x) OR (v_multi_row AND ...)"
        -- predicate stops the planner from using name as an index
        -- condition at all, degrading every subsequent peek to a full
        -- index scan filtered row-by-row instead of a bounded range scan.
        -- v_multi_row's seek predicate is a keyset tuple comparison
        -- ("name > x OR (name = x AND tiebreak)") - Postgres does not
        -- split this OR into indexable form even with fully literal
        -- values, so it falls back to a full scan filtered row-by-row.
        -- Splitting it into two independently-indexable branches (exact
        -- name match with the tiebreak filter, vs. strictly-past name)
        -- combined with UNION ALL lets each branch keep name as a real
        -- index condition; the outer ORDER BY/LIMIT picks whichever of
        -- the (at most 2) rows sorts first.
        IF delete_markers = 'only' THEN
            EXECUTE CASE WHEN v_next_seek_strict AND NOT v_multi_row
                THEN v_delete_marker_peek_query_strict
                ELSE v_delete_marker_peek_query
            END
                INTO v_peek_name
                USING _bucket_id, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END,
                    1, v_next_seek_at, v_next_seek_version, v_next_seek_strict;
        ELSIF v_multi_row THEN
            IF v_is_asc THEN
                IF v_upper_bound IS NOT NULL THEN
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND o.name COLLATE "C" < v_upper_bound
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" > v_next_seek AND o.name COLLATE "C" < v_upper_bound
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" ASC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" > v_next_seek
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" ASC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSE
                IF v_upper_bound IS NOT NULL THEN
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND o.name COLLATE "C" >= v_prefix
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" DESC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" DESC LIMIT 1;
                ELSE
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" DESC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" DESC LIMIT 1;
                END IF;
            END IF;
        ELSE
            -- Single-row mode is always noncurrent_versions='exclude'. Keep
            -- this predicate literal so generic plans use the current index.
            IF v_is_asc THEN
                IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" > v_next_seek
                      AND o.name COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSIF v_next_seek_strict THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" > v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSIF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" >= v_next_seek
                      AND o.name COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" >= v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSE
                IF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" < v_next_seek
                      AND o.name COLLATE "C" >= v_prefix
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" DESC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" < v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" DESC LIMIT 1;
                END IF;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := v_common_prefix;
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            version := NULL;
            archived_at := NULL;
            is_delete_marker := NULL;
            is_versioned := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1)
                    || chr(ascii(right(v_common_prefix, 1)) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
            v_next_seek_at := NULL;
            v_next_seek_version := '';
            v_next_seek_strict := NOT v_is_asc;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE CASE WHEN v_next_seek_strict AND NOT v_multi_row THEN v_batch_query_strict ELSE v_batch_query END
                USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size, v_next_seek_at, v_next_seek_version,
                v_next_seek_strict
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it. Reset
                    -- strict mode too it may have been set by an earlier
                    -- row in this same batch (see the single-row ASC advance
                    -- below), and v_next_seek here is the folder-triggering
                    -- row's own name, which the next peek must find inclusively.
                    v_next_seek := CASE
                        WHEN v_is_asc THEN v_current.name
                        ELSE v_current.name || delimiter_param
                    END;
                    v_next_seek_at := NULL;
                    v_next_seek_version := '';
                    v_next_seek_strict := false;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                version := v_current.version;
                archived_at := v_current.archived_at;
                is_delete_marker := v_current.is_delete_marker;
                is_versioned := v_current.is_versioned;
                RETURN NEXT;
                v_count := v_count + 1;

                -- when v_multi_row, stay on this name and record its
                -- archived_at as the new tiebreak so remaining rows for the
                -- same key are picked up before moving to the next name
                IF v_multi_row THEN
                    v_next_seek := v_current.name;
                    v_next_seek_at := COALESCE(date_trunc('milliseconds', v_current.archived_at), 'infinity'::timestamptz);
                    v_next_seek_version := COALESCE(v_current.version, '');
                    v_next_seek_strict := false;
                ELSIF v_is_asc THEN
                    -- Appending the delimiter as a fake lexical successor
                    -- would skip a real key like `name || '!'` (or any
                    -- character sorting below the delimiter), which sorts
                    -- between `name` and `name || delimiter`. Track the real
                    -- name and mark the next comparison strict instead.
                    v_next_seek := v_current.name;
                    v_next_seek_strict := true;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;

        IF v_count = v_previous_count
           AND v_next_seek IS NOT DISTINCT FROM v_previous_seek
           AND v_next_seek_at IS NOT DISTINCT FROM v_previous_seek_at
           AND v_next_seek_version IS NOT DISTINCT FROM v_previous_seek_version THEN
            RAISE EXCEPTION 'storage.list_objects_with_delimiter made no progress at seek (%, %, %)',
                v_next_seek, v_next_seek_at, v_next_seek_version;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_bucket_control_columns(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_bucket_control_columns() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  configuration_changed boolean;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.lifecycle_configuration IS NOT NULL
       OR NEW.lifecycle_configuration_generation IS NOT NULL THEN
      IF NOT pg_has_role(current_user, TG_ARGV[0], 'MEMBER') THEN
        RAISE EXCEPTION 'only members of the configured storage service role may insert lifecycle policy state'
          USING ERRCODE = '42501',
                HINT = format(
                  'Insert with both lifecycle columns NULL and configure lifecycle through the Storage API afterward, or insert as a member of %I.',
                  TG_ARGV[0]
                );
      END IF;
    END IF;

    RETURN NEW;
  END IF;

  configuration_changed =
    OLD.lifecycle_configuration IS DISTINCT FROM NEW.lifecycle_configuration
    OR OLD.lifecycle_configuration_generation IS DISTINCT FROM NEW.lifecycle_configuration_generation;

  IF NOT configuration_changed THEN
    RETURN NEW;
  END IF;

  IF NEW.type IS DISTINCT FROM 'STANDARD' THEN
    RAISE EXCEPTION 'bucket versioning and lifecycle controls require a Standard bucket'
      USING ERRCODE = '0A000';
  END IF;

  IF NEW.lifecycle_configuration IS NULL
     AND NEW.lifecycle_configuration_generation IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.lifecycle_configuration IS NULL
     OR NEW.lifecycle_configuration_generation IS NULL
     OR OLD.lifecycle_configuration IS NOT DISTINCT FROM NEW.lifecycle_configuration
     OR OLD.lifecycle_configuration_generation IS NOT DISTINCT FROM NEW.lifecycle_configuration_generation THEN
    RAISE EXCEPTION 'a changed lifecycle policy requires a new non-null generation'
      USING ERRCODE = '22023';
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_prefix_len INT;
    v_prefix_start INT;
    v_combined_levels INT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;
    v_version_filter TEXT;
    v_multi_row BOOLEAN;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;
    v_delete_marker_peek_query TEXT;
    v_delete_marker_peek_query_strict TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_next_seek_at TIMESTAMPTZ;
    v_next_seek_version TEXT;
    v_next_seek_strict BOOLEAN := false;
    v_count INT := 0;
    v_skipped INT := 0;
    v_previous_seek TEXT;
    v_previous_seek_at TIMESTAMPTZ;
    v_previous_seek_version TEXT;
    v_previous_count INT;
    v_previous_skipped INT;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_prefix_len := length(coalesce(prefix, ''));
    v_prefix_start := coalesce(array_length(string_to_array(coalesce(prefix, ''), v_delimiter), 1), 1);
    v_combined_levels := coalesce(array_length(string_to_array(v_prefix, v_delimiter), 1), 1);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);
    v_next_seek_at := NULL;
    v_next_seek_version := '';

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    v_multi_row := noncurrent_versions IN ('only', 'include');

    v_version_filter := '';
    IF noncurrent_versions = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NULL';
    ELSIF noncurrent_versions = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NOT NULL';
    END IF;
    IF delete_markers = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND NOT o.is_delete_marker';
    ELSIF delete_markers = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.is_delete_marker';
    END IF;

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT array_to_string(path_tokens[$1:$2], '/') AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $3 || '%%'
                  AND bucket_id = $4
                  AND array_length(objects.path_tokens, 1) <> $2
                  AND ($7 != 'exclude' OR objects.archived_at IS NULL)
                  AND ($7 != 'only' OR objects.archived_at IS NOT NULL)
                  AND ($8 != 'exclude' OR NOT objects.is_delete_marker)
                  AND ($8 != 'only' OR objects.is_delete_marker)
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata,
                   NULL::text AS version,
                   NULL::timestamptz AS archived_at,
                   NULL::boolean AS is_delete_marker,
                   NULL::boolean AS is_versioned FROM folders)
            UNION ALL
            (SELECT array_to_string(path_tokens[$1:$2], '/') AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata,
                   version, archived_at, is_delete_marker, is_versioned
             FROM storage.objects
             WHERE objects.name ILIKE $3 || '%%'
               AND bucket_id = $4
               AND array_length(objects.path_tokens, 1) = $2
               AND ($7 != 'exclude' OR objects.archived_at IS NULL)
               AND ($7 != 'only' OR objects.archived_at IS NOT NULL)
               AND ($8 != 'exclude' OR NOT objects.is_delete_marker)
               AND ($8 != 'only' OR objects.is_delete_marker)
             -- name, then version, as tiebreaks so two versions of the same
             -- key tying on the sort column still sort deterministically
             ORDER BY %I %s, name COLLATE "C" %s, COALESCE(version, '') %s)
            LIMIT $5 OFFSET $6
            $sql$, v_sort_order, v_order_by, v_sort_order, v_sort_order, v_sort_order
        ) USING v_prefix_start, v_combined_levels, v_prefix, bucketname, v_limit, offsets, noncurrent_versions, delete_markers;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build a resume-safe batch query. The exact-name branch returns remaining
    -- versions after the current (archived_at, version) boundary; the strict
    -- name branch returns subsequent keys. UNION ALL keeps both predicates
    -- independently indexable.
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" > $2 AND lower(o.name) COLLATE "C" < $3' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" ASC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" > $2' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" ASC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 AND lower(o.name) COLLATE "C" >= $3' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" DESC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" DESC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        END IF;
    END IF;

    -- Keep the delete-marker predicate literal so the cached generic
    -- plan can use idx_objects_delete_markers during the main-loop peek.
    IF delete_markers = 'only' THEN
        IF v_multi_row THEN
            v_delete_marker_peek_query :=
                'SELECT marker_page.name FROM (' || v_batch_query || ') marker_page LIMIT 1';
        ELSIF v_is_asc THEN
            -- Two separate literal query strings, not one gated by a bound
            -- boolean: folding "$n AND op1 OR NOT $n AND op2" into a single
            -- query defeats the generic plan's ability to push either
            -- comparison into the index. Branching in PL/pgSQL control flow
            -- instead keeps each query's index condition intact.
            v_delete_marker_peek_query :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" >= $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" < $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1';
            -- Strict variant: used once the single-row ASC batch advance
            -- (below) has left v_next_seek pointing at the last row already
            -- emitted, so a plain >= would re-match it forever.
            v_delete_marker_peek_query_strict :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" > $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" < $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1';
        ELSE
            v_delete_marker_peek_query :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" < $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" >= $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC performs one specialized initial seek so partial current-version
        -- and delete-marker indexes remain available.
        EXECUTE format(
            'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1%s%s ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1',
            CASE WHEN v_upper_bound IS NOT NULL
                THEN ' AND lower(o.name) COLLATE "C" >= $2 AND lower(o.name) COLLATE "C" < $3'
                ELSE ''
            END,
            v_version_filter
        )
        INTO v_peek_name
        USING bucketname, v_prefix_lower, v_upper_bound;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch and
    -- the delete-marker-only path
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        v_previous_seek := v_next_seek;
        v_previous_seek_at := v_next_seek_at;
        v_previous_seek_version := v_next_seek_version;
        v_previous_count := v_count;
        v_previous_skipped := v_skipped;

        -- STEP 1: PEEK
        v_peek_name := NULL;
        IF delete_markers = 'only' THEN
            EXECUTE CASE WHEN v_next_seek_strict
                THEN v_delete_marker_peek_query_strict
                ELSE v_delete_marker_peek_query
            END
                INTO v_peek_name
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END,
                    1, v_next_seek_at, v_next_seek_version;
        ELSIF v_multi_row AND v_next_seek_at IS NOT NULL THEN
            SELECT o.name INTO v_peek_name
            FROM storage.objects o
            WHERE o.bucket_id = bucketname
              AND lower(o.name) COLLATE "C" = v_next_seek
              AND (COALESCE(o.archived_at, 'infinity'::timestamptz) < v_next_seek_at
                   OR (COALESCE(o.archived_at, 'infinity'::timestamptz) = v_next_seek_at
                       AND COALESCE(o.version, '') > v_next_seek_version))
              AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
              AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
              AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
              AND (delete_markers != 'only' OR o.is_delete_marker)
            ORDER BY COALESCE(o.archived_at, 'infinity'::timestamptz) DESC,
                     COALESCE(o.version, '') ASC
            LIMIT 1;

            -- The current key is exhausted. Clear its version boundary and
            -- make the following ASC name peek strict. Appending '/' is not a
            -- valid lexical successor because keys ending in characters such
            -- as '!' sort between the exhausted name and name || '/'.
            IF v_peek_name IS NULL THEN
                IF v_is_asc THEN
                    v_next_seek_strict := true;
                END IF;
                v_next_seek_at := NULL;
                v_next_seek_version := '';
            END IF;
        END IF;

        -- Single-row mode is always noncurrent_versions='exclude'. Keep the
        -- current-row predicate literal so generic plans use the current index.
        IF delete_markers != 'only' AND v_peek_name IS NULL AND NOT v_multi_row THEN
            IF v_is_asc THEN
                IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSIF v_next_seek_strict THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSIF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSIF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                  AND o.archived_at IS NULL
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                  AND o.archived_at IS NULL
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        ELSIF delete_markers != 'only' AND v_peek_name IS NULL AND v_is_asc THEN
            IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSIF v_next_seek_strict THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSIF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSIF delete_markers != 'only' AND v_peek_name IS NULL THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- If the peek landed on a different key than we were tracking, any
        -- version boundary belongs to the OLD key and must not leak into the
        -- new one - e.g. the deleteMarkers='only' peek doesn't know or care
        -- whether it's continuing the same key or jumping to a new one, so
        -- it never clears these itself.
        IF lower(v_peek_name) IS DISTINCT FROM v_next_seek THEN
            v_next_seek_at := NULL;
            v_next_seek_version := '';
        END IF;

        -- The peek is authoritative for the next key to process. This is
        -- especially important after exhausting a multi-version key: the
        -- version boundary has been cleared, so executing the batch against
        -- a stale v_next_seek would replay every version of that old key.
        v_next_seek := lower(v_peek_name);
        v_next_seek_strict := false;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := substring(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter) from v_prefix_len + 1);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                version := NULL;
                archived_at := NULL;
                is_delete_marker := NULL;
                is_versioned := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
            v_next_seek_at := NULL;
            v_next_seek_version := '';
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size,
                    v_next_seek_at, v_next_seek_version
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it. Reset
                    -- strict mode too - it may have been set by an earlier
                    -- row in this same batch (see the single-row ASC advance
                    -- below), and v_next_seek here is the folder-triggering
                    -- row's own name, which the next peek must find inclusively.
                    v_next_seek := CASE
                        WHEN v_is_asc THEN lower(v_current.name)
                        ELSE lower(v_current.name) || v_delimiter
                    END;
                    v_next_seek_at := NULL;
                    v_next_seek_version := '';
                    v_next_seek_strict := false;
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := substring(v_current.name from v_prefix_len + 1);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    version := v_current.version;
                    archived_at := v_current.archived_at;
                    is_delete_marker := v_current.is_delete_marker;
                    is_versioned := v_current.is_versioned;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Multi-row mode must remain on this key until all of its
                -- versions have crossed the internal batch boundary.
                IF v_multi_row THEN
                    v_next_seek := lower(v_current.name);
                    v_next_seek_at := COALESCE(v_current.archived_at, 'infinity'::timestamptz);
                    v_next_seek_version := COALESCE(v_current.version, '');
                ELSIF v_is_asc THEN
                    -- Appending the delimiter as a fake lexical successor would
                    -- skip a real key like `name || '!'` (or any character
                    -- sorting below the delimiter), which sorts between `name`
                    -- and `name || delimiter`. Track the real name and mark the
                    -- next comparison strict instead - same fix as the
                    -- exhausted-key case above.
                    v_next_seek := lower(v_current.name);
                    v_next_seek_strict := true;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;

        IF v_count = v_previous_count
           AND v_skipped = v_previous_skipped
           AND v_next_seek IS NOT DISTINCT FROM v_previous_seek
           AND v_next_seek_at IS NOT DISTINCT FROM v_previous_seek_at
           AND v_next_seek_version IS NOT DISTINCT FROM v_previous_seek_version THEN
            RAISE EXCEPTION 'storage.search made no progress at seek (%, %, %)',
                v_next_seek, v_next_seek_at, v_next_seek_version;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, p_start_after_version text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
    v_prefix_pattern text;
    v_sort_order text;
    v_sort_column text;
    v_version_tiebreak text;
BEGIN
    v_prefix := coalesce(p_prefix, '');
    -- Keep the raw prefix for common-prefix calculations and escape only LIKE metacharacters.
    v_prefix_pattern := replace(v_prefix, chr(92), chr(92) || chr(92));
    v_prefix_pattern := replace(v_prefix_pattern, '%', chr(92) || '%');
    v_prefix_pattern := replace(v_prefix_pattern, '_', chr(92) || '_');

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    -- $9 is only populated in multi-row mode; it's always '' otherwise, so
    -- only use each row's real version as a tiebreak in multi-row mode.
    v_version_tiebreak := CASE WHEN noncurrent_versions IN ('only', 'include') THEN 'COALESCE(version, '''')' ELSE '''''' END;

    -- Defense-in-depth: this function is independently reachable and must
    -- not trust p_sort_order/p_sort_column to already be validated by a
    -- caller. Normalize to the same strict allow-list storage.search_v2
    -- uses before interpolating anything into dynamic SQL below.
    v_sort_order := lower(coalesce(p_sort_order, 'asc'));
    IF v_sort_order NOT IN ('asc', 'desc') THEN
        v_sort_order := 'asc';
    END IF;

    v_sort_column := lower(coalesce(p_sort_column, 'updated_at'));
    IF v_sort_column NOT IN ('updated_at', 'created_at') THEN
        v_sort_column := 'updated_at';
    END IF;

    IF v_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                o.version AS obj_version,
                o.archived_at AS obj_archived_at,
                o.is_delete_marker AS obj_is_delete_marker,
                o.is_versioned AS obj_is_versioned,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $10 || '%%'
              AND ($7 != 'exclude' OR o.archived_at IS NULL)
              AND ($7 != 'only' OR o.archived_at IS NOT NULL)
              AND ($8 != 'exclude' OR NOT o.is_delete_marker)
              AND ($8 != 'only' OR o.is_delete_marker)
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                common_prefix AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                NULL::text AS version,
                NULL::timestamptz AS archived_at,
                NULL::boolean AS is_delete_marker,
                NULL::boolean AS is_versioned,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                obj_version AS version,
                obj_archived_at AS archived_at,
                obj_is_delete_marker AS is_delete_marker,
                obj_is_versioned AS is_versioned,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz),
                    name COLLATE "C",
                    %s
                ) %s ROW(
                    -- truncated the same way as the stored value above
                    date_trunc('milliseconds', COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz)),
                    $5,
                    $9
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata,
            version,
            archived_at,
            is_delete_marker,
            is_versioned
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s,
            COALESCE(version, '') %s
        LIMIT $4
    $sql$,
        v_sort_column,
        v_version_tiebreak,
        v_cursor_op,
        v_sort_column,
        v_sort_order,
        v_sort_order,
        v_sort_order
    );

    -- version is the third tiebreak component for two versions of the same
    -- key tying on both timestamp and name (see filtered CTE / ORDER BY above)
    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after, noncurrent_versions, delete_markers, coalesce(p_start_after_version, ''), v_prefix_pattern;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text, text, text, timestamp with time zone, text, boolean); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, start_after_archived_at timestamp with time zone DEFAULT NULL::timestamp with time zone, start_after_version text DEFAULT ''::text, start_after_is_continuation boolean DEFAULT false) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata,
            l.version,
            l.archived_at,
            l.is_delete_marker,
            l.is_versioned
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            CASE WHEN start_after_is_continuation THEN '' ELSE start_after END,
            CASE WHEN start_after_is_continuation THEN start_after ELSE '' END,
            v_sort_ord,
            noncurrent_versions,
            delete_markers,
            start_after_archived_at,
            start_after_version
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after,
            noncurrent_versions, delete_markers, start_after_version
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


--
-- Name: notify_listing_status(); Type: FUNCTION; Schema: travelmate; Owner: -
--

CREATE FUNCTION travelmate.notify_listing_status() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
 IF OLD.status IS DISTINCT FROM NEW.status THEN
  INSERT INTO travelmate.notifications(user_id,message,read_at,created_at)
  SELECT bo.user_id,
   concat('Listing #',NEW.id,' (',NEW.name,') changed from ',OLD.status,' to ',NEW.status,'.'),
   NULL,clock_timestamp() AT TIME ZONE 'UTC'
  FROM travelmate.business_owners bo WHERE bo.id=NEW.owner_id;
 END IF;
 RETURN NEW;
END $$;


--
-- Name: business_listings; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.business_listings (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    destination_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    slug character varying(180) NOT NULL,
    listing_type character varying(24) NOT NULL,
    description text,
    address character varying(255) DEFAULT NULL::character varying,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    updated_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_business_listings_1 CHECK (((listing_type)::text = ANY ((ARRAY['hotel'::character varying, 'restaurant'::character varying, 'attraction'::character varying])::text[]))),
    CONSTRAINT ck_business_listings_2 CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying, 'inactive'::character varying])::text[]))),
    CONSTRAINT pg_unsigned_destination_id CHECK ((destination_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_owner_id CHECK ((owner_id >= 0))
);


--
-- Name: COLUMN business_listings.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.id IS 'Shared listing key.';


--
-- Name: COLUMN business_listings.owner_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.owner_id IS 'Exactly one responsible owner.';


--
-- Name: COLUMN business_listings.destination_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.destination_id IS 'Exactly one destination.';


--
-- Name: COLUMN business_listings.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.name IS 'Business name.';


--
-- Name: COLUMN business_listings.slug; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.slug IS 'Stable public identifier.';


--
-- Name: COLUMN business_listings.listing_type; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.listing_type IS 'hotel / restaurant / attraction.';


--
-- Name: COLUMN business_listings.description; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.description IS 'Shared descriptive content.';


--
-- Name: COLUMN business_listings.address; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.address IS 'Street/location details; required by publication validator.';


--
-- Name: COLUMN business_listings.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.status IS 'pending / approved / rejected / inactive.';


--
-- Name: COLUMN business_listings.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.created_at IS 'UTC creation.';


--
-- Name: COLUMN business_listings.updated_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_listings.updated_at IS 'UTC modification.';


--
-- Name: destinations; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.destinations (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    province character varying(100) NOT NULL,
    slug character varying(180) NOT NULL,
    description text,
    latitude numeric(10,7) DEFAULT NULL::numeric,
    longitude numeric(10,7) DEFAULT NULL::numeric,
    is_active smallint DEFAULT 1 NOT NULL,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    updated_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_destinations_1 CHECK ((is_active = ANY (ARRAY[0, 1]))),
    CONSTRAINT ck_destinations_2 CHECK ((((latitude IS NULL) AND (longitude IS NULL)) OR ((latitude IS NOT NULL) AND (longitude IS NOT NULL)))),
    CONSTRAINT ck_destinations_3 CHECK (((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric))),
    CONSTRAINT ck_destinations_4 CHECK (((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric))),
    CONSTRAINT pg_unsigned_category_id CHECK ((category_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN destinations.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.id IS 'Destination key.';


--
-- Name: COLUMN destinations.category_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.category_id IS 'Exactly one primary category.';


--
-- Name: COLUMN destinations.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.name IS 'Display name.';


--
-- Name: COLUMN destinations.province; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.province IS 'Province or equivalent area; do not assume names globally unique.';


--
-- Name: COLUMN destinations.slug; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.slug IS 'Stable URL identifier.';


--
-- Name: COLUMN destinations.description; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.description IS 'Destination description.';


--
-- Name: COLUMN destinations.latitude; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.latitude IS 'Optional map coordinate.';


--
-- Name: COLUMN destinations.longitude; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.longitude IS 'Optional map coordinate.';


--
-- Name: COLUMN destinations.is_active; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.is_active IS '0 / 1; hide inactive destinations.';


--
-- Name: COLUMN destinations.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.created_at IS 'UTC creation.';


--
-- Name: COLUMN destinations.updated_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.destinations.updated_at IS 'UTC modification.';


--
-- Name: v_public_listings; Type: VIEW; Schema: travelmate; Owner: -
--

CREATE VIEW travelmate.v_public_listings WITH (security_invoker='true') AS
 SELECT bl.id AS listing_id,
    bl.name AS listing_name,
    bl.listing_type,
    d.name AS destination_name,
    d.province,
    bl.address,
    bl.status
   FROM (travelmate.business_listings bl
     JOIN travelmate.destinations d ON ((d.id = bl.destination_id)))
  WHERE (((bl.status)::text = 'approved'::text) AND (d.is_active = 1));


--
-- Name: public_listings_by_province(character varying); Type: FUNCTION; Schema: travelmate; Owner: -
--

CREATE FUNCTION travelmate.public_listings_by_province(p_province character varying) RETURNS SETOF travelmate.v_public_listings
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog'
    AS $$
 SELECT * FROM travelmate.v_public_listings
 WHERE lower(province)=lower(trim(p_province))
 ORDER BY destination_name, listing_name;
$$;


--
-- Name: sp_public_listings_by_province(character varying, refcursor); Type: PROCEDURE; Schema: travelmate; Owner: -
--

CREATE PROCEDURE travelmate.sp_public_listings_by_province(IN p_province character varying, INOUT p_results refcursor)
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
 OPEN p_results FOR SELECT * FROM travelmate.public_listings_by_province(p_province);
END $$;


--
-- Name: touch_updated_at(); Type: FUNCTION; Schema: travelmate; Owner: -
--

CREATE FUNCTION travelmate.touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
 IF NEW IS DISTINCT FROM OLD AND NEW.updated_at IS NOT DISTINCT FROM OLD.updated_at THEN
   NEW.updated_at := clock_timestamp() AT TIME ZONE 'UTC';
 END IF;
 RETURN NEW;
END $$;


--
-- Name: current_active_user_id(); Type: FUNCTION; Schema: travelmate_private; Owner: -
--

CREATE FUNCTION travelmate_private.current_active_user_id() RETURNS bigint
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
 SELECT id FROM travelmate.users
 WHERE auth_user_id=(SELECT auth.uid()) AND account_status='active';
$$;


--
-- Name: on_auth_profile_event(); Type: FUNCTION; Schema: travelmate_private; Owner: -
--

CREATE FUNCTION travelmate_private.on_auth_profile_event() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
 PERFORM travelmate_private.provision_auth_profile(NEW.id);
 RETURN NEW;
END $$;


--
-- Name: provision_auth_profile(uuid); Type: FUNCTION; Schema: travelmate_private; Owner: -
--

CREATE FUNCTION travelmate_private.provision_auth_profile(p_auth_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE a auth.users%ROWTYPE; v_user_id bigint; v_email text; v_name text;
BEGIN
 SELECT * INTO a FROM auth.users WHERE id=p_auth_id;
 IF NOT FOUND OR a.email_confirmed_at IS NULL OR a.email IS NULL THEN RETURN; END IF;
 IF EXISTS (SELECT 1 FROM travelmate.users WHERE auth_user_id=a.id) THEN RETURN; END IF;
 v_email:=lower(btrim(a.email));
 IF v_email='' OR length(v_email)>254 THEN RAISE EXCEPTION 'Valid profile email required'; END IF;
 IF EXISTS (SELECT 1 FROM travelmate.users WHERE lower(btrim(email))=v_email) THEN
  RAISE EXCEPTION 'An imported TravelMate account already uses this email. Administrator must review account linking.';
 END IF;
 v_name:=coalesce(nullif(btrim(a.raw_user_meta_data->>'full_name'),''),
                  nullif(btrim(a.raw_user_meta_data->>'name'),''),'Traveler');
 INSERT INTO travelmate.users(full_name,email,password_hash,account_status,email_verified_at,auth_user_id)
 VALUES(left(v_name,150),v_email,NULL,'active',a.email_confirmed_at AT TIME ZONE 'UTC',a.id)
 RETURNING id INTO v_user_id;
 INSERT INTO travelmate.user_roles(user_id,role_id)
 SELECT v_user_id,id FROM travelmate.roles WHERE name='traveler';
END $$;


--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    custom_claims_allowlist text[] DEFAULT '{}'::text[] NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: mfa_recovery_code_sets; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_recovery_code_sets (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    mfa_factor_id uuid NOT NULL,
    failed_verification_count integer DEFAULT 0 NOT NULL,
    verification_locked_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT mfa_recovery_code_sets_failed_verification_count_check CHECK ((failed_verification_count >= 0))
);


--
-- Name: mfa_recovery_codes; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_recovery_codes (
    id uuid NOT NULL,
    mfa_recovery_code_set_id uuid NOT NULL,
    code_hash text NOT NULL,
    consumed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: scim_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.scim_tokens (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    token_hash text NOT NULL,
    prefix text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    revoked_at timestamp with time zone,
    last_used_at timestamp with time zone,
    CONSTRAINT scim_tokens_expires_at_future CHECK (((expires_at IS NULL) OR (expires_at > created_at))),
    CONSTRAINT scim_tokens_revoked_after_created CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at))),
    CONSTRAINT scim_tokens_token_hash_check CHECK ((token_hash ~ '^[0-9a-f]{64}$'::text))
);


--
-- Name: scim_users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.scim_users (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    user_id uuid,
    resource jsonb NOT NULL,
    user_name text GENERATED ALWAYS AS (lower((resource ->> 'userName'::text))) STORED NOT NULL,
    external_id text GENERATED ALWAYS AS ((resource ->> 'externalId'::text)) STORED,
    active boolean GENERATED ALWAYS AS (COALESCE(((resource ->> 'active'::text))::boolean, true)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: amenities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.amenities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: analytics_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analytics_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    generated_by uuid NOT NULL,
    period_start date,
    period_end date,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    generated_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_analytics_reports_1 CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('generated'::character varying)::text, ('failed'::character varying)::text]))),
    CONSTRAINT ck_analytics_reports_2 CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end >= period_start)))),
    CONSTRAINT ck_analytics_reports_3 CHECK (((((status)::text = 'generated'::text) AND (generated_at IS NOT NULL)) OR (((status)::text <> 'generated'::text) AND (generated_at IS NULL))))
);


--
-- Name: attraction_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attraction_schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    attraction_id uuid NOT NULL,
    operating_day character varying(80) NOT NULL,
    schedule_text character varying(255) NOT NULL
);


--
-- Name: attractions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attractions (
    attraction_id uuid NOT NULL,
    entrance_fee numeric(12,2) DEFAULT NULL::numeric,
    CONSTRAINT ck_attractions_1 CHECK ((entrance_fee >= (0)::numeric))
);


--
-- Name: booking_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_rooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    room_id uuid NOT NULL,
    nightly_rate numeric(12,2) NOT NULL,
    CONSTRAINT ck_booking_rooms_1 CHECK ((nightly_rate >= (0)::numeric))
);


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    booking_type character varying(24) NOT NULL,
    guest_name character varying(150) NOT NULL,
    guest_email character varying(254) NOT NULL,
    guest_phone character varying(20) DEFAULT NULL::character varying,
    guest_count smallint NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    hold_expires_at timestamp with time zone,
    idempotency_key character varying(80) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    payment_status character varying DEFAULT 'unpaid'::character varying,
    stripe_session_id character varying,
    stripe_payment_intent_id character varying,
    CONSTRAINT ck_bookings_1 CHECK (((booking_type)::text = ANY (ARRAY[('hotel'::character varying)::text, ('restaurant'::character varying)::text]))),
    CONSTRAINT ck_bookings_2 CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('confirmed'::character varying)::text, ('completed'::character varying)::text, ('cancelled'::character varying)::text, ('expired'::character varying)::text]))),
    CONSTRAINT ck_bookings_3 CHECK ((guest_count > 0)),
    CONSTRAINT ck_bookings_4 CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT ck_bookings_5 CHECK ((((status)::text <> 'pending'::text) OR ((hold_expires_at IS NOT NULL) AND (hold_expires_at > created_at)))),
    CONSTRAINT pg_unsigned_guest_count CHECK ((guest_count >= 0))
);


--
-- Name: business_owners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business_owners (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    contact_name character varying(150) DEFAULT NULL::character varying,
    contact_email character varying(254) DEFAULT NULL::character varying
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text
);


--
-- Name: cuisines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cuisines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: data_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_sources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: hotel_amenities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hotel_amenities (
    hotel_id uuid NOT NULL,
    amenity_id uuid NOT NULL
);


--
-- Name: hotel_bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hotel_bookings (
    booking_id uuid NOT NULL,
    hotel_id uuid NOT NULL,
    check_in date NOT NULL,
    check_out date NOT NULL,
    CONSTRAINT ck_hotel_bookings_1 CHECK ((check_out > check_in))
);


--
-- Name: hotels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hotels (
    hotel_id uuid NOT NULL,
    check_in_time time without time zone,
    check_out_time time without time zone
);


--
-- Name: menu_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    restaurant_id uuid NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    category character varying(80) DEFAULT NULL::character varying,
    price numeric(12,2) DEFAULT NULL::numeric,
    is_available smallint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_menu_items_1 CHECK ((price >= (0)::numeric)),
    CONSTRAINT ck_menu_items_2 CHECK ((is_available = ANY (ARRAY[0, 1])))
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    full_name character varying(150) NOT NULL,
    address character varying(255) DEFAULT NULL::character varying,
    account_status character varying(24) DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    avatar_object_path text,
    CONSTRAINT ck_users_1 CHECK (((account_status)::text = ANY (ARRAY[('active'::character varying)::text, ('suspended'::character varying)::text, ('closed'::character varying)::text]))),
    CONSTRAINT ck_users_avatar_path CHECK (((avatar_object_path IS NULL) OR ((id IS NOT NULL) AND (split_part(avatar_object_path, '/'::text, 1) = (id)::text) AND (length(split_part(avatar_object_path, '/'::text, 2)) > 0)))),
    CONSTRAINT tm_profile_name CHECK (((length(btrim((full_name)::text)) >= 1) AND (length(btrim((full_name)::text)) <= 150)))
);


--
-- Name: my_profile; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.my_profile WITH (security_invoker='true') AS
 SELECT id,
    full_name,
    address,
    account_status,
    avatar_object_path,
    created_at,
    updated_at
   FROM public.profiles;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    message text NOT NULL,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    method character varying(24) NOT NULL,
    provider character varying(80) NOT NULL,
    provider_reference character varying(150) DEFAULT NULL::character varying,
    idempotency_key character varying(80) NOT NULL,
    amount numeric(12,2) NOT NULL,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    is_demo smallint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    paid_at timestamp with time zone,
    CONSTRAINT ck_payments_1 CHECK (((method)::text = ANY (ARRAY[('gcash'::character varying)::text, ('card'::character varying)::text, ('pay_at_venue'::character varying)::text]))),
    CONSTRAINT ck_payments_2 CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('succeeded'::character varying)::text, ('failed'::character varying)::text, ('cancelled'::character varying)::text]))),
    CONSTRAINT ck_payments_3 CHECK ((amount >= (0)::numeric)),
    CONSTRAINT ck_payments_4 CHECK ((is_demo = ANY (ARRAY[0, 1]))),
    CONSTRAINT ck_payments_5 CHECK ((amount > (0)::numeric)),
    CONSTRAINT ck_payments_6 CHECK (((((status)::text = 'succeeded'::text) AND (paid_at IS NOT NULL)) OR (((status)::text <> 'succeeded'::text) AND (paid_at IS NULL))))
);


--
-- Name: photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    destination_id uuid,
    listing_id uuid,
    bucket_id text NOT NULL,
    object_path text NOT NULL,
    caption character varying(255) DEFAULT NULL::character varying,
    sort_order integer DEFAULT 0 NOT NULL,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    menu_item_id uuid,
    CONSTRAINT ck_photos_1 CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('rejected'::character varying)::text]))),
    CONSTRAINT ck_photos_2 CHECK (((((destination_id IS NOT NULL))::integer + ((listing_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT pg_unsigned_sort_order CHECK ((sort_order >= 0)),
    CONSTRAINT tm_photo_path CHECK (((bucket_id = 'travelmate-listings'::text) AND (length(object_path) > 0) AND (object_path !~ '(^/|(^|/)\.\.(/|$))'::text)))
);


--
-- Name: preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preferences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category character varying(100) NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: profile_phones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_phones (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    phone_number character varying(20) NOT NULL
);


--
-- Name: profile_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_preferences (
    profile_id uuid NOT NULL,
    preference_id uuid NOT NULL
);


--
-- Name: profile_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_roles (
    profile_id uuid NOT NULL,
    role_id uuid NOT NULL
);


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    destination_id uuid NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    recommended_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: refunds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refunds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    provider_reference character varying(150) DEFAULT NULL::character varying,
    idempotency_key character varying(80) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    refunded_at timestamp with time zone,
    CONSTRAINT ck_refunds_1 CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('succeeded'::character varying)::text, ('failed'::character varying)::text]))),
    CONSTRAINT ck_refunds_2 CHECK ((amount >= (0)::numeric)),
    CONSTRAINT ck_refunds_3 CHECK ((amount > (0)::numeric)),
    CONSTRAINT ck_refunds_4 CHECK (((((status)::text = 'succeeded'::text) AND (refunded_at IS NOT NULL)) OR (((status)::text <> 'succeeded'::text) AND (refunded_at IS NULL))))
);


--
-- Name: report_data_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_data_sources (
    report_id uuid NOT NULL,
    data_source_id uuid NOT NULL
);


--
-- Name: report_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_metrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    report_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    value numeric(18,4) NOT NULL,
    unit character varying(40) NOT NULL
);


--
-- Name: report_report_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_report_types (
    report_id uuid NOT NULL,
    report_type_id uuid NOT NULL
);


--
-- Name: report_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: restaurant_bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurant_bookings (
    booking_id uuid NOT NULL,
    slot_id uuid NOT NULL
);


--
-- Name: restaurant_cuisines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurant_cuisines (
    restaurant_id uuid NOT NULL,
    cuisine_id uuid NOT NULL
);


--
-- Name: restaurant_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurant_slots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    restaurant_id uuid NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    capacity smallint NOT NULL,
    is_open smallint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_restaurant_slots_1 CHECK ((capacity > 0)),
    CONSTRAINT ck_restaurant_slots_2 CHECK ((is_open = ANY (ARRAY[0, 1]))),
    CONSTRAINT ck_restaurant_slots_3 CHECK ((ends_at > starts_at)),
    CONSTRAINT pg_unsigned_capacity CHECK ((capacity >= 0))
);


--
-- Name: restaurants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurants (
    restaurant_id uuid NOT NULL,
    operating_hours character varying(255) DEFAULT NULL::character varying,
    reservation_fee numeric(12,2) DEFAULT 0.00 NOT NULL,
    CONSTRAINT ck_restaurants_1 CHECK ((reservation_fee >= (0)::numeric))
);


--
-- Name: review_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    review_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    body text NOT NULL,
    status character varying(24) DEFAULT 'published'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_review_comments_1 CHECK (((status)::text = ANY (ARRAY[('published'::character varying)::text, ('hidden'::character varying)::text, ('pending'::character varying)::text])))
);


--
-- Name: review_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_tags (
    review_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    destination_id uuid,
    listing_id uuid,
    rating smallint NOT NULL,
    review_text text,
    status character varying(24) DEFAULT 'published'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_reviews_1 CHECK (((status)::text = ANY (ARRAY[('published'::character varying)::text, ('hidden'::character varying)::text, ('pending'::character varying)::text]))),
    CONSTRAINT ck_reviews_2 CHECK (((((destination_id IS NOT NULL))::integer + ((listing_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT ck_reviews_3 CHECK (((rating >= 1) AND (rating <= 5))),
    CONSTRAINT pg_unsigned_rating CHECK ((rating >= 0))
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(40) NOT NULL,
    CONSTRAINT ck_roles_1 CHECK (((name)::text = ANY (ARRAY[('traveler'::character varying)::text, ('business_owner'::character varying)::text, ('admin'::character varying)::text, ('moderator'::character varying)::text, ('analyst'::character varying)::text, ('support'::character varying)::text])))
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    hotel_id uuid NOT NULL,
    room_number character varying(20) NOT NULL,
    room_type character varying(80) NOT NULL,
    max_guests smallint NOT NULL,
    base_nightly_rate numeric(12,2) DEFAULT NULL::numeric,
    operational_status character varying(24) DEFAULT 'unavailable'::character varying NOT NULL,
    CONSTRAINT ck_rooms_1 CHECK (((operational_status)::text = ANY (ARRAY[('available'::character varying)::text, ('maintenance'::character varying)::text, ('unavailable'::character varying)::text]))),
    CONSTRAINT ck_rooms_2 CHECK ((max_guests > 0)),
    CONSTRAINT ck_rooms_3 CHECK ((base_nightly_rate >= (0)::numeric)),
    CONSTRAINT pg_unsigned_max_guests CHECK ((max_guests >= 0))
);


--
-- Name: saved_destinations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saved_destinations (
    profile_id uuid NOT NULL,
    destination_id uuid NOT NULL,
    added_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: search_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.search_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    trip_id uuid,
    keyword character varying(255) NOT NULL,
    filter_text text,
    searched_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(80) NOT NULL
);


--
-- Name: transport_provider_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transport_provider_contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_id uuid NOT NULL,
    phone_number character varying(20) NOT NULL
);


--
-- Name: transport_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transport_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id uuid NOT NULL,
    company_name character varying(150) NOT NULL,
    description text
);


--
-- Name: transportation_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transportation_services (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_id uuid NOT NULL,
    destination_id uuid NOT NULL,
    transport_type character varying(50) NOT NULL,
    service_name character varying(150) NOT NULL,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    CONSTRAINT ck_transportation_services_1 CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('rejected'::character varying)::text, ('inactive'::character varying)::text])))
);


--
-- Name: trip_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trip_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    trip_id uuid NOT NULL,
    destination_id uuid,
    listing_id uuid,
    activity character varying(255) NOT NULL,
    sequence_number integer NOT NULL,
    planned_date date,
    planned_time time without time zone,
    notes text,
    status character varying(24) DEFAULT 'planned'::character varying NOT NULL,
    CONSTRAINT ck_trip_items_1 CHECK (((status)::text = ANY (ARRAY[('planned'::character varying)::text, ('completed'::character varying)::text, ('skipped'::character varying)::text]))),
    CONSTRAINT ck_trip_items_2 CHECK ((sequence_number > 0)),
    CONSTRAINT ck_trip_items_3 CHECK (((((destination_id IS NOT NULL))::integer + ((listing_id IS NOT NULL))::integer) <= 1)),
    CONSTRAINT ck_trip_items_4 CHECK (((planned_time IS NULL) OR (planned_date IS NOT NULL))),
    CONSTRAINT pg_unsigned_sequence_number CHECK ((sequence_number >= 0))
);


--
-- Name: trips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trips (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    name character varying(150) NOT NULL,
    start_date date,
    end_date date,
    budget numeric(12,2) DEFAULT NULL::numeric,
    status character varying(24) DEFAULT 'draft'::character varying NOT NULL,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_trips_1 CHECK (((status)::text = ANY (ARRAY[('draft'::character varying)::text, ('planned'::character varying)::text, ('ongoing'::character varying)::text, ('completed'::character varying)::text, ('cancelled'::character varying)::text]))),
    CONSTRAINT ck_trips_2 CHECK ((budget >= (0)::numeric)),
    CONSTRAINT ck_trips_3 CHECK ((((start_date IS NULL) AND (end_date IS NULL)) OR ((start_date IS NOT NULL) AND (end_date IS NOT NULL) AND (end_date >= start_date)))),
    CONSTRAINT ck_trips_4 CHECK ((((status)::text = 'draft'::text) OR ((start_date IS NOT NULL) AND (end_date IS NOT NULL)))),
    CONSTRAINT ck_trips_5 CHECK (((((status)::text = 'completed'::text) AND (completed_at IS NOT NULL)) OR (((status)::text <> 'completed'::text) AND (completed_at IS NULL))))
);


--
-- Name: user_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    report_type character varying(50) NOT NULL,
    description text NOT NULL,
    listing_id uuid,
    destination_id uuid,
    review_id uuid,
    photo_id uuid,
    transport_id uuid,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    assigned_to uuid,
    submitted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    resolved_at timestamp with time zone,
    CONSTRAINT ck_user_reports_1 CHECK (((report_type)::text = ANY (ARRAY[('bug'::character varying)::text, ('listing'::character varying)::text, ('destination'::character varying)::text, ('review'::character varying)::text, ('photo'::character varying)::text, ('transport'::character varying)::text, ('other'::character varying)::text]))),
    CONSTRAINT ck_user_reports_2 CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('resolved'::character varying)::text]))),
    CONSTRAINT ck_user_reports_3 CHECK ((((((((listing_id IS NOT NULL))::integer + ((destination_id IS NOT NULL))::integer) + ((review_id IS NOT NULL))::integer) + ((photo_id IS NOT NULL))::integer) + ((transport_id IS NOT NULL))::integer) <= 1)),
    CONSTRAINT ck_user_reports_4 CHECK (((((status)::text = 'resolved'::text) AND (resolved_at IS NOT NULL)) OR (((status)::text <> 'resolved'::text) AND (resolved_at IS NULL))))
);


--
-- Name: v_catalog_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_catalog_summary WITH (security_invoker='true') AS
 SELECT d.id AS destination_id,
    d.name AS destination_name,
    d.province,
    count(b.id) AS total_listings,
    count(b.id) FILTER (WHERE ((b.status)::text = 'approved'::text)) AS approved_listings,
    count(b.id) FILTER (WHERE ((b.status)::text = 'pending'::text)) AS pending_listings,
    count(b.id) FILTER (WHERE ((b.listing_type)::text = 'hotel'::text)) AS hotels,
    count(b.id) FILTER (WHERE ((b.listing_type)::text = 'restaurant'::text)) AS restaurants,
    count(b.id) FILTER (WHERE ((b.listing_type)::text = 'attraction'::text)) AS attractions
   FROM (public.destinations d
     LEFT JOIN public.business_listings b ON ((b.destination_id = d.id)))
  GROUP BY d.id, d.name, d.province;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone DEFAULT now()
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    selected_columns text[],
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL,
    versioning_status text DEFAULT 'DISABLED'::text NOT NULL,
    lifecycle_configuration jsonb,
    lifecycle_configuration_generation uuid,
    CONSTRAINT buckets_lifecycle_configuration_pair_check CHECK (((lifecycle_configuration IS NULL) = (lifecycle_configuration_generation IS NULL))),
    CONSTRAINT buckets_lifecycle_configuration_shape_check CHECK (((lifecycle_configuration IS NULL) OR ((jsonb_typeof(lifecycle_configuration) = 'object'::text) AND (lifecycle_configuration ? 'rules'::text) AND
CASE
    WHEN (jsonb_typeof((lifecycle_configuration -> 'rules'::text)) = 'array'::text) THEN ((jsonb_array_length((lifecycle_configuration -> 'rules'::text)) >= 1) AND (jsonb_array_length((lifecycle_configuration -> 'rules'::text)) <= 1000))
    ELSE false
END))),
    CONSTRAINT buckets_lifecycle_configuration_standard_only_check CHECK (((type = 'STANDARD'::storage.buckettype) OR ((lifecycle_configuration IS NULL) AND (lifecycle_configuration_generation IS NULL)))),
    CONSTRAINT buckets_versioning_dark_check CHECK ((versioning_status = 'DISABLED'::text)),
    CONSTRAINT buckets_versioning_standard_only_check CHECK (((type = 'STANDARD'::storage.buckettype) OR (versioning_status = 'DISABLED'::text))),
    CONSTRAINT buckets_versioning_status_check CHECK ((versioning_status = ANY (ARRAY['DISABLED'::text, 'ENABLED'::text, 'SUSPENDED'::text])))
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    archived_at timestamp with time zone,
    is_delete_marker boolean DEFAULT false NOT NULL,
    is_versioned boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: amenities; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.amenities (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN amenities.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.amenities.id IS 'Amenity key.';


--
-- Name: COLUMN amenities.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.amenities.name IS 'Amenity label.';


--
-- Name: amenities_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.amenities ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.amenities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: analytics_reports; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.analytics_reports (
    id bigint NOT NULL,
    generated_by bigint NOT NULL,
    period_start date,
    period_end date,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    generated_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_analytics_reports_1 CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'generated'::character varying, 'failed'::character varying])::text[]))),
    CONSTRAINT ck_analytics_reports_2 CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end >= period_start)))),
    CONSTRAINT ck_analytics_reports_3 CHECK (((((status)::text = 'generated'::text) AND (generated_at IS NOT NULL)) OR (((status)::text <> 'generated'::text) AND (generated_at IS NULL)))),
    CONSTRAINT pg_unsigned_generated_by CHECK ((generated_by >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN analytics_reports.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.analytics_reports.id IS 'Report key.';


--
-- Name: COLUMN analytics_reports.generated_by; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.analytics_reports.generated_by IS 'Authorized staff account.';


--
-- Name: COLUMN analytics_reports.period_start; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.analytics_reports.period_start IS 'Optional inclusive start.';


--
-- Name: COLUMN analytics_reports.period_end; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.analytics_reports.period_end IS 'Optional inclusive end.';


--
-- Name: COLUMN analytics_reports.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.analytics_reports.status IS 'pending / generated / failed.';


--
-- Name: COLUMN analytics_reports.generated_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.analytics_reports.generated_at IS 'UTC completion time.';


--
-- Name: COLUMN analytics_reports.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.analytics_reports.created_at IS 'UTC request.';


--
-- Name: analytics_reports_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.analytics_reports ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.analytics_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attraction_schedules; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.attraction_schedules (
    id bigint NOT NULL,
    attraction_id bigint NOT NULL,
    operating_day character varying(80) NOT NULL,
    schedule_text character varying(255) NOT NULL,
    CONSTRAINT pg_unsigned_attraction_id CHECK ((attraction_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN attraction_schedules.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.attraction_schedules.id IS 'Schedule key.';


--
-- Name: COLUMN attraction_schedules.attraction_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.attraction_schedules.attraction_id IS 'Owning attraction.';


--
-- Name: COLUMN attraction_schedules.operating_day; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.attraction_schedules.operating_day IS 'Daily or supplied day group.';


--
-- Name: COLUMN attraction_schedules.schedule_text; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.attraction_schedules.schedule_text IS 'Display-only schedule; not bookable time inventory.';


--
-- Name: attraction_schedules_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.attraction_schedules ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.attraction_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attractions; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.attractions (
    listing_id bigint NOT NULL,
    entrance_fee numeric(12,2) DEFAULT NULL::numeric,
    CONSTRAINT ck_attractions_1 CHECK ((entrance_fee >= (0)::numeric)),
    CONSTRAINT pg_unsigned_listing_id CHECK ((listing_id >= 0))
);


--
-- Name: COLUMN attractions.listing_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.attractions.listing_id IS 'Require listing_type=attraction.';


--
-- Name: COLUMN attractions.entrance_fee; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.attractions.entrance_fee IS 'PHP; zero means free; NULL means unknown.';


--
-- Name: auth_sessions; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.auth_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token_hash character(64) NOT NULL,
    login_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    last_seen_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    logout_at timestamp without time zone,
    status character varying(24) DEFAULT 'active'::character varying NOT NULL,
    CONSTRAINT ck_auth_sessions_1 CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'expired'::character varying, 'revoked'::character varying, 'ended'::character varying])::text[]))),
    CONSTRAINT ck_auth_sessions_2 CHECK ((expires_at > login_at)),
    CONSTRAINT ck_auth_sessions_3 CHECK (((logout_at IS NULL) OR (logout_at >= login_at))),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN auth_sessions.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.auth_sessions.id IS 'Session audit key, never itself a bearer credential.';


--
-- Name: COLUMN auth_sessions.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.auth_sessions.user_id IS 'Authenticated account.';


--
-- Name: COLUMN auth_sessions.token_hash; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.auth_sessions.token_hash IS 'SHA-256 of opaque random token; browser receives secure cookie only.';


--
-- Name: COLUMN auth_sessions.login_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.auth_sessions.login_at IS 'UTC start.';


--
-- Name: COLUMN auth_sessions.last_seen_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.auth_sessions.last_seen_at IS 'UTC activity.';


--
-- Name: COLUMN auth_sessions.expires_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.auth_sessions.expires_at IS 'UTC expiry set by backend.';


--
-- Name: COLUMN auth_sessions.logout_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.auth_sessions.logout_at IS 'UTC logout/revocation time.';


--
-- Name: COLUMN auth_sessions.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.auth_sessions.status IS 'active / expired / revoked / ended.';


--
-- Name: auth_sessions_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.auth_sessions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.auth_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: booking_rooms; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.booking_rooms (
    id bigint NOT NULL,
    booking_id bigint NOT NULL,
    room_id bigint NOT NULL,
    nightly_rate numeric(12,2) NOT NULL,
    CONSTRAINT ck_booking_rooms_1 CHECK ((nightly_rate >= (0)::numeric)),
    CONSTRAINT pg_unsigned_booking_id CHECK ((booking_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_room_id CHECK ((room_id >= 0))
);


--
-- Name: COLUMN booking_rooms.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.booking_rooms.id IS 'Allocation key.';


--
-- Name: COLUMN booking_rooms.booking_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.booking_rooms.booking_id IS 'Hotel booking parent.';


--
-- Name: COLUMN booking_rooms.room_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.booking_rooms.room_id IS 'Must belong to booked hotel; transaction rule.';


--
-- Name: COLUMN booking_rooms.nightly_rate; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.booking_rooms.nightly_rate IS 'Agreed PHP nightly rate, independent of later base price changes.';


--
-- Name: booking_rooms_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.booking_rooms ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.booking_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: bookings; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.bookings (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    booking_type character varying(24) NOT NULL,
    guest_name character varying(150) NOT NULL,
    guest_email character varying(254) NOT NULL,
    guest_phone character varying(20) DEFAULT NULL::character varying,
    guest_count smallint NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    hold_expires_at timestamp without time zone,
    idempotency_key character varying(80) NOT NULL,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    updated_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_bookings_1 CHECK (((booking_type)::text = ANY ((ARRAY['hotel'::character varying, 'restaurant'::character varying])::text[]))),
    CONSTRAINT ck_bookings_2 CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'completed'::character varying, 'cancelled'::character varying, 'expired'::character varying])::text[]))),
    CONSTRAINT ck_bookings_3 CHECK ((guest_count > 0)),
    CONSTRAINT ck_bookings_4 CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT ck_bookings_5 CHECK ((((status)::text <> 'pending'::text) OR ((hold_expires_at IS NOT NULL) AND (hold_expires_at > created_at)))),
    CONSTRAINT pg_unsigned_guest_count CHECK ((guest_count >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN bookings.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.id IS 'Booking key.';


--
-- Name: COLUMN bookings.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.user_id IS 'Account making reservation.';


--
-- Name: COLUMN bookings.booking_type; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.booking_type IS 'hotel / restaurant.';


--
-- Name: COLUMN bookings.guest_name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.guest_name IS 'Name snapshot for guest, may differ from account holder.';


--
-- Name: COLUMN bookings.guest_email; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.guest_email IS 'Email snapshot at booking.';


--
-- Name: COLUMN bookings.guest_phone; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.guest_phone IS 'Optional guest contact snapshot.';


--
-- Name: COLUMN bookings.guest_count; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.guest_count IS 'Positive party size.';


--
-- Name: COLUMN bookings.total_amount; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.total_amount IS 'Agreed PHP amount; backend computes and freezes.';


--
-- Name: COLUMN bookings.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.status IS 'pending / confirmed / completed / cancelled / expired.';


--
-- Name: COLUMN bookings.hold_expires_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.hold_expires_at IS 'Required while pending; UTC inventory hold expiry.';


--
-- Name: COLUMN bookings.idempotency_key; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.idempotency_key IS 'Unique request identifier; duplicate submissions return same booking.';


--
-- Name: COLUMN bookings.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.created_at IS 'UTC creation.';


--
-- Name: COLUMN bookings.updated_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.bookings.updated_at IS 'UTC modification.';


--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.bookings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.bookings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: business_listings_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.business_listings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.business_listings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: business_owners; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.business_owners (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    contact_name character varying(150) DEFAULT NULL::character varying,
    contact_email character varying(254) DEFAULT NULL::character varying,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN business_owners.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_owners.id IS 'Owner profile key.';


--
-- Name: COLUMN business_owners.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_owners.user_id IS 'Login identity; require business_owner role.';


--
-- Name: COLUMN business_owners.contact_name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_owners.contact_name IS 'Business-facing contact; may differ from account name.';


--
-- Name: COLUMN business_owners.contact_email; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.business_owners.contact_email IS 'Business-facing contact, not a second login email.';


--
-- Name: business_owners_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.business_owners ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.business_owners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: categories; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.categories (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN categories.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.categories.id IS 'Category key.';


--
-- Name: COLUMN categories.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.categories.name IS 'Category label.';


--
-- Name: COLUMN categories.description; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.categories.description IS 'Category explanation.';


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.categories ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cuisines; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.cuisines (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN cuisines.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.cuisines.id IS 'Cuisine key.';


--
-- Name: COLUMN cuisines.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.cuisines.name IS 'Cuisine label.';


--
-- Name: cuisines_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.cuisines ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.cuisines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: data_sources; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.data_sources (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN data_sources.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.data_sources.id IS 'Source key.';


--
-- Name: COLUMN data_sources.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.data_sources.name IS 'Source label, such as bookings or reviews.';


--
-- Name: data_sources_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.data_sources ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.data_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: destinations_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.destinations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hotel_amenities; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.hotel_amenities (
    hotel_id bigint NOT NULL,
    amenity_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_amenity_id CHECK ((amenity_id >= 0)),
    CONSTRAINT pg_unsigned_hotel_id CHECK ((hotel_id >= 0))
);


--
-- Name: COLUMN hotel_amenities.hotel_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotel_amenities.hotel_id IS 'Composite PK member.';


--
-- Name: COLUMN hotel_amenities.amenity_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotel_amenities.amenity_id IS 'Composite PK member.';


--
-- Name: hotel_bookings; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.hotel_bookings (
    booking_id bigint NOT NULL,
    hotel_id bigint NOT NULL,
    check_in date NOT NULL,
    check_out date NOT NULL,
    CONSTRAINT ck_hotel_bookings_1 CHECK ((check_out > check_in)),
    CONSTRAINT pg_unsigned_booking_id CHECK ((booking_id >= 0)),
    CONSTRAINT pg_unsigned_hotel_id CHECK ((hotel_id >= 0))
);


--
-- Name: COLUMN hotel_bookings.booking_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotel_bookings.booking_id IS 'Require booking_type=hotel.';


--
-- Name: COLUMN hotel_bookings.hotel_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotel_bookings.hotel_id IS 'Booked hotel.';


--
-- Name: COLUMN hotel_bookings.check_in; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotel_bookings.check_in IS 'Local arrival date.';


--
-- Name: COLUMN hotel_bookings.check_out; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotel_bookings.check_out IS 'Local departure date; exclusive end.';


--
-- Name: hotels; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.hotels (
    listing_id bigint NOT NULL,
    check_in_time time without time zone,
    check_out_time time without time zone,
    CONSTRAINT pg_unsigned_listing_id CHECK ((listing_id >= 0))
);


--
-- Name: COLUMN hotels.listing_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotels.listing_id IS 'PK is also listing FK; require listing_type=hotel.';


--
-- Name: COLUMN hotels.check_in_time; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotels.check_in_time IS 'Local hotel time.';


--
-- Name: COLUMN hotels.check_out_time; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.hotels.check_out_time IS 'Local hotel time.';


--
-- Name: login_attempts; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.login_attempts (
    id bigint NOT NULL,
    user_id bigint,
    attempted_email character varying(254) NOT NULL,
    ip_address character varying(45) NOT NULL,
    succeeded smallint DEFAULT 0 NOT NULL,
    attempted_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_login_attempts_1 CHECK ((succeeded = ANY (ARRAY[0, 1]))),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN login_attempts.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.login_attempts.id IS 'Attempt key.';


--
-- Name: COLUMN login_attempts.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.login_attempts.user_id IS 'NULL for unknown account.';


--
-- Name: COLUMN login_attempts.attempted_email; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.login_attempts.attempted_email IS 'Submitted normalized address; restrict access and retention.';


--
-- Name: COLUMN login_attempts.ip_address; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.login_attempts.ip_address IS 'Origin address.';


--
-- Name: COLUMN login_attempts.succeeded; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.login_attempts.succeeded IS '0 / 1.';


--
-- Name: COLUMN login_attempts.attempted_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.login_attempts.attempted_at IS 'UTC time.';


--
-- Name: login_attempts_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.login_attempts ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.login_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: menu_items; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.menu_items (
    id bigint NOT NULL,
    restaurant_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    category character varying(80) DEFAULT NULL::character varying,
    price numeric(12,2) DEFAULT NULL::numeric,
    is_available smallint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_menu_items_1 CHECK ((price >= (0)::numeric)),
    CONSTRAINT ck_menu_items_2 CHECK ((is_available = ANY (ARRAY[0, 1]))),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_restaurant_id CHECK ((restaurant_id >= 0))
);


--
-- Name: COLUMN menu_items.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.menu_items.id IS 'Menu item key.';


--
-- Name: COLUMN menu_items.restaurant_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.menu_items.restaurant_id IS 'Owning restaurant.';


--
-- Name: COLUMN menu_items.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.menu_items.name IS 'Item label.';


--
-- Name: COLUMN menu_items.description; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.menu_items.description IS 'Item description.';


--
-- Name: COLUMN menu_items.category; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.menu_items.category IS 'Display grouping such as mains or desserts.';


--
-- Name: COLUMN menu_items.price; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.menu_items.price IS 'PHP; unknown stays NULL.';


--
-- Name: COLUMN menu_items.is_available; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.menu_items.is_available IS '0 / 1.';


--
-- Name: menu_items_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.menu_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: notifications; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.notifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    message text NOT NULL,
    read_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN notifications.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.notifications.id IS 'Notification key.';


--
-- Name: COLUMN notifications.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.notifications.user_id IS 'Recipient.';


--
-- Name: COLUMN notifications.message; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.notifications.message IS 'Display text.';


--
-- Name: COLUMN notifications.read_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.notifications.read_at IS 'NULL means unread; IsRead is derived.';


--
-- Name: COLUMN notifications.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.notifications.created_at IS 'UTC creation.';


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.notifications ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payments; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.payments (
    id bigint NOT NULL,
    booking_id bigint NOT NULL,
    method character varying(24) NOT NULL,
    provider character varying(80) NOT NULL,
    provider_reference character varying(150) DEFAULT NULL::character varying,
    idempotency_key character varying(80) NOT NULL,
    amount numeric(12,2) NOT NULL,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    is_demo smallint DEFAULT 1 NOT NULL,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    paid_at timestamp without time zone,
    CONSTRAINT ck_payments_1 CHECK (((method)::text = ANY ((ARRAY['gcash'::character varying, 'card'::character varying, 'pay_at_venue'::character varying])::text[]))),
    CONSTRAINT ck_payments_2 CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'succeeded'::character varying, 'failed'::character varying, 'cancelled'::character varying])::text[]))),
    CONSTRAINT ck_payments_3 CHECK ((amount >= (0)::numeric)),
    CONSTRAINT ck_payments_4 CHECK ((is_demo = ANY (ARRAY[0, 1]))),
    CONSTRAINT ck_payments_5 CHECK ((amount > (0)::numeric)),
    CONSTRAINT ck_payments_6 CHECK (((((status)::text = 'succeeded'::text) AND (paid_at IS NOT NULL)) OR (((status)::text <> 'succeeded'::text) AND (paid_at IS NULL)))),
    CONSTRAINT pg_unsigned_booking_id CHECK ((booking_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN payments.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.id IS 'Attempt key.';


--
-- Name: COLUMN payments.booking_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.booking_id IS 'Related reservation.';


--
-- Name: COLUMN payments.method; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.method IS 'gcash / card / pay_at_venue; informational demo values in v1.';


--
-- Name: COLUMN payments.provider; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.provider IS 'demo / venue / configured gateway.';


--
-- Name: COLUMN payments.provider_reference; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.provider_reference IS 'External reference; NULL until available.';


--
-- Name: COLUMN payments.idempotency_key; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.idempotency_key IS 'Unique payment request key.';


--
-- Name: COLUMN payments.amount; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.amount IS 'PHP amount for this attempt.';


--
-- Name: COLUMN payments.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.status IS 'pending / succeeded / failed / cancelled.';


--
-- Name: COLUMN payments.is_demo; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.is_demo IS '0 / 1; demo data excluded from real settlement totals.';


--
-- Name: COLUMN payments.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.created_at IS 'UTC attempt time.';


--
-- Name: COLUMN payments.paid_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.payments.paid_at IS 'UTC confirmed payment time.';


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.payments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: photos; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.photos (
    id bigint NOT NULL,
    destination_id bigint,
    listing_id bigint,
    url character varying(2048) NOT NULL,
    caption character varying(255) DEFAULT NULL::character varying,
    sort_order integer DEFAULT 0 NOT NULL,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_photos_1 CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying])::text[]))),
    CONSTRAINT ck_photos_2 CHECK (((((destination_id IS NOT NULL))::integer + ((listing_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT pg_unsigned_destination_id CHECK ((destination_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_listing_id CHECK ((listing_id >= 0)),
    CONSTRAINT pg_unsigned_sort_order CHECK ((sort_order >= 0))
);


--
-- Name: COLUMN photos.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.photos.id IS 'Image key.';


--
-- Name: COLUMN photos.destination_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.photos.destination_id IS 'Destination image target, mutually exclusive with listing_id.';


--
-- Name: COLUMN photos.listing_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.photos.listing_id IS 'Hotel/restaurant/attraction image target.';


--
-- Name: COLUMN photos.url; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.photos.url IS 'Stored file path or approved URL.';


--
-- Name: COLUMN photos.caption; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.photos.caption IS 'Display caption.';


--
-- Name: COLUMN photos.sort_order; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.photos.sort_order IS 'First approved image is hero; ties resolved by id.';


--
-- Name: COLUMN photos.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.photos.status IS 'pending / approved / rejected.';


--
-- Name: COLUMN photos.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.photos.created_at IS 'UTC upload time.';


--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.photos ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: preferences; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.preferences (
    id bigint NOT NULL,
    category character varying(100) NOT NULL,
    name character varying(100) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN preferences.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.preferences.id IS 'Preference key.';


--
-- Name: COLUMN preferences.category; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.preferences.category IS 'Preference group.';


--
-- Name: COLUMN preferences.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.preferences.name IS 'Preference label.';


--
-- Name: preferences_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.preferences ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: recommendations; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.recommendations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    destination_id bigint NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    recommended_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT pg_unsigned_destination_id CHECK ((destination_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN recommendations.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.recommendations.id IS 'Recommendation event key.';


--
-- Name: COLUMN recommendations.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.recommendations.user_id IS 'Recipient.';


--
-- Name: COLUMN recommendations.destination_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.recommendations.destination_id IS 'Suggested destination.';


--
-- Name: COLUMN recommendations.reason; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.recommendations.reason IS 'Explanation produced by recommendation logic.';


--
-- Name: COLUMN recommendations.recommended_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.recommendations.recommended_at IS 'UTC event time.';


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.recommendations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: refunds; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.refunds (
    id bigint NOT NULL,
    payment_id bigint NOT NULL,
    amount numeric(12,2) NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    provider_reference character varying(150) DEFAULT NULL::character varying,
    idempotency_key character varying(80) NOT NULL,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    refunded_at timestamp without time zone,
    CONSTRAINT ck_refunds_1 CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'succeeded'::character varying, 'failed'::character varying])::text[]))),
    CONSTRAINT ck_refunds_2 CHECK ((amount >= (0)::numeric)),
    CONSTRAINT ck_refunds_3 CHECK ((amount > (0)::numeric)),
    CONSTRAINT ck_refunds_4 CHECK (((((status)::text = 'succeeded'::text) AND (refunded_at IS NOT NULL)) OR (((status)::text <> 'succeeded'::text) AND (refunded_at IS NULL)))),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_payment_id CHECK ((payment_id >= 0))
);


--
-- Name: COLUMN refunds.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.id IS 'Refund key.';


--
-- Name: COLUMN refunds.payment_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.payment_id IS 'Original successful payment.';


--
-- Name: COLUMN refunds.amount; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.amount IS 'PHP refund amount.';


--
-- Name: COLUMN refunds.reason; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.reason IS 'Cancellation or adjustment reason.';


--
-- Name: COLUMN refunds.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.status IS 'pending / succeeded / failed.';


--
-- Name: COLUMN refunds.provider_reference; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.provider_reference IS 'Gateway reference scoped to parent payment.';


--
-- Name: COLUMN refunds.idempotency_key; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.idempotency_key IS 'Retry protection.';


--
-- Name: COLUMN refunds.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.created_at IS 'UTC request.';


--
-- Name: COLUMN refunds.refunded_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.refunds.refunded_at IS 'UTC confirmed refund time.';


--
-- Name: refunds_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.refunds ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.refunds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: report_data_sources; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.report_data_sources (
    report_id bigint NOT NULL,
    data_source_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_data_source_id CHECK ((data_source_id >= 0)),
    CONSTRAINT pg_unsigned_report_id CHECK ((report_id >= 0))
);


--
-- Name: COLUMN report_data_sources.report_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_data_sources.report_id IS 'Composite PK member.';


--
-- Name: COLUMN report_data_sources.data_source_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_data_sources.data_source_id IS 'Composite PK member.';


--
-- Name: report_metrics; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.report_metrics (
    id bigint NOT NULL,
    report_id bigint NOT NULL,
    name character varying(100) NOT NULL,
    value numeric(18,4) NOT NULL,
    unit character varying(40) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_report_id CHECK ((report_id >= 0))
);


--
-- Name: COLUMN report_metrics.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_metrics.id IS 'Metric key.';


--
-- Name: COLUMN report_metrics.report_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_metrics.report_id IS 'Report snapshot.';


--
-- Name: COLUMN report_metrics.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_metrics.name IS 'Metric definition label.';


--
-- Name: COLUMN report_metrics.value; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_metrics.value IS 'Numeric snapshot.';


--
-- Name: COLUMN report_metrics.unit; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_metrics.unit IS 'count / PHP / percent / other documented unit.';


--
-- Name: report_metrics_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.report_metrics ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.report_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: report_report_types; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.report_report_types (
    report_id bigint NOT NULL,
    report_type_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_report_id CHECK ((report_id >= 0)),
    CONSTRAINT pg_unsigned_report_type_id CHECK ((report_type_id >= 0))
);


--
-- Name: COLUMN report_report_types.report_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_report_types.report_id IS 'Composite PK member.';


--
-- Name: COLUMN report_report_types.report_type_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_report_types.report_type_id IS 'Composite PK member.';


--
-- Name: report_types; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.report_types (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN report_types.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_types.id IS 'Type key.';


--
-- Name: COLUMN report_types.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.report_types.name IS 'Type label.';


--
-- Name: report_types_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.report_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.report_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: restaurant_bookings; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.restaurant_bookings (
    booking_id bigint NOT NULL,
    slot_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_booking_id CHECK ((booking_id >= 0)),
    CONSTRAINT pg_unsigned_slot_id CHECK ((slot_id >= 0))
);


--
-- Name: COLUMN restaurant_bookings.booking_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_bookings.booking_id IS 'Require booking_type=restaurant.';


--
-- Name: COLUMN restaurant_bookings.slot_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_bookings.slot_id IS 'Reserved seating slot.';


--
-- Name: restaurant_cuisines; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.restaurant_cuisines (
    restaurant_id bigint NOT NULL,
    cuisine_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_cuisine_id CHECK ((cuisine_id >= 0)),
    CONSTRAINT pg_unsigned_restaurant_id CHECK ((restaurant_id >= 0))
);


--
-- Name: COLUMN restaurant_cuisines.restaurant_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_cuisines.restaurant_id IS 'Composite PK member.';


--
-- Name: COLUMN restaurant_cuisines.cuisine_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_cuisines.cuisine_id IS 'Composite PK member.';


--
-- Name: restaurant_slots; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.restaurant_slots (
    id bigint NOT NULL,
    restaurant_id bigint NOT NULL,
    starts_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    capacity smallint NOT NULL,
    is_open smallint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_restaurant_slots_1 CHECK ((capacity > 0)),
    CONSTRAINT ck_restaurant_slots_2 CHECK ((is_open = ANY (ARRAY[0, 1]))),
    CONSTRAINT ck_restaurant_slots_3 CHECK ((ends_at > starts_at)),
    CONSTRAINT pg_unsigned_capacity CHECK ((capacity >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_restaurant_id CHECK ((restaurant_id >= 0))
);


--
-- Name: COLUMN restaurant_slots.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_slots.id IS 'Slot key.';


--
-- Name: COLUMN restaurant_slots.restaurant_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_slots.restaurant_id IS 'Restaurant.';


--
-- Name: COLUMN restaurant_slots.starts_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_slots.starts_at IS 'UTC slot start; display Asia/Manila.';


--
-- Name: COLUMN restaurant_slots.ends_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_slots.ends_at IS 'UTC slot end.';


--
-- Name: COLUMN restaurant_slots.capacity; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_slots.capacity IS 'Maximum total guests in this slot.';


--
-- Name: COLUMN restaurant_slots.is_open; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurant_slots.is_open IS '0 / 1.';


--
-- Name: restaurant_slots_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.restaurant_slots ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.restaurant_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: restaurants; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.restaurants (
    listing_id bigint NOT NULL,
    operating_hours character varying(255) DEFAULT NULL::character varying,
    reservation_fee numeric(12,2) DEFAULT 0.00 NOT NULL,
    CONSTRAINT ck_restaurants_1 CHECK ((reservation_fee >= (0)::numeric)),
    CONSTRAINT pg_unsigned_listing_id CHECK ((listing_id >= 0))
);


--
-- Name: COLUMN restaurants.listing_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurants.listing_id IS 'Require listing_type=restaurant.';


--
-- Name: COLUMN restaurants.operating_hours; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurants.operating_hours IS 'Human-readable schedule; booking inventory uses slots.';


--
-- Name: COLUMN restaurants.reservation_fee; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.restaurants.reservation_fee IS 'PHP flat fee per reservation; zero is valid, not prototype hardcoded 300.';


--
-- Name: review_comments; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.review_comments (
    id bigint NOT NULL,
    review_id bigint NOT NULL,
    user_id bigint NOT NULL,
    body text NOT NULL,
    status character varying(24) DEFAULT 'published'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_review_comments_1 CHECK (((status)::text = ANY ((ARRAY['published'::character varying, 'hidden'::character varying, 'pending'::character varying])::text[]))),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_review_id CHECK ((review_id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN review_comments.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.review_comments.id IS 'Comment key.';


--
-- Name: COLUMN review_comments.review_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.review_comments.review_id IS 'Parent review.';


--
-- Name: COLUMN review_comments.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.review_comments.user_id IS 'Registered author.';


--
-- Name: COLUMN review_comments.body; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.review_comments.body IS 'Comment text.';


--
-- Name: COLUMN review_comments.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.review_comments.status IS 'published / hidden / pending.';


--
-- Name: COLUMN review_comments.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.review_comments.created_at IS 'UTC submission.';


--
-- Name: review_comments_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.review_comments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.review_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: review_tags; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.review_tags (
    review_id bigint NOT NULL,
    tag_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_review_id CHECK ((review_id >= 0)),
    CONSTRAINT pg_unsigned_tag_id CHECK ((tag_id >= 0))
);


--
-- Name: COLUMN review_tags.review_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.review_tags.review_id IS 'Composite PK member.';


--
-- Name: COLUMN review_tags.tag_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.review_tags.tag_id IS 'Composite PK member.';


--
-- Name: reviews; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.reviews (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    destination_id bigint,
    listing_id bigint,
    rating smallint NOT NULL,
    review_text text,
    status character varying(24) DEFAULT 'published'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    updated_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_reviews_1 CHECK (((status)::text = ANY ((ARRAY['published'::character varying, 'hidden'::character varying, 'pending'::character varying])::text[]))),
    CONSTRAINT ck_reviews_2 CHECK (((((destination_id IS NOT NULL))::integer + ((listing_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT ck_reviews_3 CHECK (((rating >= 1) AND (rating <= 5))),
    CONSTRAINT pg_unsigned_destination_id CHECK ((destination_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_listing_id CHECK ((listing_id >= 0)),
    CONSTRAINT pg_unsigned_rating CHECK ((rating >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN reviews.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.id IS 'Review key.';


--
-- Name: COLUMN reviews.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.user_id IS 'Registered author.';


--
-- Name: COLUMN reviews.destination_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.destination_id IS 'Exclusive destination target.';


--
-- Name: COLUMN reviews.listing_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.listing_id IS 'Exclusive business target.';


--
-- Name: COLUMN reviews.rating; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.rating IS 'Integer 1 through 5.';


--
-- Name: COLUMN reviews.review_text; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.review_text IS 'NULL for rating-only submission; avoids separate competing score table.';


--
-- Name: COLUMN reviews.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.status IS 'published / hidden / pending.';


--
-- Name: COLUMN reviews.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.created_at IS 'UTC submission.';


--
-- Name: COLUMN reviews.updated_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.reviews.updated_at IS 'UTC edit.';


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.reviews ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: roles; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.roles (
    id bigint NOT NULL,
    name character varying(40) NOT NULL,
    CONSTRAINT ck_roles_1 CHECK (((name)::text = ANY ((ARRAY['traveler'::character varying, 'business_owner'::character varying, 'admin'::character varying, 'moderator'::character varying, 'analyst'::character varying, 'support'::character varying])::text[]))),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN roles.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.roles.id IS 'Role key.';


--
-- Name: COLUMN roles.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.roles.name IS 'traveler / business_owner / admin / moderator / analyst / support.';


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.roles ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rooms; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.rooms (
    id bigint NOT NULL,
    hotel_id bigint NOT NULL,
    room_number character varying(20) NOT NULL,
    room_type character varying(80) NOT NULL,
    max_guests smallint NOT NULL,
    base_nightly_rate numeric(12,2) DEFAULT NULL::numeric,
    operational_status character varying(24) DEFAULT 'unavailable'::character varying NOT NULL,
    CONSTRAINT ck_rooms_1 CHECK (((operational_status)::text = ANY ((ARRAY['available'::character varying, 'maintenance'::character varying, 'unavailable'::character varying])::text[]))),
    CONSTRAINT ck_rooms_2 CHECK ((max_guests > 0)),
    CONSTRAINT ck_rooms_3 CHECK ((base_nightly_rate >= (0)::numeric)),
    CONSTRAINT pg_unsigned_hotel_id CHECK ((hotel_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_max_guests CHECK ((max_guests >= 0))
);


--
-- Name: COLUMN rooms.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.rooms.id IS 'Physical room key.';


--
-- Name: COLUMN rooms.hotel_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.rooms.hotel_id IS 'Owning hotel.';


--
-- Name: COLUMN rooms.room_number; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.rooms.room_number IS 'Hotel-local room label.';


--
-- Name: COLUMN rooms.room_type; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.rooms.room_type IS 'Descriptive type; does not alone determine rate.';


--
-- Name: COLUMN rooms.max_guests; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.rooms.max_guests IS 'Positive occupancy capacity.';


--
-- Name: COLUMN rooms.base_nightly_rate; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.rooms.base_nightly_rate IS 'PHP; NULL means unknown and not bookable.';


--
-- Name: COLUMN rooms.operational_status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.rooms.operational_status IS 'available / maintenance / unavailable; reservations are date-based.';


--
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.rooms ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: search_history; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.search_history (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    trip_id bigint,
    keyword character varying(255) NOT NULL,
    filter_text text,
    searched_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_trip_id CHECK ((trip_id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN search_history.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.search_history.id IS 'Search event key.';


--
-- Name: COLUMN search_history.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.search_history.user_id IS 'Registered searcher.';


--
-- Name: COLUMN search_history.trip_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.search_history.trip_id IS 'Optional plan context; must belong to same user.';


--
-- Name: COLUMN search_history.keyword; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.search_history.keyword IS 'Search text; empty string allowed for filter-only search.';


--
-- Name: COLUMN search_history.filter_text; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.search_history.filter_text IS 'Opaque historical filter snapshot; no FK lists inside it.';


--
-- Name: COLUMN search_history.searched_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.search_history.searched_at IS 'UTC event time.';


--
-- Name: search_history_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.search_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.search_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: session_ips; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.session_ips (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    ip_address character varying(45) NOT NULL,
    first_seen_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_session_id CHECK ((session_id >= 0))
);


--
-- Name: COLUMN session_ips.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.session_ips.id IS 'Observation key.';


--
-- Name: COLUMN session_ips.session_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.session_ips.session_id IS 'Session.';


--
-- Name: COLUMN session_ips.ip_address; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.session_ips.ip_address IS 'IPv4 or IPv6 validated by backend.';


--
-- Name: COLUMN session_ips.first_seen_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.session_ips.first_seen_at IS 'UTC first observation.';


--
-- Name: session_ips_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.session_ips ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.session_ips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tags; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.tags (
    id bigint NOT NULL,
    name character varying(80) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN tags.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.tags.id IS 'Tag key.';


--
-- Name: COLUMN tags.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.tags.name IS 'Tag label.';


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.tags ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transport_provider_contacts; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.transport_provider_contacts (
    id bigint NOT NULL,
    provider_id bigint NOT NULL,
    phone_number character varying(20) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_provider_id CHECK ((provider_id >= 0))
);


--
-- Name: COLUMN transport_provider_contacts.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transport_provider_contacts.id IS 'Contact key.';


--
-- Name: COLUMN transport_provider_contacts.provider_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transport_provider_contacts.provider_id IS 'Provider.';


--
-- Name: COLUMN transport_provider_contacts.phone_number; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transport_provider_contacts.phone_number IS 'Text phone number.';


--
-- Name: transport_provider_contacts_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.transport_provider_contacts ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.transport_provider_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transport_providers; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.transport_providers (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    company_name character varying(150) NOT NULL,
    description text,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_owner_id CHECK ((owner_id >= 0))
);


--
-- Name: COLUMN transport_providers.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transport_providers.id IS 'Provider key.';


--
-- Name: COLUMN transport_providers.owner_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transport_providers.owner_id IS 'Accountable portal owner; new link.';


--
-- Name: COLUMN transport_providers.company_name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transport_providers.company_name IS 'Company display name; not globally unique by assumption.';


--
-- Name: COLUMN transport_providers.description; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transport_providers.description IS 'Company description.';


--
-- Name: transport_providers_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.transport_providers ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.transport_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transportation_services; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.transportation_services (
    id bigint NOT NULL,
    provider_id bigint NOT NULL,
    destination_id bigint NOT NULL,
    transport_type character varying(50) NOT NULL,
    service_name character varying(150) NOT NULL,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    CONSTRAINT ck_transportation_services_1 CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying, 'inactive'::character varying])::text[]))),
    CONSTRAINT pg_unsigned_destination_id CHECK ((destination_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_provider_id CHECK ((provider_id >= 0))
);


--
-- Name: COLUMN transportation_services.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transportation_services.id IS 'Service key.';


--
-- Name: COLUMN transportation_services.provider_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transportation_services.provider_id IS 'Provider.';


--
-- Name: COLUMN transportation_services.destination_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transportation_services.destination_id IS 'Destination served.';


--
-- Name: COLUMN transportation_services.transport_type; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transportation_services.transport_type IS 'Bus, van, taxi or other validated label.';


--
-- Name: COLUMN transportation_services.service_name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transportation_services.service_name IS 'Distinguishes multiple services by one provider.';


--
-- Name: COLUMN transportation_services.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.transportation_services.status IS 'pending / approved / rejected / inactive.';


--
-- Name: transportation_services_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.transportation_services ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.transportation_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: trip_items; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.trip_items (
    id bigint NOT NULL,
    trip_id bigint NOT NULL,
    destination_id bigint,
    listing_id bigint,
    activity character varying(255) NOT NULL,
    sequence_number integer NOT NULL,
    planned_date date,
    planned_time time without time zone,
    notes text,
    status character varying(24) DEFAULT 'planned'::character varying NOT NULL,
    CONSTRAINT ck_trip_items_1 CHECK (((status)::text = ANY ((ARRAY['planned'::character varying, 'completed'::character varying, 'skipped'::character varying])::text[]))),
    CONSTRAINT ck_trip_items_2 CHECK ((sequence_number > 0)),
    CONSTRAINT ck_trip_items_3 CHECK (((((destination_id IS NOT NULL))::integer + ((listing_id IS NOT NULL))::integer) <= 1)),
    CONSTRAINT ck_trip_items_4 CHECK (((planned_time IS NULL) OR (planned_date IS NOT NULL))),
    CONSTRAINT pg_unsigned_destination_id CHECK ((destination_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_listing_id CHECK ((listing_id >= 0)),
    CONSTRAINT pg_unsigned_sequence_number CHECK ((sequence_number >= 0)),
    CONSTRAINT pg_unsigned_trip_id CHECK ((trip_id >= 0))
);


--
-- Name: COLUMN trip_items.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.id IS 'Trip item key.';


--
-- Name: COLUMN trip_items.trip_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.trip_id IS 'Parent trip.';


--
-- Name: COLUMN trip_items.destination_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.destination_id IS 'Destination stop; exclusive with listing_id.';


--
-- Name: COLUMN trip_items.listing_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.listing_id IS 'Specific venue stop; destination obtained through listing.';


--
-- Name: COLUMN trip_items.activity; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.activity IS 'User-entered activity title; permits freeform items with no target.';


--
-- Name: COLUMN trip_items.sequence_number; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.sequence_number IS 'Unique ordering within entire trip.';


--
-- Name: COLUMN trip_items.planned_date; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.planned_date IS 'Local schedule date, within trip dates when scheduled.';


--
-- Name: COLUMN trip_items.planned_time; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.planned_time IS 'Local time; date required if time supplied.';


--
-- Name: COLUMN trip_items.notes; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.notes IS 'Optional details.';


--
-- Name: COLUMN trip_items.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trip_items.status IS 'planned / completed / skipped.';


--
-- Name: trip_items_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.trip_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.trip_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: trips; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.trips (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    start_date date,
    end_date date,
    budget numeric(12,2) DEFAULT NULL::numeric,
    status character varying(24) DEFAULT 'draft'::character varying NOT NULL,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    updated_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT ck_trips_1 CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'planned'::character varying, 'ongoing'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[]))),
    CONSTRAINT ck_trips_2 CHECK ((budget >= (0)::numeric)),
    CONSTRAINT ck_trips_3 CHECK ((((start_date IS NULL) AND (end_date IS NULL)) OR ((start_date IS NOT NULL) AND (end_date IS NOT NULL) AND (end_date >= start_date)))),
    CONSTRAINT ck_trips_4 CHECK ((((status)::text = 'draft'::text) OR ((start_date IS NOT NULL) AND (end_date IS NOT NULL)))),
    CONSTRAINT ck_trips_5 CHECK (((((status)::text = 'completed'::text) AND (completed_at IS NOT NULL)) OR (((status)::text <> 'completed'::text) AND (completed_at IS NULL)))),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN trips.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.id IS 'Trip key.';


--
-- Name: COLUMN trips.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.user_id IS 'Plan owner.';


--
-- Name: COLUMN trips.name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.name IS 'Trip name.';


--
-- Name: COLUMN trips.start_date; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.start_date IS 'Local date; both dates may be unknown for a draft.';


--
-- Name: COLUMN trips.end_date; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.end_date IS 'Local inclusive final day.';


--
-- Name: COLUMN trips.budget; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.budget IS 'PHP planning budget.';


--
-- Name: COLUMN trips.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.status IS 'draft / planned / ongoing / completed / cancelled.';


--
-- Name: COLUMN trips.completed_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.completed_at IS 'UTC completion event.';


--
-- Name: COLUMN trips.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.created_at IS 'UTC creation.';


--
-- Name: COLUMN trips.updated_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.trips.updated_at IS 'UTC modification.';


--
-- Name: trips_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.trips ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.trips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_phones; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.user_phones (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    phone_number character varying(20) NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN user_phones.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_phones.id IS 'Phone key.';


--
-- Name: COLUMN user_phones.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_phones.user_id IS 'Account owner.';


--
-- Name: COLUMN user_phones.phone_number; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_phones.phone_number IS 'Text preserves leading zero or country prefix.';


--
-- Name: user_phones_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.user_phones ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.user_phones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_preferences; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.user_preferences (
    user_id bigint NOT NULL,
    preference_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_preference_id CHECK ((preference_id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN user_preferences.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_preferences.user_id IS 'Composite PK member.';


--
-- Name: COLUMN user_preferences.preference_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_preferences.preference_id IS 'Composite PK member.';


--
-- Name: user_reports; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.user_reports (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    report_type character varying(50) NOT NULL,
    description text NOT NULL,
    listing_id bigint,
    destination_id bigint,
    review_id bigint,
    photo_id bigint,
    transport_id bigint,
    status character varying(24) DEFAULT 'pending'::character varying NOT NULL,
    assigned_to bigint,
    submitted_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    resolved_at timestamp without time zone,
    CONSTRAINT ck_user_reports_1 CHECK (((report_type)::text = ANY ((ARRAY['bug'::character varying, 'listing'::character varying, 'destination'::character varying, 'review'::character varying, 'photo'::character varying, 'transport'::character varying, 'other'::character varying])::text[]))),
    CONSTRAINT ck_user_reports_2 CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'resolved'::character varying])::text[]))),
    CONSTRAINT ck_user_reports_3 CHECK ((((((((listing_id IS NOT NULL))::integer + ((destination_id IS NOT NULL))::integer) + ((review_id IS NOT NULL))::integer) + ((photo_id IS NOT NULL))::integer) + ((transport_id IS NOT NULL))::integer) <= 1)),
    CONSTRAINT ck_user_reports_4 CHECK (((((status)::text = 'resolved'::text) AND (resolved_at IS NOT NULL)) OR (((status)::text <> 'resolved'::text) AND (resolved_at IS NULL)))),
    CONSTRAINT pg_unsigned_assigned_to CHECK ((assigned_to >= 0)),
    CONSTRAINT pg_unsigned_destination_id CHECK ((destination_id >= 0)),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_listing_id CHECK ((listing_id >= 0)),
    CONSTRAINT pg_unsigned_photo_id CHECK ((photo_id >= 0)),
    CONSTRAINT pg_unsigned_review_id CHECK ((review_id >= 0)),
    CONSTRAINT pg_unsigned_transport_id CHECK ((transport_id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN user_reports.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.id IS 'Report key.';


--
-- Name: COLUMN user_reports.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.user_id IS 'Reporter.';


--
-- Name: COLUMN user_reports.report_type; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.report_type IS 'bug / listing / destination / review / photo / transport / other.';


--
-- Name: COLUMN user_reports.description; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.description IS 'Issue details.';


--
-- Name: COLUMN user_reports.listing_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.listing_id IS 'Optional reported listing.';


--
-- Name: COLUMN user_reports.destination_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.destination_id IS 'Optional reported destination.';


--
-- Name: COLUMN user_reports.review_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.review_id IS 'Optional reported review.';


--
-- Name: COLUMN user_reports.photo_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.photo_id IS 'Optional reported photo.';


--
-- Name: COLUMN user_reports.transport_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.transport_id IS 'Optional reported transport service.';


--
-- Name: COLUMN user_reports.status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.status IS 'pending / resolved.';


--
-- Name: COLUMN user_reports.assigned_to; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.assigned_to IS 'Staff account; backend validates role.';


--
-- Name: COLUMN user_reports.submitted_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.submitted_at IS 'UTC report time.';


--
-- Name: COLUMN user_reports.resolved_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_reports.resolved_at IS 'UTC resolution time.';


--
-- Name: user_reports_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.user_reports ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.user_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_roles; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_role_id CHECK ((role_id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN user_roles.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_roles.user_id IS 'Composite PK member.';


--
-- Name: COLUMN user_roles.role_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.user_roles.role_id IS 'Composite PK member.';


--
-- Name: users; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.users (
    id bigint NOT NULL,
    full_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    password_hash character varying(255),
    address character varying(255) DEFAULT NULL::character varying,
    avatar_url character varying(2048) DEFAULT NULL::character varying,
    account_status character varying(24) DEFAULT 'active'::character varying NOT NULL,
    email_verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    updated_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    auth_user_id uuid,
    avatar_object_path text,
    CONSTRAINT ck_users_1 CHECK (((account_status)::text = ANY ((ARRAY['active'::character varying, 'suspended'::character varying, 'closed'::character varying])::text[]))),
    CONSTRAINT ck_users_avatar_path CHECK (((avatar_object_path IS NULL) OR ((auth_user_id IS NOT NULL) AND (split_part(avatar_object_path, '/'::text, 1) = (auth_user_id)::text) AND (length(split_part(avatar_object_path, '/'::text, 2)) > 0)))),
    CONSTRAINT ck_users_login_identity CHECK (((password_hash IS NOT NULL) OR (auth_user_id IS NOT NULL))),
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0))
);


--
-- Name: COLUMN users.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.id IS 'Surrogate account key.';


--
-- Name: COLUMN users.full_name; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.full_name IS 'Display name; not a unique username.';


--
-- Name: COLUMN users.email; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.email IS 'Normalize trim/lowercase before write; unique account address.';


--
-- Name: COLUMN users.password_hash; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.password_hash IS 'One-way hash generated by backend; never import demo plaintext.';


--
-- Name: COLUMN users.address; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.address IS 'Optional profile address.';


--
-- Name: COLUMN users.avatar_url; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.avatar_url IS 'Optional profile image path.';


--
-- Name: COLUMN users.account_status; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.account_status IS 'active / suspended / closed.';


--
-- Name: COLUMN users.email_verified_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.email_verified_at IS 'UTC verification time.';


--
-- Name: COLUMN users.created_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.created_at IS 'UTC account creation.';


--
-- Name: COLUMN users.updated_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.users.updated_at IS 'Backend updates on modification.';


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.users ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: wishlist_destinations; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.wishlist_destinations (
    wishlist_id bigint NOT NULL,
    destination_id bigint NOT NULL,
    added_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'::text) NOT NULL,
    CONSTRAINT pg_unsigned_destination_id CHECK ((destination_id >= 0)),
    CONSTRAINT pg_unsigned_wishlist_id CHECK ((wishlist_id >= 0))
);


--
-- Name: COLUMN wishlist_destinations.wishlist_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.wishlist_destinations.wishlist_id IS 'Composite PK member.';


--
-- Name: COLUMN wishlist_destinations.destination_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.wishlist_destinations.destination_id IS 'Composite PK member.';


--
-- Name: COLUMN wishlist_destinations.added_at; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.wishlist_destinations.added_at IS 'UTC save time.';


--
-- Name: wishlists; Type: TABLE; Schema: travelmate; Owner: -
--

CREATE TABLE travelmate.wishlists (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    CONSTRAINT pg_unsigned_id CHECK ((id >= 0)),
    CONSTRAINT pg_unsigned_user_id CHECK ((user_id >= 0))
);


--
-- Name: COLUMN wishlists.id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.wishlists.id IS 'Wishlist key.';


--
-- Name: COLUMN wishlists.user_id; Type: COMMENT; Schema: travelmate; Owner: -
--

COMMENT ON COLUMN travelmate.wishlists.user_id IS 'Wishlist owner.';


--
-- Name: wishlists_id_seq; Type: SEQUENCE; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.wishlists ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME travelmate.wishlists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at, custom_claims_allowlist) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
47d47417-d603-4ff5-bd49-6b4616d425e2	\N	0f7c910b-3dca-409f-a313-b98499026e50	s256	oUXHUB6AuiXAw6Ic9gRcVPljJyFbi87Gry7IhBbyLcM	google			2026-09-16 16:00:28.039067+00	2026-09-16 16:00:28.039067+00	oauth	\N	\N	http://localhost:5173/	\N	\N	f
05509983-f7e8-4463-b65d-280f547a0b50	\N	122419b3-f6e0-4ac2-90ec-953ae0881a39	s256	cqBp2pHD07fwE7ppBp1OX9Cb9vbk_n_rJk58nAg_kSM	google			2026-09-16 16:01:20.281021+00	2026-09-16 16:01:20.281021+00	oauth	\N	\N	http://localhost:5173/	\N	\N	f
50ba0f98-04eb-49dd-abb3-09904ccd1e04	\N	22a527cf-62f2-4b50-9b2d-b120e43d6195	s256	B3BN5ov_x2de7Dqj3n5YChpec4UoKFNSCKOVNsEg-uU	google			2026-09-18 03:25:52.610498+00	2026-09-18 03:25:52.610498+00	oauth	\N	\N	http://localhost:5173/	\N	\N	f
149e287a-812d-4f2e-a4cc-03b626503607	\N	1d9f93cf-8531-4870-a272-e76ada368ff4	s256	EKMJBtwjQ3xCKkCHQXovriWrgKSekrpWgmZTJHLP8f8	google			2026-10-05 03:14:40.647849+00	2026-10-05 03:14:40.647849+00	oauth	\N	\N	http://localhost:5173/	\N	\N	f
4aa9e1e7-981d-4d1a-8676-44ac3924520c	\N	b26ed9b3-097d-4ad7-a107-63b62a5d53ac	s256	SP4ZSBp38OOPz0cYjplk3XPJohYVfsngKup1RrEzFPQ	google			2026-10-01 13:40:54.356272+00	2026-10-01 13:40:54.356272+00	oauth	\N	\N	http://localhost:5173/	\N	\N	f
7647a54d-2ea3-4acb-931f-930257b7a265	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	d7ff84e7-bf5b-47d8-9362-cc81b7572369	s256	Z2A7hAQLK-VSUlrR8fIPqldyU_o2XP37vLCoFtKuhPU	google	ya29.a0AX07Cmt83BVzcbRrnA8IM_NALxRXAIh7rEiEcb5uRT8bonogS-b0XC9RszHAG0bCZzl4CwJ2TVLxp2AUippJucVjXpVPl-m_iYEe0etEb3q74sRPPJgUkidANO0uvUmSdXUPKSwXQ860uYuuZXF1JcwtHq7lGDb16XL3aRrf-dadmcz6lMw2HrpUPjJc1Q9PPKAygut3bH_HgF2juS93l8heMixF8DyaXY75Vy3NP7kL5liNQsSCzozUdMWYxOSd7nUzKHPlHT4C8D1OdEfe9X2jL5YaCgYKATwSARISFQHGX2MiDP1zcVOODAaRbqekLwNh2w0290		2026-10-03 13:40:21.307721+00	2026-10-03 13:40:24.894845+00	oauth	2026-10-03 13:40:24.894797+00	\N	http://localhost:5173/	\N	\N	f
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
110063283083751756873	1f35520c-9114-4cbb-b369-86d2b431c76e	{"iss": "https://accounts.google.com", "sub": "110063283083751756873", "name": "Jonas Loyola", "email": "jonasloyola6@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIAIk_55eOLUvT2r8SG4klJVKjdcL8nyZTduRQF-oa0yzCkbsl2=s96-c", "full_name": "Jonas Loyola", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIAIk_55eOLUvT2r8SG4klJVKjdcL8nyZTduRQF-oa0yzCkbsl2=s96-c", "provider_id": "110063283083751756873", "email_verified": true, "phone_verified": false}	google	2026-09-16 16:01:32.494781+00	2026-09-16 16:01:32.49483+00	2026-09-30 12:00:14.018102+00	bc27ca0b-8931-45f2-94a0-e701a0fe0ef4
103978578045383846512	423028d7-3027-4ae9-947c-d5428e29b88f	{"iss": "https://accounts.google.com", "sub": "103978578045383846512", "name": "dianne joy pimentel", "email": "diannejoypimentel@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJS12m6vPbBURYhdKqA_jpni17DtC-wLkUK1MnmF88bKQfIWA=s96-c", "full_name": "dianne joy pimentel", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJS12m6vPbBURYhdKqA_jpni17DtC-wLkUK1MnmF88bKQfIWA=s96-c", "provider_id": "103978578045383846512", "email_verified": true, "phone_verified": false}	google	2026-09-17 04:06:55.000994+00	2026-09-17 04:06:55.001042+00	2026-09-17 04:10:36.399039+00	f7ee6de9-b5d8-406e-9afd-5454d9034391
108928656906286175879	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	{"iss": "https://accounts.google.com", "sub": "108928656906286175879", "name": "Subala, Shawn Marion V.", "email": "subalashawn2006@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocI2oHqSxquOuqjBB9Hbjb379fSVwtu3KRpIXbmqyDg6HBHNPe-s3A=s96-c", "full_name": "Subala, Shawn Marion V.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocI2oHqSxquOuqjBB9Hbjb379fSVwtu3KRpIXbmqyDg6HBHNPe-s3A=s96-c", "provider_id": "108928656906286175879", "email_verified": true, "phone_verified": false}	google	2026-09-17 06:36:51.587164+00	2026-09-17 06:36:51.587214+00	2026-09-17 07:04:56.131816+00	0afa8dfc-58d7-467b-a35a-a91bc30332f8
112756915146643872138	71f2a91a-e5e2-4a42-b830-2eea593be359	{"iss": "https://accounts.google.com", "sub": "112756915146643872138", "name": "Nasly H", "email": "hnasly30@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJokH424846F18tD24tgzcJs50-14lQdTFOuxSHfCGP8R9Pqyk=s96-c", "full_name": "Nasly H", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJokH424846F18tD24tgzcJs50-14lQdTFOuxSHfCGP8R9Pqyk=s96-c", "provider_id": "112756915146643872138", "email_verified": true, "phone_verified": false}	google	2026-09-17 13:06:38.066649+00	2026-09-17 13:06:38.066714+00	2026-09-17 13:06:38.066714+00	4bed3bfc-3cbc-45fc-955d-b5e8fbc8b712
08c59a01-6bf6-44c6-b6f1-de0131a3dccf	08c59a01-6bf6-44c6-b6f1-de0131a3dccf	{"sub": "08c59a01-6bf6-44c6-b6f1-de0131a3dccf", "email": "tm-demo-owner-01@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:43.140664+00	2026-09-18 01:23:43.140725+00	2026-09-18 01:23:43.140725+00	5ddd2fe9-b2f1-44b8-82f1-64d5ccbcce0f
e5931678-254c-4abf-85fa-71e667896a41	e5931678-254c-4abf-85fa-71e667896a41	{"sub": "e5931678-254c-4abf-85fa-71e667896a41", "email": "tm-demo-owner-02@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:43.469506+00	2026-09-18 01:23:43.46956+00	2026-09-18 01:23:43.46956+00	d0d2a6b2-1327-462b-afed-4d05a2cdec12
41942500-0b1b-4215-a759-29ffd1733f27	41942500-0b1b-4215-a759-29ffd1733f27	{"sub": "41942500-0b1b-4215-a759-29ffd1733f27", "email": "tm-demo-owner-03@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:43.75847+00	2026-09-18 01:23:43.758523+00	2026-09-18 01:23:43.758523+00	4f2a82ff-ee76-4c4c-aba4-15e5be630187
fe304e3d-1946-46cb-bb2d-77f8702c0f05	fe304e3d-1946-46cb-bb2d-77f8702c0f05	{"sub": "fe304e3d-1946-46cb-bb2d-77f8702c0f05", "email": "tm-demo-owner-04@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:44.046364+00	2026-09-18 01:23:44.046417+00	2026-09-18 01:23:44.046417+00	3fef3f95-9e5b-49f4-aad4-a21eea33cf67
392e6791-10b8-4c3d-8800-9efe6d29f8b2	392e6791-10b8-4c3d-8800-9efe6d29f8b2	{"sub": "392e6791-10b8-4c3d-8800-9efe6d29f8b2", "email": "tm-demo-owner-05@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:44.341356+00	2026-09-18 01:23:44.341401+00	2026-09-18 01:23:44.341401+00	7a5b2acc-dd66-4ee2-bb2c-0075259973af
8e59134a-da94-4cd6-9eb7-ff46c9d56195	8e59134a-da94-4cd6-9eb7-ff46c9d56195	{"sub": "8e59134a-da94-4cd6-9eb7-ff46c9d56195", "email": "tm-demo-owner-06@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:44.626725+00	2026-09-18 01:23:44.626777+00	2026-09-18 01:23:44.626777+00	caf18566-fc98-43b4-930c-e903584b4b8f
34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	{"sub": "34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a", "email": "tm-demo-owner-07@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:44.910708+00	2026-09-18 01:23:44.91076+00	2026-09-18 01:23:44.91076+00	0f3bf3c1-984e-4fce-ab1e-4a301810adba
6a11f3df-d69c-4148-80ee-88f1f7c95e2a	6a11f3df-d69c-4148-80ee-88f1f7c95e2a	{"sub": "6a11f3df-d69c-4148-80ee-88f1f7c95e2a", "email": "tm-demo-owner-08@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:45.194388+00	2026-09-18 01:23:45.194452+00	2026-09-18 01:23:45.194452+00	6096de44-9778-4f94-9f86-2e27369971c4
9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	{"sub": "9cb2f62f-5cab-43f3-9c64-dde893e6e4bb", "email": "tm-demo-owner-09@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:45.487806+00	2026-09-18 01:23:45.487854+00	2026-09-18 01:23:45.487854+00	75042327-81fb-480a-905a-2733e3e2ce68
c4a4841a-aa8a-4de6-b83c-b2bd6203042c	c4a4841a-aa8a-4de6-b83c-b2bd6203042c	{"sub": "c4a4841a-aa8a-4de6-b83c-b2bd6203042c", "email": "tm-demo-owner-10@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:45.779745+00	2026-09-18 01:23:45.779793+00	2026-09-18 01:23:45.779793+00	68f1e803-67e2-4d0b-bb43-005e0abd1084
8eba38fb-47ef-4be9-b26e-b109bccf0031	8eba38fb-47ef-4be9-b26e-b109bccf0031	{"sub": "8eba38fb-47ef-4be9-b26e-b109bccf0031", "email": "tm-demo-owner-11@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:46.059275+00	2026-09-18 01:23:46.059322+00	2026-09-18 01:23:46.059322+00	9d75cd3c-e26b-4b1a-9480-c4b98b87e360
5b305524-490a-4334-831e-b46d622648a8	5b305524-490a-4334-831e-b46d622648a8	{"sub": "5b305524-490a-4334-831e-b46d622648a8", "email": "tm-demo-owner-12@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:46.337709+00	2026-09-18 01:23:46.337763+00	2026-09-18 01:23:46.337763+00	4e5ee67e-df6a-4eab-a8c0-4c3c08e240a8
1ef0a385-782d-4808-999a-58733a4b209d	1ef0a385-782d-4808-999a-58733a4b209d	{"sub": "1ef0a385-782d-4808-999a-58733a4b209d", "email": "tm-demo-owner-13@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:46.618014+00	2026-09-18 01:23:46.618069+00	2026-09-18 01:23:46.618069+00	58e08804-f7c2-43ad-a188-e454b154dc0b
0ea90927-1b7e-4674-a3df-092d82395d70	0ea90927-1b7e-4674-a3df-092d82395d70	{"sub": "0ea90927-1b7e-4674-a3df-092d82395d70", "email": "tm-demo-owner-14@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:46.9038+00	2026-09-18 01:23:46.903851+00	2026-09-18 01:23:46.903851+00	8e675087-4615-485c-bf74-ea6f8d5b6e72
df48bcda-05d5-4d27-8b94-0fec879a5ab8	df48bcda-05d5-4d27-8b94-0fec879a5ab8	{"sub": "df48bcda-05d5-4d27-8b94-0fec879a5ab8", "email": "tm-demo-owner-15@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:47.179738+00	2026-09-18 01:23:47.179793+00	2026-09-18 01:23:47.179793+00	4bfd023d-e54f-41b2-9459-0e4f0faa69af
2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	{"sub": "2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3", "email": "tm-demo-traveler-01@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:47.474877+00	2026-09-18 01:23:47.474926+00	2026-09-18 01:23:47.474926+00	e2e4b604-42b2-428b-ae75-3eee624da92e
7562e428-178e-430b-af77-04f4a7fbaa0a	7562e428-178e-430b-af77-04f4a7fbaa0a	{"sub": "7562e428-178e-430b-af77-04f4a7fbaa0a", "email": "tm-demo-traveler-02@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:47.749096+00	2026-09-18 01:23:47.749143+00	2026-09-18 01:23:47.749143+00	07a5fbdb-1fcc-4a8f-a378-ea702e830668
9b8013fc-8493-409a-8f9f-f563b7d7c315	9b8013fc-8493-409a-8f9f-f563b7d7c315	{"sub": "9b8013fc-8493-409a-8f9f-f563b7d7c315", "email": "tm-demo-traveler-03@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:48.025131+00	2026-09-18 01:23:48.025198+00	2026-09-18 01:23:48.025198+00	a7517165-dcbd-4260-9e91-4060b070f0c1
6d736964-b99f-47cd-a81f-df9940200e61	6d736964-b99f-47cd-a81f-df9940200e61	{"sub": "6d736964-b99f-47cd-a81f-df9940200e61", "email": "tm-demo-traveler-04@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:48.302546+00	2026-09-18 01:23:48.302593+00	2026-09-18 01:23:48.302593+00	b382d5f2-aa92-4cda-a14d-b5850b04a6f3
c4adf4a6-b1f1-45af-8842-27d723b9519c	c4adf4a6-b1f1-45af-8842-27d723b9519c	{"sub": "c4adf4a6-b1f1-45af-8842-27d723b9519c", "email": "tm-demo-traveler-05@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:48.590764+00	2026-09-18 01:23:48.590809+00	2026-09-18 01:23:48.590809+00	44321b6a-d29b-4166-b717-56d3154f97c7
3caf5b74-5392-4930-8f4b-ea57dd4f646f	3caf5b74-5392-4930-8f4b-ea57dd4f646f	{"sub": "3caf5b74-5392-4930-8f4b-ea57dd4f646f", "email": "tm-demo-traveler-06@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:48.882931+00	2026-09-18 01:23:48.882977+00	2026-09-18 01:23:48.882977+00	b7c7f830-8553-4a0e-8a39-8f3aa7fbc859
c3f1a421-b31e-4352-9a90-761ab03e4498	c3f1a421-b31e-4352-9a90-761ab03e4498	{"sub": "c3f1a421-b31e-4352-9a90-761ab03e4498", "email": "tm-demo-traveler-07@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:49.16086+00	2026-09-18 01:23:49.160918+00	2026-09-18 01:23:49.160918+00	77dd6b66-6743-4fd5-871c-179739e8d6d9
748530a7-420a-4609-93eb-980e78db48e3	748530a7-420a-4609-93eb-980e78db48e3	{"sub": "748530a7-420a-4609-93eb-980e78db48e3", "email": "tm-demo-traveler-08@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:49.446714+00	2026-09-18 01:23:49.446761+00	2026-09-18 01:23:49.446761+00	d549876d-6d16-4a9f-9a50-ba23c2c56de5
4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	{"sub": "4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a", "email": "tm-demo-traveler-09@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:49.743323+00	2026-09-18 01:23:49.743374+00	2026-09-18 01:23:49.743374+00	829ebb6e-c060-42cf-b821-6ce0e41d4232
99f4f909-197a-433d-aa42-5d552f2778d5	99f4f909-197a-433d-aa42-5d552f2778d5	{"sub": "99f4f909-197a-433d-aa42-5d552f2778d5", "email": "tm-demo-traveler-10@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:50.028556+00	2026-09-18 01:23:50.028615+00	2026-09-18 01:23:50.028615+00	769fff2c-ac02-4a37-8a85-543fb6b08fec
a4f9becd-16e4-47a7-b32d-39930b707c1f	a4f9becd-16e4-47a7-b32d-39930b707c1f	{"sub": "a4f9becd-16e4-47a7-b32d-39930b707c1f", "email": "tm-demo-traveler-11@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:50.305578+00	2026-09-18 01:23:50.305625+00	2026-09-18 01:23:50.305625+00	fe951f9c-8c0b-41c7-94d0-54095b816e5d
5a4b619a-3c52-45ef-afaf-d3d1351f7343	5a4b619a-3c52-45ef-afaf-d3d1351f7343	{"sub": "5a4b619a-3c52-45ef-afaf-d3d1351f7343", "email": "tm-demo-traveler-12@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:50.579006+00	2026-09-18 01:23:50.57906+00	2026-09-18 01:23:50.57906+00	10bc249b-b394-4d80-8124-f9e9d702937d
5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	{"sub": "5bd9c3ca-6f85-48ce-b4bb-a0996c081a59", "email": "tm-demo-traveler-13@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:50.859786+00	2026-09-18 01:23:50.85984+00	2026-09-18 01:23:50.85984+00	49803b4e-255f-4cde-906e-70831e88f7ef
3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	{"sub": "3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4", "email": "tm-demo-traveler-14@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:51.136352+00	2026-09-18 01:23:51.136398+00	2026-09-18 01:23:51.136398+00	e49da1b0-c2c3-4190-8ad9-fdb14c530304
f5512436-7401-4ee0-88a0-095ca33c7cbb	f5512436-7401-4ee0-88a0-095ca33c7cbb	{"sub": "f5512436-7401-4ee0-88a0-095ca33c7cbb", "email": "tm-demo-traveler-15@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:51.413701+00	2026-09-18 01:23:51.413749+00	2026-09-18 01:23:51.413749+00	4db4b7bd-54a1-49f6-aef0-9494197ad704
d58126bf-5070-47dd-9865-c34af15569e4	d58126bf-5070-47dd-9865-c34af15569e4	{"sub": "d58126bf-5070-47dd-9865-c34af15569e4", "email": "tm-demo-analyst-01@example.test", "email_verified": false, "phone_verified": false}	email	2026-09-18 01:23:51.687074+00	2026-09-18 01:23:51.687122+00	2026-09-18 01:23:51.687122+00	9683e328-9d75-4ecc-8b88-6dcd095919c9
112535748985763575580	024f263f-0def-45aa-b740-8882d949bd77	{"iss": "https://accounts.google.com", "sub": "112535748985763575580", "name": "Borja, Rasheed Jermaine P.", "email": "rasheedborja@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLXWrlZVyLm8W6X6ddL_yNIyrN_0vjRce9I4b4utDpWRFi91fq5=s96-c", "full_name": "Borja, Rasheed Jermaine P.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLXWrlZVyLm8W6X6ddL_yNIyrN_0vjRce9I4b4utDpWRFi91fq5=s96-c", "provider_id": "112535748985763575580", "email_verified": true, "phone_verified": false}	google	2026-09-30 12:12:40.917826+00	2026-09-30 12:12:40.917891+00	2026-09-30 12:12:40.917891+00	a5d16502-c42e-4fc5-875d-8101a26fd376
116109664390320337552	9f8f0e34-1876-4a04-9a26-a65537ad2f33	{"iss": "https://accounts.google.com", "sub": "116109664390320337552", "name": "RIMNARWHAL", "email": "rimnarwhal@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIytoEUT3EHXPMrFoZr-snonUbYFTFy5KU6l-PCmYcJG9M_Cso=s96-c", "full_name": "RIMNARWHAL", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIytoEUT3EHXPMrFoZr-snonUbYFTFy5KU6l-PCmYcJG9M_Cso=s96-c", "provider_id": "116109664390320337552", "email_verified": true, "phone_verified": false}	google	2026-10-01 13:54:56.515065+00	2026-10-01 13:54:56.515161+00	2026-10-05 03:25:12.755994+00	1d60e978-116b-4855-bcf4-be3bef352d37
3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	{"sub": "3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b", "email": "delpilargian0@gmail.com", "full_name": "gian delpilar", "email_verified": false, "phone_verified": false}	email	2026-10-01 14:10:04.495891+00	2026-10-01 14:10:04.495935+00	2026-10-01 14:10:04.495935+00	074b2521-093e-4a93-ae30-63846a5850b6
e848cf46-0fb6-4065-b436-d5142e6b9f48	e848cf46-0fb6-4065-b436-d5142e6b9f48	{"sub": "e848cf46-0fb6-4065-b436-d5142e6b9f48", "email": "majinbuurger@gmail.com", "full_name": "majin buu", "email_verified": false, "phone_verified": false}	email	2026-10-05 03:36:49.416812+00	2026-10-05 03:36:49.416852+00	2026-10-05 03:36:49.416852+00	5051ccc2-42fa-4263-9622-d3669f287511
107496803441966106671	bfc3af84-a566-412d-a1f3-b3f36b697278	{"iss": "https://accounts.google.com", "sub": "107496803441966106671", "name": "Del Pilar, Gian Kayl A.", "email": "delpilargian727@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJTXpTZq_pm6WLM4cVj0hLwZlMbiZYUHlkfiY6-nC5BFqA7KM2t=s96-c", "full_name": "Del Pilar, Gian Kayl A.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJTXpTZq_pm6WLM4cVj0hLwZlMbiZYUHlkfiY6-nC5BFqA7KM2t=s96-c", "provider_id": "107496803441966106671", "email_verified": true, "phone_verified": false}	google	2026-09-30 12:19:41.098924+00	2026-09-30 12:19:41.098976+00	2026-10-04 14:08:30.782515+00	d01326ea-7dc3-487c-8209-e7f4cd4e8e73
116210743358829437064	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	{"iss": "https://accounts.google.com", "sub": "116210743358829437064", "name": "Gian DelPilar", "email": "delpilargian0@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJVAb27urKPpY0FBJ-UySn-Iy0yonBSd-6t5U71a_ogcwgkeg=s96-c", "full_name": "Gian DelPilar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJVAb27urKPpY0FBJ-UySn-Iy0yonBSd-6t5U71a_ogcwgkeg=s96-c", "provider_id": "116210743358829437064", "email_verified": true, "phone_verified": false}	google	2026-10-03 00:33:35.574211+00	2026-10-03 00:33:35.57431+00	2026-10-05 03:14:02.828326+00	955e9212-ee0c-455c-8cef-b7e431236679
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
dd4930ef-8df9-4242-aaa8-1815817f0e8a	2026-09-17 04:10:37.02703+00	2026-09-17 04:10:37.02703+00	oauth	b760a77b-f483-4cdb-a70d-d355591d1443
a20397c3-7cc7-424c-b06d-7ba9a3bcca26	2026-09-17 07:04:56.648314+00	2026-09-17 07:04:56.648314+00	oauth	51a4c44c-dd42-466d-94ab-8affcdc0f47d
1e70c8e8-71cb-40db-baf5-1516de43bb2b	2026-09-30 12:00:14.908489+00	2026-09-30 12:00:14.908489+00	oauth	8d293a5d-3957-4f96-be42-57449f4678dc
29b7e503-50cf-4ba2-a65e-2410788ac578	2026-10-04 14:08:31.140912+00	2026-10-04 14:08:31.140912+00	oauth	839b4755-967a-4d77-8903-4822abe84ccb
9cecbabf-85a9-4b7f-b404-823d3c56e4c7	2026-10-05 03:25:13.261449+00	2026-10-05 03:25:13.261449+00	oauth	6d14f9a0-cb4b-4354-bb56-7a1d3a3d5b99
d5162c51-fe88-4b43-b07d-b1f37495d109	2026-10-05 03:36:49.476994+00	2026-10-05 03:36:49.476994+00	password	b4a504ac-11d4-4ce6-a632-377f25c16313
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: mfa_recovery_code_sets; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_recovery_code_sets (id, user_id, mfa_factor_id, failed_verification_count, verification_locked_until, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_recovery_codes; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_recovery_codes (id, mfa_recovery_code_set_id, code_hash, consumed_at, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at, expires_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	4	wgf3m2gxasdw	423028d7-3027-4ae9-947c-d5428e29b88f	t	2026-09-17 04:10:37.023349+00	2026-09-17 06:29:36.769473+00	\N	dd4930ef-8df9-4242-aaa8-1815817f0e8a
00000000-0000-0000-0000-000000000000	5	36dmaz4thwno	423028d7-3027-4ae9-947c-d5428e29b88f	t	2026-09-17 06:29:36.786675+00	2026-09-25 15:00:49.321624+00	wgf3m2gxasdw	dd4930ef-8df9-4242-aaa8-1815817f0e8a
00000000-0000-0000-0000-000000000000	11	afhqa6skyww3	423028d7-3027-4ae9-947c-d5428e29b88f	t	2026-09-25 15:00:49.342891+00	2026-09-30 11:53:11.712301+00	36dmaz4thwno	dd4930ef-8df9-4242-aaa8-1815817f0e8a
00000000-0000-0000-0000-000000000000	12	m27e3wab7pu3	423028d7-3027-4ae9-947c-d5428e29b88f	f	2026-09-30 11:53:11.727956+00	2026-09-30 11:53:11.727956+00	afhqa6skyww3	dd4930ef-8df9-4242-aaa8-1815817f0e8a
00000000-0000-0000-0000-000000000000	7	y4z3o5q2lo3w	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	t	2026-09-17 07:04:56.632074+00	2026-09-30 12:04:55.213046+00	\N	a20397c3-7cc7-424c-b06d-7ba9a3bcca26
00000000-0000-0000-0000-000000000000	14	yxcuoni74rlu	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	f	2026-09-30 12:04:55.218329+00	2026-09-30 12:04:55.218329+00	y4z3o5q2lo3w	a20397c3-7cc7-424c-b06d-7ba9a3bcca26
00000000-0000-0000-0000-000000000000	61	rx4i5bef3nnw	bfc3af84-a566-412d-a1f3-b3f36b697278	f	2026-10-04 14:08:31.138772+00	2026-10-04 14:08:31.138772+00	\N	29b7e503-50cf-4ba2-a65e-2410788ac578
00000000-0000-0000-0000-000000000000	63	7h6jdedqikfd	9f8f0e34-1876-4a04-9a26-a65537ad2f33	f	2026-10-05 03:25:13.218821+00	2026-10-05 03:25:13.218821+00	\N	9cecbabf-85a9-4b7f-b404-823d3c56e4c7
00000000-0000-0000-0000-000000000000	64	gbkolqeowgx7	e848cf46-0fb6-4065-b436-d5142e6b9f48	f	2026-10-05 03:36:49.456915+00	2026-10-05 03:36:49.456915+00	\N	d5162c51-fe88-4b43-b07d-b1f37495d109
00000000-0000-0000-0000-000000000000	13	7jzvz3vnvzd7	1f35520c-9114-4cbb-b369-86d2b431c76e	t	2026-09-30 12:00:14.894908+00	2026-10-02 11:11:42.148617+00	\N	1e70c8e8-71cb-40db-baf5-1516de43bb2b
00000000-0000-0000-0000-000000000000	33	q6yvym4bs7y5	1f35520c-9114-4cbb-b369-86d2b431c76e	f	2026-10-02 11:11:42.165136+00	2026-10-02 11:11:42.165136+00	7jzvz3vnvzd7	1e70c8e8-71cb-40db-baf5-1516de43bb2b
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
20260302000000
20260625000000
20260821000000
20260821010000
20260824000000
20260824000001
20260831180000
\.


--
-- Data for Name: scim_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.scim_tokens (id, sso_provider_id, token_hash, prefix, created_at, expires_at, revoked_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: scim_users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.scim_users (id, sso_provider_id, user_id, resource, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
d5162c51-fe88-4b43-b07d-b1f37495d109	e848cf46-0fb6-4065-b436-d5142e6b9f48	2026-10-05 03:36:49.446488+00	2026-10-05 03:36:49.446488+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36	210.4.122.140	\N	\N	\N	\N	\N
dd4930ef-8df9-4242-aaa8-1815817f0e8a	423028d7-3027-4ae9-947c-d5428e29b88f	2026-09-17 04:10:37.020687+00	2026-09-30 11:53:11.755646+00	\N	aal1	\N	2026-09-30 11:53:11.755537	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0	119.111.228.180	\N	\N	\N	\N	\N
a20397c3-7cc7-424c-b06d-7ba9a3bcca26	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	2026-09-17 07:04:56.624045+00	2026-09-30 12:04:55.225706+00	\N	aal1	\N	2026-09-30 12:04:55.225614	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36	119.111.228.180	\N	\N	\N	\N	\N
1e70c8e8-71cb-40db-baf5-1516de43bb2b	1f35520c-9114-4cbb-b369-86d2b431c76e	2026-09-30 12:00:14.888187+00	2026-10-02 11:11:42.19843+00	\N	aal1	\N	2026-10-02 11:11:42.198321	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36	124.217.90.240	\N	\N	\N	\N	\N
29b7e503-50cf-4ba2-a65e-2410788ac578	bfc3af84-a566-412d-a1f3-b3f36b697278	2026-10-04 14:08:31.137708+00	2026-10-04 14:08:31.137708+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36	119.111.230.93	\N	\N	\N	\N	\N
9cecbabf-85a9-4b7f-b404-823d3c56e4c7	9f8f0e34-1876-4a04-9a26-a65537ad2f33	2026-10-05 03:25:13.196759+00	2026-10-05 03:25:13.196759+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36	210.4.122.140	\N	\N	\N	\N	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	423028d7-3027-4ae9-947c-d5428e29b88f	authenticated	authenticated	diannejoypimentel@gmail.com	\N	2026-09-17 04:06:55.007838+00	\N		\N		\N			\N	2026-09-17 04:10:37.019588+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "103978578045383846512", "name": "dianne joy pimentel", "email": "diannejoypimentel@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJS12m6vPbBURYhdKqA_jpni17DtC-wLkUK1MnmF88bKQfIWA=s96-c", "full_name": "dianne joy pimentel", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJS12m6vPbBURYhdKqA_jpni17DtC-wLkUK1MnmF88bKQfIWA=s96-c", "provider_id": "103978578045383846512", "email_verified": true, "phone_verified": false}	\N	2026-09-17 04:06:54.985212+00	2026-09-30 11:53:11.736433+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1f35520c-9114-4cbb-b369-86d2b431c76e	authenticated	authenticated	jonasloyola6@gmail.com	\N	2026-09-16 16:01:32.497714+00	\N		\N		\N			\N	2026-09-30 12:00:14.887025+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "110063283083751756873", "name": "Jonas Loyola", "email": "jonasloyola6@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIAIk_55eOLUvT2r8SG4klJVKjdcL8nyZTduRQF-oa0yzCkbsl2=s96-c", "full_name": "Jonas Loyola", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIAIk_55eOLUvT2r8SG4klJVKjdcL8nyZTduRQF-oa0yzCkbsl2=s96-c", "provider_id": "110063283083751756873", "account_type": "business_owner", "email_verified": true, "phone_verified": false}	\N	2026-09-16 16:01:32.492306+00	2026-10-02 11:11:49.945082+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	authenticated	authenticated	subalashawn2006@gmail.com	\N	2026-09-17 06:36:51.592102+00	\N		\N		\N			\N	2026-09-17 07:04:56.622711+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "108928656906286175879", "name": "Subala, Shawn Marion V.", "email": "subalashawn2006@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocI2oHqSxquOuqjBB9Hbjb379fSVwtu3KRpIXbmqyDg6HBHNPe-s3A=s96-c", "full_name": "Subala, Shawn Marion V.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocI2oHqSxquOuqjBB9Hbjb379fSVwtu3KRpIXbmqyDg6HBHNPe-s3A=s96-c", "provider_id": "108928656906286175879", "email_verified": true, "phone_verified": false}	\N	2026-09-17 06:36:51.575458+00	2026-09-30 12:04:55.221099+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	41942500-0b1b-4215-a759-29ffd1733f27	authenticated	authenticated	tm-demo-owner-03@example.test	$2a$10$MSU1vs.4pYHty4CeNpQrluCylY8NQcB.k8v0AV8T7AVHr.PjvgksO	2026-09-18 01:23:43.761937+00	\N		\N		\N			\N	\N	{"demo_no": 3, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Carla Valdez (Demo)", "email_verified": true}	\N	2026-09-18 01:23:43.75577+00	2026-09-18 01:23:43.763324+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	08c59a01-6bf6-44c6-b6f1-de0131a3dccf	authenticated	authenticated	tm-demo-owner-01@example.test	$2a$10$Iyic8Bh.jqOeYhTRTsBM..n1ByuZKp21wtOA4I/zdMVencrjpPAj.	2026-09-18 01:23:43.1491+00	\N		\N		\N			\N	\N	{"demo_no": 1, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Elena Mercado (Demo)", "email_verified": true}	\N	2026-09-18 01:23:43.118627+00	2026-09-18 01:23:43.166165+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	71f2a91a-e5e2-4a42-b830-2eea593be359	authenticated	authenticated	hnasly30@gmail.com	\N	2026-09-17 13:06:38.070572+00	\N		\N		\N			\N	2026-09-17 13:06:38.834183+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "112756915146643872138", "name": "Nasly H", "email": "hnasly30@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJokH424846F18tD24tgzcJs50-14lQdTFOuxSHfCGP8R9Pqyk=s96-c", "full_name": "Nasly H", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJokH424846F18tD24tgzcJs50-14lQdTFOuxSHfCGP8R9Pqyk=s96-c", "provider_id": "112756915146643872138", "email_verified": true, "phone_verified": false}	\N	2026-09-17 13:06:38.056946+00	2026-09-17 13:06:38.841701+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8e59134a-da94-4cd6-9eb7-ff46c9d56195	authenticated	authenticated	tm-demo-owner-06@example.test	$2a$10$cQV/w8EntRcP8HPdpkK9TevGPak2bLFMmwOXes.Wbeezd.VHRUtaW	2026-09-18 01:23:44.632401+00	\N		\N		\N			\N	\N	{"demo_no": 6, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Enzo Salazar (Demo)", "email_verified": true}	\N	2026-09-18 01:23:44.625501+00	2026-09-18 01:23:44.634566+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	392e6791-10b8-4c3d-8800-9efe6d29f8b2	authenticated	authenticated	tm-demo-owner-05@example.test	$2a$10$j9vWfCOsAeoaCylr3SyY8OSqNrMmVXRBmSZ7cBVprtd5bwvhvaGRC	2026-09-18 01:23:44.344453+00	\N		\N		\N			\N	\N	{"demo_no": 5, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Diana Pascual (Demo)", "email_verified": true}	\N	2026-09-18 01:23:44.340128+00	2026-09-18 01:23:44.345644+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e5931678-254c-4abf-85fa-71e667896a41	authenticated	authenticated	tm-demo-owner-02@example.test	$2a$10$cdYKe7qJUV.GKLuSWqGx1.EgYn/79SgjqlFiWsOM2PDyxlXKfylHm	2026-09-18 01:23:43.472533+00	\N		\N		\N			\N	\N	{"demo_no": 2, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Adrian Domingo (Demo)", "email_verified": true}	\N	2026-09-18 01:23:43.467374+00	2026-09-18 01:23:43.474005+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fe304e3d-1946-46cb-bb2d-77f8702c0f05	authenticated	authenticated	tm-demo-owner-04@example.test	$2a$10$RwXyj3WfPrw4GQ0HmVaIDuU2DhEcDnuIM9p6lm8PVaA2V.eTNYDVC	2026-09-18 01:23:44.049171+00	\N		\N		\N			\N	\N	{"demo_no": 4, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Nico Soriano (Demo)", "email_verified": true}	\N	2026-09-18 01:23:44.045245+00	2026-09-18 01:23:44.050421+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	authenticated	authenticated	tm-demo-owner-07@example.test	$2a$10$pUiID0IcMRtvD2ndVwi9NORK6ipWR4g558IZUvGj5kJFWEPyN815a	2026-09-18 01:23:44.912552+00	\N		\N		\N			\N	\N	{"demo_no": 7, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Lara Fernandez (Demo)", "email_verified": true}	\N	2026-09-18 01:23:44.90946+00	2026-09-18 01:23:44.91353+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6a11f3df-d69c-4148-80ee-88f1f7c95e2a	authenticated	authenticated	tm-demo-owner-08@example.test	$2a$10$d8rupg5oOFLMX0yMQ.z.Eu.xBO5JZOyy0y81OOGOiURAfwli6o6Pe	2026-09-18 01:23:45.196952+00	\N		\N		\N			\N	\N	{"demo_no": 8, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Anton Rivera (Demo)", "email_verified": true}	\N	2026-09-18 01:23:45.193058+00	2026-09-18 01:23:45.197902+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6d736964-b99f-47cd-a81f-df9940200e61	authenticated	authenticated	tm-demo-traveler-04@example.test	$2a$10$YiEIcVJKTAdjQuDzalfj0.4lsxW2NxUClqyttihxzYe3v91/jdR5S	2026-09-18 01:23:48.30454+00	\N		\N		\N			\N	\N	{"demo_no": 4, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Paolo Reyes (Demo)", "email_verified": true}	\N	2026-09-18 01:23:48.3014+00	2026-09-18 01:23:48.305493+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	authenticated	authenticated	tm-demo-owner-09@example.test	$2a$10$9mmeU95BBcvAI7rpLOyNpeQIzjGH0O4gXI7G076IdCH4tGvyl00wW	2026-09-18 01:23:45.492622+00	\N		\N		\N			\N	\N	{"demo_no": 9, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Mara Dela Cruz (Demo)", "email_verified": true}	\N	2026-09-18 01:23:45.48564+00	2026-09-18 01:23:45.493562+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1ef0a385-782d-4808-999a-58733a4b209d	authenticated	authenticated	tm-demo-owner-13@example.test	$2a$10$DhHRN7zaD7jCQ0CYdMa8huUFt3JDKNxnM7FUlk9R.49NWfdVqHRSy	2026-09-18 01:23:46.620899+00	\N		\N		\N			\N	\N	{"demo_no": 13, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Lea Ignacio (Demo)", "email_verified": true}	\N	2026-09-18 01:23:46.61686+00	2026-09-18 01:23:46.621863+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	authenticated	authenticated	tm-demo-traveler-01@example.test	$2a$10$6L8HU4CHeSvCbuySm.cKCu4qWU0lUJwEIsdHHL0It.FoXJCJcOFb6	2026-09-18 01:23:47.477497+00	\N		\N		\N			\N	\N	{"demo_no": 1, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Andrea Ramos (Demo)", "email_verified": true}	\N	2026-09-18 01:23:47.473671+00	2026-09-18 01:23:47.478446+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c4a4841a-aa8a-4de6-b83c-b2bd6203042c	authenticated	authenticated	tm-demo-owner-10@example.test	$2a$10$dBKgG8WY7iQBqekbDqSRruS/Fpmmuw0ILi.vRAj3gWEwWNwXD5Z9u	2026-09-18 01:23:45.781615+00	\N		\N		\N			\N	\N	{"demo_no": 10, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Jules Rosales (Demo)", "email_verified": true}	\N	2026-09-18 01:23:45.778551+00	2026-09-18 01:23:45.782565+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9b8013fc-8493-409a-8f9f-f563b7d7c315	authenticated	authenticated	tm-demo-traveler-03@example.test	$2a$10$p/8yLP5HJiHr.8vD3hDb2eDIHfBxYL/UdibkclJRq64gHYVqUBsQe	2026-09-18 01:23:48.026965+00	\N		\N		\N			\N	\N	{"demo_no": 3, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Bea Cruz (Demo)", "email_verified": true}	\N	2026-09-18 01:23:48.023955+00	2026-09-18 01:23:48.028009+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0ea90927-1b7e-4674-a3df-092d82395d70	authenticated	authenticated	tm-demo-owner-14@example.test	$2a$10$ngfFBr2dIZE5jWJor78hpOPcTh5oKf.T3oKm/bUHWhkgYxITUKgwK	2026-09-18 01:23:46.906925+00	\N		\N		\N			\N	\N	{"demo_no": 14, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Ivan Padilla (Demo)", "email_verified": true}	\N	2026-09-18 01:23:46.902586+00	2026-09-18 01:23:46.907949+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8eba38fb-47ef-4be9-b26e-b109bccf0031	authenticated	authenticated	tm-demo-owner-11@example.test	$2a$10$np3SyHXDyxGQa46noUAfuu3h/vgK/IcfE7v9zRiQKiI050fusJ7u.	2026-09-18 01:23:46.061476+00	\N		\N		\N			\N	\N	{"demo_no": 11, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Iris Manalo (Demo)", "email_verified": true}	\N	2026-09-18 01:23:46.058049+00	2026-09-18 01:23:46.06243+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	5b305524-490a-4334-831e-b46d622648a8	authenticated	authenticated	tm-demo-owner-12@example.test	$2a$10$a89UTMpaKBOWRxI4iL9eS.OVsW8zHf4giYjLobWLkTUndQ20HTTlq	2026-09-18 01:23:46.340061+00	\N		\N		\N			\N	\N	{"demo_no": 12, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Theo Herrera (Demo)", "email_verified": true}	\N	2026-09-18 01:23:46.335838+00	2026-09-18 01:23:46.341072+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7562e428-178e-430b-af77-04f4a7fbaa0a	authenticated	authenticated	tm-demo-traveler-02@example.test	$2a$10$l0LW4AtDwAwgXhqaCm.EC.1/UFzi8it.4eII5X88bSIoyawv51/je	2026-09-18 01:23:47.751046+00	\N		\N		\N			\N	\N	{"demo_no": 2, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Miguel Santos (Demo)", "email_verified": true}	\N	2026-09-18 01:23:47.747964+00	2026-09-18 01:23:47.751998+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	df48bcda-05d5-4d27-8b94-0fec879a5ab8	authenticated	authenticated	tm-demo-owner-15@example.test	$2a$10$mgEeEau9QKYK2/ifwzNsj.FmcgswK8p2bnqWxBzDudhXSm9N6Spk.	2026-09-18 01:23:47.181743+00	\N		\N		\N			\N	\N	{"demo_no": 15, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Celia Del Rosario (Demo)", "email_verified": true}	\N	2026-09-18 01:23:47.178499+00	2026-09-18 01:23:47.182785+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c4adf4a6-b1f1-45af-8842-27d723b9519c	authenticated	authenticated	tm-demo-traveler-05@example.test	$2a$10$mlxXRTHgVAZIlaGUcBsF7uX3wePubT7vx2J3XAhbZaVDwwhIyccHq	2026-09-18 01:23:48.593543+00	\N		\N		\N			\N	\N	{"demo_no": 5, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Camille Garcia (Demo)", "email_verified": true}	\N	2026-09-18 01:23:48.589626+00	2026-09-18 01:23:48.594487+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3caf5b74-5392-4930-8f4b-ea57dd4f646f	authenticated	authenticated	tm-demo-traveler-06@example.test	$2a$10$WbK4/Y11.TgTD33cbOpJpuz8vg549Ehk7idAfC4Lupn1zIJKql5Pe	2026-09-18 01:23:48.884885+00	\N		\N		\N			\N	\N	{"demo_no": 6, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Rafael Mendoza (Demo)", "email_verified": true}	\N	2026-09-18 01:23:48.881729+00	2026-09-18 01:23:48.885847+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c3f1a421-b31e-4352-9a90-761ab03e4498	authenticated	authenticated	tm-demo-traveler-07@example.test	$2a$10$yutZm3t/.CY9t00pLbizL.VM2bt8N5KdoXxoUBVm1aCzhlwHAr.Ty	2026-09-18 01:23:49.162927+00	\N		\N		\N			\N	\N	{"demo_no": 7, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Nina Flores (Demo)", "email_verified": true}	\N	2026-09-18 01:23:49.159591+00	2026-09-18 01:23:49.163939+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a4f9becd-16e4-47a7-b32d-39930b707c1f	authenticated	authenticated	tm-demo-traveler-11@example.test	$2a$10$jZdVLdCTb7QrF1bFn.0eVOqPhNY6LSVPfw64Rkrz/MepEucwhy47e	2026-09-18 01:23:50.307731+00	\N		\N		\N			\N	\N	{"demo_no": 11, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Sofia Aguilar (Demo)", "email_verified": true}	\N	2026-09-18 01:23:50.304416+00	2026-09-18 01:23:50.308709+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	748530a7-420a-4609-93eb-980e78db48e3	authenticated	authenticated	tm-demo-traveler-08@example.test	$2a$10$EbEYFtsq1PcBPP7jujtIj.ubh5O7Ei.yPOP2E4QeGAnWSQyCaGw2u	2026-09-18 01:23:49.449052+00	\N		\N		\N			\N	\N	{"demo_no": 8, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Gabriel Torres (Demo)", "email_verified": true}	\N	2026-09-18 01:23:49.444657+00	2026-09-18 01:23:49.449964+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	d58126bf-5070-47dd-9865-c34af15569e4	authenticated	authenticated	tm-demo-analyst-01@example.test	$2a$10$Y7AihazoUYk3oxSpBNyqNeiefcF7udkrSYJK7A9inGHKlD6q3bJ5K	2026-09-18 01:23:51.689037+00	\N		\N		\N			\N	\N	{"demo_no": 1, "provider": "email", "demo_kind": "analyst", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Alex Medina (Demo)", "email_verified": true}	\N	2026-09-18 01:23:51.685958+00	2026-09-18 01:23:51.689998+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	5a4b619a-3c52-45ef-afaf-d3d1351f7343	authenticated	authenticated	tm-demo-traveler-12@example.test	$2a$10$Yo4LGeyGqIUfMwBGpoSI0e.YfFQx6Ijd9XTlv3dD7M93/Bz.u9C2e	2026-09-18 01:23:50.581195+00	\N		\N		\N			\N	\N	{"demo_no": 12, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Luis Santiago (Demo)", "email_verified": true}	\N	2026-09-18 01:23:50.577897+00	2026-09-18 01:23:50.582834+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	authenticated	authenticated	tm-demo-traveler-09@example.test	$2a$10$E6jIzbwLRvExa65qvetywehGhX9cOd.UEYBNPeGd0lEjE691QPEE.	2026-09-18 01:23:49.745356+00	\N		\N		\N			\N	\N	{"demo_no": 9, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Ella Navarro (Demo)", "email_verified": true}	\N	2026-09-18 01:23:49.74214+00	2026-09-18 01:23:49.746314+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	authenticated	authenticated	tm-demo-traveler-14@example.test	$2a$10$kgGVHz1WDxxBSI2xvwBVpunbZGrFVckz3eXSOXoriQa6zNfgxSdoy	2026-09-18 01:23:51.138218+00	\N		\N		\N			\N	\N	{"demo_no": 14, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Daniel Aquino (Demo)", "email_verified": true}	\N	2026-09-18 01:23:51.135168+00	2026-09-18 01:23:51.139206+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	99f4f909-197a-433d-aa42-5d552f2778d5	authenticated	authenticated	tm-demo-traveler-10@example.test	$2a$10$vECblLfbqkR8ukwPJOujcu5qRt2hC45bBYk9Mt5bMMrI96gKTkb1y	2026-09-18 01:23:50.030863+00	\N		\N		\N			\N	\N	{"demo_no": 10, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Marco Castillo (Demo)", "email_verified": true}	\N	2026-09-18 01:23:50.02739+00	2026-09-18 01:23:50.03179+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f5512436-7401-4ee0-88a0-095ca33c7cbb	authenticated	authenticated	tm-demo-traveler-15@example.test	$2a$10$ZHFiqWLVoNYHELdm12tTOuPgGtF4RduKHI6wWMaQ6LyaS37uovnsu	2026-09-18 01:23:51.415438+00	\N		\N		\N			\N	\N	{"demo_no": 15, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Clara Bautista (Demo)", "email_verified": true}	\N	2026-09-18 01:23:51.412601+00	2026-09-18 01:23:51.416363+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	authenticated	authenticated	tm-demo-traveler-13@example.test	$2a$10$1C6efGXCQFOP8Kf8YqJ3rekUqC2eYcDVg9gZfw9DDDIbKuu1iXTfC	2026-09-18 01:23:50.862096+00	\N		\N		\N			\N	\N	{"demo_no": 13, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}	{"full_name": "Mika Villanueva (Demo)", "email_verified": true}	\N	2026-09-18 01:23:50.858684+00	2026-09-18 01:23:50.863017+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	authenticated	authenticated	delpilargian0@gmail.com	$2a$10$j8/dXPc0d/nqkC3gSvo60u5K6e2W8ZO0zCGNiL6vdYbhVaiE2fe0m	2026-10-01 14:10:04.500263+00	\N		\N		\N			\N	2026-10-05 03:14:03.335691+00	{"provider": "email", "providers": ["email", "google"]}	{"iss": "https://accounts.google.com", "sub": "116210743358829437064", "name": "Gian DelPilar", "email": "delpilargian0@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJVAb27urKPpY0FBJ-UySn-Iy0yonBSd-6t5U71a_ogcwgkeg=s96-c", "full_name": "Gian DelPilar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJVAb27urKPpY0FBJ-UySn-Iy0yonBSd-6t5U71a_ogcwgkeg=s96-c", "provider_id": "116210743358829437064", "account_type": "traveler", "email_verified": true, "phone_verified": false}	\N	2026-10-01 14:10:04.47645+00	2026-10-05 03:14:03.379072+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e848cf46-0fb6-4065-b436-d5142e6b9f48	authenticated	authenticated	majinbuurger@gmail.com	$2a$10$4thJvSn2PstqrSyXz79kw.tcRULgt3i/1vdPUMCqbcSqOAe3ZdBfq	2026-10-05 03:36:49.419843+00	\N		\N		\N			\N	2026-10-05 03:36:49.446353+00	{"provider": "email", "providers": ["email"]}	{"sub": "e848cf46-0fb6-4065-b436-d5142e6b9f48", "email": "majinbuurger@gmail.com", "full_name": "majin buu", "account_type": "traveler", "email_verified": true, "phone_verified": false}	\N	2026-10-05 03:36:49.409925+00	2026-10-05 03:36:54.518547+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	024f263f-0def-45aa-b740-8882d949bd77	authenticated	authenticated	rasheedborja@gmail.com	\N	2026-09-30 12:12:40.925909+00	\N		\N		\N			\N	2026-09-30 12:12:41.18857+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "112535748985763575580", "name": "Borja, Rasheed Jermaine P.", "email": "rasheedborja@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLXWrlZVyLm8W6X6ddL_yNIyrN_0vjRce9I4b4utDpWRFi91fq5=s96-c", "full_name": "Borja, Rasheed Jermaine P.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLXWrlZVyLm8W6X6ddL_yNIyrN_0vjRce9I4b4utDpWRFi91fq5=s96-c", "provider_id": "112535748985763575580", "email_verified": true, "phone_verified": false}	\N	2026-09-30 12:12:40.909897+00	2026-09-30 12:12:41.196127+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9f8f0e34-1876-4a04-9a26-a65537ad2f33	authenticated	authenticated	rimnarwhal@gmail.com	\N	2026-10-01 13:54:56.520279+00	\N		\N		\N			\N	2026-10-05 03:25:13.195676+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "116109664390320337552", "name": "RIMNARWHAL", "email": "rimnarwhal@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIytoEUT3EHXPMrFoZr-snonUbYFTFy5KU6l-PCmYcJG9M_Cso=s96-c", "full_name": "RIMNARWHAL", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIytoEUT3EHXPMrFoZr-snonUbYFTFy5KU6l-PCmYcJG9M_Cso=s96-c", "provider_id": "116109664390320337552", "account_type": "business_owner", "email_verified": true, "phone_verified": false}	\N	2026-10-01 13:54:56.496989+00	2026-10-05 03:25:13.247397+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	bfc3af84-a566-412d-a1f3-b3f36b697278	authenticated	authenticated	delpilargian727@gmail.com	\N	2026-09-30 12:19:41.105349+00	\N		\N		\N			\N	2026-10-04 14:08:31.136553+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "107496803441966106671", "name": "Del Pilar, Gian Kayl A.", "email": "delpilargian727@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJTXpTZq_pm6WLM4cVj0hLwZlMbiZYUHlkfiY6-nC5BFqA7KM2t=s96-c", "full_name": "Del Pilar, Gian Kayl A.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJTXpTZq_pm6WLM4cVj0hLwZlMbiZYUHlkfiY6-nC5BFqA7KM2t=s96-c", "provider_id": "107496803441966106671", "account_type": "traveler", "email_verified": true, "phone_verified": false}	\N	2026-09-30 12:19:41.084878+00	2026-10-04 14:08:31.140508+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_challenges (id, user_id, challenge_type, session_data, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_credentials (id, user_id, credential_id, public_key, attestation_type, aaguid, sign_count, transports, backup_eligible, backed_up, friendly_name, created_at, updated_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: amenities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.amenities (id, name) FROM stdin;
d7142244-31aa-4ea5-b2a5-92c3ce6869d6	Wi-Fi
bf56f04e-e2bf-4320-a189-5aad7bfeff4e	Air conditioning
64550e32-d148-48c8-93e9-1a20011d0520	Parking
47bd6d66-4ca8-4237-b459-00e6c75c4445	Breakfast service
e8edf554-93cc-4f4e-9fcb-2d13c809bec1	Family rooms
50be533c-e785-4a8d-ab68-d4936243c3ee	Accessible entrance
e7a3282d-516a-4645-bcf3-6a5bf81d7244	Swimming pool
b3071c7c-d231-4b85-8186-3d1162705986	Garden
3443d2c7-8e98-4f6d-9950-39d7862cdebc	Work desk
3ed2b9d3-1c47-4e03-9f90-13cad6e4ffac	Hot shower
32eb87d8-7d86-48a8-b953-22658abd4728	Luggage storage
ca2e7f88-1e75-495f-88ce-9f4c9e3975f4	Laundry service
c0c835c0-8dfe-4097-96e7-4d67a3079846	Meeting room
94c17035-47ed-406f-90a8-1bdc28098dd3	Airport transfer
9048c0a1-ef2b-4fd1-8c9a-ccf432085b62	Bicycle storage
\.


--
-- Data for Name: analytics_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.analytics_reports (id, generated_by, period_start, period_end, status, generated_at, created_at) FROM stdin;
953dd371-00b3-5991-94c0-7a82e50b3589	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
46e472fb-9168-5156-b628-29d4a8f05326	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
aee468ab-a005-5693-8424-947a8cf1ca89	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
31887b69-6f1b-5ea1-b8f9-be1cae0d7f98	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
879e9939-224e-5feb-9966-343e02027c6a	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
33f88932-81e0-5c0b-ab17-fe8a86bb4391	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
f27ca172-d58c-5ddb-acc3-cbbc8c30dd83	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
70f19908-1c5d-5b24-9e87-dd12f62f240d	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
e6438198-f18c-5564-b3de-850c1da7327c	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
c98d7a40-056f-5ddf-8046-af4b470d35ca	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
5ea09ea9-bbb4-5426-8b80-26dba05a3a6f	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
1517a01c-99ad-554c-ac8c-69e713a4304b	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
7e87a435-228e-5ebd-9a10-4b879791afbf	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
741165f1-800d-5a25-b423-c71677e54b88	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c	d58126bf-5070-47dd-9865-c34af15569e4	2026-08-01	2026-08-31	generated	2026-09-01 01:00:00+00	2026-09-01 00:59:00+00
\.


--
-- Data for Name: attraction_schedules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attraction_schedules (id, attraction_id, operating_day, schedule_text) FROM stdin;
020b20ec-b964-5ff6-b9ac-13b237ef42ff	b4684683-0b4e-57c7-a2da-538662ac1623	Saturday	09:00-17:00 (demo schedule)
da603b56-8ae5-5e0e-b67a-19a3ec560b65	c9c2d665-33f0-5eda-8cf4-0e45ec6d242a	Saturday	09:00-17:00 (demo schedule)
242107e4-79db-5df6-b5fd-1a0d91fcff99	87878ea1-db87-51e8-9e27-0db6321c8cf9	Saturday	09:00-17:00 (demo schedule)
c01a78dd-4409-5b6f-a9e8-86ef51b21f66	78afeb8a-28d8-531b-af16-da8dad728550	Saturday	09:00-17:00 (demo schedule)
589649b5-1d77-5048-b450-4c926e1568e9	5c6e8d11-ba1c-5a15-bb5f-0870a1a3948b	Saturday	09:00-17:00 (demo schedule)
ff2afb8b-58ff-57da-8d4b-2d4324168017	c426d31f-ee4a-503c-ad03-b7668670cb1d	Saturday	09:00-17:00 (demo schedule)
4deef670-254e-5aae-ab83-3922b445dfa1	56c0336f-aca2-506f-857e-bb9dc3a38575	Saturday	09:00-17:00 (demo schedule)
f8ae75ea-3398-52c5-87f9-f20bec078248	1d201536-a2f6-505b-80f9-d0000a2b6db8	Saturday	09:00-17:00 (demo schedule)
f1095f8c-a9c2-5e0d-b93b-e863a2e9a5a1	74b3172f-f41a-5743-bc4d-f6eb03a16047	Saturday	09:00-17:00 (demo schedule)
6db703e8-3fc1-55c6-8e9c-e403713e7705	50fc3f85-f202-5997-9828-6dd46035b3d3	Saturday	09:00-17:00 (demo schedule)
ec9dca6f-bc5f-589f-8df1-7f99374d86aa	888d81e5-b37d-5452-b956-92a7523761e1	Saturday	09:00-17:00 (demo schedule)
a0ff26bb-797f-56f1-b8f3-3b53045c9deb	9415615e-4a1e-5330-a84d-80f1bb33037f	Saturday	09:00-17:00 (demo schedule)
72090868-887f-51f5-b5b8-079e1b27a495	dc057260-3d1f-5736-94ab-a2f8c2222a5f	Saturday	09:00-17:00 (demo schedule)
2d3ef507-62a0-5fe3-b42d-111c3e19f79a	c80b65fe-d043-5b4d-8127-87bb1a2bb5e5	Saturday	09:00-17:00 (demo schedule)
fc3c19e4-77b0-5356-ba17-6fd05602d042	f6e1127b-0493-5626-b4e0-62bb503d863d	Saturday	09:00-17:00 (demo schedule)
\.


--
-- Data for Name: attractions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attractions (attraction_id, entrance_fee) FROM stdin;
b4684683-0b4e-57c7-a2da-538662ac1623	55.00
c9c2d665-33f0-5eda-8cf4-0e45ec6d242a	60.00
87878ea1-db87-51e8-9e27-0db6321c8cf9	65.00
78afeb8a-28d8-531b-af16-da8dad728550	70.00
5c6e8d11-ba1c-5a15-bb5f-0870a1a3948b	75.00
c426d31f-ee4a-503c-ad03-b7668670cb1d	80.00
56c0336f-aca2-506f-857e-bb9dc3a38575	85.00
1d201536-a2f6-505b-80f9-d0000a2b6db8	90.00
74b3172f-f41a-5743-bc4d-f6eb03a16047	95.00
50fc3f85-f202-5997-9828-6dd46035b3d3	100.00
888d81e5-b37d-5452-b956-92a7523761e1	105.00
9415615e-4a1e-5330-a84d-80f1bb33037f	110.00
dc057260-3d1f-5736-94ab-a2f8c2222a5f	115.00
c80b65fe-d043-5b4d-8127-87bb1a2bb5e5	120.00
f6e1127b-0493-5626-b4e0-62bb503d863d	125.00
\.


--
-- Data for Name: booking_rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.booking_rooms (id, booking_id, room_id, nightly_rate) FROM stdin;
9a01b4a1-6172-568d-8690-8acbdbab3542	1f05c565-9d85-5547-b78a-1d48c65a7ac5	4459f1a2-9ab0-52e5-94c7-87292d43f836	1300.00
36056cb1-e38e-5164-84e6-49c254b83ee5	10c8e7ce-aecb-53af-b11f-4bd1b64341a9	09b9e419-23bc-5b7f-8a1e-25330dbf8c6f	1400.00
08638e2f-7c06-5691-a4f6-5e5dcd371ad1	84afe302-1517-5245-a0a4-6e97149c3d2f	6b26743c-b5b4-5ed6-958b-17b75d850413	1500.00
b7c7ccd6-db92-5e77-a436-aa8b16f6791e	838cd55a-ef2c-58da-a8ca-9760668af078	8c26eadb-c9b8-5293-9f1c-2eb49283622a	1600.00
dae1bcea-6cc1-5c87-87d8-69dba4bebdf4	dd9d796f-8b52-511d-a270-2e43108bb830	5c45912c-2cbb-5f8b-8aef-9b2943d171bd	1700.00
7c994e4b-95e1-5990-9aa2-9adcd246dd4a	3c972c00-33b1-5331-b5ac-256aeddbf55f	39ac536e-a786-5bf5-9f47-4a0572ae72d1	1800.00
dbf3d71d-094e-5496-91b2-a9cd5d5fba2d	0a225aef-77bd-515c-bd57-49facf19bfec	b2be20fc-79c7-51d7-8fad-938580dd3a54	1900.00
71ffc330-1971-5381-998d-b323c066eef4	114e28dd-d2b2-5013-98b3-004aeb0b79ac	111b36ad-fef0-53a6-a141-466725afa88a	2000.00
deeb2239-47ba-5842-bde6-7edc3659a3e7	61054763-93ad-5b9a-84d4-ad1dd65bd27d	7aa59e9a-aa9b-57c4-9151-031bc66872fd	2100.00
4199c74b-e62b-5dd7-a89c-214250b31a2e	7353719a-1f79-5371-b1a0-56f3cf76aa92	aec49986-57ac-59d9-935c-0c02a6d9b832	2200.00
1b64684e-3cd6-546c-90fd-5971b6a8b116	2bc25997-f7fd-5836-b78a-9f0aaadf938c	3ec239b9-26dd-5b40-98c0-1f208312bde4	2300.00
6b1d10a5-dd5f-59c3-a363-d3049451a3a6	76a2903d-b252-5490-8584-18fe5d9d2628	2ad36cac-b35f-51fb-89ae-84339f6fa432	2400.00
e4a00f6f-6968-5073-9ade-0d91631fd98e	0f8ae9bf-5e4a-5746-a534-c53e61fd1a63	2da779fa-f1e4-5781-8d36-18f029b3e2d1	2500.00
e4fa7425-e6d6-52b9-96c9-054f53245ce6	92532d9f-b041-52f9-9095-513504eb4305	9f58b9f4-d398-58da-845e-645106988229	2600.00
561233af-d3fa-5195-911b-3534c4606c82	11c56faa-db75-5c9f-bc78-7110ab4dc5ac	570234b1-4e04-581f-8817-d53d32df9060	2700.00
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookings (id, profile_id, booking_type, guest_name, guest_email, guest_phone, guest_count, total_amount, status, hold_expires_at, idempotency_key, created_at, updated_at, payment_status, stripe_session_id, stripe_payment_intent_id) FROM stdin;
1f05c565-9d85-5547-b78a-1d48c65a7ac5	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	hotel	Andrea Ramos (Demo)	tm-demo-traveler-01@example.test	\N	2	2600.00	completed	\N	tm-demo-v1-booking-hotel-01	2026-07-20 03:00:00+00	2026-08-04 10:00:00+00	unpaid	\N	\N
9f650f7f-ad1c-5029-b5e7-55194f71a382	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	restaurant	Andrea Ramos (Demo)	tm-demo-traveler-01@example.test	\N	2	110.00	completed	\N	tm-demo-v1-booking-restaurant-01	2026-07-20 03:00:00+00	2026-08-04 10:00:00+00	unpaid	\N	\N
10c8e7ce-aecb-53af-b11f-4bd1b64341a9	7562e428-178e-430b-af77-04f4a7fbaa0a	hotel	Miguel Santos (Demo)	tm-demo-traveler-02@example.test	\N	2	2800.00	completed	\N	tm-demo-v1-booking-hotel-02	2026-07-20 03:00:00+00	2026-08-05 10:00:00+00	unpaid	\N	\N
a9ba838e-30f2-5ee0-8fde-e978b0e67fa2	7562e428-178e-430b-af77-04f4a7fbaa0a	restaurant	Miguel Santos (Demo)	tm-demo-traveler-02@example.test	\N	2	120.00	completed	\N	tm-demo-v1-booking-restaurant-02	2026-07-20 03:00:00+00	2026-08-05 10:00:00+00	unpaid	\N	\N
84afe302-1517-5245-a0a4-6e97149c3d2f	9b8013fc-8493-409a-8f9f-f563b7d7c315	hotel	Bea Cruz (Demo)	tm-demo-traveler-03@example.test	\N	2	3000.00	completed	\N	tm-demo-v1-booking-hotel-03	2026-07-20 03:00:00+00	2026-08-06 10:00:00+00	unpaid	\N	\N
2150d480-c117-5bcc-b0f4-87f280851492	9b8013fc-8493-409a-8f9f-f563b7d7c315	restaurant	Bea Cruz (Demo)	tm-demo-traveler-03@example.test	\N	2	130.00	completed	\N	tm-demo-v1-booking-restaurant-03	2026-07-20 03:00:00+00	2026-08-06 10:00:00+00	unpaid	\N	\N
838cd55a-ef2c-58da-a8ca-9760668af078	6d736964-b99f-47cd-a81f-df9940200e61	hotel	Paolo Reyes (Demo)	tm-demo-traveler-04@example.test	\N	2	3200.00	completed	\N	tm-demo-v1-booking-hotel-04	2026-07-20 03:00:00+00	2026-08-07 10:00:00+00	unpaid	\N	\N
7e4726f5-a678-54cb-b2fb-563069faa4f7	6d736964-b99f-47cd-a81f-df9940200e61	restaurant	Paolo Reyes (Demo)	tm-demo-traveler-04@example.test	\N	2	140.00	completed	\N	tm-demo-v1-booking-restaurant-04	2026-07-20 03:00:00+00	2026-08-07 10:00:00+00	unpaid	\N	\N
dd9d796f-8b52-511d-a270-2e43108bb830	c4adf4a6-b1f1-45af-8842-27d723b9519c	hotel	Camille Garcia (Demo)	tm-demo-traveler-05@example.test	\N	2	3400.00	completed	\N	tm-demo-v1-booking-hotel-05	2026-07-20 03:00:00+00	2026-08-08 10:00:00+00	unpaid	\N	\N
c171473e-592a-5878-9495-bd21159e2efd	c4adf4a6-b1f1-45af-8842-27d723b9519c	restaurant	Camille Garcia (Demo)	tm-demo-traveler-05@example.test	\N	2	150.00	completed	\N	tm-demo-v1-booking-restaurant-05	2026-07-20 03:00:00+00	2026-08-08 10:00:00+00	unpaid	\N	\N
3c972c00-33b1-5331-b5ac-256aeddbf55f	3caf5b74-5392-4930-8f4b-ea57dd4f646f	hotel	Rafael Mendoza (Demo)	tm-demo-traveler-06@example.test	\N	2	3600.00	completed	\N	tm-demo-v1-booking-hotel-06	2026-07-20 03:00:00+00	2026-08-09 10:00:00+00	unpaid	\N	\N
1ebedf59-516e-5c66-b06f-f37631fa717c	3caf5b74-5392-4930-8f4b-ea57dd4f646f	restaurant	Rafael Mendoza (Demo)	tm-demo-traveler-06@example.test	\N	2	160.00	completed	\N	tm-demo-v1-booking-restaurant-06	2026-07-20 03:00:00+00	2026-08-09 10:00:00+00	unpaid	\N	\N
0a225aef-77bd-515c-bd57-49facf19bfec	c3f1a421-b31e-4352-9a90-761ab03e4498	hotel	Nina Flores (Demo)	tm-demo-traveler-07@example.test	\N	2	3800.00	completed	\N	tm-demo-v1-booking-hotel-07	2026-07-20 03:00:00+00	2026-08-10 10:00:00+00	unpaid	\N	\N
0d253c07-0789-5ff6-af54-b30a58c218f8	c3f1a421-b31e-4352-9a90-761ab03e4498	restaurant	Nina Flores (Demo)	tm-demo-traveler-07@example.test	\N	2	170.00	completed	\N	tm-demo-v1-booking-restaurant-07	2026-07-20 03:00:00+00	2026-08-10 10:00:00+00	unpaid	\N	\N
114e28dd-d2b2-5013-98b3-004aeb0b79ac	748530a7-420a-4609-93eb-980e78db48e3	hotel	Gabriel Torres (Demo)	tm-demo-traveler-08@example.test	\N	2	4000.00	completed	\N	tm-demo-v1-booking-hotel-08	2026-07-20 03:00:00+00	2026-08-11 10:00:00+00	unpaid	\N	\N
858b4ec0-e6fc-5fda-b7d9-888a7909e2e8	748530a7-420a-4609-93eb-980e78db48e3	restaurant	Gabriel Torres (Demo)	tm-demo-traveler-08@example.test	\N	2	180.00	completed	\N	tm-demo-v1-booking-restaurant-08	2026-07-20 03:00:00+00	2026-08-11 10:00:00+00	unpaid	\N	\N
61054763-93ad-5b9a-84d4-ad1dd65bd27d	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	hotel	Ella Navarro (Demo)	tm-demo-traveler-09@example.test	\N	2	4200.00	completed	\N	tm-demo-v1-booking-hotel-09	2026-07-20 03:00:00+00	2026-08-12 10:00:00+00	unpaid	\N	\N
564de051-ffe4-5a70-b15b-6672481b98b5	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	restaurant	Ella Navarro (Demo)	tm-demo-traveler-09@example.test	\N	2	190.00	completed	\N	tm-demo-v1-booking-restaurant-09	2026-07-20 03:00:00+00	2026-08-12 10:00:00+00	unpaid	\N	\N
7353719a-1f79-5371-b1a0-56f3cf76aa92	99f4f909-197a-433d-aa42-5d552f2778d5	hotel	Marco Castillo (Demo)	tm-demo-traveler-10@example.test	\N	2	4400.00	completed	\N	tm-demo-v1-booking-hotel-10	2026-07-20 03:00:00+00	2026-08-13 10:00:00+00	unpaid	\N	\N
60b147c8-1d18-5bb3-b91c-0f0dc5362c96	99f4f909-197a-433d-aa42-5d552f2778d5	restaurant	Marco Castillo (Demo)	tm-demo-traveler-10@example.test	\N	2	200.00	completed	\N	tm-demo-v1-booking-restaurant-10	2026-07-20 03:00:00+00	2026-08-13 10:00:00+00	unpaid	\N	\N
2bc25997-f7fd-5836-b78a-9f0aaadf938c	a4f9becd-16e4-47a7-b32d-39930b707c1f	hotel	Sofia Aguilar (Demo)	tm-demo-traveler-11@example.test	\N	2	4600.00	completed	\N	tm-demo-v1-booking-hotel-11	2026-07-20 03:00:00+00	2026-08-14 10:00:00+00	unpaid	\N	\N
650dd7dc-a4ea-5967-a32c-99ac6f392090	a4f9becd-16e4-47a7-b32d-39930b707c1f	restaurant	Sofia Aguilar (Demo)	tm-demo-traveler-11@example.test	\N	2	210.00	completed	\N	tm-demo-v1-booking-restaurant-11	2026-07-20 03:00:00+00	2026-08-14 10:00:00+00	unpaid	\N	\N
76a2903d-b252-5490-8584-18fe5d9d2628	5a4b619a-3c52-45ef-afaf-d3d1351f7343	hotel	Luis Santiago (Demo)	tm-demo-traveler-12@example.test	\N	2	4800.00	completed	\N	tm-demo-v1-booking-hotel-12	2026-07-20 03:00:00+00	2026-08-15 10:00:00+00	unpaid	\N	\N
c53777e1-6114-5a70-866d-50efe6104d51	5a4b619a-3c52-45ef-afaf-d3d1351f7343	restaurant	Luis Santiago (Demo)	tm-demo-traveler-12@example.test	\N	2	220.00	completed	\N	tm-demo-v1-booking-restaurant-12	2026-07-20 03:00:00+00	2026-08-15 10:00:00+00	unpaid	\N	\N
0f8ae9bf-5e4a-5746-a534-c53e61fd1a63	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	hotel	Mika Villanueva (Demo)	tm-demo-traveler-13@example.test	\N	2	5000.00	completed	\N	tm-demo-v1-booking-hotel-13	2026-07-20 03:00:00+00	2026-08-16 10:00:00+00	unpaid	\N	\N
1facbb60-c68d-5b8a-b5b0-3e91065525e0	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	restaurant	Mika Villanueva (Demo)	tm-demo-traveler-13@example.test	\N	2	230.00	completed	\N	tm-demo-v1-booking-restaurant-13	2026-07-20 03:00:00+00	2026-08-16 10:00:00+00	unpaid	\N	\N
92532d9f-b041-52f9-9095-513504eb4305	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	hotel	Daniel Aquino (Demo)	tm-demo-traveler-14@example.test	\N	2	5200.00	completed	\N	tm-demo-v1-booking-hotel-14	2026-07-20 03:00:00+00	2026-08-17 10:00:00+00	unpaid	\N	\N
e3efcfb0-12f1-5b45-8ee4-eea9d761c42b	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	restaurant	Daniel Aquino (Demo)	tm-demo-traveler-14@example.test	\N	2	240.00	completed	\N	tm-demo-v1-booking-restaurant-14	2026-07-20 03:00:00+00	2026-08-17 10:00:00+00	unpaid	\N	\N
11c56faa-db75-5c9f-bc78-7110ab4dc5ac	f5512436-7401-4ee0-88a0-095ca33c7cbb	hotel	Clara Bautista (Demo)	tm-demo-traveler-15@example.test	\N	2	5400.00	completed	\N	tm-demo-v1-booking-hotel-15	2026-07-20 03:00:00+00	2026-08-18 10:00:00+00	unpaid	\N	\N
03165b8d-e97e-5f0a-9047-eb25f4b81ab5	f5512436-7401-4ee0-88a0-095ca33c7cbb	restaurant	Clara Bautista (Demo)	tm-demo-traveler-15@example.test	\N	2	250.00	confirmed	\N	tm-demo-v1-booking-restaurant-15	2026-07-20 03:00:00+00	2026-10-03 18:08:50.5921+00	paid	cs_test_a1GImmF2xWqNBJnAVXoOfqf7I3ixAYe24IxrTIhzLOY3tVV4w2zocX85Bf	pi_3UMWPM8ekNHjfy6F0M68SZso
\.


--
-- Data for Name: business_listings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.business_listings (id, owner_id, destination_id, name, slug, listing_type, description, address, status, created_at, updated_at, reviewed_by, reviewed_at, rejection_reason) FROM stdin;
82c3bb86-1c0f-5ec4-ad34-672223d70608	29df924a-3eb4-5ca6-922f-2a7bb6f4770f	b1e02830-dbd4-4f9a-aaa3-34876be83810	Amihan Guesthouse (Demo)	tm-demo-hotel-01	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 1, Agoo, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
a083d312-6ccd-58cc-a890-e06a99bc2bb8	29df924a-3eb4-5ca6-922f-2a7bb6f4770f	b1e02830-dbd4-4f9a-aaa3-34876be83810	Amihan Kitchen (Demo)	tm-demo-restaurant-01	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 1, Agoo, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
b4684683-0b4e-57c7-a2da-538662ac1623	29df924a-3eb4-5ca6-922f-2a7bb6f4770f	b1e02830-dbd4-4f9a-aaa3-34876be83810	Amihan Craft Garden (Demo)	tm-demo-attraction-01	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 1, Agoo, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
33f41b4c-d352-5fe4-bb66-7a12e5b13c75	82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9	b8090183-fec2-420f-b103-b0b3d6f8a633	Bituin Guesthouse (Demo)	tm-demo-hotel-02	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 2, Aringay, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
151d6181-3837-5268-aea2-28404c4a756a	82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9	b8090183-fec2-420f-b103-b0b3d6f8a633	Bituin Kitchen (Demo)	tm-demo-restaurant-02	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 2, Aringay, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
c9c2d665-33f0-5eda-8cf4-0e45ec6d242a	82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9	b8090183-fec2-420f-b103-b0b3d6f8a633	Bituin Craft Garden (Demo)	tm-demo-attraction-02	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 2, Aringay, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
45c1b62c-dece-5435-be5e-a60d386fb7b8	650f700c-4cce-5f4c-8bda-6a4f650ede75	814a31d0-b736-45e1-a47b-e05541ac5a9a	Dalisay Guesthouse (Demo)	tm-demo-hotel-03	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 3, Bacnotan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
81dc328b-3be7-5b12-9b05-a3b3145b0c88	650f700c-4cce-5f4c-8bda-6a4f650ede75	814a31d0-b736-45e1-a47b-e05541ac5a9a	Dalisay Kitchen (Demo)	tm-demo-restaurant-03	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 3, Bacnotan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
87878ea1-db87-51e8-9e27-0db6321c8cf9	650f700c-4cce-5f4c-8bda-6a4f650ede75	814a31d0-b736-45e1-a47b-e05541ac5a9a	Dalisay Craft Garden (Demo)	tm-demo-attraction-03	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 3, Bacnotan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
b3ce66c3-4971-5e59-afb7-bd97e05ea55f	5189473a-f7bb-564f-b0b1-cb3a8478d4a5	dcac0e2d-39a3-427f-855d-b2f9662fb021	Hiraya Guesthouse (Demo)	tm-demo-hotel-04	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 4, Bagulin, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
edfa8fec-18f4-5300-95aa-4bd65eb25558	5189473a-f7bb-564f-b0b1-cb3a8478d4a5	dcac0e2d-39a3-427f-855d-b2f9662fb021	Hiraya Kitchen (Demo)	tm-demo-restaurant-04	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 4, Bagulin, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
78afeb8a-28d8-531b-af16-da8dad728550	5189473a-f7bb-564f-b0b1-cb3a8478d4a5	dcac0e2d-39a3-427f-855d-b2f9662fb021	Hiraya Craft Garden (Demo)	tm-demo-attraction-04	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 4, Bagulin, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
97d12e59-9306-5a71-bb23-cceefc44cfd1	eea0e58b-9652-5084-85e7-6bbe46350307	0c80412f-b4f3-4d99-baf8-681072cf34f7	Luntian Guesthouse (Demo)	tm-demo-hotel-05	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 5, Balaoan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
f938c99a-491f-5cf1-8bd4-b366b550bb56	eea0e58b-9652-5084-85e7-6bbe46350307	0c80412f-b4f3-4d99-baf8-681072cf34f7	Luntian Kitchen (Demo)	tm-demo-restaurant-05	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 5, Balaoan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
5c6e8d11-ba1c-5a15-bb5f-0870a1a3948b	eea0e58b-9652-5084-85e7-6bbe46350307	0c80412f-b4f3-4d99-baf8-681072cf34f7	Luntian Craft Garden (Demo)	tm-demo-attraction-05	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 5, Balaoan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
725197f4-b349-502e-acdb-c7660c422884	c5a1e919-b05f-5b58-b2ea-ee7e8c513645	c304304e-a89e-40b7-a827-7043c149ace0	Marilag Guesthouse (Demo)	tm-demo-hotel-06	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 6, Bangar, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
66f6c68a-f8fe-529f-b212-4547bb6709c9	c5a1e919-b05f-5b58-b2ea-ee7e8c513645	c304304e-a89e-40b7-a827-7043c149ace0	Marilag Kitchen (Demo)	tm-demo-restaurant-06	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 6, Bangar, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
c426d31f-ee4a-503c-ad03-b7668670cb1d	c5a1e919-b05f-5b58-b2ea-ee7e8c513645	c304304e-a89e-40b7-a827-7043c149ace0	Marilag Craft Garden (Demo)	tm-demo-attraction-06	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 6, Bangar, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	e6cd4c42-6b57-5c46-9fd4-32d75e311073	545b976c-9104-4c15-bf69-863b1ef4cf49	Mayumi Guesthouse (Demo)	tm-demo-hotel-07	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 7, Bauang, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
1806542c-12f1-5886-9692-161e2180f12f	e6cd4c42-6b57-5c46-9fd4-32d75e311073	545b976c-9104-4c15-bf69-863b1ef4cf49	Mayumi Kitchen (Demo)	tm-demo-restaurant-07	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 7, Bauang, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
56c0336f-aca2-506f-857e-bb9dc3a38575	e6cd4c42-6b57-5c46-9fd4-32d75e311073	545b976c-9104-4c15-bf69-863b1ef4cf49	Mayumi Craft Garden (Demo)	tm-demo-attraction-07	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 7, Bauang, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
d3412e6e-644e-5e2b-bcce-a7ee456917c1	465bc167-fa39-58bd-9c84-4bacebafba97	0445837d-520d-4fdf-9334-5bf9222f1e16	Mutya Guesthouse (Demo)	tm-demo-hotel-08	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 8, Burgos, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
d5cca9ba-5411-541f-8a94-ac593ac460f8	465bc167-fa39-58bd-9c84-4bacebafba97	0445837d-520d-4fdf-9334-5bf9222f1e16	Mutya Kitchen (Demo)	tm-demo-restaurant-08	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 8, Burgos, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
1d201536-a2f6-505b-80f9-d0000a2b6db8	465bc167-fa39-58bd-9c84-4bacebafba97	0445837d-520d-4fdf-9334-5bf9222f1e16	Mutya Craft Garden (Demo)	tm-demo-attraction-08	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 8, Burgos, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3	7061d75c-c9a5-4943-bfc9-6f2532cd323a	Sampaguita Guesthouse (Demo)	tm-demo-hotel-09	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 9, Caba, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
6fa94169-6895-50d2-a558-bbd2319adfd6	16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3	7061d75c-c9a5-4943-bfc9-6f2532cd323a	Sampaguita Kitchen (Demo)	tm-demo-restaurant-09	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 9, Caba, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
74b3172f-f41a-5743-bc4d-f6eb03a16047	16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3	7061d75c-c9a5-4943-bfc9-6f2532cd323a	Sampaguita Craft Garden (Demo)	tm-demo-attraction-09	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 9, Caba, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
9a488d00-e1b0-56e5-a144-975d4cf028d6	966f7bcc-8dc1-51c5-b910-e3f8a317f3f7	eb756643-47fd-4232-a94b-218cc9be6c09	Sinag Guesthouse (Demo)	tm-demo-hotel-10	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 10, Luna, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
41a40c49-1a84-54e0-a57c-13c9f35eee67	966f7bcc-8dc1-51c5-b910-e3f8a317f3f7	eb756643-47fd-4232-a94b-218cc9be6c09	Sinag Kitchen (Demo)	tm-demo-restaurant-10	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 10, Luna, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
50fc3f85-f202-5997-9828-6dd46035b3d3	966f7bcc-8dc1-51c5-b910-e3f8a317f3f7	eb756643-47fd-4232-a94b-218cc9be6c09	Sinag Craft Garden (Demo)	tm-demo-attraction-10	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 10, Luna, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
aace4668-7c23-57e6-9152-8172aef490b6	96e3d384-b745-51d5-8f03-ec434911025e	609998ae-3f65-45be-90d1-68bbb2bf9619	Tala Guesthouse (Demo)	tm-demo-hotel-11	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 11, Naguilian, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
f20c4c94-6527-590b-9d92-010183847313	96e3d384-b745-51d5-8f03-ec434911025e	609998ae-3f65-45be-90d1-68bbb2bf9619	Tala Kitchen (Demo)	tm-demo-restaurant-11	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 11, Naguilian, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
888d81e5-b37d-5452-b956-92a7523761e1	96e3d384-b745-51d5-8f03-ec434911025e	609998ae-3f65-45be-90d1-68bbb2bf9619	Tala Craft Garden (Demo)	tm-demo-attraction-11	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 11, Naguilian, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	7e22034a-af65-58f6-a141-f011fddf6912	1ebe6703-fbff-4b83-bd06-ab9527f2dc65	Silayan Guesthouse (Demo)	tm-demo-hotel-12	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 12, Pugo, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
0e8ffa31-2640-54c0-8ebf-2a58e81eccde	7e22034a-af65-58f6-a141-f011fddf6912	1ebe6703-fbff-4b83-bd06-ab9527f2dc65	Silayan Kitchen (Demo)	tm-demo-restaurant-12	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 12, Pugo, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
9415615e-4a1e-5330-a84d-80f1bb33037f	7e22034a-af65-58f6-a141-f011fddf6912	1ebe6703-fbff-4b83-bd06-ab9527f2dc65	Silayan Craft Garden (Demo)	tm-demo-attraction-12	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 12, Pugo, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
985a6a86-06a3-5c91-8d1b-24f504a3c01b	6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe	7e4ab8c3-5c11-490e-b548-9c66b65c45be	Malaya Guesthouse (Demo)	tm-demo-hotel-13	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 13, Rosario, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
d9eb84af-8227-5c6f-a346-3708594abd23	6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe	7e4ab8c3-5c11-490e-b548-9c66b65c45be	Malaya Kitchen (Demo)	tm-demo-restaurant-13	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 13, Rosario, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
dc057260-3d1f-5736-94ab-a2f8c2222a5f	6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe	7e4ab8c3-5c11-490e-b548-9c66b65c45be	Malaya Craft Garden (Demo)	tm-demo-attraction-13	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 13, Rosario, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	cd23ed36-e393-5e54-9576-5e51e7858b91	7159ad9e-653d-4575-9598-569d54e519b3	Liwayway Guesthouse (Demo)	tm-demo-hotel-14	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 14, San Fernando City, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
5dc87c99-76c8-5404-9e48-48dec03b3533	cd23ed36-e393-5e54-9576-5e51e7858b91	7159ad9e-653d-4575-9598-569d54e519b3	Liwayway Kitchen (Demo)	tm-demo-restaurant-14	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 14, San Fernando City, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
c80b65fe-d043-5b4d-8127-87bb1a2bb5e5	cd23ed36-e393-5e54-9576-5e51e7858b91	7159ad9e-653d-4575-9598-569d54e519b3	Liwayway Craft Garden (Demo)	tm-demo-attraction-14	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 14, San Fernando City, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
58486d62-05e9-5e1f-be39-fc315fff5f5c	127dd080-9b40-56d2-a99a-fd626a602fa4	df51b4af-a619-47fc-81d8-5d97c021ef15	Ligaya Guesthouse (Demo)	tm-demo-hotel-15	hotel	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 15, San Juan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
1b84ae34-a436-5efa-a3f6-41929b781669	127dd080-9b40-56d2-a99a-fd626a602fa4	df51b4af-a619-47fc-81d8-5d97c021ef15	Ligaya Kitchen (Demo)	tm-demo-restaurant-15	restaurant	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 15, San Juan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
f6e1127b-0493-5626-b4e0-62bb503d863d	127dd080-9b40-56d2-a99a-fd626a602fa4	df51b4af-a619-47fc-81d8-5d97c021ef15	Ligaya Craft Garden (Demo)	tm-demo-attraction-15	attraction	Fictional classroom demonstration listing. Not a real business or bookable offer.	Demo Lane 15, San Juan, La Union (fictional street)	approved	2026-07-01 00:00:00+00	2026-07-01 00:00:00+00	\N	\N	\N
06f7fb52-4345-4555-a27f-258d8e829b95	fb81a9bb-82ed-4e1c-94b7-2a0a52567fa1	b1e02830-dbd4-4f9a-aaa3-34876be83810	okew	boolabola2-a15217	restaurant	\N	mabini st	approved	2026-10-04 01:48:36.242828+00	2026-10-04 14:08:12.341235+00	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	2026-10-04 14:08:12.341235+00	\N
\.


--
-- Data for Name: business_owners; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.business_owners (id, profile_id, contact_name, contact_email) FROM stdin;
29df924a-3eb4-5ca6-922f-2a7bb6f4770f	08c59a01-6bf6-44c6-b6f1-de0131a3dccf	Elena Mercado (Demo)	tm-demo-owner-01@example.test
82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9	e5931678-254c-4abf-85fa-71e667896a41	Adrian Domingo (Demo)	tm-demo-owner-02@example.test
650f700c-4cce-5f4c-8bda-6a4f650ede75	41942500-0b1b-4215-a759-29ffd1733f27	Carla Valdez (Demo)	tm-demo-owner-03@example.test
5189473a-f7bb-564f-b0b1-cb3a8478d4a5	fe304e3d-1946-46cb-bb2d-77f8702c0f05	Nico Soriano (Demo)	tm-demo-owner-04@example.test
eea0e58b-9652-5084-85e7-6bbe46350307	392e6791-10b8-4c3d-8800-9efe6d29f8b2	Diana Pascual (Demo)	tm-demo-owner-05@example.test
c5a1e919-b05f-5b58-b2ea-ee7e8c513645	8e59134a-da94-4cd6-9eb7-ff46c9d56195	Enzo Salazar (Demo)	tm-demo-owner-06@example.test
e6cd4c42-6b57-5c46-9fd4-32d75e311073	34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	Lara Fernandez (Demo)	tm-demo-owner-07@example.test
465bc167-fa39-58bd-9c84-4bacebafba97	6a11f3df-d69c-4148-80ee-88f1f7c95e2a	Anton Rivera (Demo)	tm-demo-owner-08@example.test
16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3	9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	Mara Dela Cruz (Demo)	tm-demo-owner-09@example.test
966f7bcc-8dc1-51c5-b910-e3f8a317f3f7	c4a4841a-aa8a-4de6-b83c-b2bd6203042c	Jules Rosales (Demo)	tm-demo-owner-10@example.test
96e3d384-b745-51d5-8f03-ec434911025e	8eba38fb-47ef-4be9-b26e-b109bccf0031	Iris Manalo (Demo)	tm-demo-owner-11@example.test
7e22034a-af65-58f6-a141-f011fddf6912	5b305524-490a-4334-831e-b46d622648a8	Theo Herrera (Demo)	tm-demo-owner-12@example.test
6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe	1ef0a385-782d-4808-999a-58733a4b209d	Lea Ignacio (Demo)	tm-demo-owner-13@example.test
cd23ed36-e393-5e54-9576-5e51e7858b91	0ea90927-1b7e-4674-a3df-092d82395d70	Ivan Padilla (Demo)	tm-demo-owner-14@example.test
127dd080-9b40-56d2-a99a-fd626a602fa4	df48bcda-05d5-4d27-8b94-0fec879a5ab8	Celia Del Rosario (Demo)	tm-demo-owner-15@example.test
fb81a9bb-82ed-4e1c-94b7-2a0a52567fa1	9f8f0e34-1876-4a04-9a26-a65537ad2f33	RIMNARWHAL	rimnarwhal@gmail.com
acdd4ac2-e9d1-496e-a7e9-31919a7356bc	1f35520c-9114-4cbb-b369-86d2b431c76e	Jonas Wally Loyola	jonasloyola6@gmail.com
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, description) FROM stdin;
1e5b6885-04c0-427a-990b-dd31a6621ca6	Coastal towns	TravelMate sample category for planning and browsing.
58820f14-b87e-44df-8e7d-a0e844a3d57d	Mountain escapes	TravelMate sample category for planning and browsing.
1342fb1b-c639-45cb-80d0-b0ad0b41295b	Heritage towns	TravelMate sample category for planning and browsing.
a0f683c1-bf81-4eed-ab5c-8819060b8177	City breaks	TravelMate sample category for planning and browsing.
2bcaf031-8125-4f19-8090-ab5f4e0bb474	Nature parks	TravelMate sample category for planning and browsing.
87ea5114-f235-4d91-bbc1-90222e43f4cd	Waterfall trips	TravelMate sample category for planning and browsing.
f5fc5b0c-ecb1-420c-b8a3-c6d2ef6923e1	River activities	TravelMate sample category for planning and browsing.
255854d3-2d6b-4d04-993a-8614c657f901	Farm visits	TravelMate sample category for planning and browsing.
841f3b6b-28d8-4a82-8cf3-c413889e557b	Craft communities	TravelMate sample category for planning and browsing.
fde7c7ea-2f46-47f0-93e6-079b423a9139	Food trails	TravelMate sample category for planning and browsing.
3031b3b3-17bb-4724-a280-4bc76b6d38e4	Cultural sites	TravelMate sample category for planning and browsing.
c814adc6-9ea0-45e8-8124-60ef4f28cbe6	Island trips	TravelMate sample category for planning and browsing.
6cbee3e9-904d-4869-a47f-d5aedbd4cc61	Garden visits	TravelMate sample category for planning and browsing.
1cea23cf-74c9-40f3-af7a-fcf88a16ee37	Scenic drives	TravelMate sample category for planning and browsing.
682ab252-3b96-4392-a5cf-568e626b866a	Family outings	TravelMate sample category for planning and browsing.
\.


--
-- Data for Name: cuisines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cuisines (id, name) FROM stdin;
290427dd-9131-44cd-b6ba-a1bc85c9fc93	Ilocano
34aa6d14-2d85-4c01-abb7-1bfec02a7502	Filipino
f8a5bb5d-a6a7-4eec-a92d-d4b3b4861e8a	Seafood
67608615-01ef-426b-b5f9-473dc83f45fd	Vegetarian
0c8d8f78-d2f1-431b-9f93-0a6e1bc9a2ad	Japanese
59a22810-10ff-440d-8b73-3bde4da403ac	Korean
34a1ee8e-2181-4a0d-9d79-9caa5b2a07be	Chinese
50f4399c-6941-4e81-b23a-1a1b2c73558e	Italian
4c794d4c-517d-4589-8080-a307fb6d5ab8	Thai
c8c185b9-5c65-4d61-9aef-3d66f53aced3	Indian
95362d33-8c83-4f1d-a4f7-9313b0fb5f25	Mexican
a76c1503-25a8-4f9f-a51b-00b896dac86e	Mediterranean
b6edd29a-6077-45cf-97c8-8adf4665fb5c	American
d2fcf8c0-89e5-4228-aa26-3aaf6537aaa1	Bakery
abf227e4-fe47-4219-ab32-a2aa34819cce	Cafe
\.


--
-- Data for Name: data_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.data_sources (id, name) FROM stdin;
f228ff3c-19eb-5521-a056-adce4d3c046f	Business listings
5dd30fa4-577c-5f4d-a7a9-7ffb54808eab	Bookings
70a64d28-6b70-5838-a65b-d44b2347dbc5	Hotel bookings
89870b82-f2f8-5301-a7d7-603927e9cb9a	Restaurant bookings
585cbb78-1298-5914-90e8-59c011145c4c	Rooms
5f440c43-530a-51a0-8697-fc560db66714	Menu items
15cb7ec9-c3d2-56dd-b476-0a341738a3d2	Reviews
8b9a0178-bea5-5a96-aa2e-6d4d91992364	Refunds
ea50b906-4f02-5ce2-a9cd-546108b658a4	Payments
2cd6d50b-53dd-5113-a900-3f4369e1e4d1	Trips
aec63ddf-396c-55f6-b69f-925748a0a393	Saved destinations
c6ae7564-86a5-58e6-a746-d8fe26772021	Transportation services
39798a41-00a8-528f-ab09-3bef6ca00d53	Photos
e2546a66-dd10-5a05-824c-52c1d46a6e89	User reports
d4ff727b-f0e5-5251-b0b4-90ffd3151d6e	Profile preferences
\.


--
-- Data for Name: destinations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.destinations (id, category_id, name, province, slug, description, latitude, longitude, is_active, created_at, updated_at) FROM stdin;
b1e02830-dbd4-4f9a-aaa3-34876be83810	682ab252-3b96-4392-a5cf-568e626b866a	Agoo	La Union	agoo-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
b8090183-fec2-420f-b103-b0b3d6f8a633	682ab252-3b96-4392-a5cf-568e626b866a	Aringay	La Union	aringay-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
814a31d0-b736-45e1-a47b-e05541ac5a9a	682ab252-3b96-4392-a5cf-568e626b866a	Bacnotan	La Union	bacnotan-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
dcac0e2d-39a3-427f-855d-b2f9662fb021	682ab252-3b96-4392-a5cf-568e626b866a	Bagulin	La Union	bagulin-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
0c80412f-b4f3-4d99-baf8-681072cf34f7	682ab252-3b96-4392-a5cf-568e626b866a	Balaoan	La Union	balaoan-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
c304304e-a89e-40b7-a827-7043c149ace0	682ab252-3b96-4392-a5cf-568e626b866a	Bangar	La Union	bangar-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
545b976c-9104-4c15-bf69-863b1ef4cf49	682ab252-3b96-4392-a5cf-568e626b866a	Bauang	La Union	bauang-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
0445837d-520d-4fdf-9334-5bf9222f1e16	682ab252-3b96-4392-a5cf-568e626b866a	Burgos	La Union	burgos-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
7061d75c-c9a5-4943-bfc9-6f2532cd323a	682ab252-3b96-4392-a5cf-568e626b866a	Caba	La Union	caba-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
eb756643-47fd-4232-a94b-218cc9be6c09	682ab252-3b96-4392-a5cf-568e626b866a	Luna	La Union	luna-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
609998ae-3f65-45be-90d1-68bbb2bf9619	682ab252-3b96-4392-a5cf-568e626b866a	Naguilian	La Union	naguilian-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
1ebe6703-fbff-4b83-bd06-ab9527f2dc65	682ab252-3b96-4392-a5cf-568e626b866a	Pugo	La Union	pugo-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
7e4ab8c3-5c11-490e-b548-9c66b65c45be	682ab252-3b96-4392-a5cf-568e626b866a	Rosario	La Union	rosario-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
7159ad9e-653d-4575-9598-569d54e519b3	682ab252-3b96-4392-a5cf-568e626b866a	San Fernando City	La Union	san-fernando-city-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
df51b4af-a619-47fc-81d8-5d97c021ef15	682ab252-3b96-4392-a5cf-568e626b866a	San Juan	La Union	san-juan-la-union	Sample TravelMate destination entry. Venue details will use fictional demonstration records.	\N	\N	1	2026-09-17 12:46:08.639996+00	2026-09-17 12:46:08.639996+00
\.


--
-- Data for Name: hotel_amenities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hotel_amenities (hotel_id, amenity_id) FROM stdin;
82c3bb86-1c0f-5ec4-ad34-672223d70608	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
82c3bb86-1c0f-5ec4-ad34-672223d70608	64550e32-d148-48c8-93e9-1a20011d0520
33f41b4c-d352-5fe4-bb66-7a12e5b13c75	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
33f41b4c-d352-5fe4-bb66-7a12e5b13c75	64550e32-d148-48c8-93e9-1a20011d0520
45c1b62c-dece-5435-be5e-a60d386fb7b8	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
45c1b62c-dece-5435-be5e-a60d386fb7b8	64550e32-d148-48c8-93e9-1a20011d0520
b3ce66c3-4971-5e59-afb7-bd97e05ea55f	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
b3ce66c3-4971-5e59-afb7-bd97e05ea55f	64550e32-d148-48c8-93e9-1a20011d0520
97d12e59-9306-5a71-bb23-cceefc44cfd1	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
97d12e59-9306-5a71-bb23-cceefc44cfd1	64550e32-d148-48c8-93e9-1a20011d0520
725197f4-b349-502e-acdb-c7660c422884	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
725197f4-b349-502e-acdb-c7660c422884	64550e32-d148-48c8-93e9-1a20011d0520
3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	64550e32-d148-48c8-93e9-1a20011d0520
d3412e6e-644e-5e2b-bcce-a7ee456917c1	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
d3412e6e-644e-5e2b-bcce-a7ee456917c1	64550e32-d148-48c8-93e9-1a20011d0520
db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	64550e32-d148-48c8-93e9-1a20011d0520
9a488d00-e1b0-56e5-a144-975d4cf028d6	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
9a488d00-e1b0-56e5-a144-975d4cf028d6	64550e32-d148-48c8-93e9-1a20011d0520
aace4668-7c23-57e6-9152-8172aef490b6	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
aace4668-7c23-57e6-9152-8172aef490b6	64550e32-d148-48c8-93e9-1a20011d0520
1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	64550e32-d148-48c8-93e9-1a20011d0520
985a6a86-06a3-5c91-8d1b-24f504a3c01b	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
985a6a86-06a3-5c91-8d1b-24f504a3c01b	64550e32-d148-48c8-93e9-1a20011d0520
7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	64550e32-d148-48c8-93e9-1a20011d0520
58486d62-05e9-5e1f-be39-fc315fff5f5c	d7142244-31aa-4ea5-b2a5-92c3ce6869d6
58486d62-05e9-5e1f-be39-fc315fff5f5c	64550e32-d148-48c8-93e9-1a20011d0520
\.


--
-- Data for Name: hotel_bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hotel_bookings (booking_id, hotel_id, check_in, check_out) FROM stdin;
1f05c565-9d85-5547-b78a-1d48c65a7ac5	82c3bb86-1c0f-5ec4-ad34-672223d70608	2026-08-02	2026-08-04
10c8e7ce-aecb-53af-b11f-4bd1b64341a9	33f41b4c-d352-5fe4-bb66-7a12e5b13c75	2026-08-03	2026-08-05
84afe302-1517-5245-a0a4-6e97149c3d2f	45c1b62c-dece-5435-be5e-a60d386fb7b8	2026-08-04	2026-08-06
838cd55a-ef2c-58da-a8ca-9760668af078	b3ce66c3-4971-5e59-afb7-bd97e05ea55f	2026-08-05	2026-08-07
dd9d796f-8b52-511d-a270-2e43108bb830	97d12e59-9306-5a71-bb23-cceefc44cfd1	2026-08-06	2026-08-08
3c972c00-33b1-5331-b5ac-256aeddbf55f	725197f4-b349-502e-acdb-c7660c422884	2026-08-07	2026-08-09
0a225aef-77bd-515c-bd57-49facf19bfec	3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	2026-08-08	2026-08-10
114e28dd-d2b2-5013-98b3-004aeb0b79ac	d3412e6e-644e-5e2b-bcce-a7ee456917c1	2026-08-09	2026-08-11
61054763-93ad-5b9a-84d4-ad1dd65bd27d	db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	2026-08-10	2026-08-12
7353719a-1f79-5371-b1a0-56f3cf76aa92	9a488d00-e1b0-56e5-a144-975d4cf028d6	2026-08-11	2026-08-13
2bc25997-f7fd-5836-b78a-9f0aaadf938c	aace4668-7c23-57e6-9152-8172aef490b6	2026-08-12	2026-08-14
76a2903d-b252-5490-8584-18fe5d9d2628	1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	2026-08-13	2026-08-15
0f8ae9bf-5e4a-5746-a534-c53e61fd1a63	985a6a86-06a3-5c91-8d1b-24f504a3c01b	2026-08-14	2026-08-16
92532d9f-b041-52f9-9095-513504eb4305	7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	2026-08-15	2026-08-17
11c56faa-db75-5c9f-bc78-7110ab4dc5ac	58486d62-05e9-5e1f-be39-fc315fff5f5c	2026-08-16	2026-08-18
\.


--
-- Data for Name: hotels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hotels (hotel_id, check_in_time, check_out_time) FROM stdin;
82c3bb86-1c0f-5ec4-ad34-672223d70608	14:00:00	11:00:00
33f41b4c-d352-5fe4-bb66-7a12e5b13c75	14:00:00	11:00:00
45c1b62c-dece-5435-be5e-a60d386fb7b8	14:00:00	11:00:00
b3ce66c3-4971-5e59-afb7-bd97e05ea55f	14:00:00	11:00:00
97d12e59-9306-5a71-bb23-cceefc44cfd1	14:00:00	11:00:00
725197f4-b349-502e-acdb-c7660c422884	14:00:00	11:00:00
3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	14:00:00	11:00:00
d3412e6e-644e-5e2b-bcce-a7ee456917c1	14:00:00	11:00:00
db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	14:00:00	11:00:00
9a488d00-e1b0-56e5-a144-975d4cf028d6	14:00:00	11:00:00
aace4668-7c23-57e6-9152-8172aef490b6	14:00:00	11:00:00
1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	14:00:00	11:00:00
985a6a86-06a3-5c91-8d1b-24f504a3c01b	14:00:00	11:00:00
7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	14:00:00	11:00:00
58486d62-05e9-5e1f-be39-fc315fff5f5c	14:00:00	11:00:00
\.


--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.menu_items (id, restaurant_id, name, description, category, price, is_available) FROM stdin;
a45c9085-2d61-577d-bb9d-fb2e7456c858	a083d312-6ccd-58cc-a890-e06a99bc2bb8	Vegetable rice bowl	Fictional demonstration menu item.	Meals	130.00	1
2eae8897-aa53-5c44-a73d-2f1e02bade20	151d6181-3837-5268-aea2-28404c4a756a	Grilled fish plate	Fictional demonstration menu item.	Meals	140.00	1
58de9b39-3ab0-5496-96f4-f001c89d713f	81dc328b-3be7-5b12-9b05-a3b3145b0c88	Chicken rice meal	Fictional demonstration menu item.	Meals	150.00	1
fd856873-74a8-52a5-97f9-9049767d3c37	edfa8fec-18f4-5300-95aa-4bd65eb25558	Mushroom pasta	Fictional demonstration menu item.	Meals	160.00	1
fe84cb76-8b0a-5522-ab98-0ac5bb57eb1e	f938c99a-491f-5cf1-8bd4-b366b550bb56	Vegetable soup	Fictional demonstration menu item.	Meals	170.00	1
697764f4-b593-5597-bd7a-347f66585022	66f6c68a-f8fe-529f-b212-4547bb6709c9	Tofu rice plate	Fictional demonstration menu item.	Meals	180.00	1
21530e5a-2760-57f6-a039-add2900a128f	1806542c-12f1-5886-9692-161e2180f12f	Egg sandwich	Fictional demonstration menu item.	Meals	190.00	1
4028fdc0-5403-50e9-ae40-fb93e7eafeaa	d5cca9ba-5411-541f-8a94-ac593ac460f8	Fresh fruit bowl	Fictional demonstration menu item.	Meals	200.00	1
236f56ee-2ef5-5fd7-a086-71198c69c266	6fa94169-6895-50d2-a558-bbd2319adfd6	Pancake breakfast	Fictional demonstration menu item.	Meals	210.00	1
9b15f833-3e59-5b49-9916-d9106d85f8f5	41a40c49-1a84-54e0-a57c-13c9f35eee67	Noodle soup	Fictional demonstration menu item.	Meals	220.00	1
85b56bf5-3940-5677-a17b-91c096deebdb	f20c4c94-6527-590b-9d92-010183847313	Garden salad	Fictional demonstration menu item.	Meals	230.00	1
4eb82c7e-ba1f-57b4-be77-5b005b95e95f	0e8ffa31-2640-54c0-8ebf-2a58e81eccde	Chicken noodle bowl	Fictional demonstration menu item.	Meals	240.00	1
6a1ad2ec-09db-54f6-b31b-0db25185f1a9	d9eb84af-8227-5c6f-a346-3708594abd23	Vegetable wrap	Fictional demonstration menu item.	Meals	250.00	1
c3d952a6-3d18-57ec-8778-040f7ce601a6	5dc87c99-76c8-5404-9e48-48dec03b3533	Seafood rice bowl	Fictional demonstration menu item.	Meals	260.00	1
4ae5f514-b3f2-5e33-92bd-75f37ddf21a4	1b84ae34-a436-5efa-a3f6-41929b781669	Tomato pasta	Fictional demonstration menu item.	Meals	270.00	1
127ef9ee-b2de-42bb-b5ec-e8968d8ca644	06f7fb52-4345-4555-a27f-258d8e829b95	sinigang na milk tea	dwdatesrt	soup drink	100.00	1
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, profile_id, message, read_at, created_at) FROM stdin;
46705278-d6f7-561c-87db-aba0f98a86ee	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	Demo: your Agoo itinerary has been completed.	\N	2026-08-04 10:05:00+00
cd69d414-e8f2-5473-93a6-62ac6c875da4	7562e428-178e-430b-af77-04f4a7fbaa0a	Demo: your Aringay itinerary has been completed.	\N	2026-08-05 10:05:00+00
b273eceb-4b8c-5dfd-8b2a-3fb118e16da1	9b8013fc-8493-409a-8f9f-f563b7d7c315	Demo: your Bacnotan itinerary has been completed.	\N	2026-08-06 10:05:00+00
15ff1a8e-100f-5f1f-ad2d-c199b5395708	6d736964-b99f-47cd-a81f-df9940200e61	Demo: your Bagulin itinerary has been completed.	\N	2026-08-07 10:05:00+00
4ca6ba3e-ff9b-5210-96f3-354c5e0f14b9	c4adf4a6-b1f1-45af-8842-27d723b9519c	Demo: your Balaoan itinerary has been completed.	\N	2026-08-08 10:05:00+00
08c78823-8298-50eb-a7e1-c0c388dedfd9	3caf5b74-5392-4930-8f4b-ea57dd4f646f	Demo: your Bangar itinerary has been completed.	\N	2026-08-09 10:05:00+00
731f70cf-3023-545a-8172-333c5e7926bc	c3f1a421-b31e-4352-9a90-761ab03e4498	Demo: your Bauang itinerary has been completed.	\N	2026-08-10 10:05:00+00
c191f293-bcd5-516e-8603-cd02431a4af2	748530a7-420a-4609-93eb-980e78db48e3	Demo: your Burgos itinerary has been completed.	\N	2026-08-11 10:05:00+00
35d52682-52ff-5108-99c3-d8cc6268e67e	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	Demo: your Caba itinerary has been completed.	\N	2026-08-12 10:05:00+00
8388562e-3b87-5c92-80d5-97be78344858	99f4f909-197a-433d-aa42-5d552f2778d5	Demo: your Luna itinerary has been completed.	\N	2026-08-13 10:05:00+00
6093bc7c-6ec4-52a0-9980-6b5e57ef204b	a4f9becd-16e4-47a7-b32d-39930b707c1f	Demo: your Naguilian itinerary has been completed.	\N	2026-08-14 10:05:00+00
e2ae8b99-3972-5621-a000-49b16f173a57	5a4b619a-3c52-45ef-afaf-d3d1351f7343	Demo: your Pugo itinerary has been completed.	\N	2026-08-15 10:05:00+00
15a59c86-06cd-5d4e-a6a4-a641ce8f0c2e	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	Demo: your Rosario itinerary has been completed.	\N	2026-08-16 10:05:00+00
ae20fff7-e78d-5ef6-b0be-5e2b5ff005fb	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	Demo: your San Fernando City itinerary has been completed.	\N	2026-08-17 10:05:00+00
f9af9719-c5ea-5855-af90-904bfbee1d79	f5512436-7401-4ee0-88a0-095ca33c7cbb	Demo: your San Juan itinerary has been completed.	\N	2026-08-18 10:05:00+00
a675c0a7-8a48-4698-b937-60ffedf00710	024f263f-0def-45aa-b740-8882d949bd77	Hotel listing "BOOLABOLA" is awaiting review.	\N	2026-10-03 13:45:39.384251+00
533e7117-36d7-4c10-8fdb-c2f9df924bb5	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "BOOLABOLA" status changed to rejected	2026-10-03 13:45:49.30457+00	2026-10-03 13:41:36.089053+00
0bb64638-67d2-4783-afe9-c90348229a14	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Your hotel listing "BOOLABOLA" was not approved. Reason: test	2026-10-03 13:45:49.30457+00	2026-10-03 13:41:36.089053+00
0cf89f2c-7785-4713-b911-6b0c04ac9f74	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "BOOLABOLA" status changed to pending	2026-10-03 13:45:49.30457+00	2026-10-03 13:45:39.384251+00
498b4100-5b9f-40c7-83cd-6eec827c4907	024f263f-0def-45aa-b740-8882d949bd77	Restaurant listing "BOOLABOLA2" is awaiting review.	\N	2026-10-04 01:29:39.659253+00
8484da93-5554-45ed-ac45-635f986e53ea	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "BOOLABOLA2" status changed to approved	\N	2026-10-04 01:34:58.472906+00
c9afbb93-82d1-412e-8669-71a2cb785b3a	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Your restaurant listing "BOOLABOLA2" was approved and is now visible to travelers.	\N	2026-10-04 01:34:58.472906+00
e90d131a-671e-4e69-bc49-51fb0fe36739	024f263f-0def-45aa-b740-8882d949bd77	Restaurant listing "BOOLABOLA2" is awaiting review.	\N	2026-10-04 01:39:05.417704+00
c963f50d-9d4d-421a-8ea5-1b8f9e541b46	024f263f-0def-45aa-b740-8882d949bd77	Restaurant listing "BOOLABOLA2" is awaiting review.	\N	2026-10-04 01:40:14.584349+00
5803c707-12aa-420f-b9b5-32e9f7cacfb1	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "BOOLABOLA2" status changed to pending	\N	2026-10-04 01:40:14.584349+00
2c1d907a-5fa6-402f-9807-f67d18ac9390	024f263f-0def-45aa-b740-8882d949bd77	Restaurant listing "BOOLABOLA2" is awaiting review.	\N	2026-10-04 01:48:36.242828+00
3a139ae8-84dd-48d8-aaa5-13fd232faeac	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	Hotel listing "BOOLABOLA" is awaiting review.	2026-10-04 01:55:30.695243+00	2026-10-03 13:45:39.384251+00
f72a6f8e-a2e2-4c16-8f8d-f6652039b039	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	Restaurant listing "BOOLABOLA2" is awaiting review.	2026-10-04 01:55:30.695243+00	2026-10-04 01:29:39.659253+00
6248c374-5bb4-43be-86e7-1b877c0f43b6	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	Restaurant listing "BOOLABOLA2" is awaiting review.	2026-10-04 01:55:30.695243+00	2026-10-04 01:39:05.417704+00
7c2efeb8-a1bc-4661-abf0-85bec72e6e1c	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	Restaurant listing "BOOLABOLA2" is awaiting review.	2026-10-04 01:55:30.695243+00	2026-10-04 01:40:14.584349+00
48dba5dc-176f-404a-afbe-de8a9d925ff4	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	Restaurant listing "BOOLABOLA2" is awaiting review.	2026-10-04 01:55:30.695243+00	2026-10-04 01:48:36.242828+00
ca4c336c-b270-45bf-a2b6-86cae11d8b8d	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "BOOLABOLA2" status changed to rejected	\N	2026-10-04 01:55:33.453331+00
0904c68c-aa10-43f3-902f-018dbec5e453	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Your restaurant listing "BOOLABOLA2" was not approved. Reason: testing	\N	2026-10-04 01:55:33.453331+00
5a9143a4-4fa9-4512-acba-894d6bb8e7de	024f263f-0def-45aa-b740-8882d949bd77	Restaurant listing "okew" is awaiting review.	\N	2026-10-04 01:56:00.781472+00
8be45d1f-ab22-44b8-9ffc-a656f1313646	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "okew" status changed to pending	\N	2026-10-04 01:56:00.781472+00
0ca22270-b8d3-4840-9fcb-a20251c250aa	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "okew" status changed to approved	\N	2026-10-04 01:59:17.855535+00
4bf68f83-e378-4e20-bf09-0a16b3d8cb50	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Your restaurant listing "okew" was approved and is now visible to travelers.	\N	2026-10-04 01:59:17.855535+00
6a60ea2e-7005-4c87-af5c-9e18f90f2c92	024f263f-0def-45aa-b740-8882d949bd77	Restaurant listing "okew" is awaiting review.	\N	2026-10-04 02:12:23.703551+00
ff4b24e4-01bd-4e5d-bd52-9f1693341114	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "okew" status changed to pending	\N	2026-10-04 02:12:23.703551+00
34346e9a-0347-4200-90f8-8bbdcae59e94	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Listing "okew" status changed to approved	\N	2026-10-04 14:08:12.341235+00
8b254f39-75d3-4527-b350-62277d055d7b	9f8f0e34-1876-4a04-9a26-a65537ad2f33	Your restaurant listing "okew" was approved and is now visible to travelers.	\N	2026-10-04 14:08:12.341235+00
0cfbda89-8fd0-42ce-ac16-5748c3272ab7	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	Restaurant listing "okew" is awaiting review.	2026-10-04 14:08:19.664247+00	2026-10-04 01:56:00.781472+00
8cd5c362-dd3d-4ec3-a461-198f9c7dfab7	3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	Restaurant listing "okew" is awaiting review.	2026-10-04 14:08:19.664247+00	2026-10-04 02:12:23.703551+00
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, booking_id, method, provider, provider_reference, idempotency_key, amount, status, is_demo, created_at, paid_at) FROM stdin;
e342643d-92c9-53d5-ab0b-76360e9debfd	1f05c565-9d85-5547-b78a-1d48c65a7ac5	card	demo	DEMO-HOTEL-01	tm-demo-v1-payment-hotel-01	2600.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
3e87a6b8-c52a-569f-a7ea-2026f518f008	9f650f7f-ad1c-5029-b5e7-55194f71a382	card	demo	DEMO-RESTAURANT-01	tm-demo-v1-payment-restaurant-01	110.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
cc7ad41a-eafe-56e1-be1b-0b8c4fb6957e	10c8e7ce-aecb-53af-b11f-4bd1b64341a9	card	demo	DEMO-HOTEL-02	tm-demo-v1-payment-hotel-02	2800.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
4ac0d5c2-7017-5331-96ad-230db2edef1b	a9ba838e-30f2-5ee0-8fde-e978b0e67fa2	card	demo	DEMO-RESTAURANT-02	tm-demo-v1-payment-restaurant-02	120.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
0421f0b7-b144-5a5c-9f16-c99e277d9289	84afe302-1517-5245-a0a4-6e97149c3d2f	card	demo	DEMO-HOTEL-03	tm-demo-v1-payment-hotel-03	3000.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
d057cbba-3ccd-561a-8fce-2a272fa8acfd	2150d480-c117-5bcc-b0f4-87f280851492	card	demo	DEMO-RESTAURANT-03	tm-demo-v1-payment-restaurant-03	130.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
b5ad5015-8c51-519e-a8de-eb717e2bfdc3	838cd55a-ef2c-58da-a8ca-9760668af078	card	demo	DEMO-HOTEL-04	tm-demo-v1-payment-hotel-04	3200.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
0866d9a2-a023-5581-9599-f07b9677ed47	7e4726f5-a678-54cb-b2fb-563069faa4f7	card	demo	DEMO-RESTAURANT-04	tm-demo-v1-payment-restaurant-04	140.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
45e74530-8002-5530-9421-d604e14ba2b6	dd9d796f-8b52-511d-a270-2e43108bb830	card	demo	DEMO-HOTEL-05	tm-demo-v1-payment-hotel-05	3400.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
54aec8e3-075e-59a5-bf22-3efa10bb8fd4	c171473e-592a-5878-9495-bd21159e2efd	card	demo	DEMO-RESTAURANT-05	tm-demo-v1-payment-restaurant-05	150.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
02c708ae-faa0-5f93-8563-ed708e3c7e0b	3c972c00-33b1-5331-b5ac-256aeddbf55f	card	demo	DEMO-HOTEL-06	tm-demo-v1-payment-hotel-06	3600.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
7b4ece19-f48f-53b7-9d13-2e702258b184	1ebedf59-516e-5c66-b06f-f37631fa717c	card	demo	DEMO-RESTAURANT-06	tm-demo-v1-payment-restaurant-06	160.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
fe43012c-4866-50f7-a092-3ffa5437a4f1	0a225aef-77bd-515c-bd57-49facf19bfec	card	demo	DEMO-HOTEL-07	tm-demo-v1-payment-hotel-07	3800.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
635dc0e5-41e0-5d02-b847-dfbe426e6da2	0d253c07-0789-5ff6-af54-b30a58c218f8	card	demo	DEMO-RESTAURANT-07	tm-demo-v1-payment-restaurant-07	170.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
fa845935-9c2a-5531-b20c-bd870fff4389	114e28dd-d2b2-5013-98b3-004aeb0b79ac	card	demo	DEMO-HOTEL-08	tm-demo-v1-payment-hotel-08	4000.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
67cd4801-ddf6-558a-8674-0fee8b9eb29b	858b4ec0-e6fc-5fda-b7d9-888a7909e2e8	card	demo	DEMO-RESTAURANT-08	tm-demo-v1-payment-restaurant-08	180.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
92694b8d-430a-5c61-932d-8383a82e1f02	61054763-93ad-5b9a-84d4-ad1dd65bd27d	card	demo	DEMO-HOTEL-09	tm-demo-v1-payment-hotel-09	4200.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
2bcc8836-55e3-51c2-a9f5-32aba53f2d43	564de051-ffe4-5a70-b15b-6672481b98b5	card	demo	DEMO-RESTAURANT-09	tm-demo-v1-payment-restaurant-09	190.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
ee17167e-4889-59c4-ab9d-c40ff6be2943	7353719a-1f79-5371-b1a0-56f3cf76aa92	card	demo	DEMO-HOTEL-10	tm-demo-v1-payment-hotel-10	4400.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
1a908d98-7986-53bb-9382-1fc22f993af9	60b147c8-1d18-5bb3-b91c-0f0dc5362c96	card	demo	DEMO-RESTAURANT-10	tm-demo-v1-payment-restaurant-10	200.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
94ffd800-bcb6-5450-a69e-589a968c3f47	2bc25997-f7fd-5836-b78a-9f0aaadf938c	card	demo	DEMO-HOTEL-11	tm-demo-v1-payment-hotel-11	4600.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
ca0b5c45-038a-51db-a841-92ddd30f7676	650dd7dc-a4ea-5967-a32c-99ac6f392090	card	demo	DEMO-RESTAURANT-11	tm-demo-v1-payment-restaurant-11	210.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
28316498-bc89-59e7-8c41-6d3220a684da	76a2903d-b252-5490-8584-18fe5d9d2628	card	demo	DEMO-HOTEL-12	tm-demo-v1-payment-hotel-12	4800.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
9a74854b-a61a-5e08-9d41-5aa2ebc2b6e3	c53777e1-6114-5a70-866d-50efe6104d51	card	demo	DEMO-RESTAURANT-12	tm-demo-v1-payment-restaurant-12	220.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
98b09d24-956c-5dd6-8922-45a1e77c8cc3	0f8ae9bf-5e4a-5746-a534-c53e61fd1a63	card	demo	DEMO-HOTEL-13	tm-demo-v1-payment-hotel-13	5000.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
77c0e0c4-f109-5ae9-ab71-804d69ee8bad	1facbb60-c68d-5b8a-b5b0-3e91065525e0	card	demo	DEMO-RESTAURANT-13	tm-demo-v1-payment-restaurant-13	230.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
5082c820-9d34-5850-9d35-3ec18d734079	92532d9f-b041-52f9-9095-513504eb4305	card	demo	DEMO-HOTEL-14	tm-demo-v1-payment-hotel-14	5200.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
647bb64d-9d21-5fa0-abad-c786099c5891	e3efcfb0-12f1-5b45-8ee4-eea9d761c42b	card	demo	DEMO-RESTAURANT-14	tm-demo-v1-payment-restaurant-14	240.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
b4549885-0912-5765-8665-9a01182ac617	11c56faa-db75-5c9f-bc78-7110ab4dc5ac	card	demo	DEMO-HOTEL-15	tm-demo-v1-payment-hotel-15	5400.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
510e06f8-b64c-5706-bcf4-c2b78d9b8f0e	03165b8d-e97e-5f0a-9047-eb25f4b81ab5	card	demo	DEMO-RESTAURANT-15	tm-demo-v1-payment-restaurant-15	250.00	succeeded	1	2026-07-20 03:05:00+00	2026-07-20 03:06:00+00
\.


--
-- Data for Name: photos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.photos (id, destination_id, listing_id, bucket_id, object_path, caption, sort_order, status, created_at, menu_item_id) FROM stdin;
5d290e23-762f-5236-81ad-cb4d70cac10a	\N	82c3bb86-1c0f-5ec4-ad34-672223d70608	travelmate-listings	08c59a01-6bf6-44c6-b6f1-de0131a3dccf/82c3bb86-1c0f-5ec4-ad34-672223d70608/demo.png	Illustrated placeholder for Amihan Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
b673c76c-28b5-57aa-9432-5f9e7f18b7a0	\N	33f41b4c-d352-5fe4-bb66-7a12e5b13c75	travelmate-listings	e5931678-254c-4abf-85fa-71e667896a41/33f41b4c-d352-5fe4-bb66-7a12e5b13c75/demo.png	Illustrated placeholder for Bituin Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
fdb3b365-4e6e-57fb-b883-86e109968c65	\N	45c1b62c-dece-5435-be5e-a60d386fb7b8	travelmate-listings	41942500-0b1b-4215-a759-29ffd1733f27/45c1b62c-dece-5435-be5e-a60d386fb7b8/demo.png	Illustrated placeholder for Dalisay Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
5c7e898b-b395-549b-bf68-2e0ccc1a554c	\N	b3ce66c3-4971-5e59-afb7-bd97e05ea55f	travelmate-listings	fe304e3d-1946-46cb-bb2d-77f8702c0f05/b3ce66c3-4971-5e59-afb7-bd97e05ea55f/demo.png	Illustrated placeholder for Hiraya Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
8897c31f-b225-5e90-9b9a-a16cce4b3531	\N	97d12e59-9306-5a71-bb23-cceefc44cfd1	travelmate-listings	392e6791-10b8-4c3d-8800-9efe6d29f8b2/97d12e59-9306-5a71-bb23-cceefc44cfd1/demo.png	Illustrated placeholder for Luntian Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
cb2aecf3-c373-5d28-91ef-c7e4f7db8609	\N	725197f4-b349-502e-acdb-c7660c422884	travelmate-listings	8e59134a-da94-4cd6-9eb7-ff46c9d56195/725197f4-b349-502e-acdb-c7660c422884/demo.png	Illustrated placeholder for Marilag Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
0ef76740-bb51-5135-88b8-b9b7e143f909	\N	3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	travelmate-listings	34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a/3ef64d86-c29a-5a30-b940-4b0b56b7cfd9/demo.png	Illustrated placeholder for Mayumi Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
193cf3ed-b4cd-50df-9663-b17c2d600c89	\N	d3412e6e-644e-5e2b-bcce-a7ee456917c1	travelmate-listings	6a11f3df-d69c-4148-80ee-88f1f7c95e2a/d3412e6e-644e-5e2b-bcce-a7ee456917c1/demo.png	Illustrated placeholder for Mutya Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
c883036f-cf5a-51c8-8d8d-202d9463b84d	\N	db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	travelmate-listings	9cb2f62f-5cab-43f3-9c64-dde893e6e4bb/db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc/demo.png	Illustrated placeholder for Sampaguita Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
44a8ee31-ce1e-54f6-9fff-09cdd2518690	\N	9a488d00-e1b0-56e5-a144-975d4cf028d6	travelmate-listings	c4a4841a-aa8a-4de6-b83c-b2bd6203042c/9a488d00-e1b0-56e5-a144-975d4cf028d6/demo.png	Illustrated placeholder for Sinag Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
b3591a8f-dee7-500e-b01c-e10d7d355d58	\N	aace4668-7c23-57e6-9152-8172aef490b6	travelmate-listings	8eba38fb-47ef-4be9-b26e-b109bccf0031/aace4668-7c23-57e6-9152-8172aef490b6/demo.png	Illustrated placeholder for Tala Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
6a5a551c-e670-514a-92cf-dc4063936605	\N	1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	travelmate-listings	5b305524-490a-4334-831e-b46d622648a8/1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc/demo.png	Illustrated placeholder for Silayan Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
17ddf588-4244-5023-8123-b3a2da0ebd50	\N	985a6a86-06a3-5c91-8d1b-24f504a3c01b	travelmate-listings	1ef0a385-782d-4808-999a-58733a4b209d/985a6a86-06a3-5c91-8d1b-24f504a3c01b/demo.png	Illustrated placeholder for Malaya Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
2ceded07-6c1f-50a9-a9d1-b1bfe3b3371a	\N	7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	travelmate-listings	0ea90927-1b7e-4674-a3df-092d82395d70/7efb5c97-0baf-5cce-9416-bc0c0ab55fd1/demo.png	Illustrated placeholder for Liwayway Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
8c986051-d41a-5503-b7a5-12514e856124	\N	58486d62-05e9-5e1f-be39-fc315fff5f5c	travelmate-listings	df48bcda-05d5-4d27-8b94-0fec879a5ab8/58486d62-05e9-5e1f-be39-fc315fff5f5c/demo.png	Illustrated placeholder for Ligaya Guesthouse. Not a property photograph.	0	approved	2026-09-18 01:24:47.675698+00	\N
f32a7bf4-f756-4d95-8503-0f95e6c921cb	\N	06f7fb52-4345-4555-a27f-258d8e829b95	travelmate-listings	9f8f0e34-1876-4a04-9a26-a65537ad2f33/06f7fb52-4345-4555-a27f-258d8e829b95/2d4c92bc-6d2f-4a3e-8aae-3a4ad817d2e4.png	\N	0	approved	2026-10-04 02:12:23.703551+00	\N
\.


--
-- Data for Name: preferences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.preferences (id, category, name) FROM stdin;
ceedd95f-68df-4510-9c5a-096b48dc3ad1	Travel interests	Coastal visits
87a4a49c-323f-4bcf-aba2-9a88d4d1ee13	Travel interests	Mountain scenery
20b89add-9aae-4869-b8a3-9f8c1e88613d	Travel interests	Heritage walks
135a6f59-e306-4de4-b91a-dff2c7c0dde2	Travel interests	Local cuisine
d21ef1a9-c97e-4694-b1fe-1f065353a32a	Travel interests	Nature walks
fb2301b0-d4ba-4ce8-bcfd-07881124e729	Travel interests	Museum visits
0e50adc2-967e-43fa-9614-1cb546845b24	Travel interests	Craft workshops
27db6520-d7b6-4f51-b860-3c785c4009b9	Travel interests	Garden visits
42e4d098-e284-44af-8970-91e6037a8a27	Travel interests	Family activities
b29a0c7e-76c1-4857-a428-97a389b8c7fa	Travel interests	Quiet stays
be56f8bc-e332-4b25-b1bd-61d612e24676	Travel interests	Public transport
01ae9126-c307-4b04-9c5d-c1bb770f6621	Travel interests	Accessible facilities
c77e584e-22d3-4744-a0ae-7b7b4adc896a	Travel interests	Vegetarian meals
799f4e1f-7196-4818-9788-05d86c3f9d47	Travel interests	Budget accommodation
02f87592-20ec-4064-8f85-ab9719c1e0b0	Travel interests	Photography spots
\.


--
-- Data for Name: profile_phones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profile_phones (id, profile_id, phone_number) FROM stdin;
c182d752-f78e-57c8-867a-e586bbf21eb2	08c59a01-6bf6-44c6-b6f1-de0131a3dccf	+12025550121
d5611c58-ab0f-531e-b83c-299efa3c7aef	e5931678-254c-4abf-85fa-71e667896a41	+12025550122
15aa4257-1ac4-5302-990d-88b07c4dc80a	41942500-0b1b-4215-a759-29ffd1733f27	+12025550123
4a71269c-899e-5d8f-a090-8f405a3cbc54	fe304e3d-1946-46cb-bb2d-77f8702c0f05	+12025550124
33165070-bce7-521f-ba5c-26ce9393e711	392e6791-10b8-4c3d-8800-9efe6d29f8b2	+12025550125
867ae632-42f7-527c-8a24-7eab4d989023	8e59134a-da94-4cd6-9eb7-ff46c9d56195	+12025550126
f365993a-cd55-5b1f-a6ac-6ee54bb3cedf	34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	+12025550127
ae7266d6-48cf-5686-a8d4-43be50897188	6a11f3df-d69c-4148-80ee-88f1f7c95e2a	+12025550128
2a8dc5ba-63d9-5c22-9c6a-cf6186b08e81	9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	+12025550129
8f1aab06-920b-574d-87f9-bfc6cf3fe3fa	c4a4841a-aa8a-4de6-b83c-b2bd6203042c	+12025550130
c5c98715-28a4-5f5f-b945-4df0eb162307	8eba38fb-47ef-4be9-b26e-b109bccf0031	+12025550131
c57a1c0a-1875-5d63-8852-a071875f445e	5b305524-490a-4334-831e-b46d622648a8	+12025550132
61ad8362-2152-544b-870e-ae641c8f7c5c	1ef0a385-782d-4808-999a-58733a4b209d	+12025550133
b68be590-c2d9-5715-837f-a97b808acded	0ea90927-1b7e-4674-a3df-092d82395d70	+12025550134
d780b6a9-faf2-5c48-9461-9f04c2b6d5fd	df48bcda-05d5-4d27-8b94-0fec879a5ab8	+12025550135
a7ecd843-3830-5ffb-b9df-09e0271650f1	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	+12025550101
e32375e9-6939-5f08-a725-41b0fb4bf5f8	7562e428-178e-430b-af77-04f4a7fbaa0a	+12025550102
d114124d-dddb-5c8b-8836-d32b34424a9d	9b8013fc-8493-409a-8f9f-f563b7d7c315	+12025550103
fbe11e10-7fe4-5229-868e-061e0becc51f	6d736964-b99f-47cd-a81f-df9940200e61	+12025550104
12c30efb-ceec-58c1-a080-7d43af74ee0d	c4adf4a6-b1f1-45af-8842-27d723b9519c	+12025550105
86b1b3e8-e26c-5589-8cf6-b3406d41f4bf	3caf5b74-5392-4930-8f4b-ea57dd4f646f	+12025550106
594ad02e-8c0e-5e7b-9531-652c74e71356	c3f1a421-b31e-4352-9a90-761ab03e4498	+12025550107
e594a90d-de52-5662-a1fd-e0c14c072784	748530a7-420a-4609-93eb-980e78db48e3	+12025550108
3baffa9f-a235-5c2e-bb7e-44efd4daaeb7	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	+12025550109
6f02f4be-fe87-59a1-8fe6-1a641227e3e1	99f4f909-197a-433d-aa42-5d552f2778d5	+12025550110
ab9aad38-9694-5c67-b083-947a931c13b6	a4f9becd-16e4-47a7-b32d-39930b707c1f	+12025550111
e9045b5f-38cf-5ccc-bbfb-20f48eddaccb	5a4b619a-3c52-45ef-afaf-d3d1351f7343	+12025550112
0a9c0066-7335-533c-b76e-60009bbc5021	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	+12025550113
dfa4eb08-fbaf-5109-999f-742b0cf56262	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	+12025550114
0a654796-0f81-5e09-a6cc-6dc9abc0021c	f5512436-7401-4ee0-88a0-095ca33c7cbb	+12025550115
164852f2-7e14-5e7e-a0fc-2a2e494034e5	d58126bf-5070-47dd-9865-c34af15569e4	+12025550160
\.


--
-- Data for Name: profile_preferences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profile_preferences (profile_id, preference_id) FROM stdin;
2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	135a6f59-e306-4de4-b91a-dff2c7c0dde2
7562e428-178e-430b-af77-04f4a7fbaa0a	135a6f59-e306-4de4-b91a-dff2c7c0dde2
9b8013fc-8493-409a-8f9f-f563b7d7c315	135a6f59-e306-4de4-b91a-dff2c7c0dde2
6d736964-b99f-47cd-a81f-df9940200e61	135a6f59-e306-4de4-b91a-dff2c7c0dde2
c4adf4a6-b1f1-45af-8842-27d723b9519c	135a6f59-e306-4de4-b91a-dff2c7c0dde2
3caf5b74-5392-4930-8f4b-ea57dd4f646f	135a6f59-e306-4de4-b91a-dff2c7c0dde2
c3f1a421-b31e-4352-9a90-761ab03e4498	135a6f59-e306-4de4-b91a-dff2c7c0dde2
748530a7-420a-4609-93eb-980e78db48e3	135a6f59-e306-4de4-b91a-dff2c7c0dde2
4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	135a6f59-e306-4de4-b91a-dff2c7c0dde2
99f4f909-197a-433d-aa42-5d552f2778d5	135a6f59-e306-4de4-b91a-dff2c7c0dde2
a4f9becd-16e4-47a7-b32d-39930b707c1f	135a6f59-e306-4de4-b91a-dff2c7c0dde2
5a4b619a-3c52-45ef-afaf-d3d1351f7343	135a6f59-e306-4de4-b91a-dff2c7c0dde2
5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	135a6f59-e306-4de4-b91a-dff2c7c0dde2
3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	135a6f59-e306-4de4-b91a-dff2c7c0dde2
f5512436-7401-4ee0-88a0-095ca33c7cbb	135a6f59-e306-4de4-b91a-dff2c7c0dde2
\.


--
-- Data for Name: profile_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profile_roles (profile_id, role_id) FROM stdin;
423028d7-3027-4ae9-947c-d5428e29b88f	f9611e7f-0588-4649-9d8c-e7238ce74876
b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	f9611e7f-0588-4649-9d8c-e7238ce74876
1f35520c-9114-4cbb-b369-86d2b431c76e	f9611e7f-0588-4649-9d8c-e7238ce74876
71f2a91a-e5e2-4a42-b830-2eea593be359	f9611e7f-0588-4649-9d8c-e7238ce74876
08c59a01-6bf6-44c6-b6f1-de0131a3dccf	f9611e7f-0588-4649-9d8c-e7238ce74876
e5931678-254c-4abf-85fa-71e667896a41	f9611e7f-0588-4649-9d8c-e7238ce74876
41942500-0b1b-4215-a759-29ffd1733f27	f9611e7f-0588-4649-9d8c-e7238ce74876
fe304e3d-1946-46cb-bb2d-77f8702c0f05	f9611e7f-0588-4649-9d8c-e7238ce74876
392e6791-10b8-4c3d-8800-9efe6d29f8b2	f9611e7f-0588-4649-9d8c-e7238ce74876
8e59134a-da94-4cd6-9eb7-ff46c9d56195	f9611e7f-0588-4649-9d8c-e7238ce74876
34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	f9611e7f-0588-4649-9d8c-e7238ce74876
6a11f3df-d69c-4148-80ee-88f1f7c95e2a	f9611e7f-0588-4649-9d8c-e7238ce74876
9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	f9611e7f-0588-4649-9d8c-e7238ce74876
c4a4841a-aa8a-4de6-b83c-b2bd6203042c	f9611e7f-0588-4649-9d8c-e7238ce74876
8eba38fb-47ef-4be9-b26e-b109bccf0031	f9611e7f-0588-4649-9d8c-e7238ce74876
5b305524-490a-4334-831e-b46d622648a8	f9611e7f-0588-4649-9d8c-e7238ce74876
1ef0a385-782d-4808-999a-58733a4b209d	f9611e7f-0588-4649-9d8c-e7238ce74876
0ea90927-1b7e-4674-a3df-092d82395d70	f9611e7f-0588-4649-9d8c-e7238ce74876
df48bcda-05d5-4d27-8b94-0fec879a5ab8	f9611e7f-0588-4649-9d8c-e7238ce74876
2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	f9611e7f-0588-4649-9d8c-e7238ce74876
7562e428-178e-430b-af77-04f4a7fbaa0a	f9611e7f-0588-4649-9d8c-e7238ce74876
9b8013fc-8493-409a-8f9f-f563b7d7c315	f9611e7f-0588-4649-9d8c-e7238ce74876
6d736964-b99f-47cd-a81f-df9940200e61	f9611e7f-0588-4649-9d8c-e7238ce74876
c4adf4a6-b1f1-45af-8842-27d723b9519c	f9611e7f-0588-4649-9d8c-e7238ce74876
3caf5b74-5392-4930-8f4b-ea57dd4f646f	f9611e7f-0588-4649-9d8c-e7238ce74876
c3f1a421-b31e-4352-9a90-761ab03e4498	f9611e7f-0588-4649-9d8c-e7238ce74876
748530a7-420a-4609-93eb-980e78db48e3	f9611e7f-0588-4649-9d8c-e7238ce74876
4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	f9611e7f-0588-4649-9d8c-e7238ce74876
99f4f909-197a-433d-aa42-5d552f2778d5	f9611e7f-0588-4649-9d8c-e7238ce74876
a4f9becd-16e4-47a7-b32d-39930b707c1f	f9611e7f-0588-4649-9d8c-e7238ce74876
5a4b619a-3c52-45ef-afaf-d3d1351f7343	f9611e7f-0588-4649-9d8c-e7238ce74876
5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	f9611e7f-0588-4649-9d8c-e7238ce74876
3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	f9611e7f-0588-4649-9d8c-e7238ce74876
f5512436-7401-4ee0-88a0-095ca33c7cbb	f9611e7f-0588-4649-9d8c-e7238ce74876
d58126bf-5070-47dd-9865-c34af15569e4	f9611e7f-0588-4649-9d8c-e7238ce74876
08c59a01-6bf6-44c6-b6f1-de0131a3dccf	bf087f6b-35b2-4b8b-9017-7ec22423d167
e5931678-254c-4abf-85fa-71e667896a41	bf087f6b-35b2-4b8b-9017-7ec22423d167
41942500-0b1b-4215-a759-29ffd1733f27	bf087f6b-35b2-4b8b-9017-7ec22423d167
fe304e3d-1946-46cb-bb2d-77f8702c0f05	bf087f6b-35b2-4b8b-9017-7ec22423d167
392e6791-10b8-4c3d-8800-9efe6d29f8b2	bf087f6b-35b2-4b8b-9017-7ec22423d167
8e59134a-da94-4cd6-9eb7-ff46c9d56195	bf087f6b-35b2-4b8b-9017-7ec22423d167
34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	bf087f6b-35b2-4b8b-9017-7ec22423d167
6a11f3df-d69c-4148-80ee-88f1f7c95e2a	bf087f6b-35b2-4b8b-9017-7ec22423d167
9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	bf087f6b-35b2-4b8b-9017-7ec22423d167
c4a4841a-aa8a-4de6-b83c-b2bd6203042c	bf087f6b-35b2-4b8b-9017-7ec22423d167
8eba38fb-47ef-4be9-b26e-b109bccf0031	bf087f6b-35b2-4b8b-9017-7ec22423d167
5b305524-490a-4334-831e-b46d622648a8	bf087f6b-35b2-4b8b-9017-7ec22423d167
1ef0a385-782d-4808-999a-58733a4b209d	bf087f6b-35b2-4b8b-9017-7ec22423d167
0ea90927-1b7e-4674-a3df-092d82395d70	bf087f6b-35b2-4b8b-9017-7ec22423d167
df48bcda-05d5-4d27-8b94-0fec879a5ab8	bf087f6b-35b2-4b8b-9017-7ec22423d167
d58126bf-5070-47dd-9865-c34af15569e4	dc5ae7d4-be17-4bce-9ac3-f71509975fe7
024f263f-0def-45aa-b740-8882d949bd77	f9611e7f-0588-4649-9d8c-e7238ce74876
bfc3af84-a566-412d-a1f3-b3f36b697278	f9611e7f-0588-4649-9d8c-e7238ce74876
9f8f0e34-1876-4a04-9a26-a65537ad2f33	f9611e7f-0588-4649-9d8c-e7238ce74876
9f8f0e34-1876-4a04-9a26-a65537ad2f33	bf087f6b-35b2-4b8b-9017-7ec22423d167
3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	f9611e7f-0588-4649-9d8c-e7238ce74876
1f35520c-9114-4cbb-b369-86d2b431c76e	bf087f6b-35b2-4b8b-9017-7ec22423d167
3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	e3c35be9-1b4a-4ef6-901b-9942671d615f
024f263f-0def-45aa-b740-8882d949bd77	e3c35be9-1b4a-4ef6-901b-9942671d615f
e848cf46-0fb6-4065-b436-d5142e6b9f48	f9611e7f-0588-4649-9d8c-e7238ce74876
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (id, full_name, address, account_status, created_at, updated_at, avatar_object_path) FROM stdin;
423028d7-3027-4ae9-947c-d5428e29b88f	dianne joy pimentel	\N	active	2026-09-17 04:06:54.975802+00	2026-09-17 04:07:55.256588+00	423028d7-3027-4ae9-947c-d5428e29b88f/64d6445c-a409-44c1-a4c6-ef4143b53c96.jpg
b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	Subala, Shawn Marion V.	Tapat ng Oasis	active	2026-09-17 06:36:51.565923+00	2026-09-17 07:05:13.209119+00	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c/24d6e64d-d2c3-4bb7-add0-c71252a5aa0d.jpg
1f35520c-9114-4cbb-b369-86d2b431c76e	Jonas Wally Loyola	Balaoan	active	2026-09-16 16:01:32.490643+00	2026-09-17 13:02:31.340303+00	1f35520c-9114-4cbb-b369-86d2b431c76e/6e2e76a3-a5ec-4717-a35b-052b9968d21c.png
71f2a91a-e5e2-4a42-b830-2eea593be359	Nasly H	hello	active	2026-09-17 13:06:38.049086+00	2026-09-17 13:07:40.473302+00	71f2a91a-e5e2-4a42-b830-2eea593be359/09fb61ca-3fc0-4c0e-9fc1-c94b0cf979fe.png
08c59a01-6bf6-44c6-b6f1-de0131a3dccf	Elena Mercado (Demo)	\N	active	2026-09-18 01:23:43.117463+00	2026-09-18 01:23:43.117463+00	\N
e5931678-254c-4abf-85fa-71e667896a41	Adrian Domingo (Demo)	\N	active	2026-09-18 01:23:43.467011+00	2026-09-18 01:23:43.467011+00	\N
41942500-0b1b-4215-a759-29ffd1733f27	Carla Valdez (Demo)	\N	active	2026-09-18 01:23:43.755424+00	2026-09-18 01:23:43.755424+00	\N
fe304e3d-1946-46cb-bb2d-77f8702c0f05	Nico Soriano (Demo)	\N	active	2026-09-18 01:23:44.044919+00	2026-09-18 01:23:44.044919+00	\N
392e6791-10b8-4c3d-8800-9efe6d29f8b2	Diana Pascual (Demo)	\N	active	2026-09-18 01:23:44.339755+00	2026-09-18 01:23:44.339755+00	\N
8e59134a-da94-4cd6-9eb7-ff46c9d56195	Enzo Salazar (Demo)	\N	active	2026-09-18 01:23:44.625099+00	2026-09-18 01:23:44.625099+00	\N
34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	Lara Fernandez (Demo)	\N	active	2026-09-18 01:23:44.909085+00	2026-09-18 01:23:44.909085+00	\N
6a11f3df-d69c-4148-80ee-88f1f7c95e2a	Anton Rivera (Demo)	\N	active	2026-09-18 01:23:45.19274+00	2026-09-18 01:23:45.19274+00	\N
9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	Mara Dela Cruz (Demo)	\N	active	2026-09-18 01:23:45.485272+00	2026-09-18 01:23:45.485272+00	\N
c4a4841a-aa8a-4de6-b83c-b2bd6203042c	Jules Rosales (Demo)	\N	active	2026-09-18 01:23:45.778234+00	2026-09-18 01:23:45.778234+00	\N
8eba38fb-47ef-4be9-b26e-b109bccf0031	Iris Manalo (Demo)	\N	active	2026-09-18 01:23:46.057681+00	2026-09-18 01:23:46.057681+00	\N
5b305524-490a-4334-831e-b46d622648a8	Theo Herrera (Demo)	\N	active	2026-09-18 01:23:46.335489+00	2026-09-18 01:23:46.335489+00	\N
1ef0a385-782d-4808-999a-58733a4b209d	Lea Ignacio (Demo)	\N	active	2026-09-18 01:23:46.616515+00	2026-09-18 01:23:46.616515+00	\N
0ea90927-1b7e-4674-a3df-092d82395d70	Ivan Padilla (Demo)	\N	active	2026-09-18 01:23:46.901017+00	2026-09-18 01:23:46.901017+00	\N
df48bcda-05d5-4d27-8b94-0fec879a5ab8	Celia Del Rosario (Demo)	\N	active	2026-09-18 01:23:47.178142+00	2026-09-18 01:23:47.178142+00	\N
2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	Andrea Ramos (Demo)	\N	active	2026-09-18 01:23:47.473355+00	2026-09-18 01:23:47.473355+00	\N
7562e428-178e-430b-af77-04f4a7fbaa0a	Miguel Santos (Demo)	\N	active	2026-09-18 01:23:47.747642+00	2026-09-18 01:23:47.747642+00	\N
9b8013fc-8493-409a-8f9f-f563b7d7c315	Bea Cruz (Demo)	\N	active	2026-09-18 01:23:48.023599+00	2026-09-18 01:23:48.023599+00	\N
6d736964-b99f-47cd-a81f-df9940200e61	Paolo Reyes (Demo)	\N	active	2026-09-18 01:23:48.301078+00	2026-09-18 01:23:48.301078+00	\N
c4adf4a6-b1f1-45af-8842-27d723b9519c	Camille Garcia (Demo)	\N	active	2026-09-18 01:23:48.589297+00	2026-09-18 01:23:48.589297+00	\N
3caf5b74-5392-4930-8f4b-ea57dd4f646f	Rafael Mendoza (Demo)	\N	active	2026-09-18 01:23:48.88142+00	2026-09-18 01:23:48.88142+00	\N
c3f1a421-b31e-4352-9a90-761ab03e4498	Nina Flores (Demo)	\N	active	2026-09-18 01:23:49.159191+00	2026-09-18 01:23:49.159191+00	\N
748530a7-420a-4609-93eb-980e78db48e3	Gabriel Torres (Demo)	\N	active	2026-09-18 01:23:49.444326+00	2026-09-18 01:23:49.444326+00	\N
4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	Ella Navarro (Demo)	\N	active	2026-09-18 01:23:49.74183+00	2026-09-18 01:23:49.74183+00	\N
99f4f909-197a-433d-aa42-5d552f2778d5	Marco Castillo (Demo)	\N	active	2026-09-18 01:23:50.027051+00	2026-09-18 01:23:50.027051+00	\N
a4f9becd-16e4-47a7-b32d-39930b707c1f	Sofia Aguilar (Demo)	\N	active	2026-09-18 01:23:50.304069+00	2026-09-18 01:23:50.304069+00	\N
5a4b619a-3c52-45ef-afaf-d3d1351f7343	Luis Santiago (Demo)	\N	active	2026-09-18 01:23:50.577566+00	2026-09-18 01:23:50.577566+00	\N
5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	Mika Villanueva (Demo)	\N	active	2026-09-18 01:23:50.858342+00	2026-09-18 01:23:50.858342+00	\N
3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	Daniel Aquino (Demo)	\N	active	2026-09-18 01:23:51.134797+00	2026-09-18 01:23:51.134797+00	\N
f5512436-7401-4ee0-88a0-095ca33c7cbb	Clara Bautista (Demo)	\N	active	2026-09-18 01:23:51.412273+00	2026-09-18 01:23:51.412273+00	\N
d58126bf-5070-47dd-9865-c34af15569e4	Alex Medina (Demo)	\N	active	2026-09-18 01:23:51.68564+00	2026-09-18 01:23:51.68564+00	\N
024f263f-0def-45aa-b740-8882d949bd77	Borja, Rasheed Jermaine P.	\N	active	2026-09-30 12:12:40.902538+00	2026-09-30 12:12:50.833402+00	\N
bfc3af84-a566-412d-a1f3-b3f36b697278	Del Pilar, Gian Kayl A.	dawdawdw	active	2026-09-30 12:19:41.071355+00	2026-10-01 13:21:41.421701+00	bfc3af84-a566-412d-a1f3-b3f36b697278/986f0697-bf16-4188-9aa0-5d8a39f49bbe.png
9f8f0e34-1876-4a04-9a26-a65537ad2f33	RIMNARWHAL	\N	active	2026-10-01 13:54:56.485798+00	2026-10-01 13:55:21.399955+00	9f8f0e34-1876-4a04-9a26-a65537ad2f33/d65146b7-6daf-4c93-a467-bf32976957c8.png
3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b	gian delpilar	\N	active	2026-10-01 14:10:04.474205+00	2026-10-01 14:10:04.474205+00	\N
e848cf46-0fb6-4065-b436-d5142e6b9f48	majin buu	\N	active	2026-10-05 03:36:49.409512+00	2026-10-05 03:36:49.409512+00	\N
\.


--
-- Data for Name: recommendations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recommendations (id, profile_id, destination_id, reason, recommended_at) FROM stdin;
bba4173c-a135-5d77-903a-017d5a3c29df	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	b1e02830-dbd4-4f9a-aaa3-34876be83810	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
3a2e4656-7752-574c-9d11-a9cfc956146d	7562e428-178e-430b-af77-04f4a7fbaa0a	b8090183-fec2-420f-b103-b0b3d6f8a633	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
5958e3d0-880e-5207-819e-51e1513954dc	9b8013fc-8493-409a-8f9f-f563b7d7c315	814a31d0-b736-45e1-a47b-e05541ac5a9a	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
ba131259-49df-5273-8b6d-65334a1e2f1f	6d736964-b99f-47cd-a81f-df9940200e61	dcac0e2d-39a3-427f-855d-b2f9662fb021	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
27dbc6e2-8ba5-5229-86a0-1b1ddfd03dc7	c4adf4a6-b1f1-45af-8842-27d723b9519c	0c80412f-b4f3-4d99-baf8-681072cf34f7	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
47951d72-c400-5945-88cc-4c8b8612eefc	3caf5b74-5392-4930-8f4b-ea57dd4f646f	c304304e-a89e-40b7-a827-7043c149ace0	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
8a7635d5-88d7-54d5-9658-2c3dd29cc90d	c3f1a421-b31e-4352-9a90-761ab03e4498	545b976c-9104-4c15-bf69-863b1ef4cf49	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
800c1e38-0fa9-5f11-a5f4-bb319873a1fd	748530a7-420a-4609-93eb-980e78db48e3	0445837d-520d-4fdf-9334-5bf9222f1e16	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
38e896df-e7ec-5d23-87b5-ab2fd004d9a9	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	7061d75c-c9a5-4943-bfc9-6f2532cd323a	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
b29e9d12-1d0f-529b-b9d4-0d27e2bf7e2a	99f4f909-197a-433d-aa42-5d552f2778d5	eb756643-47fd-4232-a94b-218cc9be6c09	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
757d1ec2-b81a-5ab9-8249-c458de79546f	a4f9becd-16e4-47a7-b32d-39930b707c1f	609998ae-3f65-45be-90d1-68bbb2bf9619	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
926782b2-4cf6-5089-af4b-a4e0efbefc31	5a4b619a-3c52-45ef-afaf-d3d1351f7343	1ebe6703-fbff-4b83-bd06-ab9527f2dc65	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
dcac1274-c941-57b8-a4b7-4a2047b3fa3e	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	7e4ab8c3-5c11-490e-b548-9c66b65c45be	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
d7581e74-095e-5141-8fe4-02b96fa05154	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	7159ad9e-653d-4575-9598-569d54e519b3	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
d2ad427a-3666-5f27-be2f-01213d424487	f5512436-7401-4ee0-88a0-095ca33c7cbb	df51b4af-a619-47fc-81d8-5d97c021ef15	Demo recommendation based on the local-cuisine preference.	2026-07-19 02:00:00+00
\.


--
-- Data for Name: refunds; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refunds (id, payment_id, amount, reason, status, provider_reference, idempotency_key, created_at, refunded_at) FROM stdin;
2fada2e0-6499-5e4c-a773-1d7281efc34c	e342643d-92c9-53d5-ab0b-76360e9debfd	650.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-01	tm-demo-v1-refund-01	2026-08-04 11:00:00+00	2026-08-04 11:15:00+00
acfd1dc5-3c35-5509-9cac-5a7e900ca16a	cc7ad41a-eafe-56e1-be1b-0b8c4fb6957e	700.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-02	tm-demo-v1-refund-02	2026-08-05 11:00:00+00	2026-08-05 11:15:00+00
ca554197-bd90-525d-ada0-c53d2f7cd7f3	0421f0b7-b144-5a5c-9f16-c99e277d9289	750.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-03	tm-demo-v1-refund-03	2026-08-06 11:00:00+00	2026-08-06 11:15:00+00
b458059c-8f74-51d0-8523-11797b1f84a4	b5ad5015-8c51-519e-a8de-eb717e2bfdc3	800.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-04	tm-demo-v1-refund-04	2026-08-07 11:00:00+00	2026-08-07 11:15:00+00
decd2ec3-81c1-5a98-893d-99948d698e62	45e74530-8002-5530-9421-d604e14ba2b6	850.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-05	tm-demo-v1-refund-05	2026-08-08 11:00:00+00	2026-08-08 11:15:00+00
c57ffb99-85a5-58ab-b790-5ed8304b7c64	02c708ae-faa0-5f93-8563-ed708e3c7e0b	900.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-06	tm-demo-v1-refund-06	2026-08-09 11:00:00+00	2026-08-09 11:15:00+00
c3f6ed19-5666-5c69-9f25-4e452dfa12af	fe43012c-4866-50f7-a092-3ffa5437a4f1	950.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-07	tm-demo-v1-refund-07	2026-08-10 11:00:00+00	2026-08-10 11:15:00+00
7c2f42ab-9087-567b-be38-5e806ed8b941	fa845935-9c2a-5531-b20c-bd870fff4389	1000.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-08	tm-demo-v1-refund-08	2026-08-11 11:00:00+00	2026-08-11 11:15:00+00
edfa3622-ffd9-5408-a44a-a965d429547e	92694b8d-430a-5c61-932d-8383a82e1f02	1050.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-09	tm-demo-v1-refund-09	2026-08-12 11:00:00+00	2026-08-12 11:15:00+00
1fc7b0fc-17d4-5318-8268-3e6e06b61c21	ee17167e-4889-59c4-ab9d-c40ff6be2943	1100.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-10	tm-demo-v1-refund-10	2026-08-13 11:00:00+00	2026-08-13 11:15:00+00
c2355122-757e-5fa6-94de-da4702af5bf8	94ffd800-bcb6-5450-a69e-589a968c3f47	1150.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-11	tm-demo-v1-refund-11	2026-08-14 11:00:00+00	2026-08-14 11:15:00+00
5b7ec729-8b77-533a-b328-8765684895e4	28316498-bc89-59e7-8c41-6d3220a684da	1200.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-12	tm-demo-v1-refund-12	2026-08-15 11:00:00+00	2026-08-15 11:15:00+00
a51b1e60-df77-5f38-a858-15be071667f4	98b09d24-956c-5dd6-8922-45a1e77c8cc3	1250.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-13	tm-demo-v1-refund-13	2026-08-16 11:00:00+00	2026-08-16 11:15:00+00
fa57a41b-9db6-58d6-b236-c4d0729494b5	5082c820-9d34-5850-9d35-3ec18d734079	1300.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-14	tm-demo-v1-refund-14	2026-08-17 11:00:00+00	2026-08-17 11:15:00+00
117dc697-d56b-5ddf-b1bf-b90a2acf0593	b4549885-0912-5765-8665-9a01182ac617	1350.00	Demo partial service adjustment; no actual money movement.	succeeded	DEMO-REFUND-15	tm-demo-v1-refund-15	2026-08-18 11:00:00+00	2026-08-18 11:15:00+00
\.


--
-- Data for Name: report_data_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.report_data_sources (report_id, data_source_id) FROM stdin;
953dd371-00b3-5991-94c0-7a82e50b3589	f228ff3c-19eb-5521-a056-adce4d3c046f
953dd371-00b3-5991-94c0-7a82e50b3589	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
46e472fb-9168-5156-b628-29d4a8f05326	f228ff3c-19eb-5521-a056-adce4d3c046f
46e472fb-9168-5156-b628-29d4a8f05326	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
aee468ab-a005-5693-8424-947a8cf1ca89	f228ff3c-19eb-5521-a056-adce4d3c046f
aee468ab-a005-5693-8424-947a8cf1ca89	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
31887b69-6f1b-5ea1-b8f9-be1cae0d7f98	f228ff3c-19eb-5521-a056-adce4d3c046f
31887b69-6f1b-5ea1-b8f9-be1cae0d7f98	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
879e9939-224e-5feb-9966-343e02027c6a	f228ff3c-19eb-5521-a056-adce4d3c046f
879e9939-224e-5feb-9966-343e02027c6a	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
33f88932-81e0-5c0b-ab17-fe8a86bb4391	f228ff3c-19eb-5521-a056-adce4d3c046f
33f88932-81e0-5c0b-ab17-fe8a86bb4391	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
f27ca172-d58c-5ddb-acc3-cbbc8c30dd83	f228ff3c-19eb-5521-a056-adce4d3c046f
f27ca172-d58c-5ddb-acc3-cbbc8c30dd83	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
70f19908-1c5d-5b24-9e87-dd12f62f240d	f228ff3c-19eb-5521-a056-adce4d3c046f
70f19908-1c5d-5b24-9e87-dd12f62f240d	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
e6438198-f18c-5564-b3de-850c1da7327c	f228ff3c-19eb-5521-a056-adce4d3c046f
e6438198-f18c-5564-b3de-850c1da7327c	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
c98d7a40-056f-5ddf-8046-af4b470d35ca	f228ff3c-19eb-5521-a056-adce4d3c046f
c98d7a40-056f-5ddf-8046-af4b470d35ca	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
5ea09ea9-bbb4-5426-8b80-26dba05a3a6f	f228ff3c-19eb-5521-a056-adce4d3c046f
5ea09ea9-bbb4-5426-8b80-26dba05a3a6f	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
1517a01c-99ad-554c-ac8c-69e713a4304b	f228ff3c-19eb-5521-a056-adce4d3c046f
1517a01c-99ad-554c-ac8c-69e713a4304b	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
7e87a435-228e-5ebd-9a10-4b879791afbf	f228ff3c-19eb-5521-a056-adce4d3c046f
7e87a435-228e-5ebd-9a10-4b879791afbf	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
741165f1-800d-5a25-b423-c71677e54b88	f228ff3c-19eb-5521-a056-adce4d3c046f
741165f1-800d-5a25-b423-c71677e54b88	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c	f228ff3c-19eb-5521-a056-adce4d3c046f
f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c	5dd30fa4-577c-5f4d-a7a9-7ffb54808eab
\.


--
-- Data for Name: report_metrics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.report_metrics (id, report_id, name, value, unit) FROM stdin;
a61d02a4-00b8-5cfa-b2df-d020df160bbe	953dd371-00b3-5991-94c0-7a82e50b3589	Agoo: demo listings	3.0000	listings
023775bd-a6e3-581f-9fd8-9af0e84b8617	953dd371-00b3-5991-94c0-7a82e50b3589	Agoo: demo bookings	2.0000	bookings
9d31b05a-61ea-52e5-a2e0-8f0c9ef46975	46e472fb-9168-5156-b628-29d4a8f05326	Aringay: demo listings	3.0000	listings
c5bd4c56-5875-51d1-9fdb-0d1facd49b8d	46e472fb-9168-5156-b628-29d4a8f05326	Aringay: demo bookings	2.0000	bookings
baa1141a-4712-5cac-a34c-0ac8da879850	aee468ab-a005-5693-8424-947a8cf1ca89	Bacnotan: demo listings	3.0000	listings
162dce05-e9f8-55d2-b4ac-584578cef13d	aee468ab-a005-5693-8424-947a8cf1ca89	Bacnotan: demo bookings	2.0000	bookings
a244ca9e-80b5-574e-91c5-22b36417abef	31887b69-6f1b-5ea1-b8f9-be1cae0d7f98	Bagulin: demo listings	3.0000	listings
7814289c-5bd4-5433-a7d4-bbcc03d810d1	31887b69-6f1b-5ea1-b8f9-be1cae0d7f98	Bagulin: demo bookings	2.0000	bookings
33b3a093-0ab6-576e-b944-e3c1faf8a99d	879e9939-224e-5feb-9966-343e02027c6a	Balaoan: demo listings	3.0000	listings
ad47e3bf-78dc-58e3-bbf3-9033252905f1	879e9939-224e-5feb-9966-343e02027c6a	Balaoan: demo bookings	2.0000	bookings
cf846436-9705-5324-aa99-3c82a1faec15	33f88932-81e0-5c0b-ab17-fe8a86bb4391	Bangar: demo listings	3.0000	listings
635647b4-08af-5dab-abed-f55289262c0d	33f88932-81e0-5c0b-ab17-fe8a86bb4391	Bangar: demo bookings	2.0000	bookings
f39667b6-eb8c-529e-af84-0442120a5468	f27ca172-d58c-5ddb-acc3-cbbc8c30dd83	Bauang: demo listings	3.0000	listings
aea2651b-0924-5b38-bb90-9ebe7d2aa6fd	f27ca172-d58c-5ddb-acc3-cbbc8c30dd83	Bauang: demo bookings	2.0000	bookings
63c1e0af-6c1c-596d-9037-5aa72d9a0c17	70f19908-1c5d-5b24-9e87-dd12f62f240d	Burgos: demo listings	3.0000	listings
ae87e368-7483-5170-a161-670a4add78f4	70f19908-1c5d-5b24-9e87-dd12f62f240d	Burgos: demo bookings	2.0000	bookings
7f8b0b98-d1ff-5589-9c28-b738a83a2d4c	e6438198-f18c-5564-b3de-850c1da7327c	Caba: demo listings	3.0000	listings
13bc6677-f298-5848-92f6-17a0693eb746	e6438198-f18c-5564-b3de-850c1da7327c	Caba: demo bookings	2.0000	bookings
ccf499a5-ed73-5b5a-8b6f-c94ff8cdf74f	c98d7a40-056f-5ddf-8046-af4b470d35ca	Luna: demo listings	3.0000	listings
defc801f-2b01-506a-897e-981ce898c663	c98d7a40-056f-5ddf-8046-af4b470d35ca	Luna: demo bookings	2.0000	bookings
05d09bbf-0b38-5d0b-9ea3-ec95f805d64c	5ea09ea9-bbb4-5426-8b80-26dba05a3a6f	Naguilian: demo listings	3.0000	listings
6e2a2644-df44-5ba8-b8ff-60bccd54e02e	5ea09ea9-bbb4-5426-8b80-26dba05a3a6f	Naguilian: demo bookings	2.0000	bookings
4e71baa0-4e34-5c96-b526-4601974fa648	1517a01c-99ad-554c-ac8c-69e713a4304b	Pugo: demo listings	3.0000	listings
8156a972-0b46-5207-9423-5fe8753ca5a7	1517a01c-99ad-554c-ac8c-69e713a4304b	Pugo: demo bookings	2.0000	bookings
51aec757-5a73-515e-b071-709388736edb	7e87a435-228e-5ebd-9a10-4b879791afbf	Rosario: demo listings	3.0000	listings
b7f3e01a-e524-50be-a504-d87285baafd9	7e87a435-228e-5ebd-9a10-4b879791afbf	Rosario: demo bookings	2.0000	bookings
6fa5c764-89d0-5e2d-aa5f-887b3bb4a049	741165f1-800d-5a25-b423-c71677e54b88	San Fernando City: demo listings	3.0000	listings
8d882ac2-ca18-5021-b37d-e0504fdaded3	741165f1-800d-5a25-b423-c71677e54b88	San Fernando City: demo bookings	2.0000	bookings
a1b2ce62-d762-5be9-994f-9538f6b3d1ee	f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c	San Juan: demo listings	3.0000	listings
2e61cc5c-fa58-5af0-ae67-5157e2180ee2	f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c	San Juan: demo bookings	2.0000	bookings
\.


--
-- Data for Name: report_report_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.report_report_types (report_id, report_type_id) FROM stdin;
953dd371-00b3-5991-94c0-7a82e50b3589	c7dc267f-d482-51fb-a66d-e1969d507115
46e472fb-9168-5156-b628-29d4a8f05326	c7dc267f-d482-51fb-a66d-e1969d507115
aee468ab-a005-5693-8424-947a8cf1ca89	c7dc267f-d482-51fb-a66d-e1969d507115
31887b69-6f1b-5ea1-b8f9-be1cae0d7f98	c7dc267f-d482-51fb-a66d-e1969d507115
879e9939-224e-5feb-9966-343e02027c6a	c7dc267f-d482-51fb-a66d-e1969d507115
33f88932-81e0-5c0b-ab17-fe8a86bb4391	c7dc267f-d482-51fb-a66d-e1969d507115
f27ca172-d58c-5ddb-acc3-cbbc8c30dd83	c7dc267f-d482-51fb-a66d-e1969d507115
70f19908-1c5d-5b24-9e87-dd12f62f240d	c7dc267f-d482-51fb-a66d-e1969d507115
e6438198-f18c-5564-b3de-850c1da7327c	c7dc267f-d482-51fb-a66d-e1969d507115
c98d7a40-056f-5ddf-8046-af4b470d35ca	c7dc267f-d482-51fb-a66d-e1969d507115
5ea09ea9-bbb4-5426-8b80-26dba05a3a6f	c7dc267f-d482-51fb-a66d-e1969d507115
1517a01c-99ad-554c-ac8c-69e713a4304b	c7dc267f-d482-51fb-a66d-e1969d507115
7e87a435-228e-5ebd-9a10-4b879791afbf	c7dc267f-d482-51fb-a66d-e1969d507115
741165f1-800d-5a25-b423-c71677e54b88	c7dc267f-d482-51fb-a66d-e1969d507115
f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c	c7dc267f-d482-51fb-a66d-e1969d507115
\.


--
-- Data for Name: report_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.report_types (id, name) FROM stdin;
c7dc267f-d482-51fb-a66d-e1969d507115	Destination overview
af774b25-4352-5e78-be8d-014dd4dc03f1	Booking volume
76df3bbe-2c08-5d82-a41b-b1f1d02f29f6	Hotel demand
edc40531-a9bc-5640-92b0-61d941150ee1	Restaurant demand
d9108af8-2a5e-5f4a-b6a0-f9cf68fac829	Room inventory
f9cd1da5-0ac0-5adf-8974-379b009955d9	Menu availability
5a28fbb7-c792-5964-93dc-dcddf0d40590	Review summary
11b96083-0a3b-5168-b782-68cf8166b7f6	Refund summary
69407a7a-526c-504c-9249-f9973e0d963a	Payment summary
21310445-ba76-5150-9b3a-7e2b2ed80e90	Trip completion
e999169e-9580-54b0-880b-6755d634cb81	Saved destinations
2f2165dd-4bbb-529b-8fee-b8b1a1d1b5f9	Transport coverage
ea6660b7-274e-56ee-a960-42fdd1419e40	Content moderation
6dacfef3-6943-51cc-92c2-838b2ac44abe	Support queue
958e8396-7eb0-5dba-9cb0-abd0d892a429	Preference summary
\.


--
-- Data for Name: restaurant_bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.restaurant_bookings (booking_id, slot_id) FROM stdin;
9f650f7f-ad1c-5029-b5e7-55194f71a382	50c2d8d3-a642-5d9a-99b8-2909cc074c4e
a9ba838e-30f2-5ee0-8fde-e978b0e67fa2	c99b0e8c-cc39-55a8-a440-0bc43f08730e
2150d480-c117-5bcc-b0f4-87f280851492	e01787d6-79db-5e7b-bf55-7498be9a1241
7e4726f5-a678-54cb-b2fb-563069faa4f7	5c6f5a9c-7f74-5abe-9ad1-b3c77419e19c
c171473e-592a-5878-9495-bd21159e2efd	65b0fa85-ee41-5e7f-9e42-7ce3e6ccae75
1ebedf59-516e-5c66-b06f-f37631fa717c	dd52f3c6-a6fc-5baa-84ff-2f3a879fae1f
0d253c07-0789-5ff6-af54-b30a58c218f8	00a0a2bb-e0de-5642-b1f3-ae54ec3818e7
858b4ec0-e6fc-5fda-b7d9-888a7909e2e8	e9cd2beb-32e7-5a54-aed9-9030ed1be745
564de051-ffe4-5a70-b15b-6672481b98b5	fcd31d8e-ee1b-5646-b460-2545e73cd1f0
60b147c8-1d18-5bb3-b91c-0f0dc5362c96	c616b83b-7a24-5423-ab21-fa9d4b86ea07
650dd7dc-a4ea-5967-a32c-99ac6f392090	f8011bc6-1acb-565f-a5dc-fbb0553a67e5
c53777e1-6114-5a70-866d-50efe6104d51	41ba319a-72d3-5fa8-bcb2-17c971366649
1facbb60-c68d-5b8a-b5b0-3e91065525e0	f1efdcfb-8a48-5c98-a54a-63928f27607c
e3efcfb0-12f1-5b45-8ee4-eea9d761c42b	f18d69a9-e46b-5da2-a658-3b2b593ba22c
03165b8d-e97e-5f0a-9047-eb25f4b81ab5	36166f94-c5e6-559b-a7b3-48c004e67364
\.


--
-- Data for Name: restaurant_cuisines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.restaurant_cuisines (restaurant_id, cuisine_id) FROM stdin;
a083d312-6ccd-58cc-a890-e06a99bc2bb8	34aa6d14-2d85-4c01-abb7-1bfec02a7502
151d6181-3837-5268-aea2-28404c4a756a	34aa6d14-2d85-4c01-abb7-1bfec02a7502
81dc328b-3be7-5b12-9b05-a3b3145b0c88	34aa6d14-2d85-4c01-abb7-1bfec02a7502
edfa8fec-18f4-5300-95aa-4bd65eb25558	34aa6d14-2d85-4c01-abb7-1bfec02a7502
f938c99a-491f-5cf1-8bd4-b366b550bb56	34aa6d14-2d85-4c01-abb7-1bfec02a7502
66f6c68a-f8fe-529f-b212-4547bb6709c9	34aa6d14-2d85-4c01-abb7-1bfec02a7502
1806542c-12f1-5886-9692-161e2180f12f	34aa6d14-2d85-4c01-abb7-1bfec02a7502
d5cca9ba-5411-541f-8a94-ac593ac460f8	34aa6d14-2d85-4c01-abb7-1bfec02a7502
6fa94169-6895-50d2-a558-bbd2319adfd6	34aa6d14-2d85-4c01-abb7-1bfec02a7502
41a40c49-1a84-54e0-a57c-13c9f35eee67	34aa6d14-2d85-4c01-abb7-1bfec02a7502
f20c4c94-6527-590b-9d92-010183847313	34aa6d14-2d85-4c01-abb7-1bfec02a7502
0e8ffa31-2640-54c0-8ebf-2a58e81eccde	34aa6d14-2d85-4c01-abb7-1bfec02a7502
d9eb84af-8227-5c6f-a346-3708594abd23	34aa6d14-2d85-4c01-abb7-1bfec02a7502
5dc87c99-76c8-5404-9e48-48dec03b3533	34aa6d14-2d85-4c01-abb7-1bfec02a7502
1b84ae34-a436-5efa-a3f6-41929b781669	34aa6d14-2d85-4c01-abb7-1bfec02a7502
06f7fb52-4345-4555-a27f-258d8e829b95	34aa6d14-2d85-4c01-abb7-1bfec02a7502
\.


--
-- Data for Name: restaurant_slots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.restaurant_slots (id, restaurant_id, starts_at, ends_at, capacity, is_open) FROM stdin;
50c2d8d3-a642-5d9a-99b8-2909cc074c4e	a083d312-6ccd-58cc-a890-e06a99bc2bb8	2026-08-02 10:00:00+00	2026-08-02 11:30:00+00	20	0
c99b0e8c-cc39-55a8-a440-0bc43f08730e	151d6181-3837-5268-aea2-28404c4a756a	2026-08-03 10:00:00+00	2026-08-03 11:30:00+00	20	0
e01787d6-79db-5e7b-bf55-7498be9a1241	81dc328b-3be7-5b12-9b05-a3b3145b0c88	2026-08-04 10:00:00+00	2026-08-04 11:30:00+00	20	0
5c6f5a9c-7f74-5abe-9ad1-b3c77419e19c	edfa8fec-18f4-5300-95aa-4bd65eb25558	2026-08-05 10:00:00+00	2026-08-05 11:30:00+00	20	0
65b0fa85-ee41-5e7f-9e42-7ce3e6ccae75	f938c99a-491f-5cf1-8bd4-b366b550bb56	2026-08-06 10:00:00+00	2026-08-06 11:30:00+00	20	0
dd52f3c6-a6fc-5baa-84ff-2f3a879fae1f	66f6c68a-f8fe-529f-b212-4547bb6709c9	2026-08-07 10:00:00+00	2026-08-07 11:30:00+00	20	0
00a0a2bb-e0de-5642-b1f3-ae54ec3818e7	1806542c-12f1-5886-9692-161e2180f12f	2026-08-08 10:00:00+00	2026-08-08 11:30:00+00	20	0
e9cd2beb-32e7-5a54-aed9-9030ed1be745	d5cca9ba-5411-541f-8a94-ac593ac460f8	2026-08-09 10:00:00+00	2026-08-09 11:30:00+00	20	0
fcd31d8e-ee1b-5646-b460-2545e73cd1f0	6fa94169-6895-50d2-a558-bbd2319adfd6	2026-08-10 10:00:00+00	2026-08-10 11:30:00+00	20	0
c616b83b-7a24-5423-ab21-fa9d4b86ea07	41a40c49-1a84-54e0-a57c-13c9f35eee67	2026-08-11 10:00:00+00	2026-08-11 11:30:00+00	20	0
f8011bc6-1acb-565f-a5dc-fbb0553a67e5	f20c4c94-6527-590b-9d92-010183847313	2026-08-12 10:00:00+00	2026-08-12 11:30:00+00	20	0
41ba319a-72d3-5fa8-bcb2-17c971366649	0e8ffa31-2640-54c0-8ebf-2a58e81eccde	2026-08-13 10:00:00+00	2026-08-13 11:30:00+00	20	0
f1efdcfb-8a48-5c98-a54a-63928f27607c	d9eb84af-8227-5c6f-a346-3708594abd23	2026-08-14 10:00:00+00	2026-08-14 11:30:00+00	20	0
f18d69a9-e46b-5da2-a658-3b2b593ba22c	5dc87c99-76c8-5404-9e48-48dec03b3533	2026-08-15 10:00:00+00	2026-08-15 11:30:00+00	20	0
36166f94-c5e6-559b-a7b3-48c004e67364	1b84ae34-a436-5efa-a3f6-41929b781669	2026-08-16 10:00:00+00	2026-08-16 11:30:00+00	20	0
\.


--
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.restaurants (restaurant_id, operating_hours, reservation_fee) FROM stdin;
a083d312-6ccd-58cc-a890-e06a99bc2bb8	Daily 08:00-20:00 (demo schedule)	110.00
151d6181-3837-5268-aea2-28404c4a756a	Daily 08:00-20:00 (demo schedule)	120.00
81dc328b-3be7-5b12-9b05-a3b3145b0c88	Daily 08:00-20:00 (demo schedule)	130.00
edfa8fec-18f4-5300-95aa-4bd65eb25558	Daily 08:00-20:00 (demo schedule)	140.00
f938c99a-491f-5cf1-8bd4-b366b550bb56	Daily 08:00-20:00 (demo schedule)	150.00
66f6c68a-f8fe-529f-b212-4547bb6709c9	Daily 08:00-20:00 (demo schedule)	160.00
1806542c-12f1-5886-9692-161e2180f12f	Daily 08:00-20:00 (demo schedule)	170.00
d5cca9ba-5411-541f-8a94-ac593ac460f8	Daily 08:00-20:00 (demo schedule)	180.00
6fa94169-6895-50d2-a558-bbd2319adfd6	Daily 08:00-20:00 (demo schedule)	190.00
41a40c49-1a84-54e0-a57c-13c9f35eee67	Daily 08:00-20:00 (demo schedule)	200.00
f20c4c94-6527-590b-9d92-010183847313	Daily 08:00-20:00 (demo schedule)	210.00
0e8ffa31-2640-54c0-8ebf-2a58e81eccde	Daily 08:00-20:00 (demo schedule)	220.00
d9eb84af-8227-5c6f-a346-3708594abd23	Daily 08:00-20:00 (demo schedule)	230.00
5dc87c99-76c8-5404-9e48-48dec03b3533	Daily 08:00-20:00 (demo schedule)	240.00
1b84ae34-a436-5efa-a3f6-41929b781669	Daily 08:00-20:00 (demo schedule)	250.00
06f7fb52-4345-4555-a27f-258d8e829b95	10:00 AM - 12:00 PM	500.00
\.


--
-- Data for Name: review_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.review_comments (id, review_id, profile_id, body, status, created_at) FROM stdin;
4149680b-21f5-53e7-b21a-3e186db877c3	b8129a1a-14c1-5c8a-9068-1dd0987e9084	08c59a01-6bf6-44c6-b6f1-de0131a3dccf	Demo owner response: thank you for the sample feedback.	published	2026-08-04 13:00:00+00
4a486bc3-fcd1-5e0d-8ac7-cf48287ebf66	be32d5a2-c9fb-5942-b946-ab86c91475a0	e5931678-254c-4abf-85fa-71e667896a41	Demo owner response: thank you for the sample feedback.	published	2026-08-05 13:00:00+00
694a6b81-4ce3-581d-baa0-fd9b0b0c7ef8	47e54022-55b5-5f3a-98e7-5003b9f25194	41942500-0b1b-4215-a759-29ffd1733f27	Demo owner response: thank you for the sample feedback.	published	2026-08-06 13:00:00+00
630e0727-dc66-51fd-88fc-bc7c09793cd2	539202b4-3e57-52b4-8707-5d9eb7b6a49b	fe304e3d-1946-46cb-bb2d-77f8702c0f05	Demo owner response: thank you for the sample feedback.	published	2026-08-07 13:00:00+00
f91a51e6-f944-56ee-891b-07af54067ac4	edb9973c-3566-5b07-a877-aeaaa9c2f5e8	392e6791-10b8-4c3d-8800-9efe6d29f8b2	Demo owner response: thank you for the sample feedback.	published	2026-08-08 13:00:00+00
d423c071-354a-52b1-922b-efab2bdde2a2	dbeb499e-0b93-52db-99d1-53e29dff137a	8e59134a-da94-4cd6-9eb7-ff46c9d56195	Demo owner response: thank you for the sample feedback.	published	2026-08-09 13:00:00+00
36bdec82-877a-59bf-8c4c-0c2cac78250d	51064e34-19f4-5f0e-a6b2-459baa541e8c	34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a	Demo owner response: thank you for the sample feedback.	published	2026-08-10 13:00:00+00
cb410a63-c160-5b6c-8c4d-6fa921ebf495	74e299e6-2065-5e87-9f6d-9dda850f0a8f	6a11f3df-d69c-4148-80ee-88f1f7c95e2a	Demo owner response: thank you for the sample feedback.	published	2026-08-11 13:00:00+00
ece2fd59-3ce9-50ab-b0ab-c3038e3c5263	1d6ad645-a72e-5503-a504-7c61663d2b79	9cb2f62f-5cab-43f3-9c64-dde893e6e4bb	Demo owner response: thank you for the sample feedback.	published	2026-08-12 13:00:00+00
ad20ec7f-1cac-571a-ad9c-0f56081327c6	a4b00c4f-b0e4-56b2-a049-d4c59e202881	c4a4841a-aa8a-4de6-b83c-b2bd6203042c	Demo owner response: thank you for the sample feedback.	published	2026-08-13 13:00:00+00
8a65a95b-05b6-5723-a265-72aadd72396b	2b409c2f-3289-5a10-ab22-01fc2f901708	8eba38fb-47ef-4be9-b26e-b109bccf0031	Demo owner response: thank you for the sample feedback.	published	2026-08-14 13:00:00+00
0d2cf9e0-c882-5805-b84e-bccc0352e720	00f5d410-386c-5c91-a6cd-997e54580412	5b305524-490a-4334-831e-b46d622648a8	Demo owner response: thank you for the sample feedback.	published	2026-08-15 13:00:00+00
3cec4aef-1376-5729-934a-98baa2a1737b	6a359fb4-87bd-5e6f-9759-1643818332b1	1ef0a385-782d-4808-999a-58733a4b209d	Demo owner response: thank you for the sample feedback.	published	2026-08-16 13:00:00+00
49997496-1b17-5093-8e9d-2fac46123a00	a43e379b-0e8f-5e6a-a119-b040bf9aac2c	0ea90927-1b7e-4674-a3df-092d82395d70	Demo owner response: thank you for the sample feedback.	published	2026-08-17 13:00:00+00
4f5a23c0-b328-5f12-b40a-d5e890c121c2	377dc8d3-32b8-5abb-9282-9341452c8d8e	df48bcda-05d5-4d27-8b94-0fec879a5ab8	Demo owner response: thank you for the sample feedback.	published	2026-08-18 13:00:00+00
\.


--
-- Data for Name: review_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.review_tags (review_id, tag_id) FROM stdin;
b8129a1a-14c1-5c8a-9068-1dd0987e9084	96e289da-f920-4a5f-9440-00b84ff3c972
be32d5a2-c9fb-5942-b946-ab86c91475a0	96e289da-f920-4a5f-9440-00b84ff3c972
47e54022-55b5-5f3a-98e7-5003b9f25194	96e289da-f920-4a5f-9440-00b84ff3c972
539202b4-3e57-52b4-8707-5d9eb7b6a49b	96e289da-f920-4a5f-9440-00b84ff3c972
edb9973c-3566-5b07-a877-aeaaa9c2f5e8	96e289da-f920-4a5f-9440-00b84ff3c972
dbeb499e-0b93-52db-99d1-53e29dff137a	96e289da-f920-4a5f-9440-00b84ff3c972
51064e34-19f4-5f0e-a6b2-459baa541e8c	96e289da-f920-4a5f-9440-00b84ff3c972
74e299e6-2065-5e87-9f6d-9dda850f0a8f	96e289da-f920-4a5f-9440-00b84ff3c972
1d6ad645-a72e-5503-a504-7c61663d2b79	96e289da-f920-4a5f-9440-00b84ff3c972
a4b00c4f-b0e4-56b2-a049-d4c59e202881	96e289da-f920-4a5f-9440-00b84ff3c972
2b409c2f-3289-5a10-ab22-01fc2f901708	96e289da-f920-4a5f-9440-00b84ff3c972
00f5d410-386c-5c91-a6cd-997e54580412	96e289da-f920-4a5f-9440-00b84ff3c972
6a359fb4-87bd-5e6f-9759-1643818332b1	96e289da-f920-4a5f-9440-00b84ff3c972
a43e379b-0e8f-5e6a-a119-b040bf9aac2c	96e289da-f920-4a5f-9440-00b84ff3c972
377dc8d3-32b8-5abb-9282-9341452c8d8e	96e289da-f920-4a5f-9440-00b84ff3c972
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reviews (id, profile_id, destination_id, listing_id, rating, review_text, status, created_at, updated_at) FROM stdin;
b8129a1a-14c1-5c8a-9068-1dd0987e9084	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	\N	82c3bb86-1c0f-5ec4-ad34-672223d70608	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-04 12:00:00+00	2026-08-04 12:00:00+00
be32d5a2-c9fb-5942-b946-ab86c91475a0	7562e428-178e-430b-af77-04f4a7fbaa0a	\N	33f41b4c-d352-5fe4-bb66-7a12e5b13c75	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-05 12:00:00+00	2026-08-05 12:00:00+00
47e54022-55b5-5f3a-98e7-5003b9f25194	9b8013fc-8493-409a-8f9f-f563b7d7c315	\N	45c1b62c-dece-5435-be5e-a60d386fb7b8	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-06 12:00:00+00	2026-08-06 12:00:00+00
539202b4-3e57-52b4-8707-5d9eb7b6a49b	6d736964-b99f-47cd-a81f-df9940200e61	\N	b3ce66c3-4971-5e59-afb7-bd97e05ea55f	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-07 12:00:00+00	2026-08-07 12:00:00+00
edb9973c-3566-5b07-a877-aeaaa9c2f5e8	c4adf4a6-b1f1-45af-8842-27d723b9519c	\N	97d12e59-9306-5a71-bb23-cceefc44cfd1	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-08 12:00:00+00	2026-08-08 12:00:00+00
dbeb499e-0b93-52db-99d1-53e29dff137a	3caf5b74-5392-4930-8f4b-ea57dd4f646f	\N	725197f4-b349-502e-acdb-c7660c422884	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-09 12:00:00+00	2026-08-09 12:00:00+00
51064e34-19f4-5f0e-a6b2-459baa541e8c	c3f1a421-b31e-4352-9a90-761ab03e4498	\N	3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-10 12:00:00+00	2026-08-10 12:00:00+00
74e299e6-2065-5e87-9f6d-9dda850f0a8f	748530a7-420a-4609-93eb-980e78db48e3	\N	d3412e6e-644e-5e2b-bcce-a7ee456917c1	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-11 12:00:00+00	2026-08-11 12:00:00+00
1d6ad645-a72e-5503-a504-7c61663d2b79	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	\N	db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-12 12:00:00+00	2026-08-12 12:00:00+00
a4b00c4f-b0e4-56b2-a049-d4c59e202881	99f4f909-197a-433d-aa42-5d552f2778d5	\N	9a488d00-e1b0-56e5-a144-975d4cf028d6	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-13 12:00:00+00	2026-08-13 12:00:00+00
2b409c2f-3289-5a10-ab22-01fc2f901708	a4f9becd-16e4-47a7-b32d-39930b707c1f	\N	aace4668-7c23-57e6-9152-8172aef490b6	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-14 12:00:00+00	2026-08-14 12:00:00+00
00f5d410-386c-5c91-a6cd-997e54580412	5a4b619a-3c52-45ef-afaf-d3d1351f7343	\N	1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-15 12:00:00+00	2026-08-15 12:00:00+00
6a359fb4-87bd-5e6f-9759-1643818332b1	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	\N	985a6a86-06a3-5c91-8d1b-24f504a3c01b	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-16 12:00:00+00	2026-08-16 12:00:00+00
a43e379b-0e8f-5e6a-a119-b040bf9aac2c	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	\N	7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-17 12:00:00+00	2026-08-17 12:00:00+00
377dc8d3-32b8-5abb-9282-9341452c8d8e	f5512436-7401-4ee0-88a0-095ca33c7cbb	\N	58486d62-05e9-5e1f-be39-fc315fff5f5c	4	Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.	published	2026-08-18 12:00:00+00	2026-08-18 12:00:00+00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name) FROM stdin;
f9611e7f-0588-4649-9d8c-e7238ce74876	traveler
bf087f6b-35b2-4b8b-9017-7ec22423d167	business_owner
e3c35be9-1b4a-4ef6-901b-9942671d615f	admin
220b4c17-0b6b-4e6a-8050-997b98ed9807	moderator
dc5ae7d4-be17-4bce-9ac3-f71509975fe7	analyst
e50a27eb-9c3f-4abd-be6a-680557cd9177	support
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rooms (id, hotel_id, room_number, room_type, max_guests, base_nightly_rate, operational_status) FROM stdin;
4459f1a2-9ab0-52e5-94c7-87292d43f836	82c3bb86-1c0f-5ec4-ad34-672223d70608	101	Standard twin	2	1300.00	available
09b9e419-23bc-5b7f-8a1e-25330dbf8c6f	33f41b4c-d352-5fe4-bb66-7a12e5b13c75	101	Standard twin	2	1400.00	available
6b26743c-b5b4-5ed6-958b-17b75d850413	45c1b62c-dece-5435-be5e-a60d386fb7b8	101	Standard twin	2	1500.00	available
8c26eadb-c9b8-5293-9f1c-2eb49283622a	b3ce66c3-4971-5e59-afb7-bd97e05ea55f	101	Standard twin	2	1600.00	available
5c45912c-2cbb-5f8b-8aef-9b2943d171bd	97d12e59-9306-5a71-bb23-cceefc44cfd1	101	Standard twin	2	1700.00	available
39ac536e-a786-5bf5-9f47-4a0572ae72d1	725197f4-b349-502e-acdb-c7660c422884	101	Standard twin	2	1800.00	available
b2be20fc-79c7-51d7-8fad-938580dd3a54	3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	101	Standard twin	2	1900.00	available
111b36ad-fef0-53a6-a141-466725afa88a	d3412e6e-644e-5e2b-bcce-a7ee456917c1	101	Standard twin	2	2000.00	available
7aa59e9a-aa9b-57c4-9151-031bc66872fd	db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	101	Standard twin	2	2100.00	available
aec49986-57ac-59d9-935c-0c02a6d9b832	9a488d00-e1b0-56e5-a144-975d4cf028d6	101	Standard twin	2	2200.00	available
3ec239b9-26dd-5b40-98c0-1f208312bde4	aace4668-7c23-57e6-9152-8172aef490b6	101	Standard twin	2	2300.00	available
2ad36cac-b35f-51fb-89ae-84339f6fa432	1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	101	Standard twin	2	2400.00	available
2da779fa-f1e4-5781-8d36-18f029b3e2d1	985a6a86-06a3-5c91-8d1b-24f504a3c01b	101	Standard twin	2	2500.00	available
9f58b9f4-d398-58da-845e-645106988229	7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	101	Standard twin	2	2600.00	available
570234b1-4e04-581f-8817-d53d32df9060	58486d62-05e9-5e1f-be39-fc315fff5f5c	101	Standard twin	2	2700.00	available
\.


--
-- Data for Name: saved_destinations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.saved_destinations (profile_id, destination_id, added_at) FROM stdin;
2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	b1e02830-dbd4-4f9a-aaa3-34876be83810	2026-07-19 01:00:00+00
7562e428-178e-430b-af77-04f4a7fbaa0a	b8090183-fec2-420f-b103-b0b3d6f8a633	2026-07-19 01:00:00+00
9b8013fc-8493-409a-8f9f-f563b7d7c315	814a31d0-b736-45e1-a47b-e05541ac5a9a	2026-07-19 01:00:00+00
6d736964-b99f-47cd-a81f-df9940200e61	dcac0e2d-39a3-427f-855d-b2f9662fb021	2026-07-19 01:00:00+00
c4adf4a6-b1f1-45af-8842-27d723b9519c	0c80412f-b4f3-4d99-baf8-681072cf34f7	2026-07-19 01:00:00+00
3caf5b74-5392-4930-8f4b-ea57dd4f646f	c304304e-a89e-40b7-a827-7043c149ace0	2026-07-19 01:00:00+00
c3f1a421-b31e-4352-9a90-761ab03e4498	545b976c-9104-4c15-bf69-863b1ef4cf49	2026-07-19 01:00:00+00
748530a7-420a-4609-93eb-980e78db48e3	0445837d-520d-4fdf-9334-5bf9222f1e16	2026-07-19 01:00:00+00
4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	7061d75c-c9a5-4943-bfc9-6f2532cd323a	2026-07-19 01:00:00+00
99f4f909-197a-433d-aa42-5d552f2778d5	eb756643-47fd-4232-a94b-218cc9be6c09	2026-07-19 01:00:00+00
a4f9becd-16e4-47a7-b32d-39930b707c1f	609998ae-3f65-45be-90d1-68bbb2bf9619	2026-07-19 01:00:00+00
5a4b619a-3c52-45ef-afaf-d3d1351f7343	1ebe6703-fbff-4b83-bd06-ab9527f2dc65	2026-07-19 01:00:00+00
5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	7e4ab8c3-5c11-490e-b548-9c66b65c45be	2026-07-19 01:00:00+00
3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	7159ad9e-653d-4575-9598-569d54e519b3	2026-07-19 01:00:00+00
f5512436-7401-4ee0-88a0-095ca33c7cbb	df51b4af-a619-47fc-81d8-5d97c021ef15	2026-07-19 01:00:00+00
bfc3af84-a566-412d-a1f3-b3f36b697278	b1e02830-dbd4-4f9a-aaa3-34876be83810	2026-10-01 13:21:58.358414+00
bfc3af84-a566-412d-a1f3-b3f36b697278	b8090183-fec2-420f-b103-b0b3d6f8a633	2026-10-01 13:21:59.758007+00
\.


--
-- Data for Name: search_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.search_history (id, profile_id, trip_id, keyword, filter_text, searched_at) FROM stdin;
395e72f2-6981-59a2-8f6c-efc8bbe172f2	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	73937aee-5652-5451-a803-786e5eb9e2e3	Agoo accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
a8764b37-ef3a-59c4-bb52-080c87bbe4eb	7562e428-178e-430b-af77-04f4a7fbaa0a	9c492966-aa51-57b0-996c-f4d4a0862a71	Aringay accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
3b51d3b9-8d62-5fb4-a971-d804b036f216	9b8013fc-8493-409a-8f9f-f563b7d7c315	dc3087d5-4fea-553a-9d24-21e658b6daf1	Bacnotan accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
00511d8b-21b4-5a7c-a16a-5e7c83cddf8c	6d736964-b99f-47cd-a81f-df9940200e61	8c985e95-ab8b-5942-9140-d7fa7f3da57d	Bagulin accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
9a9125db-fd9c-557f-be45-be8bb5f020f1	c4adf4a6-b1f1-45af-8842-27d723b9519c	61fb83b7-89b1-597a-bfb0-26c691e43087	Balaoan accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
6cc9e787-ee29-5e9d-b50d-fb77daeda153	3caf5b74-5392-4930-8f4b-ea57dd4f646f	40da3808-36f1-59cc-b682-5d6ee1707abe	Bangar accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
19bdffd4-38be-5d1c-be8f-ebda2b734f4e	c3f1a421-b31e-4352-9a90-761ab03e4498	1280bb0d-5aae-5c86-af7c-082864371b26	Bauang accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
6003760a-de13-59e3-aa49-6fa4f8f9330e	748530a7-420a-4609-93eb-980e78db48e3	931d36d0-512e-5ab7-9ff6-82ce277e4fee	Burgos accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
20e4ff04-6b10-535d-8d19-8a89b59e1096	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	128f4bb2-d04c-5a75-8425-023faa0145e8	Caba accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
785c2e07-2aae-5824-8035-1a563d56edc2	99f4f909-197a-433d-aa42-5d552f2778d5	bda935d3-1603-5307-967d-5be5f18cbd2d	Luna accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
9e330c73-98a3-50e2-9462-bc0dc47a2afa	a4f9becd-16e4-47a7-b32d-39930b707c1f	63b0f67a-a14c-55c1-8989-4c7fda629421	Naguilian accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
f5f7dc2f-a5cd-59e2-8e12-567a1f9806f7	5a4b619a-3c52-45ef-afaf-d3d1351f7343	5b6599d8-f659-58b1-b453-bc4226cdae62	Pugo accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
3ec6f19e-46a6-557f-affa-4edcac6ac192	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	576819a4-65ac-5fa9-949c-447726262176	Rosario accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
9b8f1d0e-12b3-5355-81d2-83c7106f3e83	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea	San Fernando City accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
dec26cfe-d92a-5e9e-be8d-379ad876e016	f5512436-7401-4ee0-88a0-095ca33c7cbb	61451445-3b0b-54f7-a59d-2652cb5ef2b6	San Juan accommodation	Demo search: two guests, standard room	2026-07-19 00:00:00+00
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tags (id, name) FROM stdin;
6accdb1d-8d11-4f0a-bc33-b3de56cdd79f	Family friendly
57ab9a1e-6fa2-4949-ac81-6ba683157258	Quiet setting
175689ed-04e2-4b98-9d57-1f37b4c7a72c	Scenic views
bd8efe7c-4906-4662-920b-43678a1b8658	Local food
941f71ff-5541-4f35-a0ee-44f15f458bcc	Accessible entrance
ff466640-6720-46bf-9e03-600a125c2b70	Helpful staff
96e289da-f920-4a5f-9440-00b84ff3c972	Clean facilities
1d1940da-408a-4618-8e3f-c1c6214cf8d0	Near transport
afdd1fa5-49d6-4e8e-9204-4026d5ff6876	Outdoor seating
3efafb16-7a1a-47be-b8a8-55d97e7f819c	Good for groups
8afa3a50-85cc-4767-b282-f1b36efdc746	Budget friendly
674757bb-9a3e-41c3-a058-5d7cc6dd8f35	Cultural experience
56c30ea9-09bc-48a5-b354-cbd72ad7cbcf	Nature activities
4669610f-4031-4a50-a2ec-ba22280e7629	Easy to find
8090ad48-433c-468c-832a-9c81f7b706de	Advance booking
\.


--
-- Data for Name: transport_provider_contacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transport_provider_contacts (id, provider_id, phone_number) FROM stdin;
0cc1992f-2f2e-504f-89c0-e8cc89d96802	21754d70-6eb4-5202-b72d-a431d16932ba	+12025550141
71136c6c-7ae5-5a08-9ca8-c4403d6aee26	3211b24c-9b8d-5b6d-98b2-045ca115aa47	+12025550142
09ed33db-1148-5347-8199-d101e204d903	2bed9c73-afd2-5d6b-bf5e-649caf084d62	+12025550143
570c21bd-34f0-5f4f-92ab-ab63e68fed28	823e049a-59f0-52c1-b5b1-ad87e44c7277	+12025550144
a6f6394b-686a-56f4-ba7c-d18b97c37236	b3b312a3-9ed0-59fc-8b77-00fa22fcb556	+12025550145
99d77f26-a7f7-5729-a30b-7d15bb69bb3c	cad74a9e-f303-58da-8c34-9ddab18e3ae8	+12025550146
b1e129d6-2932-5b56-b29b-d5fe2313a51e	d0809b38-7e6d-55ae-8311-c112f27fa6be	+12025550147
8936e7e9-fecb-59d9-bd7c-481b50c1d9f3	0c282fc9-b4f2-5165-a639-85c917b803fa	+12025550148
f2050a95-1641-50b0-b026-474dc33b623a	8636a8ba-b297-5c16-9196-0be505ccedf9	+12025550149
cd900474-9ae7-5cb4-b090-00b463b62b2d	76d52f21-589d-5a87-b9ca-70d89cad4c59	+12025550150
d7cdfc25-b079-51d3-914e-a2665c932251	24c85daf-403a-591d-ba46-d9b9b11d2437	+12025550151
ef5b6fa3-ab3f-5221-9a74-826f6fabd5dc	95f8792a-f3b4-5ad8-861d-378041278ba8	+12025550152
7d92b00b-6971-5f6c-8ca2-58e1bbb1a7c8	a59ca060-d879-599e-81b5-e8b519a9a5ec	+12025550153
69aa5c62-e493-5cc8-ab28-741893a2b665	f084fd5a-1766-5ab6-b56d-b271512a7d8b	+12025550154
062910a8-5838-5277-b78d-f6ea62d4a099	a35695a3-bcd4-5a2d-b307-4d1226fba00f	+12025550155
\.


--
-- Data for Name: transport_providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transport_providers (id, owner_id, company_name, description) FROM stdin;
21754d70-6eb4-5202-b72d-a431d16932ba	29df924a-3eb4-5ca6-922f-2a7bb6f4770f	Amihan Local Transfers (Demo)	Fictional transport provider; no real service offered.
3211b24c-9b8d-5b6d-98b2-045ca115aa47	82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9	Bituin Local Transfers (Demo)	Fictional transport provider; no real service offered.
2bed9c73-afd2-5d6b-bf5e-649caf084d62	650f700c-4cce-5f4c-8bda-6a4f650ede75	Dalisay Local Transfers (Demo)	Fictional transport provider; no real service offered.
823e049a-59f0-52c1-b5b1-ad87e44c7277	5189473a-f7bb-564f-b0b1-cb3a8478d4a5	Hiraya Local Transfers (Demo)	Fictional transport provider; no real service offered.
b3b312a3-9ed0-59fc-8b77-00fa22fcb556	eea0e58b-9652-5084-85e7-6bbe46350307	Luntian Local Transfers (Demo)	Fictional transport provider; no real service offered.
cad74a9e-f303-58da-8c34-9ddab18e3ae8	c5a1e919-b05f-5b58-b2ea-ee7e8c513645	Marilag Local Transfers (Demo)	Fictional transport provider; no real service offered.
d0809b38-7e6d-55ae-8311-c112f27fa6be	e6cd4c42-6b57-5c46-9fd4-32d75e311073	Mayumi Local Transfers (Demo)	Fictional transport provider; no real service offered.
0c282fc9-b4f2-5165-a639-85c917b803fa	465bc167-fa39-58bd-9c84-4bacebafba97	Mutya Local Transfers (Demo)	Fictional transport provider; no real service offered.
8636a8ba-b297-5c16-9196-0be505ccedf9	16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3	Sampaguita Local Transfers (Demo)	Fictional transport provider; no real service offered.
76d52f21-589d-5a87-b9ca-70d89cad4c59	966f7bcc-8dc1-51c5-b910-e3f8a317f3f7	Sinag Local Transfers (Demo)	Fictional transport provider; no real service offered.
24c85daf-403a-591d-ba46-d9b9b11d2437	96e3d384-b745-51d5-8f03-ec434911025e	Tala Local Transfers (Demo)	Fictional transport provider; no real service offered.
95f8792a-f3b4-5ad8-861d-378041278ba8	7e22034a-af65-58f6-a141-f011fddf6912	Silayan Local Transfers (Demo)	Fictional transport provider; no real service offered.
a59ca060-d879-599e-81b5-e8b519a9a5ec	6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe	Malaya Local Transfers (Demo)	Fictional transport provider; no real service offered.
f084fd5a-1766-5ab6-b56d-b271512a7d8b	cd23ed36-e393-5e54-9576-5e51e7858b91	Liwayway Local Transfers (Demo)	Fictional transport provider; no real service offered.
a35695a3-bcd4-5a2d-b307-4d1226fba00f	127dd080-9b40-56d2-a99a-fd626a602fa4	Ligaya Local Transfers (Demo)	Fictional transport provider; no real service offered.
\.


--
-- Data for Name: transportation_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transportation_services (id, provider_id, destination_id, transport_type, service_name, status) FROM stdin;
fb2ab3b7-c1c3-54b9-acbd-d10daa537b9d	21754d70-6eb4-5202-b72d-a431d16932ba	b1e02830-dbd4-4f9a-aaa3-34876be83810	Shuttle	Agoo town shuttle (Demo)	approved
049d20f7-73e5-53ba-94cd-ac6d51d010de	3211b24c-9b8d-5b6d-98b2-045ca115aa47	b8090183-fec2-420f-b103-b0b3d6f8a633	Shuttle	Aringay town shuttle (Demo)	approved
0e8aa241-a06a-5e32-b338-922d79e723e8	2bed9c73-afd2-5d6b-bf5e-649caf084d62	814a31d0-b736-45e1-a47b-e05541ac5a9a	Shuttle	Bacnotan town shuttle (Demo)	approved
918babbf-69a1-5075-a48a-82169045d251	823e049a-59f0-52c1-b5b1-ad87e44c7277	dcac0e2d-39a3-427f-855d-b2f9662fb021	Shuttle	Bagulin town shuttle (Demo)	approved
452eb573-9414-5665-b090-cda4df82ace0	b3b312a3-9ed0-59fc-8b77-00fa22fcb556	0c80412f-b4f3-4d99-baf8-681072cf34f7	Shuttle	Balaoan town shuttle (Demo)	approved
d0f446c0-14d9-5bac-8998-25259ad0cc8b	cad74a9e-f303-58da-8c34-9ddab18e3ae8	c304304e-a89e-40b7-a827-7043c149ace0	Shuttle	Bangar town shuttle (Demo)	approved
853a0ec4-4019-5c27-83f9-8216b315c0de	d0809b38-7e6d-55ae-8311-c112f27fa6be	545b976c-9104-4c15-bf69-863b1ef4cf49	Shuttle	Bauang town shuttle (Demo)	approved
cab89ff8-20c6-537d-be6f-4d4ba8175fd9	0c282fc9-b4f2-5165-a639-85c917b803fa	0445837d-520d-4fdf-9334-5bf9222f1e16	Shuttle	Burgos town shuttle (Demo)	approved
543ecebb-f430-5c4b-bef5-3ab9dfa689e2	8636a8ba-b297-5c16-9196-0be505ccedf9	7061d75c-c9a5-4943-bfc9-6f2532cd323a	Shuttle	Caba town shuttle (Demo)	approved
3794719b-52cf-516c-8a09-c1e4d8ae740a	76d52f21-589d-5a87-b9ca-70d89cad4c59	eb756643-47fd-4232-a94b-218cc9be6c09	Shuttle	Luna town shuttle (Demo)	approved
32ad5d3d-23c6-5829-9f68-c2b968b89c86	24c85daf-403a-591d-ba46-d9b9b11d2437	609998ae-3f65-45be-90d1-68bbb2bf9619	Shuttle	Naguilian town shuttle (Demo)	approved
41dc7e31-a5b8-562f-bd46-58231daa2ad1	95f8792a-f3b4-5ad8-861d-378041278ba8	1ebe6703-fbff-4b83-bd06-ab9527f2dc65	Shuttle	Pugo town shuttle (Demo)	approved
827e3891-439c-5c6e-a37e-1c62dce3eef8	a59ca060-d879-599e-81b5-e8b519a9a5ec	7e4ab8c3-5c11-490e-b548-9c66b65c45be	Shuttle	Rosario town shuttle (Demo)	approved
3ce47fa9-29d3-5de3-8e1d-4679d212b230	f084fd5a-1766-5ab6-b56d-b271512a7d8b	7159ad9e-653d-4575-9598-569d54e519b3	Shuttle	San Fernando City town shuttle (Demo)	approved
2f6572a2-6a45-5682-8409-86072a429eed	a35695a3-bcd4-5a2d-b307-4d1226fba00f	df51b4af-a619-47fc-81d8-5d97c021ef15	Shuttle	San Juan town shuttle (Demo)	approved
\.


--
-- Data for Name: trip_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.trip_items (id, trip_id, destination_id, listing_id, activity, sequence_number, planned_date, planned_time, notes, status) FROM stdin;
41c7b1f1-6e2d-5feb-8e11-6015706cdf3a	73937aee-5652-5451-a803-786e5eb9e2e3	\N	82c3bb86-1c0f-5ec4-ad34-672223d70608	Check in at demo guesthouse	1	2026-08-02	14:00:00	Fictional itinerary for database testing.	completed
c6243456-32ac-596a-ae44-44a18f938f00	73937aee-5652-5451-a803-786e5eb9e2e3	\N	b4684683-0b4e-57c7-a2da-538662ac1623	Visit demo craft garden	2	2026-08-02	15:00:00	Fictional itinerary for database testing.	completed
72613ee2-b702-5735-88b5-96780deb4a29	73937aee-5652-5451-a803-786e5eb9e2e3	\N	a083d312-6ccd-58cc-a890-e06a99bc2bb8	Dinner at demo kitchen	3	2026-08-02	18:00:00	Fictional itinerary for database testing.	completed
af6c647c-cb7b-55de-9f4d-d6579553ed93	9c492966-aa51-57b0-996c-f4d4a0862a71	\N	33f41b4c-d352-5fe4-bb66-7a12e5b13c75	Check in at demo guesthouse	1	2026-08-03	14:00:00	Fictional itinerary for database testing.	completed
2d4339e3-d696-551b-952a-24ff23dc3644	9c492966-aa51-57b0-996c-f4d4a0862a71	\N	c9c2d665-33f0-5eda-8cf4-0e45ec6d242a	Visit demo craft garden	2	2026-08-03	15:00:00	Fictional itinerary for database testing.	completed
9dc6fc5e-9fd9-5d51-92a1-60eacbe23f46	9c492966-aa51-57b0-996c-f4d4a0862a71	\N	151d6181-3837-5268-aea2-28404c4a756a	Dinner at demo kitchen	3	2026-08-03	18:00:00	Fictional itinerary for database testing.	completed
dd75b612-6b2d-5758-8039-dd81ce322739	dc3087d5-4fea-553a-9d24-21e658b6daf1	\N	45c1b62c-dece-5435-be5e-a60d386fb7b8	Check in at demo guesthouse	1	2026-08-04	14:00:00	Fictional itinerary for database testing.	completed
96004026-5a06-574f-b9ac-2b004236cfb3	dc3087d5-4fea-553a-9d24-21e658b6daf1	\N	87878ea1-db87-51e8-9e27-0db6321c8cf9	Visit demo craft garden	2	2026-08-04	15:00:00	Fictional itinerary for database testing.	completed
95674e67-831c-506b-9ced-73dbfbe4d7bd	dc3087d5-4fea-553a-9d24-21e658b6daf1	\N	81dc328b-3be7-5b12-9b05-a3b3145b0c88	Dinner at demo kitchen	3	2026-08-04	18:00:00	Fictional itinerary for database testing.	completed
a7d93bbd-ad7b-5525-b2f3-fdbd05906124	8c985e95-ab8b-5942-9140-d7fa7f3da57d	\N	b3ce66c3-4971-5e59-afb7-bd97e05ea55f	Check in at demo guesthouse	1	2026-08-05	14:00:00	Fictional itinerary for database testing.	completed
384dba5e-b94c-5c3f-96f1-d467d9195c24	8c985e95-ab8b-5942-9140-d7fa7f3da57d	\N	78afeb8a-28d8-531b-af16-da8dad728550	Visit demo craft garden	2	2026-08-05	15:00:00	Fictional itinerary for database testing.	completed
dcb5afbb-a457-549f-a3da-8dfcfbab39d3	8c985e95-ab8b-5942-9140-d7fa7f3da57d	\N	edfa8fec-18f4-5300-95aa-4bd65eb25558	Dinner at demo kitchen	3	2026-08-05	18:00:00	Fictional itinerary for database testing.	completed
8edac552-926c-5301-9db8-f55f09e19934	61fb83b7-89b1-597a-bfb0-26c691e43087	\N	97d12e59-9306-5a71-bb23-cceefc44cfd1	Check in at demo guesthouse	1	2026-08-06	14:00:00	Fictional itinerary for database testing.	completed
34421530-9610-544a-8a7c-ff63cdd065f0	61fb83b7-89b1-597a-bfb0-26c691e43087	\N	5c6e8d11-ba1c-5a15-bb5f-0870a1a3948b	Visit demo craft garden	2	2026-08-06	15:00:00	Fictional itinerary for database testing.	completed
74fa73c2-1ff7-5515-ac80-f99289a16ef6	61fb83b7-89b1-597a-bfb0-26c691e43087	\N	f938c99a-491f-5cf1-8bd4-b366b550bb56	Dinner at demo kitchen	3	2026-08-06	18:00:00	Fictional itinerary for database testing.	completed
0b3ef8de-ba39-5b14-864e-ee2cb1948dee	40da3808-36f1-59cc-b682-5d6ee1707abe	\N	725197f4-b349-502e-acdb-c7660c422884	Check in at demo guesthouse	1	2026-08-07	14:00:00	Fictional itinerary for database testing.	completed
c8f46e4e-897b-50ff-9261-9f046d87cd6c	40da3808-36f1-59cc-b682-5d6ee1707abe	\N	c426d31f-ee4a-503c-ad03-b7668670cb1d	Visit demo craft garden	2	2026-08-07	15:00:00	Fictional itinerary for database testing.	completed
864d9227-91ff-53d6-933a-cd40fe64fc5e	40da3808-36f1-59cc-b682-5d6ee1707abe	\N	66f6c68a-f8fe-529f-b212-4547bb6709c9	Dinner at demo kitchen	3	2026-08-07	18:00:00	Fictional itinerary for database testing.	completed
7ccc4912-6f64-5236-a2da-8f5ff1b3d5f6	1280bb0d-5aae-5c86-af7c-082864371b26	\N	3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	Check in at demo guesthouse	1	2026-08-08	14:00:00	Fictional itinerary for database testing.	completed
34740102-3637-57a3-83e8-e94fb02ca62d	1280bb0d-5aae-5c86-af7c-082864371b26	\N	56c0336f-aca2-506f-857e-bb9dc3a38575	Visit demo craft garden	2	2026-08-08	15:00:00	Fictional itinerary for database testing.	completed
33946879-e367-5662-8f00-313efdcb879f	1280bb0d-5aae-5c86-af7c-082864371b26	\N	1806542c-12f1-5886-9692-161e2180f12f	Dinner at demo kitchen	3	2026-08-08	18:00:00	Fictional itinerary for database testing.	completed
ceb107bc-2ea5-55f5-93b8-3bdb6955da1f	931d36d0-512e-5ab7-9ff6-82ce277e4fee	\N	d3412e6e-644e-5e2b-bcce-a7ee456917c1	Check in at demo guesthouse	1	2026-08-09	14:00:00	Fictional itinerary for database testing.	completed
da31e6a7-f7d7-5015-99fe-75b7e7cbd839	931d36d0-512e-5ab7-9ff6-82ce277e4fee	\N	1d201536-a2f6-505b-80f9-d0000a2b6db8	Visit demo craft garden	2	2026-08-09	15:00:00	Fictional itinerary for database testing.	completed
9d473684-7bf0-50fd-991b-c4f8f966a48f	931d36d0-512e-5ab7-9ff6-82ce277e4fee	\N	d5cca9ba-5411-541f-8a94-ac593ac460f8	Dinner at demo kitchen	3	2026-08-09	18:00:00	Fictional itinerary for database testing.	completed
af4ad4c4-7ca8-5b06-a2fd-27a04da3549e	128f4bb2-d04c-5a75-8425-023faa0145e8	\N	db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	Check in at demo guesthouse	1	2026-08-10	14:00:00	Fictional itinerary for database testing.	completed
b20c1e72-f710-592f-bf19-8f4bead23545	128f4bb2-d04c-5a75-8425-023faa0145e8	\N	74b3172f-f41a-5743-bc4d-f6eb03a16047	Visit demo craft garden	2	2026-08-10	15:00:00	Fictional itinerary for database testing.	completed
1c665753-05fa-56f9-b246-7b433eea8c5e	128f4bb2-d04c-5a75-8425-023faa0145e8	\N	6fa94169-6895-50d2-a558-bbd2319adfd6	Dinner at demo kitchen	3	2026-08-10	18:00:00	Fictional itinerary for database testing.	completed
44e6e942-362a-587a-a9fc-6bce0d6683ef	bda935d3-1603-5307-967d-5be5f18cbd2d	\N	9a488d00-e1b0-56e5-a144-975d4cf028d6	Check in at demo guesthouse	1	2026-08-11	14:00:00	Fictional itinerary for database testing.	completed
33f3bb57-b512-52e4-b8ce-a8e427ec7cad	bda935d3-1603-5307-967d-5be5f18cbd2d	\N	50fc3f85-f202-5997-9828-6dd46035b3d3	Visit demo craft garden	2	2026-08-11	15:00:00	Fictional itinerary for database testing.	completed
2f8bc6dc-7b18-5c21-8d43-336831e54a22	bda935d3-1603-5307-967d-5be5f18cbd2d	\N	41a40c49-1a84-54e0-a57c-13c9f35eee67	Dinner at demo kitchen	3	2026-08-11	18:00:00	Fictional itinerary for database testing.	completed
a9a14884-dd22-5a7c-97b9-99ee059a023e	63b0f67a-a14c-55c1-8989-4c7fda629421	\N	aace4668-7c23-57e6-9152-8172aef490b6	Check in at demo guesthouse	1	2026-08-12	14:00:00	Fictional itinerary for database testing.	completed
589c2266-0be6-5082-95c1-bcfd7a15ed2d	63b0f67a-a14c-55c1-8989-4c7fda629421	\N	888d81e5-b37d-5452-b956-92a7523761e1	Visit demo craft garden	2	2026-08-12	15:00:00	Fictional itinerary for database testing.	completed
0f2583f0-d321-5797-a5b3-d9c2bfbee62c	63b0f67a-a14c-55c1-8989-4c7fda629421	\N	f20c4c94-6527-590b-9d92-010183847313	Dinner at demo kitchen	3	2026-08-12	18:00:00	Fictional itinerary for database testing.	completed
1617270f-d9fb-52ed-8bb1-6c2aacf081fc	5b6599d8-f659-58b1-b453-bc4226cdae62	\N	1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	Check in at demo guesthouse	1	2026-08-13	14:00:00	Fictional itinerary for database testing.	completed
9674e5d7-8ced-5928-890d-3b52c26d3d71	5b6599d8-f659-58b1-b453-bc4226cdae62	\N	9415615e-4a1e-5330-a84d-80f1bb33037f	Visit demo craft garden	2	2026-08-13	15:00:00	Fictional itinerary for database testing.	completed
60b876f0-8b19-5137-83a4-f94772a14f3b	5b6599d8-f659-58b1-b453-bc4226cdae62	\N	0e8ffa31-2640-54c0-8ebf-2a58e81eccde	Dinner at demo kitchen	3	2026-08-13	18:00:00	Fictional itinerary for database testing.	completed
d7627d9f-7d38-5576-b2f6-bc7353d9637a	576819a4-65ac-5fa9-949c-447726262176	\N	985a6a86-06a3-5c91-8d1b-24f504a3c01b	Check in at demo guesthouse	1	2026-08-14	14:00:00	Fictional itinerary for database testing.	completed
dff3489c-380c-5f1b-b557-e3c05ef0870b	576819a4-65ac-5fa9-949c-447726262176	\N	dc057260-3d1f-5736-94ab-a2f8c2222a5f	Visit demo craft garden	2	2026-08-14	15:00:00	Fictional itinerary for database testing.	completed
3a9dcc52-6ab5-5646-9673-49262e7856d5	576819a4-65ac-5fa9-949c-447726262176	\N	d9eb84af-8227-5c6f-a346-3708594abd23	Dinner at demo kitchen	3	2026-08-14	18:00:00	Fictional itinerary for database testing.	completed
6705f795-8b37-53a7-9f20-b0fa85da0164	1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea	\N	7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	Check in at demo guesthouse	1	2026-08-15	14:00:00	Fictional itinerary for database testing.	completed
c353c820-4b22-5212-a423-ca94669343d9	1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea	\N	c80b65fe-d043-5b4d-8127-87bb1a2bb5e5	Visit demo craft garden	2	2026-08-15	15:00:00	Fictional itinerary for database testing.	completed
57f88bfd-e70c-5796-9946-b20701a1884c	1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea	\N	5dc87c99-76c8-5404-9e48-48dec03b3533	Dinner at demo kitchen	3	2026-08-15	18:00:00	Fictional itinerary for database testing.	completed
f13b96ea-36e2-5dfe-a29e-57f6b1b0f114	61451445-3b0b-54f7-a59d-2652cb5ef2b6	\N	58486d62-05e9-5e1f-be39-fc315fff5f5c	Check in at demo guesthouse	1	2026-08-16	14:00:00	Fictional itinerary for database testing.	completed
b5707a9b-feac-5232-b6b5-8a3976be57e3	61451445-3b0b-54f7-a59d-2652cb5ef2b6	\N	f6e1127b-0493-5626-b4e0-62bb503d863d	Visit demo craft garden	2	2026-08-16	15:00:00	Fictional itinerary for database testing.	completed
66201737-d9e3-5e57-92f3-54f00e64f456	61451445-3b0b-54f7-a59d-2652cb5ef2b6	\N	1b84ae34-a436-5efa-a3f6-41929b781669	Dinner at demo kitchen	3	2026-08-16	18:00:00	Fictional itinerary for database testing.	completed
\.


--
-- Data for Name: trips; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.trips (id, profile_id, name, start_date, end_date, budget, status, completed_at, created_at, updated_at) FROM stdin;
73937aee-5652-5451-a803-786e5eb9e2e3	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	Agoo two-night visit (Demo)	2026-08-02	2026-08-04	4100.00	completed	2026-08-04 10:00:00+00	2026-07-20 02:00:00+00	2026-08-04 10:00:00+00
9c492966-aa51-57b0-996c-f4d4a0862a71	7562e428-178e-430b-af77-04f4a7fbaa0a	Aringay two-night visit (Demo)	2026-08-03	2026-08-05	4300.00	completed	2026-08-05 10:00:00+00	2026-07-20 02:00:00+00	2026-08-05 10:00:00+00
dc3087d5-4fea-553a-9d24-21e658b6daf1	9b8013fc-8493-409a-8f9f-f563b7d7c315	Bacnotan two-night visit (Demo)	2026-08-04	2026-08-06	4500.00	completed	2026-08-06 10:00:00+00	2026-07-20 02:00:00+00	2026-08-06 10:00:00+00
8c985e95-ab8b-5942-9140-d7fa7f3da57d	6d736964-b99f-47cd-a81f-df9940200e61	Bagulin two-night visit (Demo)	2026-08-05	2026-08-07	4700.00	completed	2026-08-07 10:00:00+00	2026-07-20 02:00:00+00	2026-08-07 10:00:00+00
61fb83b7-89b1-597a-bfb0-26c691e43087	c4adf4a6-b1f1-45af-8842-27d723b9519c	Balaoan two-night visit (Demo)	2026-08-06	2026-08-08	4900.00	completed	2026-08-08 10:00:00+00	2026-07-20 02:00:00+00	2026-08-08 10:00:00+00
40da3808-36f1-59cc-b682-5d6ee1707abe	3caf5b74-5392-4930-8f4b-ea57dd4f646f	Bangar two-night visit (Demo)	2026-08-07	2026-08-09	5100.00	completed	2026-08-09 10:00:00+00	2026-07-20 02:00:00+00	2026-08-09 10:00:00+00
1280bb0d-5aae-5c86-af7c-082864371b26	c3f1a421-b31e-4352-9a90-761ab03e4498	Bauang two-night visit (Demo)	2026-08-08	2026-08-10	5300.00	completed	2026-08-10 10:00:00+00	2026-07-20 02:00:00+00	2026-08-10 10:00:00+00
931d36d0-512e-5ab7-9ff6-82ce277e4fee	748530a7-420a-4609-93eb-980e78db48e3	Burgos two-night visit (Demo)	2026-08-09	2026-08-11	5500.00	completed	2026-08-11 10:00:00+00	2026-07-20 02:00:00+00	2026-08-11 10:00:00+00
128f4bb2-d04c-5a75-8425-023faa0145e8	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	Caba two-night visit (Demo)	2026-08-10	2026-08-12	5700.00	completed	2026-08-12 10:00:00+00	2026-07-20 02:00:00+00	2026-08-12 10:00:00+00
bda935d3-1603-5307-967d-5be5f18cbd2d	99f4f909-197a-433d-aa42-5d552f2778d5	Luna two-night visit (Demo)	2026-08-11	2026-08-13	5900.00	completed	2026-08-13 10:00:00+00	2026-07-20 02:00:00+00	2026-08-13 10:00:00+00
63b0f67a-a14c-55c1-8989-4c7fda629421	a4f9becd-16e4-47a7-b32d-39930b707c1f	Naguilian two-night visit (Demo)	2026-08-12	2026-08-14	6100.00	completed	2026-08-14 10:00:00+00	2026-07-20 02:00:00+00	2026-08-14 10:00:00+00
5b6599d8-f659-58b1-b453-bc4226cdae62	5a4b619a-3c52-45ef-afaf-d3d1351f7343	Pugo two-night visit (Demo)	2026-08-13	2026-08-15	6300.00	completed	2026-08-15 10:00:00+00	2026-07-20 02:00:00+00	2026-08-15 10:00:00+00
576819a4-65ac-5fa9-949c-447726262176	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	Rosario two-night visit (Demo)	2026-08-14	2026-08-16	6500.00	completed	2026-08-16 10:00:00+00	2026-07-20 02:00:00+00	2026-08-16 10:00:00+00
1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	San Fernando City two-night visit (Demo)	2026-08-15	2026-08-17	6700.00	completed	2026-08-17 10:00:00+00	2026-07-20 02:00:00+00	2026-08-17 10:00:00+00
61451445-3b0b-54f7-a59d-2652cb5ef2b6	f5512436-7401-4ee0-88a0-095ca33c7cbb	San Juan two-night visit (Demo)	2026-08-16	2026-08-18	6900.00	completed	2026-08-18 10:00:00+00	2026-07-20 02:00:00+00	2026-08-18 10:00:00+00
\.


--
-- Data for Name: user_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_reports (id, profile_id, report_type, description, listing_id, destination_id, review_id, photo_id, transport_id, status, assigned_to, submitted_at, resolved_at) FROM stdin;
835459a5-6bf2-588e-8006-a36df919dcd6	2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3	listing	Demo report: please verify the displayed check-in instructions.	82c3bb86-1c0f-5ec4-ad34-672223d70608	\N	\N	\N	\N	pending	\N	2026-08-04 13:15:00+00	\N
ce8fb4e1-3a95-52c8-a37e-dd27d98deab6	7562e428-178e-430b-af77-04f4a7fbaa0a	listing	Demo report: please verify the displayed check-in instructions.	33f41b4c-d352-5fe4-bb66-7a12e5b13c75	\N	\N	\N	\N	pending	\N	2026-08-05 13:15:00+00	\N
9a6a3ccb-f936-5e66-8fb9-4b2e60b2134c	9b8013fc-8493-409a-8f9f-f563b7d7c315	listing	Demo report: please verify the displayed check-in instructions.	45c1b62c-dece-5435-be5e-a60d386fb7b8	\N	\N	\N	\N	pending	\N	2026-08-06 13:15:00+00	\N
face0cb3-edad-58f3-8ab9-5d9dab75ffdd	6d736964-b99f-47cd-a81f-df9940200e61	listing	Demo report: please verify the displayed check-in instructions.	b3ce66c3-4971-5e59-afb7-bd97e05ea55f	\N	\N	\N	\N	pending	\N	2026-08-07 13:15:00+00	\N
a0bde350-4423-51da-9673-4e4b2c8a4255	c4adf4a6-b1f1-45af-8842-27d723b9519c	listing	Demo report: please verify the displayed check-in instructions.	97d12e59-9306-5a71-bb23-cceefc44cfd1	\N	\N	\N	\N	pending	\N	2026-08-08 13:15:00+00	\N
1af16b2a-d020-5c7e-825e-37562becb834	3caf5b74-5392-4930-8f4b-ea57dd4f646f	listing	Demo report: please verify the displayed check-in instructions.	725197f4-b349-502e-acdb-c7660c422884	\N	\N	\N	\N	pending	\N	2026-08-09 13:15:00+00	\N
4b3ad71d-55b6-5e09-8b17-2b8209e64016	c3f1a421-b31e-4352-9a90-761ab03e4498	listing	Demo report: please verify the displayed check-in instructions.	3ef64d86-c29a-5a30-b940-4b0b56b7cfd9	\N	\N	\N	\N	pending	\N	2026-08-10 13:15:00+00	\N
4ad508c6-86e8-56bb-8449-4650e02925d2	748530a7-420a-4609-93eb-980e78db48e3	listing	Demo report: please verify the displayed check-in instructions.	d3412e6e-644e-5e2b-bcce-a7ee456917c1	\N	\N	\N	\N	pending	\N	2026-08-11 13:15:00+00	\N
f039aa49-aa6f-5dec-88be-c9fe78ca1866	4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a	listing	Demo report: please verify the displayed check-in instructions.	db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc	\N	\N	\N	\N	pending	\N	2026-08-12 13:15:00+00	\N
9100d860-af01-55c8-ad09-bd2caff2dbb8	99f4f909-197a-433d-aa42-5d552f2778d5	listing	Demo report: please verify the displayed check-in instructions.	9a488d00-e1b0-56e5-a144-975d4cf028d6	\N	\N	\N	\N	pending	\N	2026-08-13 13:15:00+00	\N
ac807674-88b8-5aef-bec9-1e3455b79471	a4f9becd-16e4-47a7-b32d-39930b707c1f	listing	Demo report: please verify the displayed check-in instructions.	aace4668-7c23-57e6-9152-8172aef490b6	\N	\N	\N	\N	pending	\N	2026-08-14 13:15:00+00	\N
e133ade5-cc54-5b4d-9f05-b79fa4e588b5	5a4b619a-3c52-45ef-afaf-d3d1351f7343	listing	Demo report: please verify the displayed check-in instructions.	1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc	\N	\N	\N	\N	pending	\N	2026-08-15 13:15:00+00	\N
c1f3204f-394d-54c5-a640-c9aac804d412	5bd9c3ca-6f85-48ce-b4bb-a0996c081a59	listing	Demo report: please verify the displayed check-in instructions.	985a6a86-06a3-5c91-8d1b-24f504a3c01b	\N	\N	\N	\N	pending	\N	2026-08-16 13:15:00+00	\N
bea85db9-5d33-5f9a-b28b-77ace2395a4f	3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4	listing	Demo report: please verify the displayed check-in instructions.	7efb5c97-0baf-5cce-9416-bc0c0ab55fd1	\N	\N	\N	\N	pending	\N	2026-08-17 13:15:00+00	\N
3951e437-1cb5-5c6a-86e2-9e4e8dca66fa	f5512436-7401-4ee0-88a0-095ca33c7cbb	listing	Demo report: please verify the displayed check-in instructions.	58486d62-05e9-5e1f-be39-fc315fff5f5c	\N	\N	\N	\N	pending	\N	2026-08-18 13:15:00+00	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2026-09-16 06:44:49
20211116045059	2026-09-16 06:44:49
20211116050929	2026-09-16 06:44:49
20211116051442	2026-09-16 06:44:49
20211116212300	2026-09-16 06:44:49
20211116213355	2026-09-16 06:44:49
20211116213934	2026-09-16 06:44:49
20211116214523	2026-09-16 06:44:49
20211122062447	2026-09-16 06:44:49
20211124070109	2026-09-16 06:44:49
20211202204204	2026-09-16 06:44:49
20211202204605	2026-09-16 06:44:49
20211210212804	2026-09-16 06:44:49
20211228014915	2026-09-16 06:44:49
20220107221237	2026-09-16 06:44:49
20220228202821	2026-09-16 06:44:49
20220312004840	2026-09-16 06:44:49
20220603231003	2026-09-16 06:44:49
20220603232444	2026-09-16 06:44:49
20220615214548	2026-09-16 06:44:49
20220712093339	2026-09-16 06:44:49
20220908172859	2026-09-16 06:44:49
20220916233421	2026-09-16 06:44:49
20230119133233	2026-09-16 06:44:49
20230128025114	2026-09-16 06:44:49
20230128025212	2026-09-16 06:44:49
20230227211149	2026-09-16 06:44:49
20230228184745	2026-09-16 06:44:49
20230308225145	2026-09-16 06:44:49
20230328144023	2026-09-16 06:44:49
20231018144023	2026-09-16 06:44:49
20231204144023	2026-09-16 06:44:49
20231204144024	2026-09-16 06:44:49
20231204144025	2026-09-16 06:44:49
20240108234812	2026-09-16 06:44:49
20240109165339	2026-09-16 06:44:49
20240227174441	2026-09-16 06:44:49
20240311171622	2026-09-16 06:44:49
20240321100241	2026-09-16 06:44:49
20240401105812	2026-09-16 06:44:49
20240418121054	2026-09-16 06:44:49
20240523004032	2026-09-16 06:44:49
20240618124746	2026-09-16 06:44:49
20240801235015	2026-09-16 06:44:49
20240805133720	2026-09-16 06:44:49
20240827160934	2026-09-16 06:44:49
20240919163303	2026-09-16 06:44:49
20240919163305	2026-09-16 06:44:49
20241019105805	2026-09-16 06:44:49
20241030150047	2026-09-16 06:44:49
20241108114728	2026-09-16 06:44:49
20241121104152	2026-09-16 06:44:49
20241130184212	2026-09-16 06:44:49
20241220035512	2026-09-16 06:44:49
20241220123912	2026-09-16 06:44:49
20241224161212	2026-09-16 06:44:49
20250107150512	2026-09-16 06:44:49
20250110162412	2026-09-16 06:44:49
20250123174212	2026-09-16 06:44:49
20250128220012	2026-09-16 06:44:49
20250506224012	2026-09-16 06:44:49
20250523164012	2026-09-16 06:44:49
20250714121412	2026-09-16 06:44:49
20250905041441	2026-09-16 06:44:49
20251103001201	2026-09-16 06:44:49
20251120212548	2026-09-16 06:44:49
20251120215549	2026-09-16 06:44:49
20260218120000	2026-09-16 06:44:49
20260326120000	2026-09-16 06:44:49
20260514120000	2026-09-16 06:44:49
20260527120000	2026-09-16 06:44:49
20260528120000	2026-09-16 06:44:49
20260603120000	2026-09-16 06:44:49
20260605120000	2026-09-16 06:44:49
20260606110000	2026-09-16 06:44:49
20260616120000	2026-09-16 06:44:49
20260624120000	2026-09-16 06:44:49
20260626120000	2026-09-16 06:44:49
20260706120000	2026-09-16 06:44:49
20260707120000	2026-09-16 06:44:49
20260709120000	2026-09-16 06:44:49
20260714120000	2026-09-16 06:44:49
20260827120000	2026-09-16 06:44:49
20260914120000	2026-09-22 08:10:19
20260916120000	2026-09-22 08:10:21
20260922120000	2026-09-25 00:50:33
20260925120000	2026-09-30 11:46:33
20260928120000	2026-10-05 02:46:02
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter, selected_columns) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type, versioning_status, lifecycle_configuration, lifecycle_configuration_generation) FROM stdin;
travelmate-avatars	travelmate-avatars	\N	2026-09-16 14:27:42.992874+00	2026-09-16 14:27:42.992874+00	f	f	2097152	{image/jpeg,image/png,image/webp}	\N	STANDARD	DISABLED	\N	\N
travelmate-listings	travelmate-listings	\N	2026-09-17 12:52:27.298827+00	2026-09-17 12:52:27.298827+00	f	f	5242880	{image/jpeg,image/png,image/webp}	\N	STANDARD	DISABLED	\N	\N
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2026-09-16 06:17:38.720595
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2026-09-16 06:17:38.756196
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2026-09-16 06:17:38.758817
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2026-09-16 06:17:38.792022
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2026-09-16 06:17:38.803238
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2026-09-16 06:17:38.81718
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2026-09-16 06:17:38.857902
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2026-09-16 06:17:38.865843
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2026-09-16 06:17:38.868689
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2026-09-16 06:17:38.885473
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2026-09-16 06:17:38.888711
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2026-09-16 06:17:38.8929
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2026-09-16 06:17:38.900338
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2026-09-16 06:17:38.955376
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2026-09-16 06:17:38.968367
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2026-09-16 06:17:39.015784
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2026-09-16 06:17:39.070436
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2026-09-16 06:17:39.073059
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2026-09-16 06:17:39.075476
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2026-09-16 06:17:39.079254
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2026-09-16 06:17:39.08186
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2026-09-16 06:17:39.086381
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2026-09-16 06:17:39.097166
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2026-09-16 06:17:39.104957
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2026-09-16 06:17:39.107805
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2026-09-16 06:17:39.110399
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2026-09-16 06:17:39.11298
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2026-09-16 06:17:39.116069
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2026-09-16 06:17:39.118185
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2026-09-16 06:17:39.120297
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2026-09-16 06:17:39.122434
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2026-09-16 06:17:39.124632
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2026-09-16 06:17:39.126753
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2026-09-16 06:17:39.128826
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2026-09-16 06:17:39.130956
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2026-09-16 06:17:39.133049
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2026-09-16 06:17:39.135077
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2026-09-16 06:17:39.137065
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2026-09-16 06:17:39.140045
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2026-09-16 06:17:39.147135
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2026-09-16 06:17:39.149208
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2026-09-16 06:17:39.151535
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2026-09-16 06:17:39.15362
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2026-09-16 06:17:39.155936
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2026-09-16 06:17:39.157963
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2026-09-16 06:17:39.160777
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2026-09-16 06:17:39.16843
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2026-09-16 06:17:39.171164
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2026-09-16 06:17:39.173419
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2026-09-16 06:17:39.187716
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-09-16 06:17:39.190467
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-09-16 06:17:39.207752
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-09-16 06:17:39.209145
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-09-16 06:17:39.21689
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-09-16 06:17:39.218582
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-09-16 06:17:39.21995
56	fix-optimized-search-function	b823ed1e418101032fa01374edc9a436e54e3ed4	2026-09-16 06:17:39.223616
57	s3-multipart-uploads-metadata	f127886e00d1b374fadbc7c6b31e09336aad5287	2026-09-16 06:17:39.227247
58	operation-ergonomics	00ca5d483b3fe0d522133d9002ccc5df98365120	2026-09-16 06:17:39.230437
59	drop-unused-functions	38456f13e39691c2bbb4b5151d0d1cdbabd4a8c4	2026-09-16 06:17:39.233575
60	optimize-existing-functions-again	db35e1c91a9201e59f4fef8d972c2f277d68b157	2026-09-16 06:17:39.238991
61	mark-filename-immutable	fe0096517ae9d60aaec1d110172ba9036dc66bb7	2026-09-16 06:17:39.24176
62	object-versioning-core	0b855f00ff3be0bfca91efee02a9858912491a9a	2026-09-16 06:17:39.244254
63	fix-search-name-relative-to-prefix	c7485e417624f795ce8bb2da21927f48e088904d	2026-09-16 06:17:39.250019
64	fix-search-by-timestamp-sqli	0af424ecd388a39bb1645184b222185a12149675	2026-09-16 06:17:39.253597
66	objects-current-version-index	191466c93aa2c46a00e36505577c5fcab8d7cb4b	2026-09-16 06:17:39.720128
67	objects-null-version-index	15bfe8c35b66642b6c78ba60060fa8793bd2207a	2026-09-16 06:17:39.72893
65	objects-key-version-index	da319c4b89ba800ce795d1b699f3a70675138058	2026-09-16 06:17:39.261377
68	bucket-lifecycle-configuration	3c08f6f889922f399519722a932b51007c11bebc	2026-09-22 08:10:19.040823
69	validate-bucket-lifecycle-constraints	4febacaaaa0e61e2b783bef081fe03a287e65eb3	2026-09-22 08:10:19.454818
70	list-objects-with-versions	5c17c3777616cd8d7b18b82835525fa3205af57b	2026-09-22 08:10:19.466339
71	objects-delete-marker-index	6d14858e66c66f8d6accf8a2630aefd1527fddba	2026-09-22 08:10:19.955102
72	drop-bucketid-objname-index	302beb09e1b469d7d4db19566f2389d280b64aa3	2026-09-22 08:10:20.186613
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, archived_at, is_delete_marker, is_versioned) FROM stdin;
2b5b7bf1-1838-4a87-92cb-89e21a35ebec	travelmate-avatars	1f35520c-9114-4cbb-b369-86d2b431c76e/6e2e76a3-a5ec-4717-a35b-052b9968d21c.png	1f35520c-9114-4cbb-b369-86d2b431c76e	2026-09-16 16:02:26.371496+00	2026-09-16 16:02:26.371496+00	2026-09-16 16:02:26.371496+00	{"eTag": "\\"ae8157f6d1226a4c3d9e96a53c766f42\\"", "size": 26070, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-16T16:02:27.000Z", "contentLength": 26070, "httpStatusCode": 200}	cf1c7df1-6044-46a5-9aeb-ed4eb325f557	1f35520c-9114-4cbb-b369-86d2b431c76e	{}	\N	f	f
6e9fdaea-cc6f-483b-9cae-26dacf865d4a	travelmate-avatars	423028d7-3027-4ae9-947c-d5428e29b88f/64d6445c-a409-44c1-a4c6-ef4143b53c96.jpg	423028d7-3027-4ae9-947c-d5428e29b88f	2026-09-17 04:07:54.764615+00	2026-09-17 04:07:54.764615+00	2026-09-17 04:07:54.764615+00	{"eTag": "\\"b66b067982498f7862682f9aac54a368\\"", "size": 309012, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-09-17T04:07:55.000Z", "contentLength": 309012, "httpStatusCode": 200}	2010533f-d3d4-4df4-957c-bd9cf2ccbbd7	423028d7-3027-4ae9-947c-d5428e29b88f	{}	\N	f	f
a2cd0f7e-d479-4d9d-955d-d99a2c734eb8	travelmate-avatars	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c/24d6e64d-d2c3-4bb7-add0-c71252a5aa0d.jpg	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	2026-09-17 07:05:12.960895+00	2026-09-17 07:05:12.960895+00	2026-09-17 07:05:12.960895+00	{"eTag": "\\"ddc333b73404d81ccc4f7621e5e959dc\\"", "size": 356435, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-09-17T07:05:13.000Z", "contentLength": 356435, "httpStatusCode": 200}	8a9a7635-d827-4b75-aa39-cb99875499d2	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	{}	\N	f	f
e8f6c9b4-0996-4a13-bd4e-432e8c926b30	travelmate-avatars	71f2a91a-e5e2-4a42-b830-2eea593be359/09fb61ca-3fc0-4c0e-9fc1-c94b0cf979fe.png	71f2a91a-e5e2-4a42-b830-2eea593be359	2026-09-17 13:07:32.562321+00	2026-09-17 13:07:32.562321+00	2026-09-17 13:07:32.562321+00	{"eTag": "\\"2ef41b09cc0ca8696ed67e10fb4e78c1\\"", "size": 6916, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-17T13:07:33.000Z", "contentLength": 6916, "httpStatusCode": 200}	98247132-74e3-495e-a20f-eecc5c991aeb	71f2a91a-e5e2-4a42-b830-2eea593be359	{}	\N	f	f
2029ed45-7a40-41fd-a595-c625848267a1	travelmate-listings	08c59a01-6bf6-44c6-b6f1-de0131a3dccf/82c3bb86-1c0f-5ec4-ad34-672223d70608/demo.png	\N	2026-09-18 01:23:52.375106+00	2026-09-18 01:23:52.375106+00	2026-09-18 01:23:52.375106+00	{"eTag": "\\"001ebde302948ce96edd0054994b6db5\\"", "size": 14449, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:53.000Z", "contentLength": 14449, "httpStatusCode": 200}	a0cc500f-6905-4a46-89bc-ddb25cb4fac3	\N	{}	\N	f	f
c26ad35c-5601-4223-a584-e7b1a43fb77d	travelmate-listings	e5931678-254c-4abf-85fa-71e667896a41/33f41b4c-d352-5fe4-bb66-7a12e5b13c75/demo.png	\N	2026-09-18 01:23:53.325533+00	2026-09-18 01:23:53.325533+00	2026-09-18 01:23:53.325533+00	{"eTag": "\\"5b846c19671a9953a2c1f039fcbede98\\"", "size": 13550, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:54.000Z", "contentLength": 13550, "httpStatusCode": 200}	8685965e-aef5-409a-b286-680c14803236	\N	{}	\N	f	f
a4540f1c-3c52-41a9-8385-6faadc703bd4	travelmate-listings	41942500-0b1b-4215-a759-29ffd1733f27/45c1b62c-dece-5435-be5e-a60d386fb7b8/demo.png	\N	2026-09-18 01:23:53.955602+00	2026-09-18 01:23:53.955602+00	2026-09-18 01:23:53.955602+00	{"eTag": "\\"fb79fdbf289a33c34df877aacd54e822\\"", "size": 14378, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:54.000Z", "contentLength": 14378, "httpStatusCode": 200}	43d48dba-4283-4851-9d32-cfdf82411829	\N	{}	\N	f	f
6822461b-045a-4463-ba86-468f77fc3a5a	travelmate-listings	fe304e3d-1946-46cb-bb2d-77f8702c0f05/b3ce66c3-4971-5e59-afb7-bd97e05ea55f/demo.png	\N	2026-09-18 01:23:54.600174+00	2026-09-18 01:23:54.600174+00	2026-09-18 01:23:54.600174+00	{"eTag": "\\"990900cbcd0b75109ebb2daa75557b93\\"", "size": 14047, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:55.000Z", "contentLength": 14047, "httpStatusCode": 200}	789778f0-8f7f-4bf5-ac21-1c8afa246b46	\N	{}	\N	f	f
4c8bb3ba-14ac-42b6-af38-1e841ca0ebcb	travelmate-listings	392e6791-10b8-4c3d-8800-9efe6d29f8b2/97d12e59-9306-5a71-bb23-cceefc44cfd1/demo.png	\N	2026-09-18 01:23:55.241788+00	2026-09-18 01:23:55.241788+00	2026-09-18 01:23:55.241788+00	{"eTag": "\\"4c053428428aa4be11b85c77db72d5c8\\"", "size": 13631, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:56.000Z", "contentLength": 13631, "httpStatusCode": 200}	eaf9bccb-9f9a-4571-b2aa-fa4e329af026	\N	{}	\N	f	f
883975d4-3aa8-43ea-b09d-2c00d99af9b2	travelmate-listings	8e59134a-da94-4cd6-9eb7-ff46c9d56195/725197f4-b349-502e-acdb-c7660c422884/demo.png	\N	2026-09-18 01:23:55.884966+00	2026-09-18 01:23:55.884966+00	2026-09-18 01:23:55.884966+00	{"eTag": "\\"db1cb5f95886a1763c6394c04da6e6dd\\"", "size": 14725, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:56.000Z", "contentLength": 14725, "httpStatusCode": 200}	3fd088bc-04a6-450a-ad6c-51ca2cd90382	\N	{}	\N	f	f
0b2af04d-7af1-4333-9015-554e26b3f3f0	travelmate-listings	34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a/3ef64d86-c29a-5a30-b940-4b0b56b7cfd9/demo.png	\N	2026-09-18 01:23:56.518482+00	2026-09-18 01:23:56.518482+00	2026-09-18 01:23:56.518482+00	{"eTag": "\\"a9c5dc4ac20b4acd0cf73d74544c5a2b\\"", "size": 14773, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:57.000Z", "contentLength": 14773, "httpStatusCode": 200}	0912b125-f37e-4372-abab-68e7a6339442	\N	{}	\N	f	f
36c82e0e-7a7c-4a10-b415-8c299f77d786	travelmate-listings	6a11f3df-d69c-4148-80ee-88f1f7c95e2a/d3412e6e-644e-5e2b-bcce-a7ee456917c1/demo.png	\N	2026-09-18 01:23:57.317674+00	2026-09-18 01:23:57.317674+00	2026-09-18 01:23:57.317674+00	{"eTag": "\\"c7dc0a29305407bd433aef2e85f9889b\\"", "size": 14337, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:58.000Z", "contentLength": 14337, "httpStatusCode": 200}	66488999-c1bd-4a8a-aae9-619707fad3c8	\N	{}	\N	f	f
ab754925-3844-4f3d-b42e-aa427ae077e2	travelmate-listings	9cb2f62f-5cab-43f3-9c64-dde893e6e4bb/db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc/demo.png	\N	2026-09-18 01:23:57.976835+00	2026-09-18 01:23:57.976835+00	2026-09-18 01:23:57.976835+00	{"eTag": "\\"2719a9aabbf6eea61ccf448014d311cd\\"", "size": 15551, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:58.000Z", "contentLength": 15551, "httpStatusCode": 200}	89409d1e-e20a-409d-b6bd-fe539dd099a7	\N	{}	\N	f	f
d378ae3d-944e-49d6-afe2-a2e8e32b1c00	travelmate-listings	c4a4841a-aa8a-4de6-b83c-b2bd6203042c/9a488d00-e1b0-56e5-a144-975d4cf028d6/demo.png	\N	2026-09-18 01:23:58.593778+00	2026-09-18 01:23:58.593778+00	2026-09-18 01:23:58.593778+00	{"eTag": "\\"7e333273974d36ceb80ecdf5c4169857\\"", "size": 14777, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:59.000Z", "contentLength": 14777, "httpStatusCode": 200}	5ba5e91c-ee1d-4585-bf45-abc682ca1a0d	\N	{}	\N	f	f
646d813d-40bb-4e99-9a7a-a19d21edfc70	travelmate-listings	8eba38fb-47ef-4be9-b26e-b109bccf0031/aace4668-7c23-57e6-9152-8172aef490b6/demo.png	\N	2026-09-18 01:23:59.253973+00	2026-09-18 01:23:59.253973+00	2026-09-18 01:23:59.253973+00	{"eTag": "\\"99d95eda09909e846049dcc4bcc18888\\"", "size": 13375, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:00.000Z", "contentLength": 13375, "httpStatusCode": 200}	eaa0fa55-3a7e-419b-a14f-c14e39d39162	\N	{}	\N	f	f
05778951-c572-460a-9daf-fd0b6be222e8	travelmate-listings	5b305524-490a-4334-831e-b46d622648a8/1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc/demo.png	\N	2026-09-18 01:24:00.055284+00	2026-09-18 01:24:00.055284+00	2026-09-18 01:24:00.055284+00	{"eTag": "\\"808d53fe0b59c806f5292cbf6ef4a090\\"", "size": 14741, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:01.000Z", "contentLength": 14741, "httpStatusCode": 200}	6efeff35-3e4a-428d-a524-0fb62ebb9037	\N	{}	\N	f	f
b5314e42-bcbc-44f2-8117-2384be8d940e	travelmate-listings	1ef0a385-782d-4808-999a-58733a4b209d/985a6a86-06a3-5c91-8d1b-24f504a3c01b/demo.png	\N	2026-09-18 01:24:00.777629+00	2026-09-18 01:24:00.777629+00	2026-09-18 01:24:00.777629+00	{"eTag": "\\"6d67546577e9d5731f64f73203c6a10c\\"", "size": 14410, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:01.000Z", "contentLength": 14410, "httpStatusCode": 200}	ecb0874c-a25a-4749-afdf-b7da38daf050	\N	{}	\N	f	f
a435c548-0c25-4516-85ba-85d52fe75665	travelmate-listings	0ea90927-1b7e-4674-a3df-092d82395d70/7efb5c97-0baf-5cce-9416-bc0c0ab55fd1/demo.png	\N	2026-09-18 01:24:01.295087+00	2026-09-18 01:24:01.295087+00	2026-09-18 01:24:01.295087+00	{"eTag": "\\"255bc0539722da4b0ef6feff59b762c6\\"", "size": 14663, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:02.000Z", "contentLength": 14663, "httpStatusCode": 200}	01781169-e6f5-4f47-834f-4038fdf68adc	\N	{}	\N	f	f
62a319b3-9c2c-4ba1-bb86-6cace10610e7	travelmate-listings	df48bcda-05d5-4d27-8b94-0fec879a5ab8/58486d62-05e9-5e1f-be39-fc315fff5f5c/demo.png	\N	2026-09-18 01:24:01.924293+00	2026-09-18 01:24:01.924293+00	2026-09-18 01:24:01.924293+00	{"eTag": "\\"8e0446018f51c45849aede3f88d50912\\"", "size": 14528, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:02.000Z", "contentLength": 14528, "httpStatusCode": 200}	28d6acb8-17ac-4f2d-959e-5882cb2b2753	\N	{}	\N	f	f
e60bdeff-5b6d-48fd-802c-5c399117ff71	travelmate-avatars	bfc3af84-a566-412d-a1f3-b3f36b697278/986f0697-bf16-4188-9aa0-5d8a39f49bbe.png	bfc3af84-a566-412d-a1f3-b3f36b697278	2026-10-01 13:21:41.242029+00	2026-10-01 13:21:41.242029+00	2026-10-01 13:21:41.242029+00	{"eTag": "\\"d5d7c2d0dc6956a36dabb2b02321f0a3\\"", "size": 1070573, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-10-01T13:21:42.000Z", "contentLength": 1070573, "httpStatusCode": 200}	3a6a9ae9-988e-4980-bea9-2d2b0bedd048	bfc3af84-a566-412d-a1f3-b3f36b697278	{}	\N	f	f
2b596e1d-cc57-40a5-90dd-12311f6b4324	travelmate-avatars	9f8f0e34-1876-4a04-9a26-a65537ad2f33/d65146b7-6daf-4c93-a467-bf32976957c8.png	9f8f0e34-1876-4a04-9a26-a65537ad2f33	2026-10-01 13:55:17.249309+00	2026-10-01 13:55:17.249309+00	2026-10-01 13:55:17.249309+00	{"eTag": "\\"05248efe27a6fc56eaa0701e2cc911d2\\"", "size": 956381, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-10-01T13:55:18.000Z", "contentLength": 956381, "httpStatusCode": 200}	93b578c6-cd06-4161-ad5e-638f20b5fcb3	9f8f0e34-1876-4a04-9a26-a65537ad2f33	{}	\N	f	f
0bb91868-b6f6-4b06-9ec7-d8c2a8c1491c	travelmate-listings	9f8f0e34-1876-4a04-9a26-a65537ad2f33/e9ac07ff-f835-41f3-b33e-67818623c6f0/6a8166fc-6007-4a51-92ab-ce41776d9c66.png	9f8f0e34-1876-4a04-9a26-a65537ad2f33	2026-10-04 01:40:14.349241+00	2026-10-04 01:40:14.349241+00	2026-10-04 01:40:14.349241+00	{"eTag": "\\"05248efe27a6fc56eaa0701e2cc911d2\\"", "size": 956381, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-10-04T01:40:15.000Z", "contentLength": 956381, "httpStatusCode": 200}	1dc81249-86f6-4fbd-a7c8-596163214e9f	9f8f0e34-1876-4a04-9a26-a65537ad2f33	{}	\N	f	f
383d4b59-9c9a-407f-a746-762443619082	travelmate-listings	9f8f0e34-1876-4a04-9a26-a65537ad2f33/06f7fb52-4345-4555-a27f-258d8e829b95/2d4c92bc-6d2f-4a3e-8aae-3a4ad817d2e4.png	9f8f0e34-1876-4a04-9a26-a65537ad2f33	2026-10-04 02:12:23.361341+00	2026-10-04 02:12:23.361341+00	2026-10-04 02:12:23.361341+00	{"eTag": "\\"05248efe27a6fc56eaa0701e2cc911d2\\"", "size": 956381, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-10-04T02:12:24.000Z", "contentLength": 956381, "httpStatusCode": 200}	1c95d6f5-97c3-4881-b63b-2ffd240f39cb	9f8f0e34-1876-4a04-9a26-a65537ad2f33	{}	\N	f	f
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata, metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: amenities; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.amenities (id, name) FROM stdin;
2	Parking
1	Wi-Fi
\.


--
-- Data for Name: analytics_reports; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.analytics_reports (id, generated_by, period_start, period_end, status, generated_at, created_at) FROM stdin;
1	3	\N	\N	generated	2026-09-11 10:43:07	2026-09-11 18:43:07
\.


--
-- Data for Name: attraction_schedules; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.attraction_schedules (id, attraction_id, operating_day, schedule_text) FROM stdin;
1	3	Tuesday-Sunday	09:00-17:00 (demo)
\.


--
-- Data for Name: attractions; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.attractions (listing_id, entrance_fee) FROM stdin;
3	100.00
\.


--
-- Data for Name: auth_sessions; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.auth_sessions (id, user_id, token_hash, login_at, last_seen_at, expires_at, logout_at, status) FROM stdin;
\.


--
-- Data for Name: booking_rooms; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.booking_rooms (id, booking_id, room_id, nightly_rate) FROM stdin;
1	1	1	1500.00
4	7	4	1000.00
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.bookings (id, user_id, booking_type, guest_name, guest_email, guest_phone, guest_count, total_amount, status, hold_expires_at, idempotency_key, created_at, updated_at) FROM stdin;
1	1	hotel	Demo Guest	guest@example.test	\N	2	3000.00	confirmed	\N	demo-booking-hotel-001	2026-09-07 14:15:07	2026-09-07 14:15:07
2	1	restaurant	Demo Guest	guest@example.test	\N	3	0.00	confirmed	\N	demo-booking-restaurant-001	2026-09-07 14:15:07	2026-09-07 14:15:07
7	6	hotel	Jonas Wally G. Loyola	hnasly30@gmail.com	\N	2	2000.00	cancelled	\N	tm7:56c93d00a9da22c355a21100d96f6b11228b57bfd293fff47a52510e744dc47a	2026-09-10 08:53:28	2026-09-11 10:51:59
\.


--
-- Data for Name: business_listings; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.business_listings (id, owner_id, destination_id, name, slug, listing_type, description, address, status, created_at, updated_at) FROM stdin;
1	1	1	Demo Coast Hotel	demo-coast-hotel	hotel	Fictional school-project sample.	Demo location; not a real business address	approved	2026-09-07 14:15:07	2026-09-07 14:15:07
2	1	1	Demo Garden Cafe	demo-garden-cafe	restaurant	Fictional school-project sample.	Demo location; not a real business address	approved	2026-09-07 14:15:07	2026-09-07 14:15:07
3	1	2	Demo Heritage Gallery	demo-heritage-gallery	attraction	Fictional school-project sample.	Demo location; not a real business address	approved	2026-09-07 14:15:07	2026-09-07 14:15:07
4	3	1	test1	test1-e502ee7f-444d-4186-b0bb-428bb97016ec	hotel	aaa	ayaya	approved	2026-09-09 18:59:38	2026-09-09 11:05:44
9	3	2	test2	test2-abf186f9-b97d-4683-9ba4-612987c769f0	restaurant	ayaya	ayaya	approved	2026-09-10 17:14:27	2026-09-10 09:17:52
\.


--
-- Data for Name: business_owners; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.business_owners (id, user_id, contact_name, contact_email) FROM stdin;
1	2	Demo TravelMate Partner	partner@example.test
2	7	Jonas Wally G. Loyola	screw1318@gmai.com
3	9	Jonas Wally G. Loyola	jloyola0669@student.dmmmsu.edu.ph
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.categories (id, name, description) FROM stdin;
1	Beach	\N
2	Mountain	\N
3	Cultural	\N
\.


--
-- Data for Name: cuisines; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.cuisines (id, name) FROM stdin;
1	Filipino
\.


--
-- Data for Name: data_sources; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.data_sources (id, name) FROM stdin;
1	bookings
3	business_listings
5	reviews
6	user_reports
2	users
\.


--
-- Data for Name: destinations; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.destinations (id, category_id, name, province, slug, description, latitude, longitude, is_active, created_at, updated_at) FROM stdin;
1	1	San Juan	La Union	san-juan-la-union	Demo content for learning. Business listings and prices below are fictional.	\N	\N	1	2026-09-07 14:15:07	2026-09-07 14:15:07
2	2	Baguio	Benguet	baguio-benguet	Demo content for learning. Business listings and prices below are fictional.	\N	\N	1	2026-09-07 14:15:07	2026-09-07 14:15:07
\.


--
-- Data for Name: hotel_amenities; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.hotel_amenities (hotel_id, amenity_id) FROM stdin;
1	1
1	2
\.


--
-- Data for Name: hotel_bookings; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.hotel_bookings (booking_id, hotel_id, check_in, check_out) FROM stdin;
1	1	2030-06-10	2030-06-12
7	4	2026-09-12	2026-09-14
\.


--
-- Data for Name: hotels; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.hotels (listing_id, check_in_time, check_out_time) FROM stdin;
1	14:00:00	12:00:00
4	18:59:00	20:00:00
\.


--
-- Data for Name: login_attempts; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.login_attempts (id, user_id, attempted_email, ip_address, succeeded, attempted_at) FROM stdin;
\.


--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.menu_items (id, restaurant_id, name, description, category, price, is_available) FROM stdin;
1	2	Demo Vegetable Rice Bowl	\N	Mains	180.00	1
2	2	Demo Calamansi Juice	\N	Drinks	60.00	1
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.notifications (id, user_id, message, read_at, created_at) FROM stdin;
1	1	Welcome to the TravelMate demo database.	\N	2026-09-07 14:15:07
13	3	Listing #9 (test2) was submitted for approval.	2026-09-10 09:17:58	2026-09-10 09:14:27
14	9	Listing #9 (test2) was submitted for approval.	2026-09-10 09:17:17	2026-09-10 09:14:27
15	3	Listing #9 (test2) was submitted for approval.	2026-09-10 09:17:56	2026-09-10 09:14:36
16	9	Listing #9 (test2) was submitted for approval.	2026-09-10 09:17:17	2026-09-10 09:14:36
17	9	Listing #9 (test2): approved.	2026-09-10 09:18:07	2026-09-10 09:17:52
30	3	A photo for listing #4 is awaiting review. Open Admin > Photo approvals.	2026-09-11 10:41:09	2026-09-10 09:58:32
37	6	Booking #7 at test1: cancelled.	2026-09-11 10:52:07	2026-09-11 10:51:59
38	9	Booking #7 at test1: cancelled.	2026-09-11 13:36:20	2026-09-11 10:51:59
39	3	Issue #2 was submitted. Open Admin > Reported issues.	\N	2026-09-11 13:22:05
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.payments (id, booking_id, method, provider, provider_reference, idempotency_key, amount, status, is_demo, created_at, paid_at) FROM stdin;
1	1	pay_at_venue	demo	DEMO-PAY-001	demo-payment-001	3000.00	pending	1	2026-09-07 14:15:07	\N
\.


--
-- Data for Name: photos; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.photos (id, destination_id, listing_id, url, caption, sort_order, status, created_at) FROM stdin;
2	\N	4	travelmate-media/e9773e34-6ad7-4214-8283-1c87981f550c.png	\N	0	approved	2026-09-10 17:58:32
\.


--
-- Data for Name: preferences; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.preferences (id, category, name) FROM stdin;
1	Travel Style	Beach trips
\.


--
-- Data for Name: recommendations; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.recommendations (id, user_id, destination_id, reason, recommended_at) FROM stdin;
1	1	1	Matches selected beach preference (demo).	2026-09-07 14:15:07
\.


--
-- Data for Name: refunds; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.refunds (id, payment_id, amount, reason, status, provider_reference, idempotency_key, created_at, refunded_at) FROM stdin;
\.


--
-- Data for Name: report_data_sources; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.report_data_sources (report_id, data_source_id) FROM stdin;
1	1
1	2
1	3
1	5
1	6
\.


--
-- Data for Name: report_metrics; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.report_metrics (id, report_id, name, value, unit) FROM stdin;
1	1	Accounts created	7.0000	count
2	1	Listings submitted	5.0000	count
3	1	Bookings created	3.0000	count
4	1	Bookings currently confirmed	3.0000	count
5	1	Bookings currently completed	0.0000	count
6	1	Bookings currently cancelled	0.0000	count
7	1	Bookings awaiting confirmation	0.0000	count
8	1	Bookings with expired holds	0.0000	count
9	1	Reviews submitted	3.0000	count
10	1	Issues submitted	1.0000	count
11	1	Issues currently pending	1.0000	count
\.


--
-- Data for Name: report_report_types; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.report_report_types (report_id, report_type_id) FROM stdin;
1	2
\.


--
-- Data for Name: report_types; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.report_types (id, name) FROM stdin;
1	Booking Summary
2	TravelMate activity summary
\.


--
-- Data for Name: restaurant_bookings; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.restaurant_bookings (booking_id, slot_id) FROM stdin;
2	1
\.


--
-- Data for Name: restaurant_cuisines; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.restaurant_cuisines (restaurant_id, cuisine_id) FROM stdin;
2	1
\.


--
-- Data for Name: restaurant_slots; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.restaurant_slots (id, restaurant_id, starts_at, ends_at, capacity, is_open) FROM stdin;
1	2	2030-06-11 04:00:00	2030-06-11 05:00:00	12	1
\.


--
-- Data for Name: restaurants; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.restaurants (listing_id, operating_hours, reservation_fee) FROM stdin;
2	Daily 09:00-20:00 (demo)	0.00
9	2	99.99
\.


--
-- Data for Name: review_comments; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.review_comments (id, review_id, user_id, body, status, created_at) FROM stdin;
1	2	2	Sample owner reply for testing.	published	2026-09-07 14:15:07
\.


--
-- Data for Name: review_tags; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.review_tags (review_id, tag_id) FROM stdin;
1	1
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.reviews (id, user_id, destination_id, listing_id, rating, review_text, status, created_at, updated_at) FROM stdin;
1	1	1	\N	5	Fictional sample destination review.	published	2026-09-07 14:15:07	2026-09-07 14:15:07
2	1	\N	1	4	Fictional sample business review.	published	2026-09-07 14:15:07	2026-09-07 14:15:07
7	6	\N	4	5	dfdfsfsdfa	published	2026-09-09 11:07:00	2026-09-09 11:07:00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.roles (id, name) FROM stdin;
3	admin
5	analyst
2	business_owner
4	moderator
6	support
1	traveler
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.rooms (id, hotel_id, room_number, room_type, max_guests, base_nightly_rate, operational_status) FROM stdin;
1	1	101	Standard	2	1500.00	available
2	1	102	Family	4	2200.00	available
4	4	101	Big	2	1000.00	available
\.


--
-- Data for Name: search_history; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.search_history (id, user_id, trip_id, keyword, filter_text, searched_at) FROM stdin;
1	1	1	San Juan	\N	2026-09-07 14:15:07
\.


--
-- Data for Name: session_ips; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.session_ips (id, session_id, ip_address, first_seen_at) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.tags (id, name) FROM stdin;
1	Scenic
\.


--
-- Data for Name: transport_provider_contacts; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.transport_provider_contacts (id, provider_id, phone_number) FROM stdin;
\.


--
-- Data for Name: transport_providers; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.transport_providers (id, owner_id, company_name, description) FROM stdin;
1	1	Demo Local Shuttle	\N
\.


--
-- Data for Name: transportation_services; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.transportation_services (id, provider_id, destination_id, transport_type, service_name, status) FROM stdin;
1	1	1	Van	Demo Town Shuttle	approved
\.


--
-- Data for Name: trip_items; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.trip_items (id, trip_id, destination_id, listing_id, activity, sequence_number, planned_date, planned_time, notes, status) FROM stdin;
1	1	1	\N	Explore destination	1	\N	\N	\N	planned
2	1	\N	2	Lunch stop	2	\N	\N	\N	planned
5	4	2	\N	wdad	1	2026-09-09	18:41:00	adsdasd	planned
\.


--
-- Data for Name: trips; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.trips (id, user_id, name, start_date, end_date, budget, status, completed_at, created_at, updated_at) FROM stdin;
1	1	Demo Weekend Plan	\N	\N	\N	draft	\N	2026-09-07 14:15:07	2026-09-07 14:15:07
4	6	Yeheyyy	2026-09-01	2026-09-30	10000.00	draft	\N	2026-09-09 18:39:07	2026-09-09 10:43:18
\.


--
-- Data for Name: user_phones; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.user_phones (id, user_id, phone_number) FROM stdin;
\.


--
-- Data for Name: user_preferences; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.user_preferences (user_id, preference_id) FROM stdin;
1	1
6	1
9	1
\.


--
-- Data for Name: user_reports; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.user_reports (id, user_id, report_type, description, listing_id, destination_id, review_id, photo_id, transport_id, status, assigned_to, submitted_at, resolved_at) FROM stdin;
1	1	listing	Demo issue report for moderation practice.	1	\N	\N	\N	\N	pending	\N	2026-09-07 14:15:07	\N
2	6	bug	yeyeyeyey yeyeyey yeyeye	\N	\N	\N	\N	\N	pending	\N	2026-09-11 21:22:05	\N
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.user_roles (user_id, role_id) FROM stdin;
1	1
2	1
2	2
3	3
6	1
7	1
7	2
8	1
9	1
9	2
10	1
11	1
12	1
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.users (id, full_name, email, password_hash, address, avatar_url, account_status, email_verified_at, created_at, updated_at, auth_user_id, avatar_object_path) FROM stdin;
1	Demo Traveler	traveler@example.test	$2b$12$uRgSRCeIdpypCSeoKd00beSk/O5UU.YFUuPaTf988oqmBuyNSvXVy	Demo address only	\N	active	\N	2026-09-07 14:15:07	2026-09-07 14:15:07	\N	\N
2	Demo Owner	owner@example.test	$2b$12$uRgSRCeIdpypCSeoKd00beSk/O5UU.YFUuPaTf988oqmBuyNSvXVy	Demo address only	\N	active	\N	2026-09-07 14:15:07	2026-09-07 14:15:07	\N	\N
3	Demo Admin	admin@example.test	$2y$12$It59Y.rHjZ9HOdNsDnPHeedioRseljcpUD8cRCGpOhY9k00qjr4d.	Demo address only	\N	active	\N	2026-09-07 14:15:07	2026-09-09 19:04:50	\N	\N
6	Jonas Wally G. Loyola	hnasly30@gmail.com	$2y$12$1VisMisenooulP6TxVcd5uYUar39GnbKtC91OnJVy3VMzPuZ37Qy2	\N	\N	active	\N	2026-09-08 13:29:58	2026-09-11 13:21:21	\N	\N
7	Jonas Wally G. Loyola	screw1318@gmai.com	$2y$12$y.OgkGTj45I2XnMG1Xzd2.cMVzfgrer6KF//AZIg.17Eseoqe2Nsi	\N	\N	active	\N	2026-09-08 13:44:55	2026-09-08 13:44:55	\N	\N
8	Jonas Wally G. Loyola	stagnantwater28@gmail.com	$2y$12$y9m0ooTFIhfsLYQ/1puIEO2KTOf2u9GgbvModOoJ/VTjXKWpI4kVa	\N	\N	active	\N	2026-09-09 10:40:43	2026-09-09 10:40:43	\N	\N
9	Nas	jloyola0669@student.dmmmsu.edu.ph	$2y$12$IT1OKzzqR4HI1/Lzq76f4.Sl/yo9lbFoQnyugMgCMSZuJAOyFmL4C	\N	\N	active	\N	2026-09-09 10:58:45	2026-09-10 09:13:24	\N	\N
10	Jonas Loyola	jonasloyola6@gmail.com	\N	\N	\N	active	2026-09-16 16:01:32.497714	2026-09-16 16:01:32.490643	2026-09-16 16:02:26.542631	1f35520c-9114-4cbb-b369-86d2b431c76e	1f35520c-9114-4cbb-b369-86d2b431c76e/6e2e76a3-a5ec-4717-a35b-052b9968d21c.png
11	dianne joy pimentel	diannejoypimentel@gmail.com	\N	\N	\N	active	2026-09-17 04:06:55.007838	2026-09-17 04:06:54.975802	2026-09-17 04:07:55.256588	423028d7-3027-4ae9-947c-d5428e29b88f	423028d7-3027-4ae9-947c-d5428e29b88f/64d6445c-a409-44c1-a4c6-ef4143b53c96.jpg
12	Subala, Shawn Marion V.	subalashawn2006@gmail.com	\N	Tapat ng Oasis	\N	active	2026-09-17 06:36:51.592102	2026-09-17 06:36:51.565923	2026-09-17 07:05:13.209119	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c	b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c/24d6e64d-d2c3-4bb7-add0-c71252a5aa0d.jpg
\.


--
-- Data for Name: wishlist_destinations; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.wishlist_destinations (wishlist_id, destination_id, added_at) FROM stdin;
1	1	2026-09-07 14:15:07
2	2	2026-09-09 10:31:39
\.


--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: travelmate; Owner: -
--

COPY travelmate.wishlists (id, user_id) FROM stdin;
1	1
2	6
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 64, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: amenities_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.amenities_id_seq', 4, false);


--
-- Name: analytics_reports_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.analytics_reports_id_seq', 2, false);


--
-- Name: attraction_schedules_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.attraction_schedules_id_seq', 3, false);


--
-- Name: auth_sessions_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.auth_sessions_id_seq', 1, false);


--
-- Name: booking_rooms_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.booking_rooms_id_seq', 5, false);


--
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.bookings_id_seq', 8, false);


--
-- Name: business_listings_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.business_listings_id_seq', 10, false);


--
-- Name: business_owners_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.business_owners_id_seq', 9, false);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.categories_id_seq', 9, false);


--
-- Name: cuisines_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.cuisines_id_seq', 2, false);


--
-- Name: data_sources_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.data_sources_id_seq', 7, false);


--
-- Name: destinations_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.destinations_id_seq', 3, false);


--
-- Name: login_attempts_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.login_attempts_id_seq', 1, false);


--
-- Name: menu_items_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.menu_items_id_seq', 3, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.notifications_id_seq', 41, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.payments_id_seq', 2, false);


--
-- Name: photos_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.photos_id_seq', 3, false);


--
-- Name: preferences_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.preferences_id_seq', 3, false);


--
-- Name: recommendations_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.recommendations_id_seq', 2, false);


--
-- Name: refunds_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.refunds_id_seq', 1, false);


--
-- Name: report_metrics_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.report_metrics_id_seq', 12, false);


--
-- Name: report_types_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.report_types_id_seq', 3, false);


--
-- Name: restaurant_slots_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.restaurant_slots_id_seq', 2, false);


--
-- Name: review_comments_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.review_comments_id_seq', 2, false);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.reviews_id_seq', 8, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.roles_id_seq', 7, false);


--
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.rooms_id_seq', 5, false);


--
-- Name: search_history_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.search_history_id_seq', 2, false);


--
-- Name: session_ips_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.session_ips_id_seq', 1, false);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.tags_id_seq', 2, false);


--
-- Name: transport_provider_contacts_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.transport_provider_contacts_id_seq', 1, false);


--
-- Name: transport_providers_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.transport_providers_id_seq', 2, false);


--
-- Name: transportation_services_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.transportation_services_id_seq', 2, false);


--
-- Name: trip_items_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.trip_items_id_seq', 6, false);


--
-- Name: trips_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.trips_id_seq', 5, false);


--
-- Name: user_phones_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.user_phones_id_seq', 3, false);


--
-- Name: user_reports_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.user_reports_id_seq', 3, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.users_id_seq', 12, true);


--
-- Name: wishlists_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: -
--

SELECT pg_catalog.setval('travelmate.wishlists_id_seq', 3, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_mfa_factor_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_mfa_factor_id_key UNIQUE (mfa_factor_id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_pkey PRIMARY KEY (id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_user_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_user_id_key UNIQUE (user_id);


--
-- Name: mfa_recovery_codes mfa_recovery_codes_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_codes
    ADD CONSTRAINT mfa_recovery_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scim_tokens scim_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_tokens
    ADD CONSTRAINT scim_tokens_pkey PRIMARY KEY (id);


--
-- Name: scim_users scim_users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: amenities amenities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (id);


--
-- Name: analytics_reports analytics_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_reports
    ADD CONSTRAINT analytics_reports_pkey PRIMARY KEY (id);


--
-- Name: attraction_schedules attraction_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attraction_schedules
    ADD CONSTRAINT attraction_schedules_pkey PRIMARY KEY (id);


--
-- Name: attractions attractions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attractions
    ADD CONSTRAINT attractions_pkey PRIMARY KEY (attraction_id);


--
-- Name: booking_rooms booking_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_rooms
    ADD CONSTRAINT booking_rooms_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: business_listings business_listings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_listings
    ADD CONSTRAINT business_listings_pkey PRIMARY KEY (id);


--
-- Name: business_owners business_owners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_owners
    ADD CONSTRAINT business_owners_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: cuisines cuisines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cuisines
    ADD CONSTRAINT cuisines_pkey PRIMARY KEY (id);


--
-- Name: data_sources data_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_sources
    ADD CONSTRAINT data_sources_pkey PRIMARY KEY (id);


--
-- Name: destinations destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_pkey PRIMARY KEY (id);


--
-- Name: hotel_amenities hotel_amenities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel_amenities
    ADD CONSTRAINT hotel_amenities_pkey PRIMARY KEY (hotel_id, amenity_id);


--
-- Name: hotel_bookings hotel_bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel_bookings
    ADD CONSTRAINT hotel_bookings_pkey PRIMARY KEY (booking_id);


--
-- Name: hotels hotels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_pkey PRIMARY KEY (hotel_id);


--
-- Name: hotels hotels_times_valid; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.hotels
    ADD CONSTRAINT hotels_times_valid CHECK (((check_in_time IS NOT NULL) AND (check_out_time IS NOT NULL) AND (check_out_time < check_in_time))) NOT VALID;


--
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: photos photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: report_data_sources report_data_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_data_sources
    ADD CONSTRAINT report_data_sources_pkey PRIMARY KEY (report_id, data_source_id);


--
-- Name: report_metrics report_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_metrics
    ADD CONSTRAINT report_metrics_pkey PRIMARY KEY (id);


--
-- Name: report_report_types report_report_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_report_types
    ADD CONSTRAINT report_report_types_pkey PRIMARY KEY (report_id, report_type_id);


--
-- Name: report_types report_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_types
    ADD CONSTRAINT report_types_pkey PRIMARY KEY (id);


--
-- Name: restaurant_bookings restaurant_bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_bookings
    ADD CONSTRAINT restaurant_bookings_pkey PRIMARY KEY (booking_id);


--
-- Name: restaurant_cuisines restaurant_cuisines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_cuisines
    ADD CONSTRAINT restaurant_cuisines_pkey PRIMARY KEY (restaurant_id, cuisine_id);


--
-- Name: restaurant_slots restaurant_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_slots
    ADD CONSTRAINT restaurant_slots_pkey PRIMARY KEY (id);


--
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (restaurant_id);


--
-- Name: review_comments review_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_comments
    ADD CONSTRAINT review_comments_pkey PRIMARY KEY (id);


--
-- Name: review_tags review_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tags
    ADD CONSTRAINT review_tags_pkey PRIMARY KEY (review_id, tag_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_guests_positive; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.rooms
    ADD CONSTRAINT rooms_guests_positive CHECK ((max_guests >= 1)) NOT VALID;


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_rate_positive; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.rooms
    ADD CONSTRAINT rooms_rate_positive CHECK ((base_nightly_rate > (0)::numeric)) NOT VALID;


--
-- Name: search_history search_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_history
    ADD CONSTRAINT search_history_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: transport_provider_contacts transport_provider_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_provider_contacts
    ADD CONSTRAINT transport_provider_contacts_pkey PRIMARY KEY (id);


--
-- Name: transport_providers transport_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_providers
    ADD CONSTRAINT transport_providers_pkey PRIMARY KEY (id);


--
-- Name: transportation_services transportation_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transportation_services
    ADD CONSTRAINT transportation_services_pkey PRIMARY KEY (id);


--
-- Name: trip_items trip_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_items
    ADD CONSTRAINT trip_items_pkey PRIMARY KEY (id);


--
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (id);


--
-- Name: amenities uq_amenities_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT uq_amenities_1 UNIQUE (name);


--
-- Name: attraction_schedules uq_attraction_schedules_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attraction_schedules
    ADD CONSTRAINT uq_attraction_schedules_1 UNIQUE (attraction_id, operating_day);


--
-- Name: booking_rooms uq_booking_rooms_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_rooms
    ADD CONSTRAINT uq_booking_rooms_1 UNIQUE (booking_id, room_id);


--
-- Name: bookings uq_bookings_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT uq_bookings_1 UNIQUE (idempotency_key);


--
-- Name: business_listings uq_business_listings_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_listings
    ADD CONSTRAINT uq_business_listings_1 UNIQUE (slug);


--
-- Name: business_owners uq_business_owners_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_owners
    ADD CONSTRAINT uq_business_owners_1 UNIQUE (profile_id);


--
-- Name: categories uq_categories_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT uq_categories_1 UNIQUE (name);


--
-- Name: cuisines uq_cuisines_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cuisines
    ADD CONSTRAINT uq_cuisines_1 UNIQUE (name);


--
-- Name: data_sources uq_data_sources_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_sources
    ADD CONSTRAINT uq_data_sources_1 UNIQUE (name);


--
-- Name: destinations uq_destinations_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT uq_destinations_1 UNIQUE (slug);


--
-- Name: destinations uq_destinations_2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT uq_destinations_2 UNIQUE (name, province);


--
-- Name: payments uq_payments_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT uq_payments_1 UNIQUE (idempotency_key);


--
-- Name: payments uq_payments_2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT uq_payments_2 UNIQUE (provider, provider_reference);


--
-- Name: preferences uq_preferences_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT uq_preferences_1 UNIQUE (category, name);


--
-- Name: refunds uq_refunds_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT uq_refunds_1 UNIQUE (idempotency_key);


--
-- Name: refunds uq_refunds_2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT uq_refunds_2 UNIQUE (payment_id, provider_reference);


--
-- Name: report_metrics uq_report_metrics_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_metrics
    ADD CONSTRAINT uq_report_metrics_1 UNIQUE (report_id, name);


--
-- Name: report_types uq_report_types_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_types
    ADD CONSTRAINT uq_report_types_1 UNIQUE (name);


--
-- Name: restaurant_slots uq_restaurant_slots_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_slots
    ADD CONSTRAINT uq_restaurant_slots_1 UNIQUE (restaurant_id, starts_at);


--
-- Name: reviews uq_reviews_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT uq_reviews_1 UNIQUE (profile_id, destination_id);


--
-- Name: reviews uq_reviews_2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT uq_reviews_2 UNIQUE (profile_id, listing_id);


--
-- Name: roles uq_roles_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT uq_roles_1 UNIQUE (name);


--
-- Name: rooms uq_rooms_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT uq_rooms_1 UNIQUE (hotel_id, room_number);


--
-- Name: tags uq_tags_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT uq_tags_1 UNIQUE (name);


--
-- Name: transport_provider_contacts uq_transport_provider_contacts_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_provider_contacts
    ADD CONSTRAINT uq_transport_provider_contacts_1 UNIQUE (provider_id, phone_number);


--
-- Name: trip_items uq_trip_items_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_items
    ADD CONSTRAINT uq_trip_items_1 UNIQUE (trip_id, sequence_number);


--
-- Name: profile_phones uq_user_phones_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_phones
    ADD CONSTRAINT uq_user_phones_1 UNIQUE (profile_id, phone_number);


--
-- Name: profile_phones user_phones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_phones
    ADD CONSTRAINT user_phones_pkey PRIMARY KEY (id);


--
-- Name: profile_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (profile_id, preference_id);


--
-- Name: user_reports user_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT user_reports_pkey PRIMARY KEY (id);


--
-- Name: profile_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (profile_id, role_id);


--
-- Name: profiles users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: saved_destinations wishlist_destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_destinations
    ADD CONSTRAINT wishlist_destinations_pkey PRIMARY KEY (profile_id, destination_id);


--
-- Name: messages messages_payload_exclusive; Type: CHECK CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages
    ADD CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL))) NOT VALID;


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: amenities amenities_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (id);


--
-- Name: analytics_reports analytics_reports_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.analytics_reports
    ADD CONSTRAINT analytics_reports_pkey PRIMARY KEY (id);


--
-- Name: attraction_schedules attraction_schedules_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.attraction_schedules
    ADD CONSTRAINT attraction_schedules_pkey PRIMARY KEY (id);


--
-- Name: attractions attractions_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.attractions
    ADD CONSTRAINT attractions_pkey PRIMARY KEY (listing_id);


--
-- Name: auth_sessions auth_sessions_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.auth_sessions
    ADD CONSTRAINT auth_sessions_pkey PRIMARY KEY (id);


--
-- Name: booking_rooms booking_rooms_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.booking_rooms
    ADD CONSTRAINT booking_rooms_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: business_listings business_listings_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.business_listings
    ADD CONSTRAINT business_listings_pkey PRIMARY KEY (id);


--
-- Name: business_owners business_owners_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.business_owners
    ADD CONSTRAINT business_owners_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: cuisines cuisines_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.cuisines
    ADD CONSTRAINT cuisines_pkey PRIMARY KEY (id);


--
-- Name: data_sources data_sources_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.data_sources
    ADD CONSTRAINT data_sources_pkey PRIMARY KEY (id);


--
-- Name: destinations destinations_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.destinations
    ADD CONSTRAINT destinations_pkey PRIMARY KEY (id);


--
-- Name: hotel_amenities hotel_amenities_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.hotel_amenities
    ADD CONSTRAINT hotel_amenities_pkey PRIMARY KEY (hotel_id, amenity_id);


--
-- Name: hotel_bookings hotel_bookings_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.hotel_bookings
    ADD CONSTRAINT hotel_bookings_pkey PRIMARY KEY (booking_id);


--
-- Name: hotels hotels_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.hotels
    ADD CONSTRAINT hotels_pkey PRIMARY KEY (listing_id);


--
-- Name: login_attempts login_attempts_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.login_attempts
    ADD CONSTRAINT login_attempts_pkey PRIMARY KEY (id);


--
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: photos photos_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: report_data_sources report_data_sources_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.report_data_sources
    ADD CONSTRAINT report_data_sources_pkey PRIMARY KEY (report_id, data_source_id);


--
-- Name: report_metrics report_metrics_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.report_metrics
    ADD CONSTRAINT report_metrics_pkey PRIMARY KEY (id);


--
-- Name: report_report_types report_report_types_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.report_report_types
    ADD CONSTRAINT report_report_types_pkey PRIMARY KEY (report_id, report_type_id);


--
-- Name: report_types report_types_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.report_types
    ADD CONSTRAINT report_types_pkey PRIMARY KEY (id);


--
-- Name: restaurant_bookings restaurant_bookings_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.restaurant_bookings
    ADD CONSTRAINT restaurant_bookings_pkey PRIMARY KEY (booking_id);


--
-- Name: restaurant_cuisines restaurant_cuisines_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.restaurant_cuisines
    ADD CONSTRAINT restaurant_cuisines_pkey PRIMARY KEY (restaurant_id, cuisine_id);


--
-- Name: restaurant_slots restaurant_slots_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.restaurant_slots
    ADD CONSTRAINT restaurant_slots_pkey PRIMARY KEY (id);


--
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (listing_id);


--
-- Name: review_comments review_comments_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.review_comments
    ADD CONSTRAINT review_comments_pkey PRIMARY KEY (id);


--
-- Name: review_tags review_tags_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.review_tags
    ADD CONSTRAINT review_tags_pkey PRIMARY KEY (review_id, tag_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: search_history search_history_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.search_history
    ADD CONSTRAINT search_history_pkey PRIMARY KEY (id);


--
-- Name: session_ips session_ips_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.session_ips
    ADD CONSTRAINT session_ips_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: transport_provider_contacts transport_provider_contacts_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.transport_provider_contacts
    ADD CONSTRAINT transport_provider_contacts_pkey PRIMARY KEY (id);


--
-- Name: transport_providers transport_providers_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.transport_providers
    ADD CONSTRAINT transport_providers_pkey PRIMARY KEY (id);


--
-- Name: transportation_services transportation_services_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.transportation_services
    ADD CONSTRAINT transportation_services_pkey PRIMARY KEY (id);


--
-- Name: trip_items trip_items_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.trip_items
    ADD CONSTRAINT trip_items_pkey PRIMARY KEY (id);


--
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (id);


--
-- Name: amenities uq_amenities_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.amenities
    ADD CONSTRAINT uq_amenities_1 UNIQUE (name);


--
-- Name: attraction_schedules uq_attraction_schedules_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.attraction_schedules
    ADD CONSTRAINT uq_attraction_schedules_1 UNIQUE (attraction_id, operating_day);


--
-- Name: auth_sessions uq_auth_sessions_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.auth_sessions
    ADD CONSTRAINT uq_auth_sessions_1 UNIQUE (token_hash);


--
-- Name: booking_rooms uq_booking_rooms_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.booking_rooms
    ADD CONSTRAINT uq_booking_rooms_1 UNIQUE (booking_id, room_id);


--
-- Name: bookings uq_bookings_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.bookings
    ADD CONSTRAINT uq_bookings_1 UNIQUE (idempotency_key);


--
-- Name: business_listings uq_business_listings_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.business_listings
    ADD CONSTRAINT uq_business_listings_1 UNIQUE (slug);


--
-- Name: business_owners uq_business_owners_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.business_owners
    ADD CONSTRAINT uq_business_owners_1 UNIQUE (user_id);


--
-- Name: categories uq_categories_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.categories
    ADD CONSTRAINT uq_categories_1 UNIQUE (name);


--
-- Name: cuisines uq_cuisines_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.cuisines
    ADD CONSTRAINT uq_cuisines_1 UNIQUE (name);


--
-- Name: data_sources uq_data_sources_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.data_sources
    ADD CONSTRAINT uq_data_sources_1 UNIQUE (name);


--
-- Name: destinations uq_destinations_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.destinations
    ADD CONSTRAINT uq_destinations_1 UNIQUE (slug);


--
-- Name: destinations uq_destinations_2; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.destinations
    ADD CONSTRAINT uq_destinations_2 UNIQUE (name, province);


--
-- Name: payments uq_payments_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.payments
    ADD CONSTRAINT uq_payments_1 UNIQUE (idempotency_key);


--
-- Name: payments uq_payments_2; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.payments
    ADD CONSTRAINT uq_payments_2 UNIQUE (provider, provider_reference);


--
-- Name: preferences uq_preferences_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.preferences
    ADD CONSTRAINT uq_preferences_1 UNIQUE (category, name);


--
-- Name: refunds uq_refunds_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.refunds
    ADD CONSTRAINT uq_refunds_1 UNIQUE (idempotency_key);


--
-- Name: refunds uq_refunds_2; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.refunds
    ADD CONSTRAINT uq_refunds_2 UNIQUE (payment_id, provider_reference);


--
-- Name: report_metrics uq_report_metrics_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.report_metrics
    ADD CONSTRAINT uq_report_metrics_1 UNIQUE (report_id, name);


--
-- Name: report_types uq_report_types_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.report_types
    ADD CONSTRAINT uq_report_types_1 UNIQUE (name);


--
-- Name: restaurant_slots uq_restaurant_slots_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.restaurant_slots
    ADD CONSTRAINT uq_restaurant_slots_1 UNIQUE (restaurant_id, starts_at);


--
-- Name: reviews uq_reviews_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.reviews
    ADD CONSTRAINT uq_reviews_1 UNIQUE (user_id, destination_id);


--
-- Name: reviews uq_reviews_2; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.reviews
    ADD CONSTRAINT uq_reviews_2 UNIQUE (user_id, listing_id);


--
-- Name: roles uq_roles_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.roles
    ADD CONSTRAINT uq_roles_1 UNIQUE (name);


--
-- Name: rooms uq_rooms_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.rooms
    ADD CONSTRAINT uq_rooms_1 UNIQUE (hotel_id, room_number);


--
-- Name: session_ips uq_session_ips_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.session_ips
    ADD CONSTRAINT uq_session_ips_1 UNIQUE (session_id, ip_address);


--
-- Name: tags uq_tags_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.tags
    ADD CONSTRAINT uq_tags_1 UNIQUE (name);


--
-- Name: transport_provider_contacts uq_transport_provider_contacts_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.transport_provider_contacts
    ADD CONSTRAINT uq_transport_provider_contacts_1 UNIQUE (provider_id, phone_number);


--
-- Name: trip_items uq_trip_items_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.trip_items
    ADD CONSTRAINT uq_trip_items_1 UNIQUE (trip_id, sequence_number);


--
-- Name: user_phones uq_user_phones_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.user_phones
    ADD CONSTRAINT uq_user_phones_1 UNIQUE (user_id, phone_number);


--
-- Name: users uq_users_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.users
    ADD CONSTRAINT uq_users_1 UNIQUE (email);


--
-- Name: users uq_users_auth_user_id; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.users
    ADD CONSTRAINT uq_users_auth_user_id UNIQUE (auth_user_id);


--
-- Name: wishlists uq_wishlists_1; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.wishlists
    ADD CONSTRAINT uq_wishlists_1 UNIQUE (user_id);


--
-- Name: user_phones user_phones_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.user_phones
    ADD CONSTRAINT user_phones_pkey PRIMARY KEY (id);


--
-- Name: user_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (user_id, preference_id);


--
-- Name: user_reports user_reports_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.user_reports
    ADD CONSTRAINT user_reports_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wishlist_destinations wishlist_destinations_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.wishlist_destinations
    ADD CONSTRAINT wishlist_destinations_pkey PRIMARY KEY (wishlist_id, destination_id);


--
-- Name: wishlists wishlists_pkey; Type: CONSTRAINT; Schema: travelmate; Owner: -
--

ALTER TABLE ONLY travelmate.wishlists
    ADD CONSTRAINT wishlists_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: idx_users_created_at_desc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_created_at_desc ON auth.users USING btree (created_at DESC);


--
-- Name: idx_users_email; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_email ON auth.users USING btree (email);


--
-- Name: idx_users_last_sign_in_at_desc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_last_sign_in_at_desc ON auth.users USING btree (last_sign_in_at DESC);


--
-- Name: idx_users_name; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_name ON auth.users USING btree (((raw_user_meta_data ->> 'name'::text))) WHERE ((raw_user_meta_data ->> 'name'::text) IS NOT NULL);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: mfa_recovery_codes_set_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_recovery_codes_set_id_idx ON auth.mfa_recovery_codes USING btree (mfa_recovery_code_set_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: scim_tokens_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_expires_at_idx ON auth.scim_tokens USING btree (expires_at);


--
-- Name: scim_tokens_revoked_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_revoked_at_idx ON auth.scim_tokens USING btree (revoked_at);


--
-- Name: scim_tokens_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_sso_provider_id_idx ON auth.scim_tokens USING btree (sso_provider_id);


--
-- Name: scim_tokens_token_hash_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_tokens_token_hash_key ON auth.scim_tokens USING btree (token_hash);


--
-- Name: scim_users_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_created_at_idx ON auth.scim_users USING btree (sso_provider_id, created_at, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_deleted_at_idx ON auth.scim_users USING btree (deleted_at);


--
-- Name: scim_users_external_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_users_external_id_key ON auth.scim_users USING btree (sso_provider_id, external_id) WHERE ((external_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: scim_users_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_id_idx ON auth.scim_users USING btree (sso_provider_id, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_sso_provider_id_idx ON auth.scim_users USING btree (sso_provider_id);


--
-- Name: scim_users_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_updated_at_idx ON auth.scim_users USING btree (sso_provider_id, updated_at, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_user_id_idx ON auth.scim_users USING btree (user_id);


--
-- Name: scim_users_user_name_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_user_name_idx ON auth.scim_users USING btree (sso_provider_id, user_name COLLATE "C", id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_user_name_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_users_user_name_key ON auth.scim_users USING btree (sso_provider_id, user_name) WHERE (deleted_at IS NULL);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: photos_one_per_dish; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX photos_one_per_dish ON public.photos USING btree (menu_item_id) WHERE (menu_item_id IS NOT NULL);


--
-- Name: rooms_hotel_room_number_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rooms_hotel_room_number_uidx ON public.rooms USING btree (hotel_id, room_number);


--
-- Name: tm_fk_idx_01; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_01 ON public.analytics_reports USING btree (generated_by);


--
-- Name: tm_fk_idx_02; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_02 ON public.attractions USING btree (attraction_id);


--
-- Name: tm_fk_idx_03; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_03 ON public.attraction_schedules USING btree (attraction_id);


--
-- Name: tm_fk_idx_04; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_04 ON public.bookings USING btree (profile_id);


--
-- Name: tm_fk_idx_05; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_05 ON public.booking_rooms USING btree (booking_id);


--
-- Name: tm_fk_idx_06; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_06 ON public.booking_rooms USING btree (room_id);


--
-- Name: tm_fk_idx_07; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_07 ON public.business_listings USING btree (owner_id);


--
-- Name: tm_fk_idx_08; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_08 ON public.business_listings USING btree (destination_id);


--
-- Name: tm_fk_idx_09; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_09 ON public.business_owners USING btree (profile_id);


--
-- Name: tm_fk_idx_10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_10 ON public.destinations USING btree (category_id);


--
-- Name: tm_fk_idx_11; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_11 ON public.hotels USING btree (hotel_id);


--
-- Name: tm_fk_idx_12; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_12 ON public.hotel_amenities USING btree (hotel_id);


--
-- Name: tm_fk_idx_13; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_13 ON public.hotel_amenities USING btree (amenity_id);


--
-- Name: tm_fk_idx_14; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_14 ON public.hotel_bookings USING btree (booking_id);


--
-- Name: tm_fk_idx_15; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_15 ON public.hotel_bookings USING btree (hotel_id);


--
-- Name: tm_fk_idx_16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_16 ON public.menu_items USING btree (restaurant_id);


--
-- Name: tm_fk_idx_17; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_17 ON public.notifications USING btree (profile_id);


--
-- Name: tm_fk_idx_18; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_18 ON public.payments USING btree (booking_id);


--
-- Name: tm_fk_idx_19; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_19 ON public.photos USING btree (destination_id);


--
-- Name: tm_fk_idx_20; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_20 ON public.photos USING btree (listing_id);


--
-- Name: tm_fk_idx_21; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_21 ON public.recommendations USING btree (profile_id);


--
-- Name: tm_fk_idx_22; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_22 ON public.recommendations USING btree (destination_id);


--
-- Name: tm_fk_idx_23; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_23 ON public.refunds USING btree (payment_id);


--
-- Name: tm_fk_idx_24; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_24 ON public.report_data_sources USING btree (report_id);


--
-- Name: tm_fk_idx_25; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_25 ON public.report_data_sources USING btree (data_source_id);


--
-- Name: tm_fk_idx_26; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_26 ON public.report_metrics USING btree (report_id);


--
-- Name: tm_fk_idx_27; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_27 ON public.report_report_types USING btree (report_id);


--
-- Name: tm_fk_idx_28; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_28 ON public.report_report_types USING btree (report_type_id);


--
-- Name: tm_fk_idx_29; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_29 ON public.restaurants USING btree (restaurant_id);


--
-- Name: tm_fk_idx_30; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_30 ON public.restaurant_bookings USING btree (booking_id);


--
-- Name: tm_fk_idx_31; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_31 ON public.restaurant_bookings USING btree (slot_id);


--
-- Name: tm_fk_idx_32; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_32 ON public.restaurant_cuisines USING btree (restaurant_id);


--
-- Name: tm_fk_idx_33; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_33 ON public.restaurant_cuisines USING btree (cuisine_id);


--
-- Name: tm_fk_idx_34; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_34 ON public.restaurant_slots USING btree (restaurant_id);


--
-- Name: tm_fk_idx_35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_35 ON public.reviews USING btree (profile_id);


--
-- Name: tm_fk_idx_36; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_36 ON public.reviews USING btree (destination_id);


--
-- Name: tm_fk_idx_37; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_37 ON public.reviews USING btree (listing_id);


--
-- Name: tm_fk_idx_38; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_38 ON public.review_comments USING btree (review_id);


--
-- Name: tm_fk_idx_39; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_39 ON public.review_comments USING btree (profile_id);


--
-- Name: tm_fk_idx_40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_40 ON public.review_tags USING btree (review_id);


--
-- Name: tm_fk_idx_41; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_41 ON public.review_tags USING btree (tag_id);


--
-- Name: tm_fk_idx_42; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_42 ON public.rooms USING btree (hotel_id);


--
-- Name: tm_fk_idx_43; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_43 ON public.search_history USING btree (profile_id);


--
-- Name: tm_fk_idx_44; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_44 ON public.search_history USING btree (trip_id);


--
-- Name: tm_fk_idx_45; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_45 ON public.transportation_services USING btree (provider_id);


--
-- Name: tm_fk_idx_46; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_46 ON public.transportation_services USING btree (destination_id);


--
-- Name: tm_fk_idx_47; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_47 ON public.transport_providers USING btree (owner_id);


--
-- Name: tm_fk_idx_48; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_48 ON public.transport_provider_contacts USING btree (provider_id);


--
-- Name: tm_fk_idx_49; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_49 ON public.trips USING btree (profile_id);


--
-- Name: tm_fk_idx_50; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_50 ON public.trip_items USING btree (trip_id);


--
-- Name: tm_fk_idx_51; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_51 ON public.trip_items USING btree (destination_id);


--
-- Name: tm_fk_idx_52; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_52 ON public.trip_items USING btree (listing_id);


--
-- Name: tm_fk_idx_53; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_53 ON public.profile_phones USING btree (profile_id);


--
-- Name: tm_fk_idx_54; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_54 ON public.profile_preferences USING btree (profile_id);


--
-- Name: tm_fk_idx_55; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_55 ON public.profile_preferences USING btree (preference_id);


--
-- Name: tm_fk_idx_56; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_56 ON public.user_reports USING btree (profile_id);


--
-- Name: tm_fk_idx_57; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_57 ON public.user_reports USING btree (listing_id);


--
-- Name: tm_fk_idx_58; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_58 ON public.user_reports USING btree (destination_id);


--
-- Name: tm_fk_idx_59; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_59 ON public.user_reports USING btree (review_id);


--
-- Name: tm_fk_idx_60; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_60 ON public.user_reports USING btree (photo_id);


--
-- Name: tm_fk_idx_61; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_61 ON public.user_reports USING btree (transport_id);


--
-- Name: tm_fk_idx_62; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_62 ON public.user_reports USING btree (assigned_to);


--
-- Name: tm_fk_idx_63; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_63 ON public.profile_roles USING btree (profile_id);


--
-- Name: tm_fk_idx_64; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_64 ON public.profile_roles USING btree (role_id);


--
-- Name: tm_fk_idx_65; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_65 ON public.saved_destinations USING btree (profile_id);


--
-- Name: tm_fk_idx_66; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tm_fk_idx_66 ON public.saved_destinations USING btree (destination_id);


--
-- Name: tm_listing_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tm_listing_name_unique ON public.business_listings USING btree (destination_id, listing_type, lower(btrim((name)::text)));


--
-- Name: tm_menu_item_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tm_menu_item_name_unique ON public.menu_items USING btree (restaurant_id, lower(btrim((name)::text)));


--
-- Name: tm_photo_object; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tm_photo_object ON public.photos USING btree (bucket_id, object_path);


--
-- Name: tm_schedule_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tm_schedule_unique ON public.attraction_schedules USING btree (attraction_id, lower(btrim((operating_day)::text)), lower(btrim((schedule_text)::text)));


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_selec; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_selec ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter, COALESCE(selected_columns, '{}'::text[]));


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: idx_objects_current_version; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_objects_current_version ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE (archived_at IS NULL);


--
-- Name: idx_objects_delete_markers; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_delete_markers ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE is_delete_marker;


--
-- Name: idx_objects_null_version; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_objects_null_version ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE (NOT is_versioned);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_name_version_key; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX objects_bucket_id_name_version_key ON storage.objects USING btree (bucket_id, name COLLATE "C", version) NULLS NOT DISTINCT;


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: ix_analytics_reports_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_analytics_reports_1 ON travelmate.analytics_reports USING btree (generated_by);


--
-- Name: ix_auth_sessions_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_auth_sessions_1 ON travelmate.auth_sessions USING btree (user_id, status);


--
-- Name: ix_auth_sessions_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_auth_sessions_2 ON travelmate.auth_sessions USING btree (expires_at);


--
-- Name: ix_booking_rooms_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_booking_rooms_1 ON travelmate.booking_rooms USING btree (room_id, booking_id);


--
-- Name: ix_bookings_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_bookings_1 ON travelmate.bookings USING btree (user_id, created_at);


--
-- Name: ix_bookings_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_bookings_2 ON travelmate.bookings USING btree (status, hold_expires_at);


--
-- Name: ix_business_listings_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_business_listings_1 ON travelmate.business_listings USING btree (destination_id, listing_type, status);


--
-- Name: ix_business_listings_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_business_listings_2 ON travelmate.business_listings USING btree (owner_id, status);


--
-- Name: ix_business_listings_3; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_business_listings_3 ON travelmate.business_listings USING btree (name);


--
-- Name: ix_destinations_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_destinations_1 ON travelmate.destinations USING btree (category_id, is_active);


--
-- Name: ix_destinations_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_destinations_2 ON travelmate.destinations USING btree (province, name);


--
-- Name: ix_hotel_amenities_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_hotel_amenities_1 ON travelmate.hotel_amenities USING btree (amenity_id);


--
-- Name: ix_hotel_bookings_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_hotel_bookings_1 ON travelmate.hotel_bookings USING btree (hotel_id, check_in, check_out);


--
-- Name: ix_login_attempts_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_login_attempts_1 ON travelmate.login_attempts USING btree (attempted_email, attempted_at);


--
-- Name: ix_login_attempts_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_login_attempts_2 ON travelmate.login_attempts USING btree (ip_address, attempted_at);


--
-- Name: ix_login_attempts_3; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_login_attempts_3 ON travelmate.login_attempts USING btree (user_id);


--
-- Name: ix_menu_items_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_menu_items_1 ON travelmate.menu_items USING btree (restaurant_id);


--
-- Name: ix_notifications_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_notifications_1 ON travelmate.notifications USING btree (user_id, read_at, created_at);


--
-- Name: ix_payments_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_payments_1 ON travelmate.payments USING btree (booking_id, status);


--
-- Name: ix_photos_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_photos_1 ON travelmate.photos USING btree (destination_id, status, sort_order);


--
-- Name: ix_photos_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_photos_2 ON travelmate.photos USING btree (listing_id, status, sort_order);


--
-- Name: ix_recommendations_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_recommendations_1 ON travelmate.recommendations USING btree (user_id, recommended_at);


--
-- Name: ix_recommendations_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_recommendations_2 ON travelmate.recommendations USING btree (destination_id);


--
-- Name: ix_report_data_sources_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_report_data_sources_1 ON travelmate.report_data_sources USING btree (data_source_id);


--
-- Name: ix_report_report_types_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_report_report_types_1 ON travelmate.report_report_types USING btree (report_type_id);


--
-- Name: ix_restaurant_bookings_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_restaurant_bookings_1 ON travelmate.restaurant_bookings USING btree (slot_id, booking_id);


--
-- Name: ix_restaurant_cuisines_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_restaurant_cuisines_1 ON travelmate.restaurant_cuisines USING btree (cuisine_id);


--
-- Name: ix_restaurant_slots_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_restaurant_slots_1 ON travelmate.restaurant_slots USING btree (restaurant_id, starts_at, is_open);


--
-- Name: ix_review_comments_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_review_comments_1 ON travelmate.review_comments USING btree (review_id, created_at);


--
-- Name: ix_review_comments_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_review_comments_2 ON travelmate.review_comments USING btree (user_id);


--
-- Name: ix_review_tags_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_review_tags_1 ON travelmate.review_tags USING btree (tag_id);


--
-- Name: ix_reviews_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_reviews_1 ON travelmate.reviews USING btree (destination_id, status);


--
-- Name: ix_reviews_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_reviews_2 ON travelmate.reviews USING btree (listing_id, status);


--
-- Name: ix_rooms_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_rooms_1 ON travelmate.rooms USING btree (hotel_id, operational_status);


--
-- Name: ix_search_history_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_search_history_1 ON travelmate.search_history USING btree (user_id, searched_at);


--
-- Name: ix_search_history_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_search_history_2 ON travelmate.search_history USING btree (trip_id);


--
-- Name: ix_transport_providers_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_transport_providers_1 ON travelmate.transport_providers USING btree (owner_id);


--
-- Name: ix_transport_providers_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_transport_providers_2 ON travelmate.transport_providers USING btree (company_name);


--
-- Name: ix_transportation_services_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_transportation_services_1 ON travelmate.transportation_services USING btree (destination_id, status, transport_type);


--
-- Name: ix_transportation_services_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_transportation_services_2 ON travelmate.transportation_services USING btree (provider_id);


--
-- Name: ix_trip_items_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_trip_items_1 ON travelmate.trip_items USING btree (destination_id);


--
-- Name: ix_trip_items_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_trip_items_2 ON travelmate.trip_items USING btree (listing_id);


--
-- Name: ix_trips_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_trips_1 ON travelmate.trips USING btree (user_id, status);


--
-- Name: ix_user_preferences_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_preferences_1 ON travelmate.user_preferences USING btree (preference_id);


--
-- Name: ix_user_reports_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_reports_1 ON travelmate.user_reports USING btree (status, submitted_at);


--
-- Name: ix_user_reports_2; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_reports_2 ON travelmate.user_reports USING btree (user_id);


--
-- Name: ix_user_reports_3; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_reports_3 ON travelmate.user_reports USING btree (assigned_to);


--
-- Name: ix_user_reports_4; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_reports_4 ON travelmate.user_reports USING btree (listing_id);


--
-- Name: ix_user_reports_5; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_reports_5 ON travelmate.user_reports USING btree (destination_id);


--
-- Name: ix_user_reports_6; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_reports_6 ON travelmate.user_reports USING btree (review_id);


--
-- Name: ix_user_reports_7; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_reports_7 ON travelmate.user_reports USING btree (photo_id);


--
-- Name: ix_user_reports_8; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_reports_8 ON travelmate.user_reports USING btree (transport_id);


--
-- Name: ix_user_roles_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_user_roles_1 ON travelmate.user_roles USING btree (role_id);


--
-- Name: ix_wishlist_destinations_1; Type: INDEX; Schema: travelmate; Owner: -
--

CREATE INDEX ix_wishlist_destinations_1 ON travelmate.wishlist_destinations USING btree (destination_id);


--
-- Name: users travelmate_auth_profile_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER travelmate_auth_profile_created AFTER INSERT OR UPDATE OF email_confirmed_at ON auth.users FOR EACH ROW EXECUTE FUNCTION public.tm_on_auth_profile_event();


--
-- Name: business_listings tm_approve_listing_photos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_approve_listing_photos AFTER UPDATE OF status ON public.business_listings FOR EACH ROW EXECUTE FUNCTION public.tm_approve_listing_photos();


--
-- Name: business_listings tm_listing_resubmitted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_listing_resubmitted AFTER UPDATE OF status ON public.business_listings FOR EACH ROW WHEN ((((new.status)::text = 'pending'::text) AND ((old.status)::text IS DISTINCT FROM 'pending'::text))) EXECUTE FUNCTION public.tm_notify_admins_listing_pending();


--
-- Name: business_listings tm_listing_status_notification; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_listing_status_notification AFTER UPDATE OF status ON public.business_listings FOR EACH ROW EXECUTE FUNCTION public.tm_notify_listing_status();


--
-- Name: business_listings tm_listing_submitted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_listing_submitted AFTER INSERT ON public.business_listings FOR EACH ROW WHEN (((new.status)::text = 'pending'::text)) EXECUTE FUNCTION public.tm_notify_admins_listing_pending();


--
-- Name: bookings tm_touch_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_touch_updated_at BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.tm_touch_updated_at();


--
-- Name: business_listings tm_touch_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_touch_updated_at BEFORE UPDATE ON public.business_listings FOR EACH ROW EXECUTE FUNCTION public.tm_touch_updated_at();


--
-- Name: destinations tm_touch_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_touch_updated_at BEFORE UPDATE ON public.destinations FOR EACH ROW EXECUTE FUNCTION public.tm_touch_updated_at();


--
-- Name: profiles tm_touch_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_touch_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.tm_touch_updated_at();


--
-- Name: reviews tm_touch_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_touch_updated_at BEFORE UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.tm_touch_updated_at();


--
-- Name: trips tm_touch_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tm_touch_updated_at BEFORE UPDATE ON public.trips FOR EACH ROW EXECUTE FUNCTION public.tm_touch_updated_at();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_bucket_control_insert; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_insert BEFORE INSERT ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_bucket_control_columns('service_role');


--
-- Name: buckets protect_bucket_control_update; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_update BEFORE UPDATE OF lifecycle_configuration, lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_bucket_control_columns();


--
-- Name: buckets protect_bucket_control_update_role; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_update_role AFTER UPDATE OF lifecycle_configuration, lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_lifecycle_service_role('service_role');


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: business_listings trg_listing_status_notification; Type: TRIGGER; Schema: travelmate; Owner: -
--

CREATE TRIGGER trg_listing_status_notification AFTER UPDATE ON travelmate.business_listings FOR EACH ROW EXECUTE FUNCTION travelmate.notify_listing_status();


--
-- Name: bookings trg_touch_updated_at; Type: TRIGGER; Schema: travelmate; Owner: -
--

CREATE TRIGGER trg_touch_updated_at BEFORE UPDATE ON travelmate.bookings FOR EACH ROW EXECUTE FUNCTION travelmate.touch_updated_at();


--
-- Name: business_listings trg_touch_updated_at; Type: TRIGGER; Schema: travelmate; Owner: -
--

CREATE TRIGGER trg_touch_updated_at BEFORE UPDATE ON travelmate.business_listings FOR EACH ROW EXECUTE FUNCTION travelmate.touch_updated_at();


--
-- Name: destinations trg_touch_updated_at; Type: TRIGGER; Schema: travelmate; Owner: -
--

CREATE TRIGGER trg_touch_updated_at BEFORE UPDATE ON travelmate.destinations FOR EACH ROW EXECUTE FUNCTION travelmate.touch_updated_at();


--
-- Name: reviews trg_touch_updated_at; Type: TRIGGER; Schema: travelmate; Owner: -
--

CREATE TRIGGER trg_touch_updated_at BEFORE UPDATE ON travelmate.reviews FOR EACH ROW EXECUTE FUNCTION travelmate.touch_updated_at();


--
-- Name: trips trg_touch_updated_at; Type: TRIGGER; Schema: travelmate; Owner: -
--

CREATE TRIGGER trg_touch_updated_at BEFORE UPDATE ON travelmate.trips FOR EACH ROW EXECUTE FUNCTION travelmate.touch_updated_at();


--
-- Name: users trg_touch_updated_at; Type: TRIGGER; Schema: travelmate; Owner: -
--

CREATE TRIGGER trg_touch_updated_at BEFORE UPDATE ON travelmate.users FOR EACH ROW EXECUTE FUNCTION travelmate.touch_updated_at();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_mfa_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_mfa_factor_id_fkey FOREIGN KEY (mfa_factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_codes mfa_recovery_codes_mfa_recovery_code_set_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_codes
    ADD CONSTRAINT mfa_recovery_codes_mfa_recovery_code_set_id_fkey FOREIGN KEY (mfa_recovery_code_set_id) REFERENCES auth.mfa_recovery_code_sets(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_tokens scim_tokens_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_tokens
    ADD CONSTRAINT scim_tokens_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_users scim_users_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_users scim_users_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: analytics_reports analytics_reports_generated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_reports
    ADD CONSTRAINT analytics_reports_generated_by_fkey FOREIGN KEY (generated_by) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: business_listings business_listings_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_listings
    ADD CONSTRAINT business_listings_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.profiles(id);


--
-- Name: photos photos_menu_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_menu_item_id_fkey FOREIGN KEY (menu_item_id) REFERENCES public.menu_items(id) ON DELETE CASCADE;


--
-- Name: attractions tm_fk_02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attractions
    ADD CONSTRAINT tm_fk_02 FOREIGN KEY (attraction_id) REFERENCES public.business_listings(id) ON DELETE RESTRICT;


--
-- Name: attraction_schedules tm_fk_03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attraction_schedules
    ADD CONSTRAINT tm_fk_03 FOREIGN KEY (attraction_id) REFERENCES public.attractions(attraction_id) ON DELETE RESTRICT;


--
-- Name: bookings tm_fk_04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT tm_fk_04 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: booking_rooms tm_fk_05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_rooms
    ADD CONSTRAINT tm_fk_05 FOREIGN KEY (booking_id) REFERENCES public.hotel_bookings(booking_id) ON DELETE RESTRICT;


--
-- Name: booking_rooms tm_fk_06; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_rooms
    ADD CONSTRAINT tm_fk_06 FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE RESTRICT;


--
-- Name: business_listings tm_fk_07; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_listings
    ADD CONSTRAINT tm_fk_07 FOREIGN KEY (owner_id) REFERENCES public.business_owners(id) ON DELETE RESTRICT;


--
-- Name: business_listings tm_fk_08; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_listings
    ADD CONSTRAINT tm_fk_08 FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: business_owners tm_fk_09; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_owners
    ADD CONSTRAINT tm_fk_09 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: destinations tm_fk_10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT tm_fk_10 FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE RESTRICT;


--
-- Name: hotels tm_fk_11; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT tm_fk_11 FOREIGN KEY (hotel_id) REFERENCES public.business_listings(id) ON DELETE RESTRICT;


--
-- Name: hotel_amenities tm_fk_12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel_amenities
    ADD CONSTRAINT tm_fk_12 FOREIGN KEY (hotel_id) REFERENCES public.hotels(hotel_id) ON DELETE RESTRICT;


--
-- Name: hotel_amenities tm_fk_13; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel_amenities
    ADD CONSTRAINT tm_fk_13 FOREIGN KEY (amenity_id) REFERENCES public.amenities(id) ON DELETE RESTRICT;


--
-- Name: hotel_bookings tm_fk_14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel_bookings
    ADD CONSTRAINT tm_fk_14 FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE RESTRICT;


--
-- Name: hotel_bookings tm_fk_15; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel_bookings
    ADD CONSTRAINT tm_fk_15 FOREIGN KEY (hotel_id) REFERENCES public.hotels(hotel_id) ON DELETE RESTRICT;


--
-- Name: menu_items tm_fk_16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT tm_fk_16 FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(restaurant_id) ON DELETE RESTRICT;


--
-- Name: notifications tm_fk_17; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT tm_fk_17 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: payments tm_fk_18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT tm_fk_18 FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE RESTRICT;


--
-- Name: photos tm_fk_19; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT tm_fk_19 FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: photos tm_fk_20; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT tm_fk_20 FOREIGN KEY (listing_id) REFERENCES public.business_listings(id) ON DELETE RESTRICT;


--
-- Name: recommendations tm_fk_21; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT tm_fk_21 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: recommendations tm_fk_22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT tm_fk_22 FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: refunds tm_fk_23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT tm_fk_23 FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE RESTRICT;


--
-- Name: report_data_sources tm_fk_24; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_data_sources
    ADD CONSTRAINT tm_fk_24 FOREIGN KEY (report_id) REFERENCES public.analytics_reports(id) ON DELETE RESTRICT;


--
-- Name: report_data_sources tm_fk_25; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_data_sources
    ADD CONSTRAINT tm_fk_25 FOREIGN KEY (data_source_id) REFERENCES public.data_sources(id) ON DELETE RESTRICT;


--
-- Name: report_metrics tm_fk_26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_metrics
    ADD CONSTRAINT tm_fk_26 FOREIGN KEY (report_id) REFERENCES public.analytics_reports(id) ON DELETE RESTRICT;


--
-- Name: report_report_types tm_fk_27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_report_types
    ADD CONSTRAINT tm_fk_27 FOREIGN KEY (report_id) REFERENCES public.analytics_reports(id) ON DELETE RESTRICT;


--
-- Name: report_report_types tm_fk_28; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_report_types
    ADD CONSTRAINT tm_fk_28 FOREIGN KEY (report_type_id) REFERENCES public.report_types(id) ON DELETE RESTRICT;


--
-- Name: restaurants tm_fk_29; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT tm_fk_29 FOREIGN KEY (restaurant_id) REFERENCES public.business_listings(id) ON DELETE RESTRICT;


--
-- Name: restaurant_bookings tm_fk_30; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_bookings
    ADD CONSTRAINT tm_fk_30 FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE RESTRICT;


--
-- Name: restaurant_bookings tm_fk_31; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_bookings
    ADD CONSTRAINT tm_fk_31 FOREIGN KEY (slot_id) REFERENCES public.restaurant_slots(id) ON DELETE RESTRICT;


--
-- Name: restaurant_cuisines tm_fk_32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_cuisines
    ADD CONSTRAINT tm_fk_32 FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(restaurant_id) ON DELETE RESTRICT;


--
-- Name: restaurant_cuisines tm_fk_33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_cuisines
    ADD CONSTRAINT tm_fk_33 FOREIGN KEY (cuisine_id) REFERENCES public.cuisines(id) ON DELETE RESTRICT;


--
-- Name: restaurant_slots tm_fk_34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_slots
    ADD CONSTRAINT tm_fk_34 FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(restaurant_id) ON DELETE RESTRICT;


--
-- Name: reviews tm_fk_35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT tm_fk_35 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: reviews tm_fk_36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT tm_fk_36 FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: reviews tm_fk_37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT tm_fk_37 FOREIGN KEY (listing_id) REFERENCES public.business_listings(id) ON DELETE RESTRICT;


--
-- Name: review_comments tm_fk_38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_comments
    ADD CONSTRAINT tm_fk_38 FOREIGN KEY (review_id) REFERENCES public.reviews(id) ON DELETE RESTRICT;


--
-- Name: review_comments tm_fk_39; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_comments
    ADD CONSTRAINT tm_fk_39 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: review_tags tm_fk_40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tags
    ADD CONSTRAINT tm_fk_40 FOREIGN KEY (review_id) REFERENCES public.reviews(id) ON DELETE RESTRICT;


--
-- Name: review_tags tm_fk_41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tags
    ADD CONSTRAINT tm_fk_41 FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE RESTRICT;


--
-- Name: rooms tm_fk_42; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT tm_fk_42 FOREIGN KEY (hotel_id) REFERENCES public.hotels(hotel_id) ON DELETE RESTRICT;


--
-- Name: search_history tm_fk_43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_history
    ADD CONSTRAINT tm_fk_43 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: search_history tm_fk_44; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_history
    ADD CONSTRAINT tm_fk_44 FOREIGN KEY (trip_id) REFERENCES public.trips(id) ON DELETE RESTRICT;


--
-- Name: transportation_services tm_fk_45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transportation_services
    ADD CONSTRAINT tm_fk_45 FOREIGN KEY (provider_id) REFERENCES public.transport_providers(id) ON DELETE RESTRICT;


--
-- Name: transportation_services tm_fk_46; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transportation_services
    ADD CONSTRAINT tm_fk_46 FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: transport_providers tm_fk_47; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_providers
    ADD CONSTRAINT tm_fk_47 FOREIGN KEY (owner_id) REFERENCES public.business_owners(id) ON DELETE RESTRICT;


--
-- Name: transport_provider_contacts tm_fk_48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_provider_contacts
    ADD CONSTRAINT tm_fk_48 FOREIGN KEY (provider_id) REFERENCES public.transport_providers(id) ON DELETE RESTRICT;


--
-- Name: trips tm_fk_49; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT tm_fk_49 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: trip_items tm_fk_50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_items
    ADD CONSTRAINT tm_fk_50 FOREIGN KEY (trip_id) REFERENCES public.trips(id) ON DELETE RESTRICT;


--
-- Name: trip_items tm_fk_51; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_items
    ADD CONSTRAINT tm_fk_51 FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: trip_items tm_fk_52; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trip_items
    ADD CONSTRAINT tm_fk_52 FOREIGN KEY (listing_id) REFERENCES public.business_listings(id) ON DELETE RESTRICT;


--
-- Name: profile_phones tm_fk_53; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_phones
    ADD CONSTRAINT tm_fk_53 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: profile_preferences tm_fk_54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_preferences
    ADD CONSTRAINT tm_fk_54 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: profile_preferences tm_fk_55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_preferences
    ADD CONSTRAINT tm_fk_55 FOREIGN KEY (preference_id) REFERENCES public.preferences(id) ON DELETE RESTRICT;


--
-- Name: user_reports tm_fk_56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT tm_fk_56 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: user_reports tm_fk_57; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT tm_fk_57 FOREIGN KEY (listing_id) REFERENCES public.business_listings(id) ON DELETE RESTRICT;


--
-- Name: user_reports tm_fk_58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT tm_fk_58 FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: user_reports tm_fk_59; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT tm_fk_59 FOREIGN KEY (review_id) REFERENCES public.reviews(id) ON DELETE RESTRICT;


--
-- Name: user_reports tm_fk_60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT tm_fk_60 FOREIGN KEY (photo_id) REFERENCES public.photos(id) ON DELETE RESTRICT;


--
-- Name: user_reports tm_fk_61; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT tm_fk_61 FOREIGN KEY (transport_id) REFERENCES public.transportation_services(id) ON DELETE RESTRICT;


--
-- Name: user_reports tm_fk_62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT tm_fk_62 FOREIGN KEY (assigned_to) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: profile_roles tm_fk_63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_roles
    ADD CONSTRAINT tm_fk_63 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: profile_roles tm_fk_64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_roles
    ADD CONSTRAINT tm_fk_64 FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- Name: saved_destinations tm_fk_65; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_destinations
    ADD CONSTRAINT tm_fk_65 FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: saved_destinations tm_fk_66; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_destinations
    ADD CONSTRAINT tm_fk_66 FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: profiles tm_fk_67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT tm_fk_67 FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE RESTRICT;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: amenities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.amenities ENABLE ROW LEVEL SECURITY;

--
-- Name: analytics_reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.analytics_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: attraction_schedules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.attraction_schedules ENABLE ROW LEVEL SECURITY;

--
-- Name: attractions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.attractions ENABLE ROW LEVEL SECURITY;

--
-- Name: booking_rooms; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.booking_rooms ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

--
-- Name: business_listings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.business_listings ENABLE ROW LEVEL SECURITY;

--
-- Name: business_owners; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.business_owners ENABLE ROW LEVEL SECURITY;

--
-- Name: categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

--
-- Name: cuisines; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cuisines ENABLE ROW LEVEL SECURITY;

--
-- Name: data_sources; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.data_sources ENABLE ROW LEVEL SECURITY;

--
-- Name: destinations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.destinations ENABLE ROW LEVEL SECURITY;

--
-- Name: hotel_amenities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hotel_amenities ENABLE ROW LEVEL SECURITY;

--
-- Name: hotel_bookings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hotel_bookings ENABLE ROW LEVEL SECURITY;

--
-- Name: hotels; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hotels ENABLE ROW LEVEL SECURITY;

--
-- Name: menu_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: payments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

--
-- Name: photos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;

--
-- Name: preferences; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.preferences ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_phones; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profile_phones ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_preferences; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profile_preferences ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profile_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: recommendations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.recommendations ENABLE ROW LEVEL SECURITY;

--
-- Name: refunds; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.refunds ENABLE ROW LEVEL SECURITY;

--
-- Name: report_data_sources; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.report_data_sources ENABLE ROW LEVEL SECURITY;

--
-- Name: report_metrics; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.report_metrics ENABLE ROW LEVEL SECURITY;

--
-- Name: report_report_types; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.report_report_types ENABLE ROW LEVEL SECURITY;

--
-- Name: report_types; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.report_types ENABLE ROW LEVEL SECURITY;

--
-- Name: restaurant_bookings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.restaurant_bookings ENABLE ROW LEVEL SECURITY;

--
-- Name: restaurant_cuisines; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.restaurant_cuisines ENABLE ROW LEVEL SECURITY;

--
-- Name: restaurant_slots; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.restaurant_slots ENABLE ROW LEVEL SECURITY;

--
-- Name: restaurants; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;

--
-- Name: review_comments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.review_comments ENABLE ROW LEVEL SECURITY;

--
-- Name: review_tags; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.review_tags ENABLE ROW LEVEL SECURITY;

--
-- Name: reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

--
-- Name: rooms; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

--
-- Name: saved_destinations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.saved_destinations ENABLE ROW LEVEL SECURITY;

--
-- Name: search_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.search_history ENABLE ROW LEVEL SECURITY;

--
-- Name: tags; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_phones tm_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_delete ON public.profile_phones FOR DELETE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: profile_preferences tm_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_delete ON public.profile_preferences FOR DELETE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: saved_destinations tm_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_delete ON public.saved_destinations FOR DELETE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: search_history tm_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_delete ON public.search_history FOR DELETE TO authenticated USING (((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)) AND ((trip_id IS NULL) OR (EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = search_history.trip_id))))));


--
-- Name: trip_items tm_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_delete ON public.trip_items FOR DELETE TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = trip_items.trip_id))));


--
-- Name: trips tm_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_delete ON public.trips FOR DELETE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: profile_phones tm_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_insert ON public.profile_phones FOR INSERT TO authenticated WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: profile_preferences tm_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_insert ON public.profile_preferences FOR INSERT TO authenticated WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: saved_destinations tm_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_insert ON public.saved_destinations FOR INSERT TO authenticated WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: search_history tm_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_insert ON public.search_history FOR INSERT TO authenticated WITH CHECK (((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)) AND ((trip_id IS NULL) OR (EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = search_history.trip_id))))));


--
-- Name: trip_items tm_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_insert ON public.trip_items FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = trip_items.trip_id))));


--
-- Name: trips tm_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_insert ON public.trips FOR INSERT TO authenticated WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: destinations tm_job_analyst_destinations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_job_analyst_destinations ON public.destinations FOR SELECT TO tm_reporting_analyst USING (true);


--
-- Name: business_listings tm_job_analyst_listings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_job_analyst_listings ON public.business_listings FOR SELECT TO tm_reporting_analyst USING (true);


--
-- Name: destinations tm_job_reviewer_destinations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_job_reviewer_destinations ON public.destinations FOR SELECT TO tm_catalog_reviewer USING (true);


--
-- Name: business_listings tm_job_reviewer_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_job_reviewer_read ON public.business_listings FOR SELECT TO tm_catalog_reviewer USING (true);


--
-- Name: business_listings tm_job_reviewer_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_job_reviewer_update ON public.business_listings FOR UPDATE TO tm_catalog_reviewer USING (true) WITH CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying, 'inactive'::character varying])::text[])));


--
-- Name: notifications tm_mark_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_mark_read ON public.notifications FOR UPDATE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id))) WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: profile_roles tm_own_roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_own_roles ON public.profile_roles FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: attraction_schedules tm_owner_attraction_schedules_del; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_attraction_schedules_del ON public.attraction_schedules FOR DELETE TO authenticated USING (public.tm_owns_listing(attraction_id));


--
-- Name: attraction_schedules tm_owner_attraction_schedules_ins; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_attraction_schedules_ins ON public.attraction_schedules FOR INSERT TO authenticated WITH CHECK (public.tm_owns_listing(attraction_id));


--
-- Name: attraction_schedules tm_owner_attraction_schedules_upd; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_attraction_schedules_upd ON public.attraction_schedules FOR UPDATE TO authenticated USING (public.tm_owns_listing(attraction_id)) WITH CHECK (public.tm_owns_listing(attraction_id));


--
-- Name: attractions tm_owner_attractions_upd; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_attractions_upd ON public.attractions FOR UPDATE TO authenticated USING (public.tm_owns_listing(attraction_id)) WITH CHECK (public.tm_owns_listing(attraction_id));


--
-- Name: hotels tm_owner_hotels_upd; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_hotels_upd ON public.hotels FOR UPDATE TO authenticated USING (public.tm_owns_listing(hotel_id)) WITH CHECK (public.tm_owns_listing(hotel_id));


--
-- Name: business_listings tm_owner_listings_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_listings_read ON public.business_listings FOR SELECT TO authenticated USING (public.tm_owns_listing(id));


--
-- Name: business_listings tm_owner_listings_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_listings_update ON public.business_listings FOR UPDATE TO authenticated USING (public.tm_owns_listing(id)) WITH CHECK ((((status)::text = ANY ((ARRAY['pending'::character varying, 'inactive'::character varying])::text[])) AND (EXISTS ( SELECT 1
   FROM public.business_owners o
  WHERE ((o.id = business_listings.owner_id) AND (o.profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)))))));


--
-- Name: menu_items tm_owner_menu_items_del; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_menu_items_del ON public.menu_items FOR DELETE TO authenticated USING (public.tm_owns_listing(restaurant_id));


--
-- Name: menu_items tm_owner_menu_items_ins; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_menu_items_ins ON public.menu_items FOR INSERT TO authenticated WITH CHECK (public.tm_owns_listing(restaurant_id));


--
-- Name: menu_items tm_owner_menu_items_upd; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_menu_items_upd ON public.menu_items FOR UPDATE TO authenticated USING (public.tm_owns_listing(restaurant_id)) WITH CHECK (public.tm_owns_listing(restaurant_id));


--
-- Name: restaurants tm_owner_restaurants_upd; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_restaurants_upd ON public.restaurants FOR UPDATE TO authenticated USING (public.tm_owns_listing(restaurant_id)) WITH CHECK (public.tm_owns_listing(restaurant_id));


--
-- Name: rooms tm_owner_rooms_del; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_rooms_del ON public.rooms FOR DELETE TO authenticated USING (public.tm_owns_listing(hotel_id));


--
-- Name: rooms tm_owner_rooms_ins; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_rooms_ins ON public.rooms FOR INSERT TO authenticated WITH CHECK (public.tm_owns_listing(hotel_id));


--
-- Name: rooms tm_owner_rooms_upd; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_owner_rooms_upd ON public.rooms FOR UPDATE TO authenticated USING (public.tm_owns_listing(hotel_id)) WITH CHECK (public.tm_owns_listing(hotel_id));


--
-- Name: profiles tm_profile_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_profile_read ON public.profiles FOR SELECT TO authenticated USING (((id = ( SELECT auth.uid() AS uid)) AND ((account_status)::text = 'active'::text)));


--
-- Name: profiles tm_profile_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_profile_update ON public.profiles FOR UPDATE TO authenticated USING (((id = ( SELECT auth.uid() AS uid)) AND ((account_status)::text = 'active'::text))) WITH CHECK (((id = ( SELECT auth.uid() AS uid)) AND ((account_status)::text = 'active'::text)));


--
-- Name: amenities tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.amenities FOR SELECT TO authenticated, anon USING (true);


--
-- Name: attraction_schedules tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.attraction_schedules FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = attraction_schedules.attraction_id))));


--
-- Name: attractions tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.attractions FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = attractions.attraction_id))));


--
-- Name: booking_rooms tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.booking_rooms FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.bookings b
  WHERE (b.id = booking_rooms.booking_id))));


--
-- Name: bookings tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.bookings FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: business_listings tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.business_listings FOR SELECT TO authenticated, anon USING ((((status)::text = 'approved'::text) AND (EXISTS ( SELECT 1
   FROM public.destinations d
  WHERE (d.id = business_listings.destination_id)))));


--
-- Name: business_owners tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.business_owners FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: categories tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.categories FOR SELECT TO authenticated, anon USING (true);


--
-- Name: cuisines tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.cuisines FOR SELECT TO authenticated, anon USING (true);


--
-- Name: destinations tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.destinations FOR SELECT TO authenticated, anon USING ((is_active = 1));


--
-- Name: hotel_amenities tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.hotel_amenities FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = hotel_amenities.hotel_id))));


--
-- Name: hotel_bookings tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.hotel_bookings FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.bookings b
  WHERE (b.id = hotel_bookings.booking_id))));


--
-- Name: hotels tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.hotels FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = hotels.hotel_id))));


--
-- Name: menu_items tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.menu_items FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = menu_items.restaurant_id))));


--
-- Name: notifications tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.notifications FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: payments tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.payments FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.bookings b
  WHERE (b.id = payments.booking_id))));


--
-- Name: photos tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.photos FOR SELECT TO authenticated, anon USING ((((status)::text = 'approved'::text) AND ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = photos.listing_id))) OR (EXISTS ( SELECT 1
   FROM public.destinations d
  WHERE (d.id = photos.destination_id))))));


--
-- Name: preferences tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.preferences FOR SELECT TO authenticated, anon USING (true);


--
-- Name: profile_phones tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.profile_phones FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: profile_preferences tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.profile_preferences FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: recommendations tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.recommendations FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: refunds tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.refunds FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.payments p
  WHERE (p.id = refunds.payment_id))));


--
-- Name: restaurant_bookings tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.restaurant_bookings FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.bookings b
  WHERE (b.id = restaurant_bookings.booking_id))));


--
-- Name: restaurant_cuisines tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.restaurant_cuisines FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = restaurant_cuisines.restaurant_id))));


--
-- Name: restaurant_slots tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.restaurant_slots FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = restaurant_slots.restaurant_id))));


--
-- Name: restaurants tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.restaurants FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = restaurants.restaurant_id))));


--
-- Name: review_comments tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.review_comments FOR SELECT TO authenticated, anon USING ((((status)::text = 'published'::text) AND (EXISTS ( SELECT 1
   FROM public.reviews r
  WHERE (r.id = review_comments.review_id)))));


--
-- Name: review_tags tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.review_tags FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.reviews r
  WHERE (r.id = review_tags.review_id))));


--
-- Name: reviews tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.reviews FOR SELECT TO authenticated, anon USING ((((status)::text = 'published'::text) AND ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = reviews.listing_id))) OR (EXISTS ( SELECT 1
   FROM public.destinations d
  WHERE (d.id = reviews.destination_id))))));


--
-- Name: rooms tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.rooms FOR SELECT TO authenticated, anon USING ((EXISTS ( SELECT 1
   FROM public.business_listings b
  WHERE (b.id = rooms.hotel_id))));


--
-- Name: saved_destinations tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.saved_destinations FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: search_history tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.search_history FOR SELECT TO authenticated USING (((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)) AND ((trip_id IS NULL) OR (EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = search_history.trip_id))))));


--
-- Name: tags tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.tags FOR SELECT TO authenticated, anon USING (true);


--
-- Name: trip_items tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.trip_items FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = trip_items.trip_id))));


--
-- Name: trips tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.trips FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: user_reports tm_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_read ON public.user_reports FOR SELECT TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: roles tm_role_names; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_role_names ON public.roles FOR SELECT TO authenticated USING (true);


--
-- Name: profile_phones tm_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_update ON public.profile_phones FOR UPDATE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id))) WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: profile_preferences tm_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_update ON public.profile_preferences FOR UPDATE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id))) WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: saved_destinations tm_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_update ON public.saved_destinations FOR UPDATE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id))) WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: search_history tm_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_update ON public.search_history FOR UPDATE TO authenticated USING (((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)) AND ((trip_id IS NULL) OR (EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = search_history.trip_id)))))) WITH CHECK (((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)) AND ((trip_id IS NULL) OR (EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = search_history.trip_id))))));


--
-- Name: trip_items tm_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_update ON public.trip_items FOR UPDATE TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = trip_items.trip_id)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.trips t
  WHERE (t.id = trip_items.trip_id))));


--
-- Name: trips tm_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tm_update ON public.trips FOR UPDATE TO authenticated USING ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id))) WITH CHECK ((profile_id = ( SELECT public.tm_active_profile_id() AS tm_active_profile_id)));


--
-- Name: transport_provider_contacts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.transport_provider_contacts ENABLE ROW LEVEL SECURITY;

--
-- Name: transport_providers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.transport_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: transportation_services; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.transportation_services ENABLE ROW LEVEL SECURITY;

--
-- Name: trip_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.trip_items ENABLE ROW LEVEL SECURITY;

--
-- Name: trips; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

--
-- Name: user_reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: objects tm_avatar_delete; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_avatar_delete ON storage.objects FOR DELETE TO authenticated USING (((bucket_id = 'travelmate-avatars'::text) AND ((storage.foldername(name))[1] = (( SELECT public.tm_active_profile_id() AS tm_active_profile_id))::text)));


--
-- Name: objects tm_avatar_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_avatar_read ON storage.objects FOR SELECT TO authenticated USING (((bucket_id = 'travelmate-avatars'::text) AND ((storage.foldername(name))[1] = (( SELECT public.tm_active_profile_id() AS tm_active_profile_id))::text)));


--
-- Name: objects tm_avatar_update; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_avatar_update ON storage.objects FOR UPDATE TO authenticated USING (((bucket_id = 'travelmate-avatars'::text) AND ((storage.foldername(name))[1] = (( SELECT public.tm_active_profile_id() AS tm_active_profile_id))::text))) WITH CHECK (((bucket_id = 'travelmate-avatars'::text) AND ((storage.foldername(name))[1] = (( SELECT public.tm_active_profile_id() AS tm_active_profile_id))::text)));


--
-- Name: objects tm_avatar_upload; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_avatar_upload ON storage.objects FOR INSERT TO authenticated WITH CHECK (((bucket_id = 'travelmate-avatars'::text) AND ((storage.foldername(name))[1] = (( SELECT public.tm_active_profile_id() AS tm_active_profile_id))::text)));


--
-- Name: objects tm_listing_admin_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_listing_admin_read ON storage.objects FOR SELECT TO authenticated USING (((bucket_id = 'travelmate-listings'::text) AND public.tm_is_admin()));


--
-- Name: objects tm_listing_approved_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_listing_approved_read ON storage.objects FOR SELECT TO authenticated, anon USING (((bucket_id = 'travelmate-listings'::text) AND (EXISTS ( SELECT 1
   FROM public.photos p
  WHERE ((p.bucket_id = objects.bucket_id) AND (p.object_path = objects.name) AND ((p.status)::text = 'approved'::text))))));


--
-- Name: objects tm_listing_owner_delete; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_listing_owner_delete ON storage.objects FOR DELETE TO authenticated USING (((bucket_id = 'travelmate-listings'::text) AND public.tm_owns_listing_path(name)));


--
-- Name: objects tm_listing_owner_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_listing_owner_read ON storage.objects FOR SELECT TO authenticated USING (((bucket_id = 'travelmate-listings'::text) AND public.tm_owns_listing_path(name)));


--
-- Name: objects tm_listing_upload; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY tm_listing_upload ON storage.objects FOR INSERT TO authenticated WITH CHECK (((bucket_id = 'travelmate-listings'::text) AND public.tm_owns_listing_path(name)));


--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: amenities; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.amenities ENABLE ROW LEVEL SECURITY;

--
-- Name: analytics_reports; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.analytics_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: attraction_schedules; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.attraction_schedules ENABLE ROW LEVEL SECURITY;

--
-- Name: attractions; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.attractions ENABLE ROW LEVEL SECURITY;

--
-- Name: auth_sessions; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.auth_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: booking_rooms; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.booking_rooms ENABLE ROW LEVEL SECURITY;

--
-- Name: bookings; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.bookings ENABLE ROW LEVEL SECURITY;

--
-- Name: business_listings; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.business_listings ENABLE ROW LEVEL SECURITY;

--
-- Name: business_owners; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.business_owners ENABLE ROW LEVEL SECURITY;

--
-- Name: categories; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.categories ENABLE ROW LEVEL SECURITY;

--
-- Name: cuisines; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.cuisines ENABLE ROW LEVEL SECURITY;

--
-- Name: data_sources; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.data_sources ENABLE ROW LEVEL SECURITY;

--
-- Name: destinations; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.destinations ENABLE ROW LEVEL SECURITY;

--
-- Name: hotel_amenities; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.hotel_amenities ENABLE ROW LEVEL SECURITY;

--
-- Name: hotel_bookings; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.hotel_bookings ENABLE ROW LEVEL SECURITY;

--
-- Name: hotels; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.hotels ENABLE ROW LEVEL SECURITY;

--
-- Name: login_attempts; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.login_attempts ENABLE ROW LEVEL SECURITY;

--
-- Name: menu_items; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.menu_items ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: payments; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.payments ENABLE ROW LEVEL SECURITY;

--
-- Name: photos; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.photos ENABLE ROW LEVEL SECURITY;

--
-- Name: preferences; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.preferences ENABLE ROW LEVEL SECURITY;

--
-- Name: recommendations; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.recommendations ENABLE ROW LEVEL SECURITY;

--
-- Name: refunds; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.refunds ENABLE ROW LEVEL SECURITY;

--
-- Name: report_data_sources; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.report_data_sources ENABLE ROW LEVEL SECURITY;

--
-- Name: report_metrics; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.report_metrics ENABLE ROW LEVEL SECURITY;

--
-- Name: report_report_types; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.report_report_types ENABLE ROW LEVEL SECURITY;

--
-- Name: report_types; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.report_types ENABLE ROW LEVEL SECURITY;

--
-- Name: restaurant_bookings; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.restaurant_bookings ENABLE ROW LEVEL SECURITY;

--
-- Name: restaurant_cuisines; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.restaurant_cuisines ENABLE ROW LEVEL SECURITY;

--
-- Name: restaurant_slots; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.restaurant_slots ENABLE ROW LEVEL SECURITY;

--
-- Name: restaurants; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.restaurants ENABLE ROW LEVEL SECURITY;

--
-- Name: review_comments; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.review_comments ENABLE ROW LEVEL SECURITY;

--
-- Name: review_tags; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.review_tags ENABLE ROW LEVEL SECURITY;

--
-- Name: reviews; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: roles; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.roles ENABLE ROW LEVEL SECURITY;

--
-- Name: rooms; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.rooms ENABLE ROW LEVEL SECURITY;

--
-- Name: search_history; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.search_history ENABLE ROW LEVEL SECURITY;

--
-- Name: session_ips; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.session_ips ENABLE ROW LEVEL SECURITY;

--
-- Name: tags; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.tags ENABLE ROW LEVEL SECURITY;

--
-- Name: users tm_profile_read_own; Type: POLICY; Schema: travelmate; Owner: -
--

CREATE POLICY tm_profile_read_own ON travelmate.users FOR SELECT TO authenticated USING (((auth_user_id = ( SELECT auth.uid() AS uid)) AND ((account_status)::text = 'active'::text)));


--
-- Name: users tm_profile_update_own; Type: POLICY; Schema: travelmate; Owner: -
--

CREATE POLICY tm_profile_update_own ON travelmate.users FOR UPDATE TO authenticated USING (((auth_user_id = ( SELECT auth.uid() AS uid)) AND ((account_status)::text = 'active'::text))) WITH CHECK (((auth_user_id = ( SELECT auth.uid() AS uid)) AND ((account_status)::text = 'active'::text)));


--
-- Name: transport_provider_contacts; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.transport_provider_contacts ENABLE ROW LEVEL SECURITY;

--
-- Name: transport_providers; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.transport_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: transportation_services; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.transportation_services ENABLE ROW LEVEL SECURITY;

--
-- Name: trip_items; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.trip_items ENABLE ROW LEVEL SECURITY;

--
-- Name: trips; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.trips ENABLE ROW LEVEL SECURITY;

--
-- Name: user_phones; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.user_phones ENABLE ROW LEVEL SECURITY;

--
-- Name: user_preferences; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.user_preferences ENABLE ROW LEVEL SECURITY;

--
-- Name: user_reports; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.user_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.user_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.users ENABLE ROW LEVEL SECURITY;

--
-- Name: wishlist_destinations; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.wishlist_destinations ENABLE ROW LEVEL SECURITY;

--
-- Name: wishlists; Type: ROW SECURITY; Schema: travelmate; Owner: -
--

ALTER TABLE travelmate.wishlists ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict TFHbn4WGhZqcQ5nr8d4Wcp9EgJaLy0P0KlUgsCQqbXZjAuw2qa3py2SRKOy8f8D

