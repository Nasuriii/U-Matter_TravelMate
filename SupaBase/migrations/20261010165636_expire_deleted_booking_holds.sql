-- A delayed checkout request may have read a pending booking before its hold
-- elapsed. Finish the expired transition under the same lock as ticket deletion
-- so checkout's conditional UPDATE(status = 'pending') cannot attach a session.
create or replace function travelmate_ui.delete_expired_booking_ticket(p_booking uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  u uuid := public.tm_active_profile_id();
  b public.bookings;
begin
  if u is null or not public.tm_has_role('traveler')
     or public.tm_is_admin() or public.tm_has_role('business_owner') then
    raise exception 'An active traveler account is required';
  end if;
  select * into b from public.bookings where id = p_booking and profile_id = u for update;
  if not found then raise exception 'Your booking was not found'; end if;
  if coalesce(b.payment_status, 'unpaid') <> 'unpaid'
     or b.stripe_payment_intent_id is not null
     or not (b.status = 'expired' or (
       b.status = 'pending' and b.hold_expires_at <= now()
       and b.stripe_session_id is null
     )) then
    raise exception 'Only expired, unpaid bookings without an active checkout can be deleted';
  end if;
  if b.status = 'pending' then
    update public.bookings set status = 'expired', updated_at = now() where id = b.id;
  end if;
  insert into travelmate_ui.deleted_booking_tickets(profile_id, booking_id)
  values (u, b.id) on conflict (profile_id, booking_id) do nothing;
end;
$$;
revoke all on function travelmate_ui.delete_expired_booking_ticket(uuid) from public, anon;
grant execute on function travelmate_ui.delete_expired_booking_ticket(uuid) to authenticated;
notify pgrst, 'reload schema';
