-- External payment reports apply only to external confirmations. A linked
-- reservation with missing payment state must remain unpaid in the catalog.
do $$declare definition text;begin
 select pg_get_functiondef('travelmate_ui.trip_booking_catalog(uuid)'::regprocedure) into definition;
 if position('coalesce(b.payment_status,''reported_paid'')' in definition)=0 then raise exception 'Booking catalog payment expression changed';end if;
 definition:=replace(definition,'coalesce(b.payment_status,''reported_paid'')',
  'case when a.booking_id is null then ''reported_paid'' else coalesce(b.payment_status,''unpaid'') end');
 execute definition;
end $$;
notify pgrst,'reload schema';
