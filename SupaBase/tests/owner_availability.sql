-- Availability summaries use the same blocking rules as checkout. Roll back every fixture.
begin;
do $$
declare owner_id uuid; traveler_id uuid; dest uuid; hotel uuid; restaurant uuid; room uuid; slot uuid; booking uuid; result jsonb; blocked boolean; day date:=current_date+10;
begin
 select o.profile_id into owner_id from public.business_owners o join public.profiles p on p.id=o.profile_id where p.account_status='active' limit 1;
 select p.id into traveler_id from public.profiles p where p.account_status='active' and p.id<>owner_id and not exists(select 1 from public.business_owners o where o.profile_id=p.id) limit 1;
 select id into dest from public.destinations where is_active=1 limit 1;
 perform set_config('request.jwt.claim.sub',owner_id::text,true);
 hotel:=public.owner_create_listing('hotel',dest,'QA availability hotel',null,null,p_check_in=>'14:00',p_check_out=>'11:00');
 room:=public.owner_add_room(hotel,'QA1','Queen',2,1500);
 result:=public.owner_availability(hotel,day,day+1);
 assert (result->'rooms'->0->>'available')::boolean,'An empty room should be available';
 insert into public.bookings(profile_id,booking_type,guest_name,guest_email,guest_count,total_amount,idempotency_key,status,hold_expires_at)
 values(traveler_id,'hotel','QA guest','qa@example.test',2,1500,gen_random_uuid()::text,'pending',now()+interval '20 minutes') returning id into booking;
 insert into public.hotel_bookings(booking_id,hotel_id,check_in,check_out) values(booking,hotel,day,day+1);
 insert into public.booking_rooms(booking_id,room_id,nightly_rate) values(booking,room,1500);
 assert not (public.owner_availability(hotel,day,day+1)->'rooms'->0->>'available')::boolean,'An active hold must block the room';
 assert (public.owner_availability(hotel,day+1,day+2)->'rooms'->0->>'available')::boolean,'Check-out does not block the next guest';
 update public.bookings set created_at=now()-interval '1 hour',hold_expires_at=now()-interval '1 minute' where id=booking;
 assert (public.owner_availability(hotel,day,day+1)->'rooms'->0->>'available')::boolean,'Expired holds release the room';
 update public.bookings set status='confirmed' where id=booking;
 assert not (public.owner_availability(hotel,day,day+1)->'rooms'->0->>'available')::boolean,'Confirmed stays block the room';
 update public.bookings set status='cancelled' where id=booking;
 assert (public.owner_availability(hotel,day,day+1)->'rooms'->0->>'available')::boolean,'Cancelled stays release the room';
 update public.rooms set operational_status='maintenance' where id=room;
 assert not (public.owner_availability(hotel,day,day+1)->'rooms'->0->>'available')::boolean,'Maintenance rooms cannot be sold';
 restaurant:=public.owner_create_listing('restaurant',dest,'QA availability restaurant',null,null,p_operating_hours=>'Daily 9 AM–9 PM');
 slot:=public.owner_add_reservation_slot(restaurant,now()+interval '10 days',now()+interval '10 days 1 hour',20);
 insert into public.bookings(profile_id,booking_type,guest_name,guest_email,guest_count,total_amount,idempotency_key,status)
 values(traveler_id,'restaurant','QA guest','qa@example.test',3,100,gen_random_uuid()::text,'confirmed') returning id into booking;
 insert into public.restaurant_bookings(booking_id,slot_id) values(booking,slot);
 assert (public.owner_availability(restaurant)->'slots'->0->>'remaining')::integer=17,'Remaining seats must subtract confirmed guests';
 blocked:=false;begin perform public.owner_availability(hotel,day,day);exception when others then blocked:=true;end;assert blocked,'Invalid stay accepted';
 perform set_config('request.jwt.claim.sub',traveler_id::text,true);
 blocked:=false;begin perform public.owner_availability(hotel,day,day+1);exception when insufficient_privilege then blocked:=true;end;assert blocked,'Another account read owner availability';
 assert not has_function_privilege('anon','public.owner_availability(uuid,date,date)','execute'),'Anonymous availability access granted';
 assert not has_function_privilege('anon','travelmate_ui.owner_availability(uuid,date,date)','execute'),'Anonymous private function access granted';
end $$;
rollback;
