import type { SupabaseClient } from '@supabase/supabase-js';
const paths = {
 bell: ['M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9','M10 21h4'],
 mail: ['M3 5h18v14H3z','m3 5 9 7 9-7'],
 open: ['m3 10 9-7 9 7v10H3z','m3 10 9 7 9-7'],
 trash: ['M3 6h18','M9 6V3h6v3','M5 6l1 15h12l1-15','M10 10v7','M14 10v7'],
 restore: ['M3 4v6h6','M3 10a9 9 0 1 1 2 8'],
 check: ['m3 12 4 4L17 6','m12 16 3 3 7-10'],
 left: ['m15 6-6 6 6 6'], right: ['m9 6 6 6-6 6'],
};
type Icon = keyof typeof paths;
const Bell:Icon='bell', Mail:Icon='mail', MailOpen:Icon='open', Trash2:Icon='trash', RotateCcw:Icon='restore', CheckCheck:Icon='check', ChevronLeft:Icon='left', ChevronRight:Icon='right';
import { confirmAction } from './action-confirm';
import { tidy } from './ui';
type Row = { id: string; message: string; created_at: string; read: boolean | number };
type Filter = 'all' | 'unread' | 'trash';
const views = new WeakMap<HTMLElement, {filter: Filter; offset: number}>();
const loads = new WeakMap<HTMLElement, number>();
const isRead = (n: Row) => n.read === true || n.read === 1;
const timestamp = new Intl.DateTimeFormat('en-PH', {month:'short',day:'numeric',year:'numeric',hour:'numeric',minute:'2-digit',timeZone:'Asia/Taipei'});
function h(tag: string, cls = '', text = '') { const e = document.createElement(tag); if (cls) e.className = cls; if (text) e.textContent = text; return e; }
function icon(component: Icon) { const e=h('span','tm-notification-icon'), svg=document.createElementNS('http://www.w3.org/2000/svg','svg'); for(const [key,value] of Object.entries({viewBox:'0 0 24 24',fill:'none',stroke:'currentColor','stroke-width':'1.6','stroke-linecap':'round','stroke-linejoin':'round','aria-hidden':'true'}))svg.setAttribute(key,value);for(const d of paths[component]){const path=document.createElementNS('http://www.w3.org/2000/svg','path');path.setAttribute('d',d);svg.append(path);}e.append(svg);return e; }
function button(label: string, component?: Icon, compact=false) { const b = h('button',compact?'tm-notification-icon-button':'tm-notification-action') as HTMLButtonElement; b.type='button'; b.setAttribute('aria-label',label); b.title=label; if(component)b.append(icon(component)); if(!compact)b.append(document.createTextNode(label)); return b; }
export async function loadNotifications(client: SupabaseClient, box: HTMLElement) {
 const state = views.get(box) ?? {filter:'all' as Filter,offset:0}; views.set(box,state);
 const version=(loads.get(box)??0)+1; loads.set(box,version);
 box.classList.add('tm-notifications');
 const header=h('div','tm-notification-header'),title=h('div','tm-notification-title'); title.append(icon(Bell),h('h2','','Notifications'));header.append(title);box.replaceChildren(header);
 const toolbar=h('div','tm-notification-toolbar'),filters=h('div','tm-notification-filters');filters.setAttribute('role','group');filters.setAttribute('aria-label','Filter notifications');
 for(const [value,label] of [['all','All'],['unread','Unread'],['trash','Trash']] as const) {const b=button(label);b.setAttribute('aria-pressed',String(state.filter===value));b.onclick=()=>{views.set(box,{filter:value,offset:0});void loadNotifications(client,box);};filters.append(b);}
 toolbar.append(filters);box.append(toolbar);
 const status=h('p','tm-notification-error');status.hidden=true;status.setAttribute('role','alert');box.append(status);
 const loading=h('p','tm-notification-empty','Loading updates…');loading.setAttribute('role','status');box.append(loading);box.setAttribute('aria-busy','true');
 let result;try{result=await client.schema('public').rpc('notification_inbox',{p_filter:state.filter,p_offset:state.offset});}catch{result={error:true,data:null};}
 if(loads.get(box)!==version)return;loading.remove();box.removeAttribute('aria-busy');
 if(result.error){status.textContent='We couldn’t load your notifications. Please try again.';status.hidden=false;const retry=button('Try again',RotateCcw);retry.onclick=()=>void loadNotifications(client,box);box.append(retry);return;}
 const data=result.data as {items:Row[];total:number;unread:number}; const rows=data.items;
 if(!rows.length && state.offset>0){views.set(box,{...state,offset:Math.max(0,state.offset-25)});void loadNotifications(client,box);return;}
 header.append(h('span','tm-notification-count',`${data.unread} unread`));
 async function perform(b:HTMLButtonElement,operation:()=>PromiseLike<{error:unknown}>) { b.disabled=true;status.hidden=true;try{const r=await operation();if(r.error)throw r.error;if(loads.get(box)===version)await loadNotifications(client,box);}catch{if(loads.get(box)===version){status.textContent='Couldn’t update this notification. Please try again.';status.hidden=false;b.disabled=false;}} }
 if(data.unread && state.filter!=='trash'){const all=button('Mark all as read',CheckCheck);all.onclick=()=>void perform(all,()=>client.schema('public').rpc('mark_my_notifications_read'));toolbar.append(all);}
 const viewport=h('div','tm-notification-scroll');viewport.tabIndex=0;viewport.setAttribute('role','region');viewport.setAttribute('aria-label',`${state.filter==='trash'?'Deleted':state.filter==='unread'?'Unread':'All'} notifications`);
 if(!rows.length){viewport.append(h('p','tm-notification-empty',state.filter==='unread'?'You’re all caught up. No unread notifications.':state.filter==='trash'?'Your trash is empty.':'No notifications yet. New updates will appear here.'));}
 const ul=h('ul','tm-notification-list');
 for(const n of rows){
  const li=h('li',isRead(n)?'tm-notification-item':'tm-notification-item tm-notification-unread');li.append(icon(isRead(n)?MailOpen:Mail));
  const content=h('div','tm-notification-content'),meta=h('div','tm-notification-meta');if(!isRead(n))meta.append(h('span','tm-notification-state','Unread'));const date=new Date(n.created_at);if(!Number.isNaN(date.getTime())){const time=h('time','',timestamp.format(date));time.setAttribute('datetime',date.toISOString());meta.append(time);}
  content.append(h('p','tm-notification-message',tidy(n.message)),meta);li.append(content);
  const actions=h('div','tm-notification-row-actions');
  if(state.filter==='trash'){const restore=button('Restore notification',RotateCcw,true);restore.onclick=()=>void perform(restore,()=>client.schema('public').rpc('notification_action',{p_id:n.id,p_action:'restore'}));actions.append(restore);}
  else{
   const read=button(isRead(n)?'Mark as unread':'Mark as read',isRead(n)?Mail:MailOpen,true);read.onclick=()=>void perform(read,()=>client.schema('public').rpc('notification_action',{p_id:n.id,p_action:isRead(n)?'unread':'read'}));actions.append(read);
   const remove=button('Delete notification',Trash2,true);remove.onclick=async()=>{remove.disabled=true;const ok=await confirmAction('Delete this notification?',`${tidy(n.message)}\n\nYou can restore it from Trash.`, 'Move to Trash', 'Cancel');if(loads.get(box)!==version)return;if(!ok){remove.disabled=false;return;}await perform(remove,()=>client.schema('public').rpc('notification_action',{p_id:n.id,p_action:'delete'}));};actions.append(remove);
  }
  li.append(actions);ul.append(li);
 }
 viewport.append(ul);box.append(viewport);
 const footer=h('div','tm-notification-pagination');footer.append(h('span','',data.total?`${state.offset+1}–${state.offset+rows.length} of ${data.total}`:'0 notifications'));
 const pages=h('div');for(const [delta,label,component] of [[-25,'Newer notifications',ChevronLeft],[25,'Older notifications',ChevronRight]] as const){const b=button(label,component,true);b.disabled=delta<0?state.offset===0:state.offset+rows.length>=data.total;b.onclick=()=>{views.set(box,{...state,offset:state.offset+delta});void loadNotifications(client,box);};pages.append(b);}footer.append(pages);box.append(footer);
}
