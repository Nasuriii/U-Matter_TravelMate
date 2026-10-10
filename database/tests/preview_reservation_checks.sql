-- Synthetic tickets only; every insert/update is rolled back.
begin;
select set_config('request.jwt.claims',jsonb_build_object('sub',(select p.id from public.profiles p where p.account_status='active' and p.full_name like '%(Demo)%' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) limit 1),'role','authenticated')::text,true);
select set_config('test.other_user',(select p.id::text from public.profiles p where p.account_status='active' and p.id<>(current_setting('request.jwt.claims')::jsonb->>'sub')::uuid and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) limit 1),true);
select set_config('test.real_listing',coalesce((select id::text from public.business_listings where status='approved' and not is_sample limit 1),''),true);
set local role authenticated;
do $$ declare l uuid; r public.rooms; s public.restaurant_slots; bid uuid; b public.sample_reservations; key text:=gen_random_uuid()::text; rejected boolean:=false; begin
 select bl.id into l from public.business_listings bl join public.rooms rm on rm.hotel_id=bl.id where bl.is_sample and bl.status='approved' and rm.operational_status='available' limit 1;
 select * into r from public.rooms where hotel_id=l and operational_status='available' limit 1;
 bid:=public.save_my_booking_preview(l,r.id,null,current_date+1,current_date+3,1,'Test Traveler','test@example.invalid',key);
 select * into b from public.sample_reservations where id=bid;
 if b.id is null or b.total_amount<>r.base_nightly_rate*2 or b.status<>'reserved' or b.profile_id<>public.tm_active_profile_id() then raise exception 'Snapshot/price validation failed';end if;
 if bid<>public.save_my_booking_preview(l,r.id,null,current_date+1,current_date+3,1,'Test Traveler','test@example.invalid',key) then raise exception 'Retry made a duplicate';end if;
 begin perform public.save_my_booking_preview(l,r.id,null,current_date+1,current_date+3,2,'Test Traveler','test@example.invalid',key);exception when others then rejected:=true;end;
 if not rejected then raise exception 'Different details accepted same key';end if;
 rejected:=false;begin perform public.save_my_booking_preview(l,r.id,null,current_date+1,current_date+3,r.max_guests+1,'Test Traveler','test@example.invalid',gen_random_uuid()::text);exception when others then rejected:=true;end;
 if not rejected then raise exception 'Overcapacity accepted';end if;
 rejected:=false;begin perform public.save_my_booking_preview(l,r.id,null,current_date-1,current_date+3,1,'Test Traveler','test@example.invalid',gen_random_uuid()::text);exception when others then rejected:=true;end;
 if not rejected then raise exception 'Past dates accepted';end if;
 rejected:=false;begin update public.sample_reservations set total_amount=1 where id=bid;exception when insufficient_privilege then rejected:=true;end;
 if not rejected then raise exception 'Client could tamper with amount';end if;
 if current_setting('test.real_listing')<>'' then
  rejected:=false;begin perform public.save_my_booking_preview(current_setting('test.real_listing')::uuid,r.id,null,current_date+1,current_date+3,1,'Test Traveler','test@example.invalid',gen_random_uuid()::text);exception when others then rejected:=true;end;
  if not rejected then raise exception 'Real listing accepted preview flow';end if;
 end if;
 select rs.* into s from public.restaurant_slots rs join public.business_listings bl on bl.id=rs.restaurant_id where bl.is_sample and bl.status='approved' and rs.is_open=1 and rs.starts_at>now() limit 1;
 if s.id is not null then perform public.save_my_booking_preview(s.restaurant_id,null,s.id,null,null,1,'Test Traveler','test@example.invalid',gen_random_uuid()::text);end if;
 perform set_config('test.ticket',bid::text,true);
 update public.sample_reservations set status='cancelled' where id=bid;
 if not exists(select 1 from public.sample_reservations where id=bid and status='cancelled') then raise exception 'Cancel failed';end if;
 rejected:=false;begin update public.sample_reservations set status='reserved' where id=bid;exception when insufficient_privilege then rejected:=true;end;
 if exists(select 1 from public.sample_reservations where id=bid and status<>'cancelled') then raise exception 'Cancelled ticket reopened';end if;
end $$;
select set_config('request.jwt.claims',jsonb_build_object('sub',current_setting('test.other_user'),'role','authenticated')::text,true);
do $$ begin
 if exists(select 1 from public.sample_reservations where id=current_setting('test.ticket')::uuid) then raise exception 'Foreign ticket visible';end if;
 update public.sample_reservations set status='cancelled' where id=current_setting('test.ticket')::uuid;
 if found then raise exception 'Foreign ticket mutable';end if;
end $$;
rollback;
select 'Preview persistence, server pricing, idempotency, invalid input, cancellation and cross-user isolation passed' result;
