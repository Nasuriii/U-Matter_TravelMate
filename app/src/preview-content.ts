import {client,photosFor,money,type Listing} from './experience/state';
import {sampleRoomPhoto,sampleMenuPhoto} from './sample-photos';
import {paceGuides,paceLimitations,type Pace} from './travel-guidance';

export type Preview={name:string;area:string;kind:string;image?:string;description?:string;facts?:{label:string;value:string}[];details?:string;heading?:string;empty?:string;footnote?:string;places?:{name:string;kind:string;image?:string}[]};
export type PreviewKind='listing'|'destination'|'rooms'|'menu'|'attraction'|'pace'|'transport';
export function contextPreview(node:HTMLElement):Promise<Preview>|null{
 const kind=node.dataset.placePreview;
 if(kind==='pace'){
  const guide=paceGuides[node.dataset.placeId as Pace];if(!guide)return null;
  return Promise.resolve({name:guide.name,area:'How your suggested itinerary changes',kind:'Travel pace',description:guide.summary,
   facts:[{label:'Attractions',value:'Up to '+guide.maxAttractions+' attraction'+(guide.maxAttractions===1?'':'s')+' per day'},{label:'Visit length',value:'About '+guide.visitMinutes+' minutes per attraction'},{label:'Good for',value:guide.fit}],details:paceLimitations});
 }
 if(kind==='transport')return Promise.resolve({name:node.dataset.placeName||'Your ride',area:node.dataset.placeArea||'',kind:'Vehicle preview',image:node.dataset.placeImage,description:node.dataset.placeDescription,footnote:node.dataset.placeNote});
 return kind==='rooms'||kind==='menu'||kind==='attraction'?listingContents(node,kind):null;
}
async function listingContents(node:HTMLElement,kind:'rooms'|'menu'|'attraction'):Promise<Preview>{
 const id=node.dataset.placeId!,name=node.dataset.placeName||'Place details',area=node.dataset.placeArea||'';
 const read=await client.from('business_listings').select('id,name,is_sample,listing_type,description,address,destination_id').eq('id',id).eq('status','approved').maybeSingle();
 if(read.error||!read.data)return {name,area,kind:'Details preview',description:'The details could not be loaded. Select the button to open this place.'};
 const listing=(await photosFor([read.data as Listing]))[0];
 const base:Preview={name:listing.name,area,kind:kind==='rooms'?'Room options':kind==='menu'?'On the menu':'Explore this place'};
 if(kind==='rooms'){
  const rooms=await client.from('rooms').select('id,room_type,room_number,max_guests,base_nightly_rate,operational_status').eq('hotel_id',id).order('base_nightly_rate').limit(4);
  if(rooms.error)return {...base,description:'Room details are temporarily unavailable. Open this stay to try again.'};
  return {...base,places:(rooms.data??[]).map(room=>({name:room.room_type+' · Room '+room.room_number,kind:'Up to '+room.max_guests+' guests · '+(room.base_nightly_rate==null?'Rate on request':money(room.base_nightly_rate)+' / night')+(room.operational_status==='available'?'':' · '+room.operational_status),image:listing.preview?sampleRoomPhoto(room.id):undefined})),
   empty:'No room options have been added.',footnote:'Showing up to 4 room options. Dates are checked when reserving.'+(listing.preview?' Images are stay inspiration.':'')};
 }
 if(kind==='menu'){
  const menu=await client.from('menu_items').select('id,name,price,category').eq('restaurant_id',id).eq('is_available',1).order('category').limit(4);
  if(menu.error)return {...base,description:'The menu is temporarily unavailable. Open this restaurant to try again.'};
  const rows=menu.data??[],images=new Map<string,string>();
  if(rows.length&&!listing.preview){
   const photos=await client.from('photos').select('menu_item_id,bucket_id,object_path').in('menu_item_id',rows.map(item=>item.id)).eq('status','approved').order('sort_order').limit(12);
   for(const photo of photos.data??[]){if(images.has(photo.menu_item_id))continue;try{const result=await client.storage.from(photo.bucket_id||'travelmate-listings').createSignedUrl(photo.object_path,3600);if(result.data?.signedUrl)images.set(photo.menu_item_id,result.data.signedUrl);}catch{/* Dish names and prices remain available. */}}
  }
  return {...base,places:rows.map(item=>({name:item.name,kind:[item.category,item.price==null?'Price on request':money(item.price)].filter(Boolean).join(' · '),image:listing.preview?sampleMenuPhoto(item.name,item.category):images.get(item.id)})),
   empty:'No available menu items have been added.',footnote:'Select Explore menu to see the full menu.'+(listing.preview?' Images are food inspiration.':'')};
 }
 const [attraction,schedules]=await Promise.all([
  client.from('attractions').select('entrance_fee').eq('attraction_id',id).maybeSingle(),
  client.from('attraction_schedules').select('operating_day,schedule_text').eq('attraction_id',id).limit(4)
 ]);
 return {...base,image:listing.image,description:listing.description?.slice(0,280),facts:[{label:'Entrance fee',value:attraction.error?'Open the listing for fees':Number(attraction.data?.entrance_fee)===0&&attraction.data?.entrance_fee!=null?'Free entry':attraction.data?.entrance_fee==null?'Ask the place for entry fees':money(attraction.data.entrance_fee)}],
  heading:'Visiting hours',places:(schedules.data??[]).map(schedule=>({name:String(schedule.operating_day),kind:schedule.schedule_text})),empty:'Visiting hours have not been added.',footnote:'Select Explore place for photos and the full details.'};
}
