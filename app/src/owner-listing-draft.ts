import type {SupabaseClient} from '@supabase/supabase-js';
import {checkImage,IMAGE_TYPES} from './ui';

type Kind='hotel'|'restaurant'|'attraction';
type Item={kind:Kind;values:Record<string,string>;saved:boolean};
export function ownerListingDraft(form:HTMLFormElement,type:()=>string){
  const inventory=document.createElement('section'),photos=document.createElement('section');inventory.className=photos.className='tm-owner-draft-section';
  const items:Item[]=[],images:{file:File;url:string;saved:boolean}[]=[];let busy=false;
  const blocks=new Map<Kind,{root:HTMLElement;fields:HTMLInputElement[];list:HTMLElement}>();
  const definitions:{kind:Kind;title:string;fields:[string,string,string?][]}[]=[
    {kind:'hotel',title:'Rooms',fields:[['room_number','Room number'],['room_type','Room type'],['max_guests','Guests','number'],['base_nightly_rate','Nightly rate (₱)','number']]},
    {kind:'restaurant',title:'Menu',fields:[['name','Dish or drink'],['category','Category'],['price','Price (₱)','number'],['description','Description']]},
    {kind:'attraction',title:'Additional schedules',fields:[['operating_day','Day'],['schedule_text','Visiting hours']]}
  ];
  function renderItems(){for(const [kind,block]of blocks){block.list.replaceChildren();items.filter(item=>item.kind===kind).forEach(item=>{const row=document.createElement('div');row.className='tm-owner-draft-item';const text=document.createElement('span');text.textContent=kind==='hotel'?`Room ${item.values.room_number} · ${item.values.room_type}`:kind==='restaurant'?item.values.name:`${item.values.operating_day} · ${item.values.schedule_text}`;const action=document.createElement('button');action.type='button';action.textContent=item.saved?'Saved':'Remove';action.disabled=item.saved||busy;action.onclick=()=>{items.splice(items.indexOf(item),1);renderItems();};row.append(text,action);block.list.append(row);});}}
  function collect(kind:Kind,optional=false){
    const block=blocks.get(kind)!;const values=Object.fromEntries(block.fields.map(field=>[field.name,field.value.trim()]));
    if(optional&&!block.fields.some(field=>field.value.trim()))return;
    if(kind==='hotel'){if(!values.room_number||!values.room_type)throw new Error('Enter a room number and type.');if(!Number.isInteger(Number(values.max_guests))||Number(values.max_guests)<1)throw new Error('Room guests must be a whole number of at least 1.');if(!values.base_nightly_rate||!Number.isFinite(Number(values.base_nightly_rate))||Number(values.base_nightly_rate)<=0)throw new Error('Set a nightly rate above 0.');}
    if(kind==='restaurant'){if(!values.name)throw new Error('Enter the dish or drink name.');if(!values.price||!Number.isFinite(Number(values.price))||Number(values.price)<0)throw new Error('Enter a menu price of 0 or more.');}
    if(kind==='attraction'&&(!values.operating_day||!values.schedule_text))throw new Error('Enter a day and visiting hours.');
    if(items.some(item=>item.kind===kind&&(kind==='hotel'?item.values.room_number===values.room_number:kind==='restaurant'?item.values.name.toLowerCase()===values.name.toLowerCase():item.values.operating_day===values.operating_day&&item.values.schedule_text===values.schedule_text)))throw new Error('That room, menu item or schedule has already been added.');
    items.push({kind,values,saved:false});block.fields.forEach(field=>field.value='');renderItems();
  }
  const error=document.createElement('p');error.className='tm-owner-draft-error';error.setAttribute('role','alert');
  definitions.forEach(definition=>{const root=document.createElement('div'),heading=document.createElement('h3'),copy=document.createElement('p'),fields:HTMLInputElement[]=[],grid=document.createElement('div'),list=document.createElement('div');heading.textContent=definition.title;copy.textContent='Add the details now. They will be saved with your listing.';grid.className='tm-owner-draft-fields';
    definition.fields.forEach(([name,label,inputType])=>{const wrap=document.createElement('label'),input=document.createElement('input');wrap.textContent=label;input.name=name;input.type=inputType??'text';if(input.type==='text')input.maxLength=name==='description'?500:120;else{input.min=name==='price'?'0':'1';input.step=name==='max_guests'?'1':'0.01';}wrap.append(input);grid.append(wrap);fields.push(input);});
    const add=document.createElement('button');add.type='button';add.className='quiet';add.textContent=definition.kind==='hotel'?'+ Add room':definition.kind==='restaurant'?'+ Add menu item':'+ Add schedule';add.onclick=()=>{try{collect(definition.kind);error.textContent='';}catch(e){error.textContent=(e as Error).message;}};
    root.append(heading,copy,list,grid,add);inventory.append(root);blocks.set(definition.kind,{root,fields,list});});inventory.append(error);
  const photoHeading=document.createElement('h3'),photoCopy=document.createElement('p'),input=document.createElement('input'),gallery=document.createElement('div'),photoError=document.createElement('p');photoHeading.textContent='Listing photos';photoCopy.textContent='Choose up to 6 photos. JPEG, PNG or WebP, up to 5 MB each. Photos are reviewed before publication.';input.type='file';input.multiple=true;input.accept='image/jpeg,image/png,image/webp';input.setAttribute('aria-label','Choose listing photos');gallery.className='tm-owner-draft-gallery';photoError.className='tm-owner-draft-error';photoError.setAttribute('role','alert');
  const renderPhotos=()=>{gallery.replaceChildren();images.forEach(image=>{const figure=document.createElement('figure'),img=document.createElement('img'),caption=document.createElement('figcaption'),remove=document.createElement('button');img.src=image.url;img.alt=image.file.name;caption.textContent=image.file.name;remove.type='button';remove.textContent=image.saved?'Saved':'Remove';remove.disabled=image.saved||busy;remove.onclick=()=>{URL.revokeObjectURL(image.url);images.splice(images.indexOf(image),1);renderPhotos();};figure.append(img,caption,remove);gallery.append(figure);});};
  input.onchange=()=>{const selected=Array.from(input.files??[]);const invalid=selected.map(checkImage).find(Boolean);if(invalid||images.length+selected.length>6){photoError.textContent=invalid||'You can add up to 6 listing photos.';input.value='';return;}selected.forEach(file=>images.push({file,url:URL.createObjectURL(file),saved:false}));input.value='';photoError.textContent='';renderPhotos();};photos.append(photoHeading,photoCopy,input,photoError,gallery);
  const sync=()=>blocks.forEach((block,kind)=>block.root.hidden=kind!==type());form.addEventListener('change',sync);sync();
  return {
    inventory,photos,
    setBusy(value:boolean){busy=value;[inventory,photos].forEach(panel=>panel.querySelectorAll<HTMLInputElement|HTMLButtonElement>('input,button').forEach(field=>field.disabled=value));renderItems();renderPhotos();},
    validate(){try{collect(type() as Kind,true);error.textContent='';}catch(e){error.textContent=(e as Error).message;throw e;}},
    summary(){return `${items.filter(item=>item.kind===type()).length} rooms/menu items/schedules · ${images.length} photos`;},
    hasChanges(){return items.some(item=>!item.saved)||images.some(image=>!image.saved)||Array.from(blocks.values()).some(block=>block.fields.some(field=>field.value));},
    async save(client:SupabaseClient,id:string,user:string,stillOwner:()=>boolean){
      for(const item of items.filter(item=>item.kind===type()&&!item.saved)){
        if(!stillOwner())throw new Error('Your account changed. Reopen your listing.');const v=item.values;
        const result=await client.rpc(item.kind==='hotel'?'owner_add_room':item.kind==='restaurant'?'owner_add_menu_item':'owner_add_schedule',item.kind==='hotel'?{p_hotel:id,p_room_number:v.room_number,p_room_type:v.room_type,p_max_guests:Number(v.max_guests),p_rate:Number(v.base_nightly_rate)}:item.kind==='restaurant'?{p_restaurant:id,p_name:v.name,p_category:v.category||null,p_price:Number(v.price),p_description:v.description||null}:{p_attraction:id,p_day:v.operating_day,p_text:v.schedule_text});if(result.error)throw result.error;item.saved=true;renderItems();
      }
      if(images.some(image=>!image.saved)){
        const identity=await client.auth.getUser();if(identity.error||identity.data.user?.id!==user)throw new Error('Please log in again.');
        for(const image of images.filter(image=>!image.saved)){if(!stillOwner())throw new Error('Your account changed. Reopen your listing.');const path=user+'/'+id+'/'+crypto.randomUUID()+'.'+IMAGE_TYPES[image.file.type];const upload=await client.storage.from('travelmate-listings').upload(path,image.file,{contentType:image.file.type,upsert:false});if(upload.error)throw upload.error;const result=await client.rpc('owner_add_photo',{p_listing:id,p_path:path});if(result.error){await client.storage.from('travelmate-listings').remove([path]);throw result.error;}image.saved=true;renderPhotos();}
      }
    },
    reset(){items.length=0;images.forEach(image=>URL.revokeObjectURL(image.url));images.length=0;blocks.forEach(block=>block.fields.forEach(field=>field.value=''));error.textContent=photoError.textContent='';renderItems();renderPhotos();sync();}
  };
}
