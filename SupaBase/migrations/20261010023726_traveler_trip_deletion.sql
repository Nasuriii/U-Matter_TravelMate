-- Delete one owned itinerary atomically; bookings and payment records are independent.
create or replace function public.delete_my_trip(p_trip uuid)
returns void language plpgsql security invoker set search_path='' as $$
begin
 if public.tm_active_profile_id() is null or not public.tm_has_role('traveler') or public.tm_has_role('admin') or public.tm_has_role('business_owner') then
  raise exception 'Traveler workspace required';
 end if;
 perform 1 from public.trips where id=p_trip and profile_id=(select public.tm_active_profile_id()) for update;
 if not found then raise exception 'Trip not found or no longer available';end if;
 delete from public.search_history where trip_id=p_trip and profile_id=(select public.tm_active_profile_id());
 delete from public.trip_items where trip_id=p_trip;
 -- Day notes use ON DELETE CASCADE. All statements roll back if any restriction fails.
 delete from public.trips where id=p_trip and profile_id=(select public.tm_active_profile_id());
 if not found then raise exception 'Trip could not be deleted';end if;
end $$;
revoke all on function public.delete_my_trip(uuid) from public,anon;
grant execute on function public.delete_my_trip(uuid) to authenticated;
