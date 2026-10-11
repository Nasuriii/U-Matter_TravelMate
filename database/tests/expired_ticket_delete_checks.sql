-- Run as the database administrator; every fixture and deletion is rolled back.
begin;
select set_config('test.traveler', (select p.id::text from public.profiles p
  where p.account_status = 'active' and exists (select 1 from public.profile_roles pr
    join public.roles r on r.id = pr.role_id where pr.profile_id = p.id and r.name = 'traveler')
  and not exists (select 1 from public.profile_roles pr join public.roles r on r.id = pr.role_id
    where pr.profile_id = p.id and r.name in ('admin','business_owner')) limit 1), true);
select set_config('test.hotel', (select h.hotel_id::text from public.hotels h
  join public.business_listings l on l.id = h.hotel_id
  join public.business_owners o on o.id = l.owner_id
  join public.profiles p on p.id = o.profile_id
  where p.account_status = 'active' and exists (select 1 from public.profile_roles pr
    join public.roles r on r.id = pr.role_id where pr.profile_id = p.id and r.name = 'business_owner') limit 1), true);
select set_config('test.owner', (select o.profile_id::text from public.business_listings l
  join public.business_owners o on o.id = l.owner_id where l.id = current_setting('test.hotel')::uuid), true);
select set_config('test.admin', (select p.id::text from public.profiles p
  join public.profile_roles pr on pr.profile_id = p.id join public.roles r on r.id = pr.role_id
  where p.account_status = 'active' and r.name = 'admin' limit 1), true);

do $$
declare bid uuid; item text;
begin
  if nullif(current_setting('test.traveler'), '') is null
    or nullif(current_setting('test.owner'), '') is null
    or nullif(current_setting('test.admin'), '') is null then
    raise exception 'Active traveler, hotel owner, and administrator fixtures are required';
  end if;
  foreach item in array array['expired', 'cancelled', 'elapsed', 'active', 'paid', 'checkout', 'active_checkout'] loop
    insert into public.bookings(profile_id, booking_type, guest_name, guest_email, guest_count,
      total_amount, status, payment_status, hold_expires_at, created_at, idempotency_key, stripe_session_id)
    values (current_setting('test.traveler')::uuid, 'hotel', 'Ticket deletion check', 'test@example.invalid', 1,
      100, case when item in ('active','active_checkout','elapsed','checkout') then 'pending' when item = 'cancelled' then 'cancelled' else 'expired' end,
      case when item = 'paid' then 'paid' else 'unpaid' end,
      case when item in ('active','active_checkout') then now() + interval '1 hour' else now() - interval '1 hour' end,
      now() - interval '2 hours', 'ticket-delete-check-' || gen_random_uuid()::text,
      case when item in ('checkout','active_checkout') then 'cs_ticket_delete_check_' || item else null end)
    returning id into bid;
    insert into public.hotel_bookings(booking_id, hotel_id, check_in, check_out)
    values (bid, current_setting('test.hotel')::uuid, current_date + 1, current_date + 2);
    perform set_config('test.' || item, bid::text, true);
  end loop;
end $$;

select set_config('request.jwt.claims', jsonb_build_object('sub', current_setting('test.traveler'), 'role', 'authenticated')::text, true);
set local role authenticated;
do $$
declare item text; blocked boolean; feed jsonb;
begin
  feed := public.workspace_reservations();
  if not exists (select 1 from jsonb_array_elements(feed) b where b->>'id' = current_setting('test.expired') and (b->>'can_delete')::boolean) then
    raise exception 'Expired ticket is not deletable';
  end if;
  if not exists (select 1 from jsonb_array_elements(feed) b where b->>'id' = current_setting('test.active') and (b->>'can_cancel')::boolean)
    or exists (select 1 from jsonb_array_elements(feed) b where b->>'id' in (current_setting('test.active_checkout'),current_setting('test.checkout'),current_setting('test.paid')) and (b->>'can_cancel')::boolean) then
    raise exception 'Cancellation actions do not match eligible reservations';
  end if;
  foreach item in array array['active', 'paid', 'active_checkout'] loop
    blocked := false;
    begin
      perform public.delete_my_expired_booking(current_setting('test.' || item)::uuid);
    exception when others then
      if sqlerrm like 'Only expired or cancelled, unpaid tickets%' then blocked := true; else raise; end if;
    end;
    if not blocked then raise exception 'Protected booking deletion allowed: %', item; end if;
    if exists (select 1 from jsonb_array_elements(feed) b where b->>'id' = current_setting('test.' || item) and (b->>'can_delete')::boolean) then
      raise exception 'Protected booking advertised as deletable: %', item;
    end if;
  end loop;
  -- Repeated requests are safe; elapsed holds without checkout may also be removed.
  perform public.delete_my_expired_booking(current_setting('test.expired')::uuid);
  perform public.delete_my_expired_booking(current_setting('test.expired')::uuid);
  perform public.delete_my_expired_booking(current_setting('test.elapsed')::uuid);
  perform public.delete_my_expired_booking(current_setting('test.checkout')::uuid);
  perform public.delete_my_expired_booking(current_setting('test.cancelled')::uuid);
  feed := public.workspace_reservations();
  if exists (select 1 from jsonb_array_elements(feed) b where b->>'id' in (current_setting('test.expired'), current_setting('test.elapsed'), current_setting('test.checkout'), current_setting('test.cancelled'))) then
    raise exception 'Deleted ticket still visible to traveler';
  end if;
  begin
    perform public.delete_my_expired_booking(gen_random_uuid());
    raise exception 'Unknown booking deletion allowed';
  exception when others then if sqlerrm <> 'Your booking was not found' then raise; end if; end;
end $$;
reset role;

-- The original reservation and business's hotel record are retained.
do $$ begin
  if not exists (select 1 from public.bookings b join public.hotel_bookings h on h.booking_id = b.id
    where b.id = current_setting('test.expired')::uuid) then raise exception 'Business record was deleted'; end if;
  if (select status from public.bookings where id = current_setting('test.elapsed')::uuid) <> 'expired' then
    raise exception 'Deleted elapsed hold is still pending';
  end if;
  -- Match the delayed checkout compare-and-set: it must update no rows.
  update public.bookings set stripe_session_id = 'cs_delayed_checkout_check'
    where id = current_setting('test.elapsed')::uuid and status = 'pending'
      and payment_status = 'unpaid' and stripe_session_id is null;
  if found then raise exception 'Delayed checkout reactivated a deleted booking'; end if;
  if (select count(*) from travelmate_ui.deleted_booking_tickets where profile_id = current_setting('test.traveler')::uuid
    and booking_id in (current_setting('test.expired')::uuid, current_setting('test.elapsed')::uuid, current_setting('test.checkout')::uuid, current_setting('test.cancelled')::uuid)) <> 4 then
    raise exception 'Deletion was not persisted or duplicate deletion added rows';
  end if;
  if has_function_privilege('anon','public.delete_my_expired_booking(uuid)','execute')
    or has_table_privilege('authenticated','travelmate_ui.deleted_booking_tickets','insert') then
    raise exception 'Client bypass permissions exist';
  end if;
end $$;

select set_config('request.jwt.claims', jsonb_build_object('sub', current_setting('test.owner'), 'role', 'authenticated')::text, true);
set local role authenticated;
do $$ begin
  if not exists (select 1 from jsonb_array_elements(public.workspace_reservations()) b
    where b->>'id' = current_setting('test.expired') and not (b->>'can_delete')::boolean) then
    raise exception 'Traveler deletion changed owner history';
  end if;
  begin
    perform public.delete_my_expired_booking(current_setting('test.expired')::uuid);
    raise exception 'Owner was able to delete traveler ticket';
  exception when others then if sqlerrm <> 'An active traveler account is required' then raise; end if; end;
end $$;
reset role;

select set_config('request.jwt.claims', jsonb_build_object('sub', current_setting('test.admin'), 'role', 'authenticated')::text, true);
set local role authenticated;
do $$ begin
  if not exists (select 1 from jsonb_array_elements(public.workspace_reservations()) b where b->>'id' = current_setting('test.expired')) then
    raise exception 'Traveler deletion changed administrator history';
  end if;
end $$;
reset role;

-- Removal must not release an attached checkout or hide a subsequent payment.
do $$ begin
  if (select status from public.bookings where id = current_setting('test.checkout')::uuid) <> 'pending'
    or (select stripe_session_id from public.bookings where id = current_setting('test.checkout')::uuid) is null then
    raise exception 'History removal changed an attached checkout';
  end if;
  update public.bookings set status = 'confirmed', payment_status = 'paid', stripe_payment_intent_id = 'pi_history_check'
    where id = current_setting('test.checkout')::uuid;
end $$;
select set_config('request.jwt.claims', jsonb_build_object('sub', current_setting('test.traveler'), 'role', 'authenticated')::text, true);
set local role authenticated;
do $$ begin
  if not exists (select 1 from jsonb_array_elements(public.workspace_reservations()) b
    where b->>'id' = current_setting('test.checkout') and not (b->>'can_delete')::boolean
      and not (b->>'can_cancel')::boolean and b->>'payment_status' = 'paid') then
    raise exception 'Late payment was hidden from traveler history';
  end if;
end $$;
reset role;

-- A different active traveler cannot delete the first traveler's booking.
select set_config('test.other', (select p.id::text from public.profiles p
  where p.account_status = 'active' and p.id <> current_setting('test.traveler')::uuid
  and exists (select 1 from public.profile_roles pr join public.roles r on r.id = pr.role_id
    where pr.profile_id = p.id and r.name = 'traveler')
  and not exists (select 1 from public.profile_roles pr join public.roles r on r.id = pr.role_id
    where pr.profile_id = p.id and r.name in ('admin','business_owner')) limit 1), true);
select set_config('request.jwt.claims', jsonb_build_object('sub', current_setting('test.other'), 'role', 'authenticated')::text, true);
set local role authenticated;
do $$ begin
  begin
    perform public.delete_my_expired_booking(current_setting('test.expired')::uuid);
    raise exception 'Cross-account deletion allowed';
  exception when others then if sqlerrm <> 'Your booking was not found' then raise; end if; end;
end $$;
reset role;
rollback;
