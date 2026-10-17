-- Reservations remain authoritative. Trip links never create bookings or payments.
create table travelmate_ui.trip_booking_attachments (
 id uuid primary key default gen_random_uuid(),
 trip_id uuid not null references public.trips(id) on delete cascade,
 profile_id uuid not null references public.profiles(id) on delete cascade,
 booking_id uuid references public.bookings(id) on delete cascade,
 planned_date date not null,
 external_type text check(external_type in ('hotel','restaurant')),
 external_name text check(char_length(external_name) between 1 and 150),
 provider text check(char_length(provider) between 1 and 150),
 reference text check(char_length(reference) between 1 and 100),
 address text check(char_length(address)<=500),
 start_date date, end_date date, start_time time, end_time time,
 amount numeric(12,2) check(amount between 0 and 9999999999.99),
 currency text check(currency in ('PHP','USD','HKD')),
 file_path text, file_name text check(char_length(file_name) between 1 and 180),
 created_at timestamptz not null default now(),
 constraint trip_booking_source check (
  (booking_id is not null and external_type is null and file_path is null) or
  (booking_id is null and external_type is not null and external_name is not null
   and provider is not null and reference is not null and start_date is not null
   and end_date is not null and start_time is not null and end_time is not null
   and amount is not null and currency is not null and file_path is not null and file_name is not null
   and ((external_type='hotel' and end_date>start_date) or
    (external_type='restaurant' and end_date=start_date and end_time>start_time)))
 )
);
alter table travelmate_ui.trip_booking_attachments enable row level security;
revoke all on travelmate_ui.trip_booking_attachments from public,anon,authenticated;
create index trip_booking_attachments_trip on travelmate_ui.trip_booking_attachments(trip_id);
create index trip_booking_attachments_profile on travelmate_ui.trip_booking_attachments(profile_id);
create unique index trip_booking_attachments_booking on travelmate_ui.trip_booking_attachments(booking_id);
create unique index trip_booking_attachments_external_reference on travelmate_ui.trip_booking_attachments(profile_id,lower(provider),lower(reference)) where booking_id is null;
create unique index trip_booking_attachments_file on travelmate_ui.trip_booking_attachments(file_path) where file_path is not null;

-- One row per booking even when a stay includes several rooms. All times are local.
create view travelmate_ui.trip_booking_details with (security_invoker=true) as
 select b.id as booking_id,b.profile_id,b.booking_type,b.status,b.payment_status,b.is_test,
  b.total_amount as amount,'PHP'::text as currency,
  coalesce(lh.id,lr.id) as listing_id,coalesce(lh.name,lr.name) as name,
  coalesce(lh.address,lr.address) as address,
  coalesce(h.check_in,(s.starts_at at time zone 'Asia/Manila')::date) as start_date,
  coalesce(h.check_out,(s.ends_at at time zone 'Asia/Manila')::date) as end_date,
  coalesce(ht.check_in_time,(s.starts_at at time zone 'Asia/Manila')::time) as start_time,
  coalesce(ht.check_out_time,(s.ends_at at time zone 'Asia/Manila')::time) as end_time,
  b.guest_count,
  (select string_agg(r.room_type||' · Room '||r.room_number,', ' order by r.room_number)
   from public.booking_rooms br join public.rooms r on r.id=br.room_id where br.booking_id=b.id) as room
 from public.bookings b
 left join public.hotel_bookings h on h.booking_id=b.id
 left join public.hotels ht on ht.hotel_id=h.hotel_id
 left join public.business_listings lh on lh.id=h.hotel_id
 left join public.restaurant_bookings rb on rb.booking_id=b.id
 left join public.restaurant_slots s on s.id=rb.slot_id
 left join public.business_listings lr on lr.id=s.restaurant_id;
revoke all on travelmate_ui.trip_booking_details from public,anon,authenticated;

create function travelmate_ui.trip_booking_catalog(p_trip uuid default null) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare u uuid:=public.tm_browsing_profile_id();begin
 if u is null or not public.tm_can_plan() then raise exception 'Traveler account required' using errcode='42501';end if;
 if p_trip is not null and not exists(select 1 from public.trips where id=p_trip and profile_id=u) then
  raise exception 'Your trip was not found' using errcode='42501';end if;
 return jsonb_build_object(
  'bookings',(select coalesce(jsonb_agg(row order by row.start_date desc,row.booking_id),'[]'::jsonb) from (
   select b.*,a.trip_id as attached_trip_id,t.name as attached_trip_name
   from travelmate_ui.trip_booking_details b
   left join travelmate_ui.trip_booking_attachments a on a.booking_id=b.booking_id
   left join public.trips t on t.id=a.trip_id
   where b.profile_id=u and b.payment_status='paid' and b.status in ('confirmed','completed') and not b.is_test
  ) row),
  'attachments',(select coalesce(jsonb_agg(row order by row.planned_date,row.created_at),'[]'::jsonb) from (
   select a.id,a.trip_id,a.planned_date,a.created_at,a.booking_id,
    case when a.booking_id is null then 'external' else 'travelmate' end as source,
    coalesce(b.booking_type,a.external_type) as booking_type,coalesce(b.name,a.external_name) as name,
    coalesce(b.address,a.address) as address,b.listing_id,b.room,b.guest_count,
    coalesce(b.start_date,a.start_date) as start_date,coalesce(b.end_date,a.end_date) as end_date,
    coalesce(b.start_time,a.start_time) as start_time,coalesce(b.end_time,a.end_time) as end_time,
    coalesce(b.amount,a.amount) as amount,coalesce(b.currency,a.currency) as currency,
    coalesce(b.status,'confirmed') as status,coalesce(b.payment_status,'reported_paid') as payment_status,
    a.provider,coalesce(a.reference,upper(left(a.booking_id::text,8))) as reference,a.file_path,a.file_name
   from travelmate_ui.trip_booking_attachments a
   left join travelmate_ui.trip_booking_details b on b.booking_id=a.booking_id and b.profile_id=u
   where a.profile_id=u and (p_trip is null or a.trip_id=p_trip)
  ) row));
end $$;

create function travelmate_ui.attach_trip_booking(p_trip uuid,p_booking uuid,p_day date,p_allow_outside boolean default false) returns uuid
language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_browsing_profile_id();t public.trips;b record;result uuid;begin
 if u is null or not public.tm_can_plan() then raise exception 'Traveler account required' using errcode='42501';end if;
 select * into t from public.trips where id=p_trip and profile_id=u for update;
 if not found or t.status<>'draft' then raise exception 'Choose your own editable trip';end if;
 if p_day is null or t.start_date is null or t.end_date is null or p_day<t.start_date or p_day>t.end_date then raise exception 'Choose a day within your trip';end if;
 perform 1 from public.bookings where id=p_booking and profile_id=u for update;
 if not found then raise exception 'Your paid booking was not found' using errcode='42501';end if;
 select * into b from travelmate_ui.trip_booking_details where booking_id=p_booking and profile_id=u;
 if b.payment_status is distinct from 'paid' or b.status not in ('confirmed','completed') or b.is_test then raise exception 'Only paid, confirmed or completed bookings can be attached';end if;
 if b.start_date is null or b.end_date is null then raise exception 'This booking has incomplete dates';end if;
 if (b.start_date<t.start_date or b.end_date>t.end_date) and p_allow_outside is distinct from true then
  raise exception 'Booking dates fall outside this trip. Acknowledge the warning to attach it anyway';end if;
 select id into result from travelmate_ui.trip_booking_attachments where booking_id=p_booking;
 if found then
  if exists(select 1 from travelmate_ui.trip_booking_attachments where id=result and trip_id=p_trip and planned_date=p_day) then return result;end if;
  raise exception 'This booking is already attached. Remove its existing trip link first';
 end if;
 insert into travelmate_ui.trip_booking_attachments(trip_id,profile_id,booking_id,planned_date) values(p_trip,u,p_booking,p_day) returning id into result;
 return result;
end $$;

-- Upload paths are generated UUIDs, never provider names or supplied filenames.
create function travelmate_ui.trip_confirmation_upload_allowed(p_name text) returns boolean
language plpgsql stable security definer set search_path='' as $$
declare u uuid:=public.tm_browsing_profile_id();parts text[]:=string_to_array(p_name,'/');begin
 if u is null or not public.tm_can_plan() or array_length(parts,1)<>3 or parts[1]<>u::text
  or parts[2]!~'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  or parts[3]!~'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(pdf|jpg|png|webp)$' then return false;end if;
 return exists(select 1 from public.trips where id=parts[2]::uuid and profile_id=u and status='draft');
end $$;
create function public.trip_confirmation_upload_allowed(p_name text) returns boolean
language sql stable security invoker set search_path='' as $$select travelmate_ui.trip_confirmation_upload_allowed(p_name)$$;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 values('trip-confirmations','trip-confirmations',false,10485760,array['application/pdf','image/jpeg','image/png','image/webp']);
create policy own_trip_confirmations_read on storage.objects for select to authenticated
 using(bucket_id='trip-confirmations' and (storage.foldername(name))[1]=(select auth.uid())::text and (select public.tm_can_plan()));
create policy own_trip_confirmations_upload on storage.objects for insert to authenticated
 with check(bucket_id='trip-confirmations' and public.trip_confirmation_upload_allowed(name));
create policy own_trip_confirmations_delete on storage.objects for delete to authenticated
 using(bucket_id='trip-confirmations' and (storage.foldername(name))[1]=(select auth.uid())::text);

create function travelmate_ui.add_external_trip_booking(p_trip uuid,p_document jsonb,p_allow_outside boolean default false) returns uuid
language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_browsing_profile_id();t public.trips;aid uuid;sd date;ed date;pd date;st time;et time;path text;begin
 if u is null or not public.tm_can_plan() then raise exception 'Traveler account required' using errcode='42501';end if;
 select * into t from public.trips where id=p_trip and profile_id=u for update;
 if not found or t.status<>'draft' then raise exception 'Choose your own editable trip';end if;
 if p_document is null or jsonb_typeof(p_document)<>'object' then raise exception 'Complete your external booking details';end if;
 aid:=(p_document->>'id')::uuid;sd:=(p_document->>'start_date')::date;ed:=(p_document->>'end_date')::date;
 pd:=(p_document->>'planned_date')::date;st:=(p_document->>'start_time')::time;et:=(p_document->>'end_time')::time;path:=p_document->>'file_path';
 if pd is null or t.start_date is null or t.end_date is null or pd<t.start_date or pd>t.end_date then raise exception 'Choose a day within your trip';end if;
 if aid is null or sd is null or ed is null or st is null or et is null or
  (p_document->>'booking_type') not in ('hotel','restaurant') or
  nullif(btrim(p_document->>'name'),'') is null or nullif(btrim(p_document->>'provider'),'') is null or
  nullif(btrim(p_document->>'reference'),'') is null or nullif(btrim(p_document->>'file_name'),'') is null or
  (p_document->>'amount') is null or (p_document->>'currency') is null then raise exception 'Complete your external booking details';end if;
 if path is null or path not in (u::text||'/'||p_trip::text||'/'||aid::text||'.pdf',u::text||'/'||p_trip::text||'/'||aid::text||'.jpg',u::text||'/'||p_trip::text||'/'||aid::text||'.png',u::text||'/'||p_trip::text||'/'||aid::text||'.webp') then raise exception 'Invalid private confirmation path';end if;
 if not exists(select 1 from storage.objects where bucket_id='trip-confirmations' and name=path) then raise exception 'Upload your receipt or confirmation first';end if;
 if (sd<t.start_date or ed>t.end_date) and p_allow_outside is distinct from true then raise exception 'Booking dates fall outside this trip. Acknowledge the warning to attach it anyway';end if;
 insert into travelmate_ui.trip_booking_attachments(id,trip_id,profile_id,planned_date,external_type,external_name,provider,reference,address,start_date,end_date,start_time,end_time,amount,currency,file_path,file_name)
 values(aid,p_trip,u,pd,p_document->>'booking_type',btrim(p_document->>'name'),btrim(p_document->>'provider'),btrim(p_document->>'reference'),nullif(btrim(p_document->>'address'),''),sd,ed,st,et,(p_document->>'amount')::numeric,p_document->>'currency',path,p_document->>'file_name');
 return aid;
exception when unique_violation then raise exception 'This booking reference or confirmation is already attached';
end $$;

create function travelmate_ui.detach_trip_booking(p_attachment uuid) returns text
language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_browsing_profile_id();a travelmate_ui.trip_booking_attachments;begin
 if u is null or not public.tm_can_plan() then raise exception 'Traveler account required' using errcode='42501';end if;
 -- Lock the parent first, matching the attach and trip deletion lock order.
 perform 1 from public.trips t join travelmate_ui.trip_booking_attachments x on x.trip_id=t.id
  where x.id=p_attachment and x.profile_id=u and t.profile_id=u and t.status='draft' for update of t;
 if not found then raise exception 'Your editable trip attachment was not found';end if;
 delete from travelmate_ui.trip_booking_attachments where id=p_attachment and profile_id=u returning * into a;
 return a.file_path;
end $$;

create function public.my_trip_booking_catalog(p_trip uuid default null) returns jsonb
language sql stable security invoker set search_path='' as $$select travelmate_ui.trip_booking_catalog(p_trip)$$;
create function public.attach_my_trip_booking(p_trip uuid,p_booking uuid,p_day date,p_allow_outside boolean default false) returns uuid
language sql security invoker set search_path='' as $$select travelmate_ui.attach_trip_booking(p_trip,p_booking,p_day,p_allow_outside)$$;
create function public.add_my_external_trip_booking(p_trip uuid,p_document jsonb,p_allow_outside boolean default false) returns uuid
language sql security invoker set search_path='' as $$select travelmate_ui.add_external_trip_booking(p_trip,p_document,p_allow_outside)$$;
create function public.detach_my_trip_booking(p_attachment uuid) returns text
language sql security invoker set search_path='' as $$select travelmate_ui.detach_trip_booking(p_attachment)$$;

revoke all on function travelmate_ui.trip_booking_catalog(uuid),travelmate_ui.attach_trip_booking(uuid,uuid,date,boolean),
 travelmate_ui.trip_confirmation_upload_allowed(text),travelmate_ui.add_external_trip_booking(uuid,jsonb,boolean),travelmate_ui.detach_trip_booking(uuid),
 public.my_trip_booking_catalog(uuid),public.attach_my_trip_booking(uuid,uuid,date,boolean),public.trip_confirmation_upload_allowed(text),
 public.add_my_external_trip_booking(uuid,jsonb,boolean),public.detach_my_trip_booking(uuid) from public,anon;
grant execute on function travelmate_ui.trip_booking_catalog(uuid),travelmate_ui.attach_trip_booking(uuid,uuid,date,boolean),
 travelmate_ui.trip_confirmation_upload_allowed(text),travelmate_ui.add_external_trip_booking(uuid,jsonb,boolean),travelmate_ui.detach_trip_booking(uuid),
 public.my_trip_booking_catalog(uuid),public.attach_my_trip_booking(uuid,uuid,date,boolean),public.trip_confirmation_upload_allowed(text),
 public.add_my_external_trip_booking(uuid,jsonb,boolean),public.detach_my_trip_booking(uuid) to authenticated;
notify pgrst,'reload schema';
