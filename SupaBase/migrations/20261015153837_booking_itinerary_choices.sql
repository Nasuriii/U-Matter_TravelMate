-- Confirmed test/free reservations are usable travel records, not paid expenses.
do $$declare definition text;begin
 select pg_get_functiondef('travelmate_ui.trip_booking_catalog(uuid)'::regprocedure) into definition;
 if position('b.profile_id=u and b.payment_status=''paid'' and b.status in (''confirmed'',''completed'') and not b.is_test' in definition)=0 then raise exception 'Unexpected booking catalog';end if;
 definition:=replace(definition,'b.profile_id=u and b.payment_status=''paid'' and b.status in (''confirmed'',''completed'') and not b.is_test',
  'b.profile_id=u and b.status in (''confirmed'',''completed'') and (b.payment_status=''paid'' or b.is_test or b.amount=0)');
 definition:=replace(definition,'select b.*,a.trip_id','select b.*,(select l.destination_id from public.business_listings l where l.id=b.listing_id) as destination_id,a.trip_id');
 execute definition;
 select pg_get_functiondef('travelmate_ui.attach_trip_booking(uuid,uuid,date,boolean)'::regprocedure) into definition;
 definition:=replace(definition,'if b.payment_status is distinct from ''paid'' or b.status not in (''confirmed'',''completed'') or b.is_test then raise exception ''Only paid, confirmed or completed bookings can be attached'';',
 'if b.status not in (''confirmed'',''completed'') or (b.payment_status is distinct from ''paid'' and not b.is_test and b.amount<>0) then raise exception ''Only confirmed paid, free or test reservations can be attached'';');
 execute definition;
end $$;
alter table travelmate_ui.trip_booking_attachments add column plan_request_key uuid,add column visit_start time,add column visit_end time;
create unique index trip_booking_plan_request on travelmate_ui.trip_booking_attachments(plan_request_key) where plan_request_key is not null;

create function travelmate_ui.schedule_trip_booking(p_trip uuid,p_booking uuid,p_day date,p_start time,p_end time,p_key uuid,p_allow_outside boolean default false,p_plan jsonb default null)
returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_browsing_profile_id();t public.trips;b record;a travelmate_ui.trip_booking_attachments;link uuid;items jsonb;days jsonb;item jsonb;target bigint;matches integer;saved timestamptz;expected timestamptz;
begin
 if u is null or not public.tm_can_plan() then raise exception 'Traveler account required' using errcode='42501';end if;
 select * into t from public.trips where id=p_trip and profile_id=u for update;
 if not found or t.status<>'draft' then raise exception 'Choose your own editable trip';end if;
 if p_key is null or p_start is null or p_end is null or p_end<=p_start then raise exception 'Choose a start and end time for this itinerary stop';end if;
 select coalesce(jsonb_agg(jsonb_build_object('planned_date',i.planned_date,'planned_time',i.planned_time,'planned_end_time',i.planned_end_time,'listing_id',i.listing_id,'activity',i.activity,'recommendation_reason',coalesce(i.recommendation_reason,''),'notes',coalesce(i.notes,'')) order by i.sequence_number),'[]') into items from public.trip_items i where i.trip_id=p_trip;
 select coalesce(jsonb_agg(jsonb_build_object('planned_date',d.planned_date,'title',d.title,'notes',d.notes) order by d.planned_date),'[]') into days from public.trip_day_notes d where d.trip_id=p_trip;
 select * into a from travelmate_ui.trip_booking_attachments where plan_request_key=p_key;
 if found then
  if a.profile_id<>u or a.trip_id<>p_trip or a.booking_id<>p_booking or a.planned_date<>p_day or a.visit_start<>p_start or a.visit_end<>p_end then raise exception 'This request is already used for different itinerary details';end if;
  return jsonb_build_object('trip_id',p_trip,'attachment_id',a.id,'updated_at',t.updated_at,'items',items,'days',days);
 end if;
 select * into b from travelmate_ui.trip_booking_details where booking_id=p_booking and profile_id=u;
 if not found then raise exception 'Your booking was not found' using errcode='42501';end if;
 if not exists(select 1 from public.business_listings l where l.id=b.listing_id and l.destination_id=t.destination_id) then raise exception 'Choose a trip for this booking destination';end if;
 expected:=t.updated_at;
 if p_plan is not null then
  if jsonb_typeof(p_plan->'items')<>'array' or jsonb_typeof(p_plan->'days')<>'array' or p_plan->>'updated_at' is null then raise exception 'Reopen the plan before attaching this reservation';end if;
  items:=p_plan->'items';days:=p_plan->'days';expected:=(p_plan->>'updated_at')::timestamptz;
 end if;
 -- Reuse one planned visit to this place, or the visit already at these times.
 select count(*) into matches from jsonb_array_elements(items) x where x->>'listing_id'=b.listing_id::text and x->>'planned_date'=p_day::text;
 select ordinality into target from jsonb_array_elements(items) with ordinality x(value,ordinality)
  where value->>'listing_id'=b.listing_id::text and value->>'planned_date'=p_day::text
   and (matches=1 or ((value->>'planned_time')::time=p_start and (value->>'planned_end_time')::time=p_end)) order by ordinality limit 1;
 item:=jsonb_build_object('planned_date',p_day,'planned_time',p_start,'planned_end_time',p_end,'listing_id',b.listing_id,'activity',b.name,'recommendation_reason','Confirmed reservation attached by the traveler.','notes','Booking reference: '||upper(left(p_booking::text,8)));
 if target is null then items:=items||jsonb_build_array(item);
 else items:=jsonb_set(items,array[(target-1)::text],(items->(target-1)::integer)||jsonb_build_object('planned_time',p_start,'planned_end_time',p_end));end if;
 select jsonb_agg(value order by value->>'planned_date',(value->>'planned_time')::time,(value->>'planned_end_time')::time) into items from jsonb_array_elements(items);
 link:=travelmate_ui.attach_trip_booking(p_trip,p_booking,p_day,p_allow_outside);
 saved:=public.save_my_trip_plan(p_trip,expected,items,days);
 update travelmate_ui.trip_booking_attachments set plan_request_key=p_key,visit_start=p_start,visit_end=p_end where id=link and profile_id=u;
 return jsonb_build_object('trip_id',p_trip,'attachment_id',link,'updated_at',saved,'items',items,'days',days);
end $$;
create function public.schedule_my_trip_booking(p_trip uuid,p_booking uuid,p_day date,p_start time,p_end time,p_key uuid,p_allow_outside boolean default false,p_plan jsonb default null)
returns jsonb language sql security invoker set search_path='' as $$select travelmate_ui.schedule_trip_booking(p_trip,p_booking,p_day,p_start,p_end,p_key,p_allow_outside,p_plan)$$;
revoke all on function travelmate_ui.schedule_trip_booking(uuid,uuid,date,time,time,uuid,boolean,jsonb),public.schedule_my_trip_booking(uuid,uuid,date,time,time,uuid,boolean,jsonb) from public,anon;
grant execute on function travelmate_ui.schedule_trip_booking(uuid,uuid,date,time,time,uuid,boolean,jsonb),public.schedule_my_trip_booking(uuid,uuid,date,time,time,uuid,boolean,jsonb) to authenticated;
notify pgrst,'reload schema';
