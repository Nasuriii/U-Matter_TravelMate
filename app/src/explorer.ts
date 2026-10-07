import type { SupabaseClient } from '@supabase/supabase-js';
import { confirmAction } from './action-confirm';
type Destination={id:string;name:string;province:string;description:string|null};
const node=<T extends HTMLElement=HTMLElement>(id:string)=>document.getElementById(id) as T;
export function createExplorer(client:SupabaseClient){
 const db=client.schema('public');
 let onlySaved=false, uid:string|null=null, generation=0, destinations:Destination[]=[],saved=new Set<string>(), savedReady=false;
 const pending=new Set<string>();
 const message=(s:string)=>{node('catalog-notice').textContent=s;};
 const errorText=(e:unknown)=>typeof e==='object' && e && 'message' in e?String(e.message):String(e);
 function render(){
  node('saved-toggle').textContent=onlySaved?'Show all destinations':'♥ Show my saved';
  node('catalog-title').textContent=onlySaved?'Your saved destinations':'Explore destinations';
  const grid=node('destination-grid');grid.replaceChildren();
  if(onlySaved&&!uid){message('Sign in from Your account to see your saved destinations.');return;}
  if(onlySaved&&!savedReady){message('Your saved destinations have not loaded. Use Refresh to try again.');return;}
  const q=node<HTMLInputElement>('search').value.trim().toLocaleLowerCase();
  const province=node<HTMLSelectElement>('province').value;
  const list=destinations.filter(d=>(!onlySaved||saved.has(d.id))&&(!province||province===d.province)&&(!q||(d.name+' '+d.province).toLocaleLowerCase().includes(q)));
  for(const d of list){
   const card=document.createElement('article');card.className='destination-card';
   const art=document.createElement('div');art.className='place-art';art.setAttribute('aria-hidden','true');art.textContent=d.province;
   const body=document.createElement('div');body.className='card-body';
   const region=document.createElement('p');region.className='eyebrow';region.textContent=d.province;
   const title=document.createElement('h3');title.textContent=d.name;
   const desc=document.createElement('p');desc.textContent=d.description||'Explore this destination and save it for later.';
   const actions=document.createElement('div');actions.className='card-actions';
   const details=document.createElement('button');details.className='quiet';details.textContent='View details ↗';
   details.textContent='Explore stays, food & attractions ↗';
   details.onclick=()=>{location.hash='#/destination/'+d.id;};
   const button=document.createElement('button');button.textContent=saved.has(d.id)?'♥ Saved':uid?'♡ Save':'♡ Sign in to save';
   button.setAttribute('aria-label',(saved.has(d.id)?'Remove saved destination ':'Save destination ')+d.name);
   button.setAttribute('aria-pressed',String(saved.has(d.id)));button.disabled=pending.has(d.id)||!!uid&&!savedReady;
   button.onclick=()=>void toggle(d.id);
   actions.append(details,button);body.append(region,title,desc,actions);card.append(art,body);grid.append(card);
  }
  if(!list.length){const empty=document.createElement('p');empty.className='empty';empty.textContent=onlySaved?'No saved destinations match. Explore places and select Save.':'No destinations match your search.';grid.append(empty);}
 }
 async function load(){
  const token=++generation,owner=uid;message('Loading destinations…');
  try{
   const all:Destination[]=[];
   for(let offset=0;;offset+=500){
    const {data,error}=await db.from('destinations').select('id,name,province,description').eq('is_active',1).order('name').order('id').range(offset,offset+499);
    if(token!==generation)return;if(error)throw error;
    all.push(...data as Destination[]);if(data.length<500)break;
   }
   destinations=all;
   const select=node<HTMLSelectElement>('province'),previous=select.value;
   select.replaceChildren(new Option('All provinces',''));
   for(const region of [...new Set(all.map(d=>d.province))].sort())select.add(new Option(region,region));
   select.value=[...select.options].some(o=>o.value===previous)?previous:'';
   saved=new Set();savedReady=!owner;
   if(owner){
    for(let offset=0;;offset+=500){
     const result=await db.from('saved_destinations').select('destination_id').eq('profile_id',owner).order('destination_id').range(offset,offset+499);
     if(token!==generation)return;if(result.error)throw result.error;
     result.data.forEach(r=>saved.add(r.destination_id));if(result.data.length<500)break;
    }
    savedReady=true;
   }
   render();if(!onlySaved||owner)message(all.length+' destinations available.');
  }catch(e){if(token===generation){render();message('Could not load data: '+errorText(e)+' Use Refresh to retry.');}}
 }
 async function toggle(id:string){
  if(!uid){location.hash='#/login';return;}
  if(pending.has(id)||!savedReady)return;
  const owner=uid,token=generation,wasSaved=saved.has(id);pending.add(id);render();
  try{
   if(!await confirmAction(wasSaved?'Remove this saved destination?':'Save this destination?',destinations.find(d=>d.id===id)?.name||'This updates your saved destinations.',wasSaved?'Remove destination':'Save destination')||uid!==owner||token!==generation)return;
   if(wasSaved){
    const {data,error}=await db.from('saved_destinations').delete().eq('profile_id',owner).eq('destination_id',id).select('destination_id');
    if(error)throw error;if(!data?.length)throw new Error('Removal was not confirmed. Refresh and try again.');
   }else{
    const {error}=await db.from('saved_destinations').insert({profile_id:owner,destination_id:id});
    if(error&&error.code!=='23505')throw error;
   }
   if(uid!==owner||token!==generation)return;
   if(wasSaved)saved.delete(id);else saved.add(id);
   render();message(wasSaved?'Destination removed from Saved.':'Destination saved.');
  }catch(e){if(uid===owner&&token===generation)message('Change not confirmed: '+errorText(e)+' Refresh before retrying.');}
  finally{pending.delete(id);render();}
 }
 node('search-form').addEventListener('submit',e=>{e.preventDefault();render();});
 node('province').addEventListener('change',render);
 node('reload-catalog').addEventListener('click',()=>void load());
 node('saved-toggle').addEventListener('click',()=>{onlySaved=!onlySaved;render();});
 node('close-detail').addEventListener('click',()=>node<HTMLDialogElement>('destination-dialog').close());
 node<HTMLDialogElement>('destination-dialog').addEventListener('click',e=>{if(e.target===e.currentTarget)(e.currentTarget as HTMLDialogElement).close();});
 window.addEventListener('hashchange',render);
 return {setUser(next:string|null){uid=next;generation++;saved.clear();savedReady=false;pending.clear();render();void load();}};
}
