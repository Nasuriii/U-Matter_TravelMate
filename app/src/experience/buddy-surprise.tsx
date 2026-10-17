import {useEffect,useState,type CSSProperties} from 'react';
import {RefreshCw,MapPin,ArrowUpRight,Sparkles,Compass,Utensils,ChefHat} from 'lucide-react';
import {chooseSurpriseCards,surpriseKey,type SurpriseCategory,type SurprisePick} from '../buddy-surprise-logic';
import {sampleMenuPhoto} from '../sample-photos';
import {client,photosFor,useIdentity,navigate,money,type Listing,type Destination} from './state';
import {destinationPhoto} from './destination-photos';
import {Modal} from './modal';
import {Button} from '../components/ui/button';

const categories=[{id:'all',name:'Marsey mix',icon:Sparkles},{id:'destination',name:'Destinations',icon:Compass},{id:'restaurant',name:'Restaurants',icon:Utensils},{id:'meal',name:'Meals',icon:ChefHat}] as const;
type Meal={id:string;restaurant_id:string;name:string;description:string|null;category:string;price:number|null};
export function BuddySurprise({close,sticker=1}:{close:()=>void;sticker?:number}){
 const identity=useIdentity(),[pool,setPool]=useState<SurprisePick[]>([]),[cards,setCards]=useState<SurprisePick[]>([]),[category,setCategory]=useState<SurpriseCategory>('all'),[warning,setWarning]=useState(''),[error,setError]=useState(''),[version,setVersion]=useState(0),[draw,setDraw]=useState(0),[loading,setLoading]=useState(true);
 useEffect(()=>{let live=true;setLoading(true);setError('');setWarning('');setPool([]);setCards([]);setCategory('all');
  void(async()=>{try{
   const [destinations,restaurants]=await Promise.all([
    client.from('destinations').select('id,name,province').eq('is_active',1).order('name').limit(100),
    client.from('business_listings').select('id,name,is_sample,listing_type,description,address,destination_id').eq('status','approved').eq('listing_type','restaurant').order('name').limit(200)
   ]);
   if(!live)return;const notices:string[]=[];
   if(destinations.error)notices.push('Destination ideas are temporarily unavailable.');
   if(restaurants.error)notices.push('Restaurant and meal ideas are temporarily unavailable.');
   const areas=(destinations.error?[]:destinations.data||[]) as Destination[],places=await photosFor((restaurants.error?[]:restaurants.data||[]) as Listing[]);
   if(!live)return;
   const items:SurprisePick[]=[...areas.map(d=>({id:d.id,name:d.name,kind:'destination' as const,path:'/destination/'+d.id,image:destinationPhoto(d.name,d.province)?.src,area:d.province})),...places.map(p=>({id:p.id,name:p.name,kind:'restaurant' as const,path:'/listing/'+p.id,image:p.image,area:p.address||areas.find(d=>d.id===p.destination_id)?.name||'',description:p.description?.slice(0,150)}))];
   if(places.length){
    const meals=await client.from('menu_items').select('id,restaurant_id,name,description,category,price').in('restaurant_id',places.map(p=>p.id)).eq('is_available',1).order('name').limit(180);
    if(!live)return;
    if(meals.error)notices.push('Meal ideas are temporarily unavailable.');
    else{
     const rows=(meals.data||[]) as Meal[],images=new Map<string,string>(),real=rows.filter(m=>!places.find(p=>p.id===m.restaurant_id)?.preview);
     if(real.length){const photos=await client.from('photos').select('menu_item_id,bucket_id,object_path').in('menu_item_id',real.map(m=>m.id)).eq('status','approved').order('sort_order').limit(360);
      await Promise.all((photos.data||[]).filter((photo,i,all)=>all.findIndex(p=>p.menu_item_id===photo.menu_item_id)===i).map(async photo=>{try{const signed=await client.storage.from(photo.bucket_id||'travelmate-listings').createSignedUrl(photo.object_path,3600);if(signed.data?.signedUrl)images.set(photo.menu_item_id,signed.data.signedUrl);}catch{/* A restaurant cover can stand in for a missing meal photo. */}}));
     }
     for(const meal of rows){const restaurant=places.find(p=>p.id===meal.restaurant_id);if(!restaurant)continue;items.push({id:meal.id,name:meal.name,kind:'meal',path:'/listing/'+restaurant.id+'?section=restaurant',image:restaurant.preview?sampleMenuPhoto(meal.name,meal.category):images.get(meal.id)||restaurant.image,area:restaurant.name,description:meal.description?.slice(0,150)||meal.category,...(meal.price!=null?{price:Number(meal.price)}:{})});}
    }
   }
   if(!live)return;if(!items.length&&notices.length)throw Error('Marsey could not load any ideas. Please try again.');setPool(items);setCards(chooseSurpriseCards(items));setWarning(notices.join(' '));
  }catch(e){if(live)setError(e instanceof Error?e.message:'Could not load ideas. Please try again.');}finally{if(live)setLoading(false);}})();
  return()=>{live=false;};
 },[identity.id,identity.role,version]);
 function shuffle(next:SurpriseCategory=category){setCategory(next);setCards(current=>chooseSurpriseCards(pool,next,current.map(surpriseKey)));setDraw(n=>n+1);}
 return <Modal title="Marsey’s surprise cards" close={close} closeOnOutside className="tm-buddy-modal tm-buddy-card-modal"><div className="tm-buddy-reveal">
  <div className="tm-buddy-reveal-intro"><img src={'/marsey/marsey-sticker-'+sticker+'.png'} alt=""/><div><span><Sparkles size={17}/>A LITTLE ADVENTURE, DEALT BY MARSEY</span><h3>{loading?'Finding your next little adventure…':'Your next adventure could start here.'}</h3><p>Three ideas to explore. Pick a card or shuffle for something new.</p></div></div>
  <div className="tm-surprise-categories" role="group" aria-label="Surprise category">{categories.map(({id,name,icon:Icon})=><button type="button" key={id} aria-pressed={category===id} disabled={loading||!!error} onClick={()=>shuffle(id)}><Icon size={18}/>{name}</button>)}</div>
  {loading?<div className="tm-surprise-loading" role="status"><Sparkles size={25}/><p>Marsey is looking through destinations, restaurants and menus…</p></div>:error?<div className="tm-surprise-empty" role="alert"><p>{error}</p><Button onClick={()=>setVersion(v=>v+1)}>Try again</Button></div>:<>
   <div className="tm-surprise-card-grid" aria-label="Your surprise ideas" aria-live="polite">{cards.map((pick,i)=>{const Icon=pick.kind==='destination'?Compass:pick.kind==='restaurant'?Utensils:ChefHat;return <article className="tm-surprise-card" data-kind={pick.kind} key={draw+':'+surpriseKey(pick)} style={{'--reveal-delay':i*100+'ms'} as CSSProperties}><div className="tm-surprise-card-photo"><img src={pick.image||'/graphics/scenic-route.svg'} alt={pick.image?pick.name:''} onError={event=>{if(!event.currentTarget.src.endsWith('/graphics/scenic-route.svg'))event.currentTarget.src='/graphics/scenic-route.svg';}}/><span><Icon size={17}/>{pick.kind==='destination'?'Destination':pick.kind==='restaurant'?'Restaurant':'Meal idea'}</span></div><div className="tm-surprise-card-copy"><small><MapPin size={15}/>{pick.area||'Explore the listing'}</small><h4>{pick.name}</h4>{pick.description&&<p>{pick.description}</p>}{pick.price!=null&&<strong className="tm-surprise-meal-price">{money(pick.price)}</strong>}<Button variant="outline" onClick={()=>{close();navigate(pick.path);}}>{pick.kind==='destination'?'Explore destination':pick.kind==='restaurant'?'View restaurant':'See meal on menu'}<ArrowUpRight size={18}/></Button></div></article>;})}</div>
   {!cards.length&&<div className="tm-surprise-empty"><ChefHat size={28}/><h3>No {category==='all'?'ideas':categories.find(c=>c.id===category)?.name.toLowerCase()} available yet</h3><p>Try another category or explore destinations while more places are added.</p><Button variant="outline" onClick={()=>{close();navigate('/explore');}}>Explore destinations<ArrowUpRight/></Button></div>}
   {warning&&<p className="tm-surprise-notice" role="status">{warning}</p>}
   <div className="tm-surprise-deal-actions"><p>{cards.length<3&&cards.length>0?'Showing '+cards.length+' available '+(cards.length===1?'idea':'ideas')+'. ':''}Ideas to explore · check the listing for current availability.</p><Button disabled={!cards.length} onClick={()=>shuffle()}><RefreshCw size={18}/>Shuffle again</Button></div>
  </>}
 </div></Modal>;
}
