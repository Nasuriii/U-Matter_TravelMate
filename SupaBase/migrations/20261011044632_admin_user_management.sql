-- Admin account directory and audited TravelMate access controls.
-- Provider credentials and role assignments remain managed outside this interface.
create table travelmate_ui.account_status_audit (
 id bigint generated always as identity primary key,
 profile_id uuid not null references public.profiles(id),
 actor_id uuid not null references public.profiles(id),
 previous_status text not null,
 next_status text not null,
 reason text not null check (char_length(reason) between 1 and 300),
 created_at timestamptz not null default now()
);
alter table travelmate_ui.account_status_audit enable row level security;
revoke all on travelmate_ui.account_status_audit from public, anon, authenticated;
revoke all on sequence travelmate_ui.account_status_audit_id_seq from public, anon, authenticated;
create index account_status_audit_profile_time on travelmate_ui.account_status_audit(profile_id,created_at desc);
create index account_status_audit_actor on travelmate_ui.account_status_audit(actor_id);

create function travelmate_ui.admin_user_directory(p_query text default '',p_role text default 'all',p_status text default 'all',p_offset integer default 0)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare result jsonb; q text:=lower(trim(coalesce(p_query,'')));
begin
 if public.tm_active_profile_id() is null or not public.tm_is_admin() then raise exception 'Administrator access required' using errcode='42501'; end if;
 if char_length(q)>120 or p_role is null or p_role not in ('all','traveler','business_owner','admin') or p_status is null or p_status not in ('all','active','suspended','closed') or p_offset is null or p_offset<0 then raise exception 'Invalid user filters'; end if;
 with directory as (
  select p.id,p.full_name,coalesce(u.email,'') email,p.account_status,p.created_at,p.updated_at,
   coalesce((select jsonb_agg(r.name order by r.name) from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id),'[]'::jsonb) roles
  from public.profiles p left join auth.users u on u.id=p.id
 ), filtered as (
  select * from directory d where (q='' or position(q in lower(coalesce(d.full_name,'')||' '||d.email))>0)
  and (p_status='all' or d.account_status=p_status)
  and (p_role='all' or d.roles ? p_role)
 ), page as (
  select * from filtered order by lower(coalesce(full_name,'')),id offset p_offset limit 25
 )
 select jsonb_build_object('items',coalesce((select jsonb_agg(to_jsonb(x)) from page x),'[]'::jsonb),
  'total',(select count(*) from filtered),'counts',jsonb_build_object(
   'total',(select count(*) from directory),'active',(select count(*) from directory where account_status='active'),
   'suspended',(select count(*) from directory where account_status='suspended'),'admins',(select count(*) from directory where roles ? 'admin')))
 into result;
 return result;
end $$;

create function travelmate_ui.admin_user_account(p_profile uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare result jsonb;
begin
 if public.tm_active_profile_id() is null or not public.tm_is_admin() then raise exception 'Administrator access required' using errcode='42501'; end if;
 select jsonb_build_object('id',p.id,'full_name',p.full_name,'email',coalesce(u.email,''),'account_status',p.account_status,
  'created_at',p.created_at,'updated_at',p.updated_at,'address',p.address,
  'roles',coalesce((select jsonb_agg(r.name order by r.name) from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=p.id),'[]'::jsonb),
  'trips',(select count(*) from public.trips t where t.profile_id=p.id),
  'bookings',(select count(*) from public.bookings b where b.profile_id=p.id),
  'listings',(select count(*) from public.business_listings l join public.business_owners o on o.id=l.owner_id where o.profile_id=p.id),
  'audit',coalesce((select jsonb_agg(to_jsonb(x)) from (
    select a.previous_status,a.next_status,a.reason,a.created_at,coalesce(actor.full_name,'Administrator') actor_name
    from travelmate_ui.account_status_audit a join public.profiles actor on actor.id=a.actor_id
    where a.profile_id=p.id order by a.created_at desc,a.id desc limit 10) x),'[]'::jsonb))
 into result from public.profiles p left join auth.users u on u.id=p.id where p.id=p_profile;
 if result is null then raise exception 'Account not found'; end if;
 return result;
end $$;

create function travelmate_ui.admin_set_user_status(p_profile uuid,p_status text,p_reason text,p_expected_updated_at timestamptz)
returns jsonb language plpgsql security definer set search_path='' as $$
declare actor uuid:=public.tm_active_profile_id(); target public.profiles; reason text:=trim(coalesce(p_reason,''));
begin
 if actor is null or not public.tm_is_admin() then raise exception 'Administrator access required' using errcode='42501'; end if;
 if p_status is null or p_status not in ('active','suspended') or char_length(reason) not between 1 and 300 then raise exception 'Choose a valid status and provide a reason (1–300 characters)'; end if;
 select * into target from public.profiles where id=p_profile for update;
 if not found then raise exception 'Account not found'; end if;
 if target.id=actor or exists(select 1 from public.profile_roles pr join public.roles r on r.id=pr.role_id where pr.profile_id=target.id and r.name='admin') then raise exception 'Administrator accounts are protected'; end if;
 if target.account_status='closed' then raise exception 'Closed accounts cannot be changed here'; end if;
 if p_expected_updated_at is null or target.updated_at is distinct from p_expected_updated_at then raise exception 'This account changed. Refresh its details and try again' using errcode='40001'; end if;
 if target.account_status=p_status then raise exception 'Account already has this status'; end if;
 update public.profiles set account_status=p_status where id=target.id;
 insert into travelmate_ui.account_status_audit(profile_id,actor_id,previous_status,next_status,reason) values(target.id,actor,target.account_status,p_status,reason);
 return travelmate_ui.admin_user_account(target.id);
end $$;

create function public.admin_user_directory(p_query text default '',p_role text default 'all',p_status text default 'all',p_offset integer default 0)
returns jsonb language sql stable security invoker set search_path='' as $$select travelmate_ui.admin_user_directory(p_query,p_role,p_status,p_offset)$$;
create function public.admin_user_account(p_profile uuid)
returns jsonb language sql stable security invoker set search_path='' as $$select travelmate_ui.admin_user_account(p_profile)$$;
create function public.admin_set_user_status(p_profile uuid,p_status text,p_reason text,p_expected_updated_at timestamptz)
returns jsonb language sql security invoker set search_path='' as $$select travelmate_ui.admin_set_user_status(p_profile,p_status,p_reason,p_expected_updated_at)$$;
revoke all on function travelmate_ui.admin_user_directory(text,text,text,integer), travelmate_ui.admin_user_account(uuid), travelmate_ui.admin_set_user_status(uuid,text,text,timestamptz), public.admin_user_directory(text,text,text,integer), public.admin_user_account(uuid), public.admin_set_user_status(uuid,text,text,timestamptz) from public,anon;
grant execute on function travelmate_ui.admin_user_directory(text,text,text,integer), travelmate_ui.admin_user_account(uuid), travelmate_ui.admin_set_user_status(uuid,text,text,timestamptz), public.admin_user_directory(text,text,text,integer), public.admin_user_account(uuid), public.admin_set_user_status(uuid,text,text,timestamptz) to authenticated;
