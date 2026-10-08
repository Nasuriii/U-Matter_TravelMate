-- Traveler reviews: one per destination/business; verification is derived from completed bookings.
alter table public.reviews add column booking_id uuid references public.bookings(id) on delete restrict;
create index reviews_booking_idx on public.reviews(booking_id) where booking_id is not null;
create index reviews_destination_feed_idx on public.reviews(destination_id,created_at desc,id) where status='published';
create index reviews_listing_feed_idx on public.reviews(listing_id,created_at desc,id) where status='published';
alter table public.reviews enable row level security;
revoke insert,update,delete on public.reviews from anon,authenticated;

-- Internal helpers are inaccessible to API roles; caller identity is never an argument to a public RPC.
create function travelmate_ui.booking_visit_end(p_booking uuid)
returns timestamptz language sql stable security definer set search_path='' as $$
 select coalesce((h.check_out+coalesce(ht.check_out_time,'12:00'::time)) at time zone 'Asia/Manila',s.ends_at)
 from public.bookings b left join public.hotel_bookings h on h.booking_id=b.id
 left join public.hotels ht on ht.hotel_id=h.hotel_id
 left join public.restaurant_bookings r on r.booking_id=b.id left join public.restaurant_slots s on s.id=r.slot_id
 where b.id=p_booking;
$$;
create function travelmate_ui.review_booking(p_listing uuid,p_profile uuid)
returns uuid language sql stable security definer set search_path='' as $$
 select b.id from public.bookings b
 left join public.hotel_bookings h on h.booking_id=b.id
 left join public.restaurant_bookings r on r.booking_id=b.id left join public.restaurant_slots s on s.id=r.slot_id
 where b.profile_id=p_profile and b.status='completed' and (b.total_amount=0 or b.payment_status='paid')
 and coalesce(h.hotel_id,s.restaurant_id)=p_listing and travelmate_ui.booking_visit_end(b.id)<=now()
 order by b.updated_at desc,b.id limit 1;
$$;
revoke all on function travelmate_ui.booking_visit_end(uuid),travelmate_ui.review_booking(uuid,uuid) from public,anon,authenticated;

create function travelmate_ui.place_reviews(p_destination uuid,p_listing uuid,p_offset integer)
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
 select jsonb_build_object('total',count(*),'average',round(avg(rating),1)) into result from public.reviews where status='published' and (destination_id=p_destination or listing_id=p_listing);
 return result||jsonb_build_object('can_review',allowed,'verified_eligible',booking is not null,'mine',own,'kind',kind,'items',coalesce((
  select jsonb_agg(x.j order by x.created_at desc,x.id) from (
   select r.id,r.created_at,jsonb_build_object('id',r.id,'rating',r.rating,'text',r.review_text,'created_at',r.created_at,
    'author',coalesce(nullif(split_part(btrim(p.full_name),' ',1),''),'Traveler'),
    'verified',r.booking_id is not null and exists(select 1 from public.bookings b left join public.hotel_bookings h on h.booking_id=b.id left join public.restaurant_bookings rb on rb.booking_id=b.id left join public.restaurant_slots s on s.id=rb.slot_id where b.id=r.booking_id and b.profile_id=r.profile_id and b.status='completed' and (b.total_amount=0 or b.payment_status='paid') and travelmate_ui.booking_visit_end(b.id)<=now() and coalesce(h.hotel_id,s.restaurant_id)=r.listing_id)) j
   from public.reviews r join public.profiles p on p.id=r.profile_id where r.status='published' and (r.destination_id=p_destination or r.listing_id=p_listing)
   order by r.created_at desc,r.id limit 10 offset p_offset
  )x),'[]'::jsonb));
end $$;
create function travelmate_ui.save_traveler_review(p_destination uuid,p_listing uuid,p_rating integer,p_text text)
returns uuid language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); feed jsonb; bid uuid; rid uuid;
begin
 if u is null or not public.tm_has_role('traveler') or public.tm_has_role('business_owner') or public.tm_has_role('admin') then raise exception 'An active traveler account is required'; end if;
 if p_rating is null or p_rating<1 or p_rating>5 or length(btrim(coalesce(p_text,'')))<10 or length(p_text)>2000 then raise exception 'Choose 1–5 stars and write between 10 and 2,000 characters'; end if;
 -- Serialize writes for the same traveler/place, including concurrent first submissions.
 perform pg_advisory_xact_lock(hashtextextended(u::text||coalesce(p_destination,p_listing)::text,0));
 feed:=travelmate_ui.place_reviews(p_destination,p_listing,0);
 if not (feed->>'can_review')::boolean then raise exception 'A completed, paid visit is required to review this business, or your review is awaiting moderation'; end if;
 bid:=travelmate_ui.review_booking(p_listing,u);
 select id into rid from public.reviews where profile_id=u and (destination_id=p_destination or listing_id=p_listing) for update;
 if rid is null then
  insert into public.reviews(id,profile_id,destination_id,listing_id,rating,review_text,status,booking_id,created_at,updated_at)
  values(gen_random_uuid(),u,p_destination,p_listing,p_rating,btrim(p_text),'published',bid,now(),now()) returning id into rid;
 else
  update public.reviews set rating=p_rating,review_text=btrim(p_text),booking_id=bid,updated_at=now() where id=rid;
 end if;
 return rid;
end $$;
create function travelmate_ui.complete_owner_booking(p_booking uuid)
returns void language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); b public.bookings; lid uuid;
begin
 if u is null or not public.tm_has_role('business_owner') or public.tm_has_role('admin') then raise exception 'Business owner access required'; end if;
 select * into b from public.bookings where id=p_booking for update;
 select coalesce(h.hotel_id,s.restaurant_id) into lid from public.bookings bk
 left join public.hotel_bookings h on h.booking_id=bk.id left join public.restaurant_bookings r on r.booking_id=bk.id
 left join public.restaurant_slots s on s.id=r.slot_id where bk.id=p_booking;
 if not exists(select 1 from public.business_listings l join public.business_owners o on o.id=l.owner_id where l.id=lid and o.profile_id=u) then raise exception 'Reservation not found for your business'; end if;
 if b.status='completed' then return; end if;
 if b.status<>'confirmed' or (b.total_amount>0 and b.payment_status is distinct from 'paid') then raise exception 'Only a confirmed, paid reservation can be completed'; end if;
 if travelmate_ui.booking_visit_end(p_booking) is null or travelmate_ui.booking_visit_end(p_booking)>now() then raise exception 'Wait until the stay or reservation has ended'; end if;
 update public.bookings set status='completed',updated_at=now() where id=p_booking;
 insert into public.notifications(id,profile_id,message,created_at) values(gen_random_uuid(),b.profile_id,'Your visit is complete. Open Bookings & tickets to review your experience.',now());
end $$;
create function public.place_reviews(p_destination uuid default null,p_listing uuid default null,p_offset integer default 0)
returns jsonb language sql stable security invoker set search_path='' as $$ select travelmate_ui.place_reviews(p_destination,p_listing,p_offset); $$;
create function public.save_traveler_review(p_destination uuid,p_listing uuid,p_rating integer,p_text text)
returns uuid language sql security invoker set search_path='' as $$ select travelmate_ui.save_traveler_review(p_destination,p_listing,p_rating,p_text); $$;
create function public.complete_owner_booking(p_booking uuid)
returns void language sql security invoker set search_path='' as $$ select travelmate_ui.complete_owner_booking(p_booking); $$;
revoke all on function travelmate_ui.place_reviews(uuid,uuid,integer),public.place_reviews(uuid,uuid,integer),travelmate_ui.save_traveler_review(uuid,uuid,integer,text),public.save_traveler_review(uuid,uuid,integer,text),travelmate_ui.complete_owner_booking(uuid),public.complete_owner_booking(uuid) from public,anon,authenticated;
grant usage on schema travelmate_ui to anon,authenticated;
grant execute on function travelmate_ui.place_reviews(uuid,uuid,integer),public.place_reviews(uuid,uuid,integer) to anon,authenticated;
grant execute on function travelmate_ui.save_traveler_review(uuid,uuid,integer,text),public.save_traveler_review(uuid,uuid,integer,text),travelmate_ui.complete_owner_booking(uuid),public.complete_owner_booking(uuid) to authenticated;
notify pgrst,'reload schema';
-- Booking references stay private; existing public review queries retain their original columns.
revoke select on public.reviews from anon,authenticated;
grant select(id,profile_id,destination_id,listing_id,rating,review_text,status,created_at,updated_at) on public.reviews to anon,authenticated;

