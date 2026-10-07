alter table public.notifications add column if not exists dismissed_at timestamptz;
create index if not exists notifications_inbox_idx on public.notifications(profile_id, created_at desc, id desc);
create or replace function travelmate_ui.notification_inbox(p_filter text default 'all', p_offset integer default 0)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id(); result jsonb;
begin
 if u is null then raise exception 'Sign in to an active account'; end if;
 if p_filter is null or p_filter not in ('all','unread','trash') or p_offset is null or p_offset<0 then raise exception 'Invalid inbox filter'; end if;
 select jsonb_build_object(
 'unread',(select count(*) from public.notifications where profile_id=u and dismissed_at is null and read_at is null),
 'total',(select count(*) from public.notifications where profile_id=u and case when p_filter='trash' then dismissed_at is not null else dismissed_at is null and (p_filter='all' or read_at is null) end),
 'items',(select coalesce(jsonb_agg(to_jsonb(t) order by t.created_at desc,t.id desc),'[]'::jsonb) from
 (select id,message,read_at is not null as read,created_at from public.notifications where profile_id=u and case when p_filter='trash' then dismissed_at is not null else dismissed_at is null and (p_filter='all' or read_at is null) end order by created_at desc,id desc limit 25 offset p_offset)t)
 ) into result; return result;
end $$;
create or replace function travelmate_ui.notification_action(p_id uuid,p_action text)
returns void language plpgsql security definer set search_path='' as $$
declare u uuid:=public.tm_active_profile_id();
begin
 if u is null then raise exception 'Sign in to an active account'; end if;
 if p_action is null or p_action not in ('read','unread','delete','restore') then raise exception 'Invalid notification action'; end if;
 update public.notifications set
 read_at=case when p_action='read' then now() when p_action='unread' then null else read_at end,
 dismissed_at=case when p_action='delete' then now() when p_action='restore' then null else dismissed_at end
 where id=p_id and profile_id=u;
 if not found then raise exception 'Notification not found'; end if;
end $$;
create or replace function public.notification_inbox(p_filter text default 'all',p_offset integer default 0)
returns jsonb language sql stable security invoker set search_path='' as $$ select travelmate_ui.notification_inbox(p_filter,p_offset); $$;
create or replace function public.notification_action(p_id uuid,p_action text)
returns void language sql security invoker set search_path='' as $$ select travelmate_ui.notification_action(p_id,p_action); $$;
revoke all on function travelmate_ui.notification_inbox(text,integer),travelmate_ui.notification_action(uuid,text),public.notification_inbox(text,integer),public.notification_action(uuid,text) from public,anon;
grant execute on function travelmate_ui.notification_inbox(text,integer),travelmate_ui.notification_action(uuid,text),public.notification_inbox(text,integer),public.notification_action(uuid,text) to authenticated;
