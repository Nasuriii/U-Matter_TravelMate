-- All profile changes, plans, favorites and appeals are rolled back.
begin;
create temp table suspension_qa as select
 (select p.id from public.profiles p where p.account_status='active' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='admin') limit 1) administrator,
 (select p.id from public.profiles p where p.account_status='active' and p.full_name like '%(Demo)%' and exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='traveler') and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name in ('admin','business_owner')) limit 1) traveler,
 (select id from public.destinations where is_active=1 limit 1) destination;
do $$begin if exists(select 1 from suspension_qa where administrator is null or traveler is null or destination is null) then raise exception 'Missing account QA fixtures';end if;end $$;
grant select on suspension_qa to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub',(select administrator::text from suspension_qa),true);
do $$declare p uuid:=(select traveler from suspension_qa);a jsonb;begin
 a:=public.admin_user_account(p);perform public.admin_set_user_status(p,'suspended','Rollback-only appeal verification',(a->>'updated_at')::timestamptz);
end $$;
select set_config('request.jwt.claim.sub',(select traveler::text from suspension_qa),true);
do $$declare u uuid:=(select traveler from suspension_qa);d uuid:=(select destination from suspension_qa);t uuid;stamp timestamptz;denied boolean;listing uuid;feed jsonb;begin
 if public.tm_active_profile_id() is not null or public.tm_browsing_profile_id()<>u or not public.tm_can_plan() then raise exception 'Suspended browsing identity incorrect';end if;
 if public.my_account_access()->>'account_status'<>'suspended' then raise exception 'Suspended account profile cannot load';end if;
 if not exists(select 1 from public.destinations where id=d) then raise exception 'Catalog browsing denied';end if;
 if exists(select 1 from public.bookings where profile_id<>u) then raise exception 'Another traveler booking is visible';end if;
 if exists(select 1 from public.trips where profile_id<>u) then raise exception 'Another traveler trip is visible';end if;
 insert into public.trips(profile_id,destination_id,name,start_date,end_date,arrival_time,departure_time,status)
 values(u,d,'Rollback-only suspended plan',current_date+5,current_date+5,'09:00','18:00','draft') returning id,updated_at into t,stamp;
 perform public.save_my_trip_plan(t,stamp,jsonb_build_array(jsonb_build_object('activity','A quiet walk','planned_date',(current_date+5)::text,'planned_time','09:00','planned_end_time','10:00')),jsonb_build_array(jsonb_build_object('planned_date',(current_date+5)::text,'title','A day away','notes','Personal planning only')));
 if not exists(select 1 from public.trip_items where trip_id=t) then raise exception 'Suspended itinerary could not be saved';end if;
 perform public.delete_my_trip(t);
 select id into listing from public.business_listings where status='approved' limit 1;
 perform public.set_saved_place(listing,null,true);
 if not exists(select 1 from public.saved_places where profile_id=u and listing_id=listing) then raise exception 'Suspended favorite could not be saved';end if;
 perform public.save_my_travel_preferences(array['food'],'balanced',false);
 denied:=false;begin insert into public.trips(profile_id,name,status) values((select administrator from suspension_qa),'Unauthorized other account plan','draft');exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'Suspended traveler can write another profile plan';end if;
 denied:=false;begin perform public.save_my_booking_preview(listing,null,null,current_date+5,current_date+6,1,'QA Traveler','qa@example.test','rollback-only-preview-booking');exception when others then denied:=position('Traveler account required' in sqlerrm)>0;end;
 if not denied then raise exception 'Suspended preview booking was not denied';end if;
 denied:=false;begin perform public.reserve_my_booking(listing,null,null,current_date+5,current_date+6,1,'QA Traveler','qa@example.test',null,'rollback-only-suspended-booking');exception when others then denied:=position('active traveler' in sqlerrm)>0;end;
 if not denied then raise exception 'Suspended booking creation was not denied by the active-account guard';end if;
 denied:=false;begin perform public.save_traveler_review(d,null,5,'This review must not be published.');exception when others then denied:=position('active traveler' in sqlerrm)>0;end;
 if not denied then raise exception 'Suspended review creation was not denied by the active-account guard';end if;
 if (public.place_reviews(d,null,0)->>'can_review')::boolean then raise exception 'Suspended account can compose a review';end if;
 feed:=public.workspace_reservations();
 if exists(select 1 from jsonb_array_elements(feed) x where not exists(select 1 from public.bookings b where b.id=(x->>'id')::uuid and b.profile_id=u)) then raise exception 'Booking RPC exposed another traveler history';end if;
 if exists(select 1 from jsonb_array_elements(feed) x where (x->>'can_cancel')::boolean or (x->>'can_delete')::boolean) then raise exception 'Suspended booking history enables mutation';end if;
 denied:=false;begin perform public.admin_account_appeals();exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'Suspended user can access administrator queue';end if;
 denied:=false;begin perform count(*) from travelmate_ui.account_appeals;exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'Private appeal table is directly exposed';end if;
 denied:=false;begin perform public.submit_account_appeal('Too short');exception when others then denied:=position('20 and 2,000' in sqlerrm)>0;end;
 if not denied then raise exception 'Short appeal accepted';end if;
 perform set_config('qa.appeal',public.submit_account_appeal('Please review my suspension. This is a rollback-only verification.')::text,true);
 denied:=false;begin perform public.submit_account_appeal('This duplicate should not enter the pending queue.');exception when others then denied:=position('already awaiting review' in sqlerrm)>0;end;
 if not denied then raise exception 'Duplicate pending appeal accepted';end if;
 denied:=false;begin perform public.admin_review_account_appeal(current_setting('qa.appeal')::uuid,true,'Unauthorized self approval',now());exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'Traveler can approve own appeal';end if;
end $$;
select set_config('request.jwt.claim.sub',(select administrator::text from suspension_qa),true);
do $$declare a jsonb;begin
 select x into a from jsonb_array_elements(public.admin_account_appeals()->'items') x where x->>'id'=current_setting('qa.appeal');
 if a is null then raise exception 'Admin queue omitted appeal';end if;
 if exists(select 1 from jsonb_array_elements(public.my_account_appeals()) x where x->>'id'=a->>'id') then raise exception 'Own appeal endpoint exposes another account';end if;
 perform public.admin_review_account_appeal((a->>'id')::uuid,false,'Please provide more information for the review.',(a->>'updated_at')::timestamptz);
end $$;
select set_config('request.jwt.claim.sub',(select traveler::text from suspension_qa),true);
do $$begin
 if public.my_account_access()->>'account_status'<>'suspended' then raise exception 'Decline reactivated account';end if;
 if not exists(select 1 from jsonb_array_elements(public.my_account_appeals()) x where x->>'status'='declined' and x->>'response'='Please provide more information for the review.') then raise exception 'Traveler cannot read decision';end if;
 perform set_config('qa.appeal',public.submit_account_appeal('Here is the additional context for this rollback-only appeal verification.')::text,true);
end $$;
select set_config('request.jwt.claim.sub',(select administrator::text from suspension_qa),true);
do $$declare a jsonb;p jsonb;denied boolean:=false;begin
 select x into a from jsonb_array_elements(public.admin_account_appeals()->'items') x where x->>'id'=current_setting('qa.appeal');
 p:=public.admin_user_account((select traveler from suspension_qa));perform public.admin_set_user_status((select traveler from suspension_qa),'active','Rollback-only reset suspension',(p->>'updated_at')::timestamptz);
 p:=public.admin_user_account((select traveler from suspension_qa));perform public.admin_set_user_status((select traveler from suspension_qa),'suspended','Rollback-only new suspension',(p->>'updated_at')::timestamptz);
 begin perform public.admin_review_account_appeal((a->>'id')::uuid,true,'Old appeal must not reactivate a new suspension.',(a->>'updated_at')::timestamptz);exception when serialization_failure then denied:=true;end;
 if not denied then raise exception 'Appeal from an earlier suspension reactivated account';end if;
end $$;
select set_config('request.jwt.claim.sub',(select traveler::text from suspension_qa),true);
do $$begin
 perform set_config('qa.appeal',public.submit_account_appeal('Please review the new suspension with this current appeal request.')::text,true);
 if (select count(*) from jsonb_array_elements(public.my_account_appeals()) x where x->>'status'='pending')<>1 then raise exception 'Obsolete pending appeal blocked current suspension appeal';end if;
end $$;
select set_config('request.jwt.claim.sub',(select administrator::text from suspension_qa),true);

do $$declare a jsonb;denied boolean:=false;begin
 select x into a from jsonb_array_elements(public.admin_account_appeals()->'items') x where x->>'id'=current_setting('qa.appeal');
 begin perform public.admin_review_account_appeal((a->>'id')::uuid,true,'Reviewed and approved after clarification.',(a->>'updated_at')::timestamptz-interval '1 second');exception when serialization_failure then denied:=true;end;
 if not denied then raise exception 'Stale admin decision accepted';end if;
 perform public.admin_review_account_appeal((a->>'id')::uuid,true,'Reviewed and approved after clarification.',(a->>'updated_at')::timestamptz);
 if not exists(select 1 from jsonb_array_elements(public.admin_user_account((select traveler from suspension_qa))->'audit') x where x->>'next_status'='active' and x->>'reason' like 'Appeal approved:%') then raise exception 'Appeal approval was not audited';end if;
end $$;
select set_config('request.jwt.claim.sub',(select traveler::text from suspension_qa),true);
do $$declare denied boolean:=false;begin
 if public.tm_active_profile_id() is null or public.my_account_access()->>'account_status'<>'active' then raise exception 'Approval did not restore active account';end if;
 begin perform public.submit_account_appeal('An active account should not submit another suspension appeal.');exception when others then denied:=position('Only suspended' in sqlerrm)>0;end;
 if not denied then raise exception 'Active account can submit suspension appeal';end if;
 if has_function_privilege('anon','public.my_account_access()','execute') or has_function_privilege('anon','public.submit_account_appeal(text)','execute') or has_function_privilege('anon','public.admin_review_account_appeal(uuid,boolean,text,timestamptz)','execute') then raise exception 'Anonymous appeal grant';end if;
end $$;
rollback;
select 'PASS: suspended catalog/plans/favorites/history; booking and review denial; appeal ownership, duplicate/length guards; admin decline/approval and audit; stale-decision and anonymous protections (all changes rolled back)' as result;
