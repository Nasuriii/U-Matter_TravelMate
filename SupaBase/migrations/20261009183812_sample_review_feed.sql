-- Preview reviews are separate from authentic ratings. Existing review eligibility and grants remain intact.
create or replace function travelmate_ui.place_reviews(p_destination uuid,p_listing uuid,p_offset integer)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); kind text; allowed boolean:=false; booking uuid; own jsonb; result jsonb;
begin
 if (p_destination is null)=(p_listing is null) or p_offset is null or p_offset<0 then raise exception 'Choose one place and a valid page'; end if;
 if p_destination is not null then
  if not exists(select 1 from public.destinations where id=p_destination and is_active=1) then raise exception 'Destination unavailable'; end if;
  kind:='destination';
 else
  select listing_type into kind from public.business_listings where id=p_listing and status='approved';
  if not found then raise exception 'Listing unavailable'; end if;
 end if;
 if u is not null and public.tm_has_role('traveler') and not public.tm_has_role('business_owner') and not public.tm_has_role('admin') then
  booking:=travelmate_ui.review_booking(p_listing,u);
  allowed:=kind in ('destination','attraction') or booking is not null;
  select jsonb_build_object('rating',rating,'text',review_text,'status',status) into own from public.reviews where profile_id=u and (destination_id=p_destination or listing_id=p_listing);
  if own is not null and own->>'status'<>'published' then allowed:=false; end if;
 end if;
 select jsonb_build_object('total',count(*),'average',round(avg(rating),1)) into result from public.reviews r join public.profiles p on p.id=r.profile_id where r.status='published' and p.full_name not like '%(Demo)%' and (r.destination_id=p_destination or r.listing_id=p_listing);
 return result||jsonb_build_object('can_review',allowed,'verified_eligible',booking is not null,'mine',own,'kind',kind,'items',coalesce((
  select jsonb_agg(x.j order by x.created_at desc,x.id) from (
   select r.id,r.created_at,jsonb_build_object('id',r.id,'rating',r.rating,'text',r.review_text,'created_at',r.created_at,
    'author',coalesce(nullif(split_part(btrim(p.full_name),' ',1),''),'Traveler'),
    'verified',r.booking_id is not null and exists(select 1 from public.bookings b left join public.hotel_bookings h on h.booking_id=b.id left join public.restaurant_bookings rb on rb.booking_id=b.id left join public.restaurant_slots s on s.id=rb.slot_id where b.id=r.booking_id and b.profile_id=r.profile_id and b.status='completed' and (b.total_amount=0 or b.payment_status='paid') and travelmate_ui.booking_visit_end(b.id)<=now() and coalesce(h.hotel_id,s.restaurant_id)=r.listing_id)) j
   from public.reviews r join public.profiles p on p.id=r.profile_id where r.status='published' and p.full_name not like '%(Demo)%' and (r.destination_id=p_destination or r.listing_id=p_listing)
   order by r.created_at desc,r.id limit 10 offset p_offset
  )x),'[]'::jsonb),'sample_items',coalesce((
 select jsonb_agg(x.j order by x.created_at desc,x.id) from (
  select r.id,r.created_at,jsonb_build_object('id',r.id,'rating',r.rating,'text',r.review_text,'created_at',r.created_at,
   'author',coalesce(nullif(split_part(btrim(p.full_name),' ',1),''),'Traveler'),'verified',false,'sample',true) j
  from public.reviews r join public.profiles p on p.id=r.profile_id
  where r.status='published' and p.full_name like '%(Demo)%' and (r.destination_id=p_destination or r.listing_id=p_listing)
  order by r.created_at desc,r.id limit 3
 )x),'[]'::jsonb));
end $$;

notify pgrst,'reload schema';
