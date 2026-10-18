-- Exercises the same RPCs used by complete restaurant setup. No rows are retained.
begin;
do $$
declare
  owner_id uuid; admin_id uuid; destination_id uuid; listing_id uuid; item_id uuid; slot_id uuid;
  missing boolean; queue jsonb; photos jsonb;
begin
  select o.profile_id into owner_id from public.business_owners o join public.profiles p on p.id=o.profile_id
  where p.account_status='active' and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='admin') limit 1;
  select pr.profile_id into admin_id from public.profile_roles pr join public.roles r on r.id=pr.role_id join public.profiles p on p.id=pr.profile_id where r.name='admin' and p.account_status='active' limit 1;
  select id into destination_id from public.destinations where is_active=1 limit 1;
  if owner_id is null or admin_id is null or destination_id is null then raise exception 'Missing restaurant QA fixtures';end if;
  perform set_config('request.jwt.claim.sub',owner_id::text,true);
  missing:=false;
  begin perform public.owner_create_listing('restaurant',destination_id,'QA incomplete restaurant',null,null,p_operating_hours=>' ');
  exception when others then missing:=sqlerrm='Restaurant operating hours are required';end;
  if not missing then raise exception 'Missing restaurant hours accepted';end if;
  listing_id:=public.owner_create_listing('restaurant',destination_id,'QA complete restaurant '||gen_random_uuid()::text,null,null,p_operating_hours=>'Mon–Sat 10:00 AM–9:00 PM');
  if not ('Add at least one available menu item'=any(public.tm_listing_problems(listing_id))) then raise exception 'Menu requirement missing';end if;
  item_id:=public.owner_add_menu_item(listing_id,'QA dish','Mains',399,'Dish description');
  if not ('Add a dish photo for every menu item'=any(public.tm_listing_problems(listing_id))) then raise exception 'Missing dish photos accepted';end if;
  perform public.owner_set_dish_photo(item_id,owner_id::text||'/'||listing_id::text||'/qa-dish.jpg');
  if cardinality(public.tm_listing_problems(listing_id))<>0 then raise exception 'Complete pending restaurant is blocked';end if;
  missing:=false;
  begin perform public.owner_update_details(listing_id,null,null,'',0,null);
  exception when others then missing:=sqlerrm='Restaurant operating hours are required';end;
  if not missing then raise exception 'Operating hours could be cleared';end if;
  slot_id:=public.owner_add_reservation_slot(listing_id,now()+interval '2 days',now()+interval '2 days 90 minutes',20);
  if not exists(select 1 from public.restaurant_slots s where s.id=slot_id and s.restaurant_id=listing_id and s.capacity=20) then raise exception 'Owner could not add slots to a pending restaurant';end if;
  missing:=false;
  begin perform public.owner_add_reservation_slot(listing_id,now()+interval '2 days',now()+interval '2 days 13 hours',20);
  exception when others then missing:=position('Check dates and capacity' in sqlerrm)>0;end;
  if not missing then raise exception 'Slot duration limit missing';end if;
  missing:=false;
  begin perform public.admin_review_queue();exception when others then missing:=sqlerrm='Administrator access required';end;
  if not missing then raise exception 'Owner could access admin review queue';end if;
  perform set_config('request.jwt.claim.sub',admin_id::text,true);
  select value into queue from jsonb_array_elements(public.admin_review_queue()) where value->>'id'=listing_id::text;
  if queue is null or queue->'menu'->0->>'id'<>item_id::text or queue->'menu'->0->>'description'<>'Dish description' or not (queue->'menu'->0->>'has_photo')::boolean then raise exception 'Admin menu metadata missing';end if;
  if queue->'slots'->0->>'id'<>slot_id::text then raise exception 'Admin reservation slots missing';end if;
  photos:=public.admin_listing_photos(listing_id);
  if photos->0->>'menu_item_id'<>item_id::text or photos->0->>'menu_name'<>'QA dish' then raise exception 'Admin dish photo metadata missing';end if;
  if has_function_privilege('anon','public.admin_review_queue()','execute') or has_function_privilege('anon','public.owner_create_listing(text,uuid,text,text,text,time,time,text,numeric,numeric,text,text)','execute') then raise exception 'Anonymous RPC access';end if;
end $$;
rollback;
