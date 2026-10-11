-- Ticket deletion affects the traveler's history only. Business, payment,
-- inventory, and reporting records must keep their original booking IDs.
create table travelmate_ui.deleted_booking_tickets (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  booking_id uuid not null references public.bookings(id) on delete cascade,
  deleted_at timestamptz not null default now(),
  primary key (profile_id, booking_id)
);
create index deleted_booking_tickets_booking_id_idx
  on travelmate_ui.deleted_booking_tickets(booking_id);
alter table travelmate_ui.deleted_booking_tickets enable row level security;
-- Private storage: authenticated clients use the guarded RPC, never this table.
revoke all on travelmate_ui.deleted_booking_tickets from public, anon, authenticated;

create function travelmate_ui.delete_expired_booking_ticket(p_booking uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  u uuid := public.tm_active_profile_id();
  b public.bookings;
begin
  if u is null or not public.tm_has_role('traveler')
     or public.tm_is_admin() or public.tm_has_role('business_owner') then
    raise exception 'An active traveler account is required';
  end if;
  -- Serialize against checkout/payment updates before checking eligibility.
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
  insert into travelmate_ui.deleted_booking_tickets(profile_id, booking_id)
  values (u, b.id) on conflict (profile_id, booking_id) do nothing;
end;
$$;

create function public.delete_my_expired_booking(p_booking uuid)
returns void language sql security invoker set search_path = '' as $$
  select travelmate_ui.delete_expired_booking_ticket(p_booking);
$$;
revoke all on function travelmate_ui.delete_expired_booking_ticket(uuid) from public, anon;
revoke all on function public.delete_my_expired_booking(uuid) from public, anon;
grant execute on function travelmate_ui.delete_expired_booking_ticket(uuid) to authenticated;
grant execute on function public.delete_my_expired_booking(uuid) to authenticated;

create or replace function travelmate_ui.reservations()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  u uuid := public.tm_active_profile_id();
  o uuid;
  a boolean;
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
        and coalesce(b.payment_status, 'unpaid') = 'unpaid'
        and b.stripe_payment_intent_id is null
        and (b.status = 'expired' or (
          b.status = 'pending' and b.hold_expires_at <= now() and b.stripe_session_id is null
        ))) as can_delete,
      coalesce(h.check_in::text, s.starts_at::text) starts_at,
      h.check_out ends_at,
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
      o is null and not a and b.profile_id = u and not exists (
        select 1 from travelmate_ui.deleted_booking_tickets d
        where d.profile_id = u and d.booking_id = b.id
      )
    )
    order by b.created_at desc limit 200
  ) row);
end;
$$;
revoke all on function travelmate_ui.reservations() from public, anon;
grant execute on function travelmate_ui.reservations() to authenticated;
notify pgrst, 'reload schema';
