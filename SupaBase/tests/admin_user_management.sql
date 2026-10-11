-- All account changes in this regression script are rolled back.
begin;
create temp table account_qa as select
 (select p.id from public.profiles p join public.profile_roles pr on pr.profile_id=p.id join public.roles r on r.id=pr.role_id where p.account_status='active' and r.name='admin' limit 1) administrator,
 (select p.id from public.profiles p where p.account_status='active' and not exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id and r.name='admin') limit 1) target,
 (select count(*) from public.profiles) expected_total;
do $$ begin if exists(select 1 from account_qa where administrator is null or target is null) then raise exception 'Missing role test fixtures'; end if; end $$;
grant select on account_qa to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub',(select target::text from account_qa),true);
do $$ declare denied boolean; begin
 denied:=false;begin perform public.admin_user_directory();exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'Non-admin could read user directory';end if;
 denied:=false;begin perform public.admin_user_account((select administrator from account_qa));exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'Non-admin could read account details';end if;
 denied:=false;begin perform public.admin_set_user_status((select target from account_qa),'suspended','QA',now());exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'Non-admin could change account access';end if;
 denied:=false;begin perform count(*) from travelmate_ui.account_status_audit;exception when insufficient_privilege then denied:=true;end;
 if not denied then raise exception 'Private audit is directly readable';end if;
 if has_function_privilege('anon','public.admin_user_directory(text,text,text,integer)','execute') or has_function_privilege('anon','public.admin_user_account(uuid)','execute') or has_function_privilege('anon','public.admin_set_user_status(uuid,text,text,timestamptz)','execute') then raise exception 'Anonymous function grant';end if;
end $$;
select set_config('request.jwt.claim.sub',(select administrator::text from account_qa),true);
do $$ declare data jsonb; target uuid:=(select target from account_qa); administrator uuid:=(select administrator from account_qa); stamp timestamptz; denied boolean; begin
 data:=public.admin_user_directory();
 if (data->>'total')::int<>(select expected_total from account_qa) or jsonb_array_length(data->'items')>25 then raise exception 'Directory counts or pagination incorrect';end if;
 data:=public.admin_user_directory(p_role=>'admin');
 if exists(select 1 from jsonb_array_elements(data->'items') x where not (x->'roles' ? 'admin')) then raise exception 'Role filtering incorrect';end if;
 data:=public.admin_user_directory(p_offset=>100000);
 if jsonb_array_length(data->'items')<>0 then raise exception 'Pagination incorrect';end if;
 denied:=false;begin perform public.admin_user_directory(p_query=>repeat('x',121));exception when others then denied:=sqlerrm='Invalid user filters';end;
 if not denied then raise exception 'Search limit missing';end if;
 data:=public.admin_user_account(target);stamp:=(data->>'updated_at')::timestamptz;
 denied:=false;begin perform public.admin_set_user_status(administrator,'suspended','QA',stamp);exception when others then denied:=sqlerrm='Administrator accounts are protected';end;
 if not denied then raise exception 'Administrator not protected';end if;
 denied:=false;begin perform public.admin_set_user_status(target,'suspended','',stamp);exception when others then denied:=position('provide a reason' in sqlerrm)>0;end;
 if not denied then raise exception 'Missing reason accepted';end if;
 denied:=false;begin perform public.admin_set_user_status(target,'suspended','QA',stamp-interval '1 second');exception when serialization_failure then denied:=true;end;
 if not denied then raise exception 'Stale account update accepted';end if;
 data:=public.admin_set_user_status(target,'suspended','QA rollback-only suspension',stamp);
 if data->>'account_status'<>'suspended' or not exists(select 1 from jsonb_array_elements(data->'audit') x where x->>'reason'='QA rollback-only suspension') then raise exception 'Suspension/audit failed';end if;
 perform set_config('request.jwt.claim.sub',target::text,true);
 if public.tm_active_profile_id() is not null then raise exception 'Suspended account remains active';end if;
 denied:=false;begin perform public.workspace_reservations();exception when others then denied:=true;end;
 if not denied then raise exception 'Suspended account can read protected reservations';end if;
 perform set_config('request.jwt.claim.sub',administrator::text,true);
 data:=public.admin_set_user_status(target,'active','QA rollback-only reactivation',(data->>'updated_at')::timestamptz);
 if data->>'account_status'<>'active' then raise exception 'Reactivation failed';end if;
end $$;
rollback;
select 'PASS: non-admin and anonymous denial; private audit protection; pagination/filters; protected admin; reason/stale guards; suspension, reactivation and audit (all changes rolled back)' as result;
