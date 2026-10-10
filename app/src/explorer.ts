import type { SupabaseClient } from '@supabase/supabase-js';
import { confirmAction } from './action-confirm';
import { destinationPhoto } from './experience/destination-photos';
import { destinationDescription } from './destination-copy';
type Destination={id:string;name:string;province:string;description:string|null};
const destinationIcon=(heart=false,filled=false)=>{const el=document.createElementNS('http://www.w3.org/2000/svg','svg');el.setAttribute('viewBox','0 0 24 24');el.setAttribute('width','18');el.setAttribute('height','18');el.setAttribute('fill',filled?'currentColor':'none');el.setAttribute('stroke','currentColor');el.setAttribute('stroke-width','1.8');el.setAttribute('aria-hidden','true');const path=document.createElementNS('http://www.w3.org/2000/svg','path');path.setAttribute('d',heart?'M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8Z':'M7 17 17 7M7 7h10v10');el.append(path);return el;};
const node=<T extends HTMLElement=HTMLElement>(id:string)=>document.getElementById(id) as T;
export function createExplorer(client:SupabaseClient){
 const db=client.schema('public');
 let onlySaved=false, uid:string|null=null, generation=0, destinations:Destination[]=[],saved=new Set<string>(), savedReady=false;
 const pending=new Set<string>();
 const message=(s:string)=>{node('catalog-notice').textContent=s;};
 const errorText=(e:unknown)=>typeof e==='object' && e && 'message' in e?String(e.message):String(e);
 function render(){
  node('saved-toggle').replaceChildren(destinationIcon(true,onlySaved),document.createTextNode(onlySaved?'Show all destinations':'Show my saved'));node('saved-toggle').setAttribute('aria-pressed',String(onlySaved));
  node('catalog-title').textContent=onlySaved?'Your saved destinations':'Explore destinations';
  const grid=node('destination-grid');grid.replaceChildren();
  if(onlySaved&&!uid){message('Sign in from Your account to see your saved destinations.');return;}
  if(onlySaved&&!savedReady){message('Your saved destinations have not loaded. Use Refresh to try again.');return;}
  const q=node<HTMLInputElement>('search').value.trim().toLocaleLowerCase();
  const province=node<HTMLSelectElement>('province').value;
  const list=destinations.filter(d=>(!onlySaved||saved.has(d.id))&&(!province||province===d.province)&&(!q||(d.name+' '+d.province).toLocaleLowerCase().includes(q)));
  for(const d of list){
   const card=document.createElement('article');card.className='destination-card';
   const open=document.createElement('a');open.className='destination-open';open.href='#/destination/'+d.id;open.setAttribute('aria-label','Explore '+d.name);
   const art=document.createElement('div');art.className='place-art';art.setAttribute('aria-hidden','true');art.textContent=d.province;
   const photo=destinationPhoto(d.name,d.province);
   if(photo){art.removeAttribute('aria-hidden');art.textContent='';art.classList.add('destination-photo-art');const image=document.createElement('img');image.src=photo.src;image.alt=photo.alt;image.loading='lazy';image.onerror=()=>{image.remove();art.textContent=d.name;};art.append(image);}
   const body=document.createElement('div');body.className='card-body';
   const region=document.createElement('p');region.className='eyebrow';region.textContent=d.province;
   const title=document.createElement('h3');title.textContent=d.name;const arrow=document.createElement('span');arrow.className='destination-open-arrow';arrow.append(destinationIcon());arrow.setAttribute('aria-hidden','true');title.append(arrow);
   const desc=document.createElement('p');desc.className='destination-summary';desc.textContent=destinationDescription(d.description)||'Stays · Food · Attractions';
   const button=document.createElement('button');button.type='button';button.className='destination-save';button.append(destinationIcon(true,saved.has(d.id)),document.createTextNode(saved.has(d.id)?'Saved':uid?'Save destination':'Sign in to save'));
   button.setAttribute('aria-label',(saved.has(d.id)?'Remove saved destination ':'Save destination ')+d.name);
   button.setAttribute('aria-pressed',String(saved.has(d.id)));button.disabled=pending.has(d.id)||!!uid&&!savedReady;
   button.onclick=()=>void toggle(d.id);
   body.append(region,title,desc);open.append(art,body);card.append(open,button);grid.append(card);
   if(photo?.source){const credit=document.createElement('p');credit.className='tm-recommendation-credit';const source=document.createElement('a');source.href=photo.source;source.target='_blank';source.rel='noreferrer';source.textContent=photo.author??'Photo source';credit.append(source,' · ');if(photo.licenseUrl){const license=document.createElement('a');license.href=photo.licenseUrl;license.target='_blank';license.rel='noreferrer';license.textContent=photo.license??'License';credit.append(license);}else credit.append(photo.license??'');credit.append(' · cropped');const info=document.createElement('details'),summary=document.createElement('summary');summary.textContent='ⓘ';summary.setAttribute('aria-label','Photo information');info.className='tm-photo-credit-details';info.append(summary,credit);card.append(info);}
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
