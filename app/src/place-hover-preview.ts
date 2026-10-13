import {client,currentIdentity,photosFor,type Listing} from './experience/state';
import {destinationPhoto} from './experience/destination-photos';

import {contextPreview,type Preview,type PreviewKind} from './preview-content';
const cache=new Map<string,{expires:number;promise:Promise<Preview>}>();
let installed=false;
const label=(kind:string)=>kind==='hotel'?'Place to stay':kind==='restaurant'?'Restaurant':kind==='attraction'?'Attraction':'Destination';
export function clearPlacePreviewCache(){cache.clear();window.dispatchEvent(new Event('travelmate:preview-clear'));}
export function placePreviewAttributes(node:HTMLElement,kind:PreviewKind,id:string,name:string,area=''){
  node.dataset.placePreview=kind;node.dataset.placeId=id;node.dataset.placeName=name;node.dataset.placeArea=area;
}
async function load(node:HTMLElement):Promise<Preview>{
  const contextual=contextPreview(node);if(contextual)return contextual;
  const id=node.dataset.placeId!,name=node.dataset.placeName??'',area=node.dataset.placeArea??'';
  if(node.dataset.placePreview==='destination'){
    const cover=destinationPhoto(name,area);const base:Preview={name,area,kind:'Destination',image:cover?.src,places:[]};
    try{
      const responses=await Promise.all(['hotel','restaurant','attraction'].map(kind=>client.from('business_listings').select('id,name,is_sample,listing_type,description,address,destination_id').eq('destination_id',id).eq('status','approved').eq('listing_type',kind).order('name').limit(1)));
      const rows=responses.flatMap(response=>response.error?[]:response.data??[]) as Listing[];
      base.places=(await photosFor(rows)).map(place=>({name:place.name,kind:label(place.listing_type),image:place.image}));
    }catch{/* Choosing a place always works, even when its preview is unavailable. */}
    return base;
  }
  const result=await client.from('business_listings').select('id,name,is_sample,listing_type,description,address,destination_id,destinations(name,province)').eq('id',id).maybeSingle();
  if(result.error||!result.data)return {name,area,kind:'Listing'};
  const row=result.data as unknown as Listing;const image=(await photosFor([row]))[0];
  const preview:Preview={name:image.name,area,kind:label(row.listing_type),image:image.image};
  const role=currentIdentity().role;
  if(!preview.image&&(role==='owner'||role==='admin')){
    const response=await client.rpc(role==='admin'?'admin_listing_photos':'owner_list_photos',{p_listing:id});const first=response.data?.[0];
    if(!response.error&&first?.object_path){const photo=await client.storage.from('travelmate-listings').createSignedUrl(first.object_path,3600);preview.image=photo.data?.signedUrl;}
  }
  return preview;
}
/** A non-interactive, top-layer peek works inside dialogs and popovers too. */
export function installPlacePreviews(){
  if(installed)return;installed=true;
  const card=document.createElement('aside');card.className='tm-place-hover-preview';card.id='tm-place-hover-preview';card.popover='manual';card.setAttribute('role','tooltip');document.body.append(card);
  let anchor:HTMLElement|null=null,timer=0,revision=0;
  const clear=()=>{window.clearTimeout(timer);revision++;if(card.matches(':popover-open'))card.hidePopover();if(anchor){const ids=(anchor.getAttribute('aria-describedby')??'').split(' ').filter(id=>id&&id!==card.id);ids.length?anchor.setAttribute('aria-describedby',ids.join(' ')):anchor.removeAttribute('aria-describedby');}anchor=null;};
  function position(){if(!anchor?.isConnected){clear();return;}const viewportWidth=document.documentElement.clientWidth,r=anchor.getBoundingClientRect(),width=Math.min(330,viewportWidth-24),height=Math.min(card.scrollHeight,innerHeight-32);const right=r.right+12,left=r.left-width-12;card.style.width=width+'px';card.style.maxHeight=(innerHeight-32)+'px';card.style.left=(right+width<=viewportWidth-12?right:left>=12?left:Math.max(12,Math.min(r.left,viewportWidth-width-12)))+'px';card.style.top=Math.max(16,Math.min(r.top,innerHeight-height-16))+'px';}
  function render(preview:Preview){
    card.replaceChildren();card.dataset.kind=anchor?.dataset.placePreview||'listing';const image=document.createElement('div');image.className='tm-peek-photo';if(preview.image){const img=document.createElement('img');img.src=preview.image;img.alt='';img.onerror=()=>{img.remove();image.textContent='Photo preview unavailable';};image.append(img);}else image.textContent='Photo preview unavailable';
    const copy=document.createElement('div');copy.className='tm-peek-copy';const type=document.createElement('small'),title=document.createElement('strong'),location=document.createElement('p');type.textContent=preview.kind;title.textContent=preview.name;location.textContent=preview.area;copy.append(type,title,location);if(preview.image||['listing','destination'].includes(card.dataset.kind))card.append(image);card.append(copy);
    if(preview.description){const description=document.createElement('p');description.className='tm-peek-description';description.textContent=preview.description;copy.append(description);}
    if(preview.facts?.length){const facts=document.createElement('dl');facts.className='tm-peek-facts';for(const fact of preview.facts){const row=document.createElement('div'),label=document.createElement('dt'),value=document.createElement('dd');label.textContent=fact.label;value.textContent=fact.value;row.append(label,value);facts.append(row);}card.append(facts);}
    if(preview.details){const detail=document.createElement('div'),heading=document.createElement('strong'),text=document.createElement('p');detail.className='tm-peek-limitations';heading.textContent='What to keep in mind';text.textContent=preview.details;detail.append(heading,text);card.append(detail);}
    if(preview.places?.length){const related=document.createElement('div');related.className='tm-peek-places';const heading=document.createElement('small');heading.textContent=preview.heading||(card.dataset.kind==='rooms'?'Your room options':card.dataset.kind==='menu'?'A taste of the menu':'Places to discover');related.append(heading);preview.places.forEach(place=>{const row=document.createElement('div'),text=document.createElement('span'),name=document.createElement('strong'),kind=document.createElement('small');if(place.image){const img=document.createElement('img');img.src=place.image;img.alt='';img.onerror=()=>img.remove();row.append(img);}name.textContent=place.name;kind.textContent=place.kind;text.append(name,kind);row.append(text);related.append(row);});card.append(related);}
    if(preview.empty&&!preview.places?.length){const empty=document.createElement('p');empty.className='tm-peek-empty';empty.textContent=preview.empty;card.append(empty);}
    if(preview.footnote){const note=document.createElement('p');note.className='tm-peek-footnote';note.textContent=preview.footnote;card.append(note);}position();
  }
  function show(node:HTMLElement){
    if(anchor===node)return;clear();anchor=node;const token=revision;timer=window.setTimeout(()=>{
      if(anchor!==node||!node.isConnected)return;const name=node.dataset.placeName??'',area=node.dataset.placeArea??'',isDestination=node.dataset.placePreview==='destination';render({name,area,kind:isDestination?'Destination':node.dataset.placePreview==='pace'?'Travel pace':node.dataset.placePreview==='transport'?'Vehicle preview':'Loading details…',image:isDestination?destinationPhoto(name,area)?.src:node.dataset.placeImage});card.showPopover();position();node.setAttribute('aria-describedby',((node.getAttribute('aria-describedby')??'')+' '+card.id).trim());
      const identity=currentIdentity(),key=[identity.id??'guest',node.dataset.placePreview,node.dataset.placeId,name].join(':');let entry=cache.get(key);
      if(!entry||entry.expires<Date.now()){if(cache.size>=48)cache.delete(cache.keys().next().value!);entry={expires:Date.now()+240000,promise:load(node).catch(()=>({name,area,kind:isDestination?'Destination':'Listing'}))};cache.set(key,entry);}
      void entry.promise.then(preview=>{if(token===revision&&anchor===node&&node.isConnected)render(preview);});
    },180);
  }
  document.addEventListener('pointerover',event=>{const node=(event.target as Element)?.closest<HTMLElement>('[data-place-preview]');if(node&&matchMedia('(hover:hover)').matches)show(node);});
  document.addEventListener('pointerout',event=>{if(anchor&&(!(event.relatedTarget instanceof Node)||!anchor.contains(event.relatedTarget)))clear();});
  document.addEventListener('focusin',event=>{const node=(event.target as Element)?.closest<HTMLElement>('[data-place-preview]');node?show(node):clear();});
  document.addEventListener('click',event=>{if(matchMedia('(hover:none)').matches){const node=(event.target as Element)?.closest<HTMLElement>('[data-place-preview=pace],[data-place-preview=transport]');if(node)show(node);}});
  document.addEventListener('pointerdown',clear,true);document.addEventListener('keydown',event=>{if(event.key==='Escape'){if(card.matches(':popover-open')){event.preventDefault();event.stopImmediatePropagation();}clear();}},true);
  document.addEventListener('scroll',()=>{if(anchor===document.activeElement?.closest('[data-place-preview]'))position();else clear();},true);window.addEventListener('resize',clear);window.addEventListener('hashchange',clear);window.addEventListener('travelmate:owner-workspace-close',clear);window.addEventListener('travelmate:identity',()=>{cache.clear();clear();});window.addEventListener('travelmate:preview-clear',clear);
}
