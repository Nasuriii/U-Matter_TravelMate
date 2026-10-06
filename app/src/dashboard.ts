import type { SupabaseClient } from '@supabase/supabase-js';
type Role = 'traveler' | 'owner' | 'admin';
function el(tag: string, text = '', cls = '') { const n = document.createElement(tag); n.textContent = text; n.className = cls; return n; }
export function initDashboard(client: SupabaseClient) {
  const db = client.schema('public'); let uid: string | null = null, role: Role = 'traveler', version = 0;
  const traveler = document.getElementById('traveler-summary')!, workspace = document.getElementById('workspace-summary')!;
  const link = (text: string, href: string) => { const n = el('a', text, 'dashboard-link') as HTMLAnchorElement; n.href = href; return n; };
  const metric = (label: string, value: number | null) => { const n = el('div', '', 'dashboard-metric'); n.append(el('strong', value === null ? 'Unavailable' : value.toLocaleString()), el('span',label)); return n; };
  async function refresh() {
    const user = uid; if (!user) return;
    const current = ++version, box = role === 'traveler' ? traveler : workspace;
    box.replaceChildren(el('p','Loading your overview…','muted'));
    try {
      if (role === 'traveler') {
        const [recent, count] = await Promise.all([
          db.from('trips').select('name,start_date,end_date,status').eq('profile_id',user).order('updated_at',{ascending:false}).limit(3),
          db.from('trips').select('id',{count:'exact',head:true}).eq('profile_id',user)
        ]);
        if(current!==version) return;
        if(recent.error) throw recent.error;
        const card = el('div','','dashboard-panel'); card.append(el('p','PICK UP WHERE YOU LEFT OFF','eyebrow'),el('h2','Your travel notebook'));
        if(!recent.data?.length) card.append(el('p','No trips yet. Choose a destination and dates to create your first itinerary.'));
        for(const t of recent.data ?? []) { const a=link(t.name,'#/trips'); a.append(el('small',`${t.start_date || 'Dates not set'} · ${t.status}`)); card.append(a); }
        card.append(link('Open all my trips →','#/trips'));
        box.replaceChildren(metric('Saved trips',count.error ? null : count.count),card);
      } else if (role === 'admin') {
        const result = await db.rpc('admin_review_queue'); if(current!==version)return; if(result.error)throw result.error;
        const rows = (result.data ?? []) as {name:string;type:string;problems?:string[]}[];
        const stats = el('div','','dashboard-stats'); stats.append(metric('Awaiting review',rows.length),metric('Ready for review',rows.filter(r=>!r.problems?.length).length),metric('Missing details',rows.filter(r=>r.problems?.length).length));
        const panel = el('div','','dashboard-panel'); panel.append(el('h2','Next in your queue'));
        if(!rows.length)panel.append(el('p','You’re caught up. New submissions will appear here.'));
        for(const r of rows.slice(0,4)){const a=link(r.name,'#/admin');a.append(el('small',r.type + (r.problems?.length ? ' · needs details' : ' · ready to inspect')));panel.append(a);}
        panel.append(link('Review all submissions →','#/admin'));box.replaceChildren(stats,panel);
      } else {
        const owner = await db.from('business_owners').select('id').eq('profile_id',user).maybeSingle();
        if(owner.error)throw owner.error;if(!owner.data)throw new Error('Your business profile is not ready. Open My business to finish setup.');
        const states=['approved','pending','rejected','inactive'];
        const counts=await Promise.all(states.map(status=>db.from('business_listings').select('id',{head:true,count:'exact'}).eq('owner_id',owner.data!.id).eq('status',status)));
        if(current!==version)return;
        const stats=el('div','','dashboard-stats');const labels=['Live listings','Awaiting review','Needs changes','Inactive'];
        counts.forEach((r,i)=>stats.append(metric(labels[i],r.error?null:r.count)));
        const panel=el('div','','dashboard-panel');panel.append(el('h2','Your next step'),el('p',(counts[2].count??0)>0?'Some listings need changes. Read the administrator’s reason, update the details, then resubmit.':'Keep your listing details, photos, menus and schedules up to date.'),link('Manage my listings →','#/owner'));box.replaceChildren(stats,panel);
      }
    } catch(e) { if(current!==version)return;box.replaceChildren(el('p', e instanceof Error ? e.message : String((e as {message?:string})?.message ?? 'Could not load overview.'),'error'));const retry=el('button','Try again') as HTMLButtonElement;retry.type='button';retry.onclick=()=>void refresh();box.append(retry); }
  }
  window.addEventListener('hashchange',()=>{if(location.hash==='#/home')void refresh();});
  return {setUser(id:string|null, next:Role){uid=id;role=next;version++;traveler.replaceChildren();workspace.replaceChildren();if(id)void refresh();}};
}
