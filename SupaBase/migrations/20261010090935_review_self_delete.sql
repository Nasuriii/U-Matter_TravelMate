-- Published reviews can be removed by their author. Moderation holds cannot be bypassed.
create or replace function travelmate_ui.delete_my_review(p_destination uuid, p_listing uuid)
returns void language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); r public.reviews;
begin
 if u is null or not public.tm_has_role('traveler') or public.tm_has_role('business_owner') or public.tm_has_role('admin') then
  raise exception 'An active traveler account is required';
 end if;
 if (p_destination is null)=(p_listing is null) then raise exception 'Choose one place'; end if;
 perform pg_advisory_xact_lock(hashtextextended(u::text||coalesce(p_destination,p_listing)::text,0));
 select * into r from public.reviews where profile_id=u and (destination_id=p_destination or listing_id=p_listing) for update;
 if not found then raise exception 'Your review was not found'; end if;
 if r.status<>'published' then raise exception 'A review under moderation cannot be removed until review is complete'; end if;
 delete from public.reviews where id=r.id and profile_id=u;
end $$;
create or replace function public.delete_my_review(p_destination uuid default null,p_listing uuid default null)
returns void language sql security invoker set search_path='' as $$ select travelmate_ui.delete_my_review(p_destination,p_listing); $$;
revoke all on function travelmate_ui.delete_my_review(uuid,uuid),public.delete_my_review(uuid,uuid) from public,anon;
grant execute on function travelmate_ui.delete_my_review(uuid,uuid),public.delete_my_review(uuid,uuid) to authenticated;
notify pgrst,'reload schema';
