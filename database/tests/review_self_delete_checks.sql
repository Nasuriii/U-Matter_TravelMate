begin;
select set_config('test.author',(select p.id::text from public.profiles p where p.account_status='active' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) limit 1),true);
select set_config('test.other',(select p.id::text from public.profiles p where p.account_status='active' and p.id<>current_setting('test.author')::uuid and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) limit 1),true);
select set_config('test.place',(select id::text from public.destinations where is_active=1 limit 1),true);
delete from public.reviews where profile_id in (current_setting('test.author')::uuid,current_setting('test.other')::uuid) and destination_id=current_setting('test.place')::uuid;
insert into public.reviews(profile_id,destination_id,rating,review_text,status) values(current_setting('test.author')::uuid,current_setting('test.place')::uuid,4,'A lovely place for a peaceful afternoon.','published');
select set_config('request.jwt.claims',jsonb_build_object('sub',current_setting('test.other'),'role','authenticated')::text,true);
set local role authenticated;
do $$ declare blocked boolean:=false; begin
 begin perform public.delete_my_review(current_setting('test.place')::uuid,null); exception when others then if sqlerrm='Your review was not found' then blocked:=true;else raise;end if;end;
 if not blocked then raise exception 'Cross-account deletion allowed';end if;
end $$;
select set_config('request.jwt.claims',jsonb_build_object('sub',current_setting('test.author'),'role','authenticated')::text,true);
select public.delete_my_review(current_setting('test.place')::uuid,null);
reset role;
do $$ begin if exists(select 1 from public.reviews where profile_id=current_setting('test.author')::uuid and destination_id=current_setting('test.place')::uuid) then raise exception 'Own review not deleted';end if;end $$;
insert into public.reviews(profile_id,destination_id,rating,review_text,status) values(current_setting('test.author')::uuid,current_setting('test.place')::uuid,4,'A review currently under moderation.','hidden');
set local role authenticated;
do $$ declare blocked boolean:=false;begin
 begin perform public.delete_my_review(current_setting('test.place')::uuid,null);exception when others then if sqlerrm like 'A review under moderation%' then blocked:=true;else raise;end if;end;
 if not blocked then raise exception 'Moderation bypass permitted';end if;
end $$;
reset role;
do $$ begin if has_function_privilege('anon','public.delete_my_review(uuid,uuid)','execute') then raise exception 'Anonymous deletion permission';end if;end $$;
rollback;
