-- Run in one transaction after the migration. Every fixture and change rolls back.
begin;
create temp table ui_qa_context as select
 (select p.id from public.profiles p join public.profile_roles pr on pr.profile_id=p.id join public.roles r on r.id=pr.role_id where p.account_status='active' and r.name='traveler' and not exists(select 1 from public.profile_roles x join public.roles y on y.id=x.role_id where x.profile_id=p.id and y.name in ('admin','business_owner')) limit 1) traveler,
 (select p.id from public.profiles p join public.profile_roles pr on pr.profile_id=p.id join public.roles r on r.id=pr.role_id where p.account_status='active' and r.name='admin' limit 1) administrator,
 (select p.id from public.profiles p join public.profile_roles pr on pr.profile_id=p.id join public.roles r on r.id=pr.role_id where p.account_status='active' and r.name='business_owner' and not exists(select 1 from public.profile_roles x join public.roles y on y.id=x.role_id where x.profile_id=p.id and y.name='admin') limit 1) owner,
 gen_random_uuid() hotel,gen_random_uuid() room,gen_random_uuid() restaurant,null::uuid booking,null::uuid slot;
do $$ begin if exists(select 1 from ui_qa_context where traveler is null or administrator is null or owner is null) then raise exception 'Missing test role fixtures'; end if; end $$;
create temp table ui_qa_results(label text);
grant select,update on ui_qa_context to authenticated;
grant select,insert on ui_qa_results to authenticated;
insert into public.business_listings(id,owner_id,destination_id,name,slug,listing_type,status) select c.hotel,o.id,d.id,'QA hotel '||c.hotel,'qa-'||c.hotel,'hotel','approved' from ui_qa_context c join public.business_owners o on o.profile_id=c.owner cross join lateral(select id from public.destinations where is_active=1 limit 1)d;
insert into public.hotels(hotel_id,check_in_time,check_out_time) select hotel,'14:00','11:00' from ui_qa_context;
insert into public.rooms(id,hotel_id,room_number,room_type,max_guests,base_nightly_rate,operational_status) select room,hotel,'QA','Standard',2,1500,'available' from ui_qa_context;
insert into public.business_listings(id,owner_id,destination_id,name,slug,listing_type,status) select c.restaurant,o.id,d.id,'QA restaurant '||c.restaurant,'qa-'||c.restaurant,'restaurant','approved' from ui_qa_context c join public.business_owners o on o.profile_id=c.owner cross join lateral(select id from public.destinations where is_active=1 limit 1)d;
insert into public.restaurants(restaurant_id,operating_hours,reservation_fee) select restaurant,'09:00–21:00',100 from ui_qa_context;
set local role authenticated;
select set_config('request.jwt.claim.sub',(select traveler::text from ui_qa_context),true);
do $$ declare denied boolean:=false; begin
 begin perform public.workspace_overview(); exception when others then denied:=true; end;
 if not denied then raise exception 'Traveler accessed staff analytics'; end if;
 insert into ui_qa_results values('Traveler denied staff analytics');
 denied:=false; begin perform count(*) from travelmate_ui.events; exception when insufficient_privilege then denied:=true; end;
 if not denied then raise exception 'Client could read private events'; end if;
 insert into ui_qa_results values('Private events denied direct client access');
 if has_function_privilege('authenticated','public.settle_booking_payment(uuid,text,bigint,text)','execute') or has_function_privilege('anon','public.reserve_my_booking(uuid,uuid,uuid,date,date,integer,text,text,text,text)','execute') then raise exception 'Unsafe function grants'; end if;
 insert into ui_qa_results values('Anonymous reservation and client payment settlement denied');
end $$;
do $$ declare c ui_qa_context; first_id uuid; second_id uuid; denied boolean:=false; begin
 select * into c from ui_qa_context;
 first_id:=public.reserve_my_booking(c.hotel,c.room,null,current_date+100,current_date+102,2,'QA traveler','qa@example.test',null,'qa-key-'||c.room);
 second_id:=public.reserve_my_booking(c.hotel,c.room,null,current_date+100,current_date+102,2,'QA traveler','qa@example.test',null,'qa-key-'||c.room);
 if first_id<>second_id then raise exception 'Duplicate reservation created'; end if;
 update ui_qa_context set booking=first_id;
 if (select total_amount from public.bookings where id=first_id)<>3000 then raise exception 'Incorrect server total'; end if;
 insert into ui_qa_results values('Hotel reservation: idempotency and server-calculated total');
 begin perform public.reserve_my_booking(c.hotel,c.room,null,current_date+101,current_date+103,1,'QA traveler','qa@example.test',null,'qa-overlap-'||c.room); exception when others then denied:=sqlerrm='This room is already reserved for those dates'; end;
 if not denied then raise exception 'Overlapping reservation accepted'; end if;
 insert into ui_qa_results values('Overlapping room dates rejected');
 denied:=false; begin perform public.reserve_my_booking(c.hotel,c.room,null,current_date+103,current_date+104,3,'QA traveler','qa@example.test',null,'qa-capacity-'||c.room); exception when others then denied:=sqlerrm='Choose an available room with space for all guests'; end;
 if not denied then raise exception 'Room capacity was not checked'; end if;
 insert into ui_qa_results values('Room capacity checked');
end $$;
select set_config('request.jwt.claim.sub',(select owner::text from ui_qa_context),true);
do $$ declare c ui_qa_context; data jsonb; sid uuid; denied boolean:=false; begin
 select * into c from ui_qa_context;
 data:=public.workspace_overview();
 if data->>'role'<>'owner' or (data->>'listings')::integer<>(select count(*) from public.business_listings l join public.business_owners o on o.id=l.owner_id where o.profile_id=c.owner) then raise exception 'Owner analytics not scoped'; end if;
 insert into ui_qa_results values('Owner overview is scoped to own listings');
 if not exists(select 1 from jsonb_array_elements(public.workspace_reservations()) x where x->>'id'=c.booking::text) then raise exception 'Owner cannot see own reservation'; end if;
 insert into ui_qa_results values('Owner can see reservations for own businesses');
 begin perform public.reserve_my_booking(c.hotel,c.room,null,current_date+103,current_date+104,1,'QA owner','qa@example.test',null,'qa-owner-'||c.room); exception when others then denied:=sqlerrm='An active traveler account is required'; end;
 if not denied then raise exception 'Owner was allowed traveler booking'; end if;
 insert into ui_qa_results values('Owner denied traveler booking');
 sid:=public.owner_add_reservation_slot(c.restaurant,now()+interval '5 days',now()+interval '5 days 2 hours',2);
 update ui_qa_context set slot=sid;
 insert into ui_qa_results values('Owner can create own restaurant availability');
end $$;
select set_config('request.jwt.claim.sub',(select traveler::text from ui_qa_context),true);
do $$ declare c ui_qa_context; bid uuid; denied boolean:=false; begin
 select * into c from ui_qa_context;
 bid:=public.reserve_my_booking(c.restaurant,null,c.slot,null,null,2,'QA traveler','qa@example.test',null,'qa-table-'||c.slot);
 begin perform public.reserve_my_booking(c.restaurant,null,c.slot,null,null,1,'QA traveler','qa@example.test',null,'qa-table-full-'||c.slot); exception when others then denied:=sqlerrm='This time slot does not have enough seats'; end;
 if not denied then raise exception 'Restaurant overbooked'; end if;
 insert into ui_qa_results values('Restaurant reservation enforces remaining seats');
 perform public.cancel_my_booking(bid);
 if (select status from public.bookings where id=bid)<>'cancelled' then raise exception 'Cancellation failed'; end if;
 insert into ui_qa_results values('Unpaid hold cancellation works');
end $$;
select set_config('request.jwt.claim.sub',(select administrator::text from ui_qa_context),true);
do $$ declare data jsonb; begin
 data:=public.workspace_overview(); if data->>'role'<>'admin' or (data->>'users')::integer<1 then raise exception 'Admin overview failed'; end if;
 insert into ui_qa_results values('Admin can read aggregate platform overview');
end $$;
reset role;
update public.bookings set stripe_session_id='cs_qa_test' where id=(select booking from ui_qa_context);
set local role authenticated;
select set_config('request.jwt.claim.sub',(select traveler::text from ui_qa_context),true);
do $$ declare denied boolean:=false; begin
 begin perform public.cancel_my_booking((select booking from ui_qa_context)); exception when others then denied:=true; end;
 if not denied then raise exception 'Active Stripe checkout could be cancelled'; end if;
 insert into ui_qa_results values('Active checkout inventory cannot be released early');
end $$;
reset role;
do $$ declare bid uuid:=(select booking from ui_qa_context); denied boolean:=false; begin
 begin perform public.settle_booking_payment(bid,'cs_wrong_session',300000,'pi_qa'); exception when others then denied:=true; end;
 if not denied then raise exception 'Mismatched payment session accepted'; end if;
 insert into ui_qa_results values('Mismatched payment rejected');
 perform public.settle_booking_payment(bid,'cs_qa_test',300000,'pi_qa');
 perform public.settle_booking_payment(bid,'cs_qa_test',300000,'pi_qa');
 if (select status from public.bookings where id=bid)<>'confirmed' or (select count(*) from public.payments where booking_id=bid)<>1 then raise exception 'Payment ledger or idempotency failed'; end if;
 insert into ui_qa_results values('Payment settlement confirms booking and writes one ledger record');
end $$;
select json_build_object('passed',(select count(*) from ui_qa_results),'checks',(select json_agg(label) from ui_qa_results),'fixtures','All fixtures rolled back') as verification;
rollback;
