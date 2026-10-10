-- Exercise linked bookings and moderation without retaining any synthetic records.
begin;
select set_config('request.jwt.claims',jsonb_build_object('sub',(select p.id from public.profiles p where p.account_status='active' and p.full_name like '%(Demo)%' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) limit 1),'role','authenticated')::text,true);
select set_config('test.hotel',(select l.id::text from public.business_listings l join public.business_owners o on o.id=l.owner_id where l.is_sample and l.listing_type='hotel' and l.status='approved' limit 1),true);
select set_config('test.owner',(select o.profile_id::text from public.business_listings l join public.business_owners o on o.id=l.owner_id where l.id=current_setting('test.hotel')::uuid),true);
insert into public.rooms(hotel_id,room_number,room_type,max_guests,base_nightly_rate,operational_status) values(current_setting('test.hotel')::uuid,'TEST-'||substr(gen_random_uuid()::text,1,8),'Synthetic test room',2,1500,'available');
select set_config('test.room',(select id::text from public.rooms where hotel_id=current_setting('test.hotel')::uuid and room_type='Synthetic test room' order by id limit 1),true);
select set_config('test.real',(select id::text from public.business_listings where not is_sample and status='approved' and listing_type='hotel' limit 1),true);
select set_config('test.restaurant',(select id::text from public.business_listings where is_sample and status='approved' and listing_type='restaurant' limit 1),true);
insert into public.restaurant_slots(restaurant_id,starts_at,ends_at,capacity,is_open) values(current_setting('test.restaurant')::uuid,now()+interval '1 day',now()+interval '1 day 1 hour',3,1);
select set_config('test.slot',(select id::text from public.restaurant_slots where restaurant_id=current_setting('test.restaurant')::uuid and capacity=3 and starts_at=now()+interval '1 day' limit 1),true);
select set_config('test.other',(select p.id::text from public.profiles p where p.account_status='active' and p.id<>public.tm_active_profile_id() and p.full_name like '%(Demo)%' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') limit 1),true);
set local role authenticated;
do $$ declare bid uuid; key text:=gen_random_uuid()::text; rejected boolean; feed jsonb; clean text; bad text; begin
 bid:=public.reserve_my_booking(current_setting('test.hotel')::uuid,current_setting('test.room')::uuid,null,current_date+1,current_date+3,2,'Synthetic Traveler','test@example.invalid',null,key);
 feed:=public.workspace_reservations();
 if not exists(select 1 from jsonb_array_elements(feed) x where x->>'id'=bid::text and (x->>'is_test')::boolean and x->>'status'='confirmed' and x->>'payment_status'='unpaid' and (x->>'total_amount')::numeric=3000 and x->>'listing_id'=current_setting('test.hotel')) then raise exception 'Linked booking not returned correctly';end if;
 if bid<>public.reserve_my_booking(current_setting('test.hotel')::uuid,current_setting('test.room')::uuid,null,current_date+1,current_date+3,2,'Synthetic Traveler','test@example.invalid',null,key) then raise exception 'Idempotency failed';end if;
 rejected:=false;begin perform public.reserve_my_booking(current_setting('test.hotel')::uuid,current_setting('test.room')::uuid,null,current_date+1,current_date+3,2,'Synthetic Traveler','test@example.invalid',null,gen_random_uuid()::text);exception when others then if sqlerrm='This room is already reserved for those dates' then rejected:=true;else raise;end if;end;
 if not rejected then raise exception 'Room was double booked';end if;
 rejected:=false;begin perform public.reserve_my_booking(current_setting('test.hotel')::uuid,current_setting('test.room')::uuid,null,current_date+4,current_date+5,3,'Synthetic Traveler','test@example.invalid',null,gen_random_uuid()::text);exception when others then rejected:=true;end;
 if not rejected then raise exception 'Guest capacity exceeded';end if;
 perform set_config('test.booking',bid::text,true);
 foreach bad in array array['This is fucking terrible.','This is sh1t service.','This is f.u.c.k service.','G@go and rude.','Putang ina rude service.','Putanginamo rude service.','Tanginamo rude service.'] loop if not public.review_has_inappropriate_words(bad) then raise exception 'Curse not rejected: %',bad;end if;end loop;
 foreach clean in array array['The room was dirty and the service was terrible.','Please improve your service.','The shiitake soup was delicious.','Our Scunthorpe trip was lovely.'] loop if public.review_has_inappropriate_words(clean) then raise exception 'Ordinary criticism rejected: %',clean;end if;end loop;
end $$;
do $$ declare bid uuid; rejected boolean:=false;begin
 bid:=public.reserve_my_booking(current_setting('test.restaurant')::uuid,null,current_setting('test.slot')::uuid,null,null,2,'Synthetic Traveler','test@example.invalid',null,gen_random_uuid()::text);
 perform set_config('test.table_booking',bid::text,true);
 if not exists(select 1 from jsonb_array_elements(public.workspace_reservations()) x where x->>'id'=bid::text and x->>'booking_type'='restaurant' and (x->>'is_test')::boolean and x->>'status'='confirmed') then raise exception 'Restaurant reservation not linked';end if;
 begin perform public.reserve_my_booking(current_setting('test.restaurant')::uuid,null,current_setting('test.slot')::uuid,null,null,2,'Synthetic Traveler','test@example.invalid',null,gen_random_uuid()::text);exception when others then if sqlerrm='This time slot does not have enough seats' then rejected:=true;else raise;end if;end;
 if not rejected then raise exception 'Restaurant overbooked';end if;
end $$;
select set_config('request.jwt.claims',jsonb_build_object('sub',current_setting('test.other'),'role','authenticated')::text,true);
do $$ declare rejected boolean:=false;begin
 if exists(select 1 from jsonb_array_elements(public.workspace_reservations()) x where x->>'id' in (current_setting('test.booking'),current_setting('test.table_booking'))) then raise exception 'Booking exposed to another traveler';end if;
 begin perform public.cancel_my_booking(current_setting('test.booking')::uuid);exception when others then if sqlerrm='Reservation not found' then rejected:=true;else raise;end if;end;
 if not rejected then raise exception 'Cross-account cancellation allowed';end if;rejected:=false;begin perform public.admin_listing_contact(current_setting('test.hotel')::uuid);exception when others then if sqlerrm='Administrator access required' then rejected:=true;else raise;end if;end;if not rejected then raise exception 'Non-admin could read pending contact details';end if;
end $$;
select set_config('request.jwt.claims',jsonb_build_object('sub',current_setting('test.owner'),'role','authenticated')::text,true);
do $$ begin
 if not exists(select 1 from jsonb_array_elements(public.workspace_reservations()) x where x->>'id'=current_setting('test.booking') and x->>'listing_id'=current_setting('test.hotel')) then raise exception 'Owner cannot see booking under listing';end if;
end $$;
do $$ declare rejected boolean:=false; begin
 begin perform public.complete_owner_booking(current_setting('test.booking')::uuid);exception when others then if sqlerrm='Wait until the stay or reservation has ended' then rejected:=true;else raise;end if;end;
 if not rejected then raise exception 'Future reservation completed too early';end if;
 perform public.owner_set_listing_contact(current_setting('test.hotel')::uuid,null,'test@example.invalid','https://example.invalid');
 if not exists(select 1 from public.business_listings where id=current_setting('test.hotel')::uuid and contact_email='test@example.invalid' and status='pending') then raise exception 'Owner contact not saved for moderation';end if;
end $$;
reset role;
update public.hotel_bookings set check_in=current_date-3,check_out=current_date-1 where booking_id=current_setting('test.booking')::uuid;
set local role authenticated;
select public.complete_owner_booking(current_setting('test.booking')::uuid);
do $$ begin
 if not exists(select 1 from jsonb_array_elements(public.workspace_reservations()) x where x->>'id'=current_setting('test.booking') and x->>'status'='completed') then raise exception 'Completion not saved';end if;
end $$;
reset role;
-- Restore the reservation for the later cancellation check.
update public.bookings set status='confirmed' where id=current_setting('test.booking')::uuid;
update public.hotel_bookings set check_in=current_date+1,check_out=current_date+3 where booking_id=current_setting('test.booking')::uuid;
update public.business_listings set status='approved' where id=current_setting('test.hotel')::uuid;
select set_config('request.jwt.claims',jsonb_build_object('sub',(select p.id from public.profiles p where p.account_status='active' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='admin') limit 1),'role','authenticated')::text,true);
set local role authenticated;
do $$ begin if public.admin_listing_contact(current_setting('test.hotel')::uuid)->>'email' is distinct from 'test@example.invalid' then raise exception 'Admin cannot review submitted contact details';end if;end $$;
reset role;
-- Public destination fields remain readable under existing approval policies.
set local role anon;
select address,contact_phone,contact_email,contact_website from public.destinations where is_active=1 limit 1;
select contact_phone,contact_email,contact_website from public.business_listings where status='approved' limit 1;
reset role;
-- A direct review write also goes through the profanity trigger, even outside the browser.
do $$ declare rejected boolean:=false; begin
 begin insert into public.reviews(profile_id,destination_id,rating,review_text,status) values((select id from public.profiles limit 1),(select id from public.destinations where is_active=1 limit 1),1,'This is f.u.c.k service.','published');exception when others then if sqlerrm='REVIEW_INAPPROPRIATE_WORDS' then rejected:=true;else raise;end if;end;
 if not rejected then raise exception 'Direct profanity insert bypassed trigger';end if;
 begin update public.bookings set payment_status='paid' where id=current_setting('test.booking')::uuid;raise exception 'Test booking marked paid';exception when check_violation then null;end;
end $$;
-- Return to original traveler, cancel and ensure inventory can be reserved again.
select set_config('request.jwt.claims',jsonb_build_object('sub',(select profile_id from public.bookings where id=current_setting('test.booking')::uuid),'role','authenticated')::text,true);
set local role authenticated;
do $$ declare bid uuid; begin
 perform public.cancel_my_booking(current_setting('test.booking')::uuid);
 if not exists(select 1 from jsonb_array_elements(public.workspace_reservations()) x where x->>'id'=current_setting('test.booking') and x->>'status'='cancelled') then raise exception 'Cancellation not saved';end if;
 bid:=public.reserve_my_booking(current_setting('test.hotel')::uuid,current_setting('test.room')::uuid,null,current_date+1,current_date+3,2,'Synthetic Traveler','test@example.invalid',null,gen_random_uuid()::text);
 if bid is null then raise exception 'Room was not released';end if;
end $$;
rollback;
select 'Linked traveler/owner bookings, restaurant seats, room conflicts, account isolation, owner completion/contact, cancellation, no test payments and profanity enforcement passed' result;
