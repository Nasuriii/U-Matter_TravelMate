-- History removal never cancels checkout or releases inventory. If a late
-- payment arrives, the live reservation becomes visible again automatically.
create function travelmate_ui.booking_ticket_is_removable(
  p_status text, p_payment_status text, p_hold_expires timestamptz, p_intent text
) returns boolean language sql stable security invoker set search_path = '' as $$
  select coalesce(coalesce(p_payment_status, 'unpaid') = 'unpaid'
    and p_intent is null
    and (p_status in ('expired', 'cancelled')
      or (p_status = 'pending' and p_hold_expires <= now())), false);
$$;
revoke all on function travelmate_ui.booking_ticket_is_removable(text,text,timestamptz,text)
  from public, anon, authenticated;

create or replace function travelmate_ui.delete_expired_booking_ticket(p_booking uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare u uuid := public.tm_active_profile_id(); b public.bookings;
begin
  if u is null or not public.tm_has_role('traveler')
    or public.tm_is_admin() or public.tm_has_role('business_owner') then
    raise exception 'An active traveler account is required';
  end if;
  select * into b from public.bookings where id = p_booking and profile_id = u for update;
  if not found then raise exception 'Your booking was not found'; end if;
  if not travelmate_ui.booking_ticket_is_removable(b.status, b.payment_status,
    b.hold_expires_at, b.stripe_payment_intent_id) then
    raise exception 'Only expired or cancelled, unpaid tickets can be deleted';
  end if;
  -- Block delayed checkout attachment only when no session is already attached.
  -- An attached session remains subject to the signed payment webhook.
  if b.status = 'pending' and b.stripe_session_id is null then
    update public.bookings set status = 'expired', updated_at = now() where id = b.id;
  end if;
  insert into travelmate_ui.deleted_booking_tickets(profile_id, booking_id)
    values (u, b.id) on conflict (profile_id, booking_id) do nothing;
end;
$$;
revoke all on function travelmate_ui.delete_expired_booking_ticket(uuid) from public, anon;
grant execute on function travelmate_ui.delete_expired_booking_ticket(uuid) to authenticated;

create or replace function travelmate_ui.reservations()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := public.tm_active_profile_id(); o uuid; a boolean;
begin
  if u is null then raise exception 'Sign in to an active account'; end if;
  a := public.tm_is_admin();
  select id into o from public.business_owners
    where profile_id = u and public.tm_has_role('business_owner');
  return (select coalesce(jsonb_agg(row), '[]'::jsonb) from (
    select b.id, b.is_test, b.booking_type, b.guest_name, b.guest_email,
      b.guest_phone, b.guest_count, b.total_amount, b.status, b.payment_status,
      b.created_at, b.hold_expires_at,
      (not a and o is null and b.profile_id = u and public.tm_has_role('traveler')
        and travelmate_ui.booking_ticket_is_removable(b.status, b.payment_status,
          b.hold_expires_at, b.stripe_payment_intent_id)) as can_delete,
      (not a and o is null and b.profile_id = u and public.tm_has_role('traveler')
        and coalesce(b.payment_status, 'unpaid') = 'unpaid'
        and b.stripe_session_id is null and b.stripe_payment_intent_id is null
        and ((b.is_test and b.status = 'confirmed')
          or (b.status = 'pending' and b.hold_expires_at > now()))) as can_cancel,
      coalesce(h.check_in::text, s.starts_at::text) starts_at, h.check_out ends_at,
      regexp_replace(coalesce(lh.name, lr.name), '\s*\(Demo\)\s*', '', 'gi') listing_name,
      coalesce(lh.id, lr.id) listing_id, r.room_type, r.room_number
    from public.bookings b
    left join public.hotel_bookings h on h.booking_id = b.id
    left join public.booking_rooms br on br.booking_id = b.id
    left join public.rooms r on r.id = br.room_id
    left join public.business_listings lh on lh.id = h.hotel_id
    left join public.restaurant_bookings rb on rb.booking_id = b.id
    left join public.restaurant_slots s on s.id = rb.slot_id
    left join public.business_listings lr on lr.id = s.restaurant_id
    where a or (o is not null and (lh.owner_id = o or lr.owner_id = o)) or (
      o is null and not a and b.profile_id = u and (
        not travelmate_ui.booking_ticket_is_removable(b.status, b.payment_status,
          b.hold_expires_at, b.stripe_payment_intent_id)
        or not exists (select 1 from travelmate_ui.deleted_booking_tickets d
          where d.profile_id = u and d.booking_id = b.id)
      )
    ) order by b.created_at desc limit 200
  ) row);
end;
$$;
revoke all on function travelmate_ui.reservations() from public, anon;
grant execute on function travelmate_ui.reservations() to authenticated;
notify pgrst, 'reload schema';
