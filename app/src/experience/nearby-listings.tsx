import {useEffect,useState} from 'react';
import {ArrowUpRight} from 'lucide-react';
import {Button} from '../components/ui/button';
import {client,errorMessage,navigate,photosFor,useIdentity,type Listing} from './state';
import {EmptyState,ErrorState,ListingCard,LoadingCards} from './shared';

/** Other approved places in this listing's destination, loaded when its drawer opens. */
export function NearbyListings({destination,type,area,exclude}:{destination:string;type:Listing['listing_type'];area?:string;exclude:string}){
 const identity=useIdentity(),[listings,setListings]=useState<Listing[]>([]),[loading,setLoading]=useState(true),[error,setError]=useState(''),[version,setVersion]=useState(0);
 const label=type==='hotel'?'stays':type==='restaurant'?'restaurants':'attractions';
 useEffect(()=>{
  let live=true;setLoading(true);setError('');setListings([]);
  void(async()=>{try{
   const result=await client.from('business_listings').select('id,name,is_sample,listing_type,description,address,destination_id')
    .eq('destination_id',destination).eq('listing_type',type).eq('status','approved').neq('id',exclude).order('name').limit(200);
   if(result.error)throw result.error;
   const places=await photosFor(result.data as Listing[]);
   if(live)setListings(places);
  }catch(error){if(live)setError(errorMessage(error));}finally{if(live)setLoading(false);}})();
  return()=>{live=false;};
 },[destination,type,exclude,identity.id,version]);
 return <section className="tm-nearby-listings" aria-label={'Nearby '+label}>
  <p className="tm-description">{area?'Discover '+label+' in '+area+'.':'Discover '+label+' in this destination.'}</p>
  {loading?<LoadingCards/>:error?<ErrorState message={error} retry={()=>setVersion(value=>value+1)}/>:listings.length?<div className="tm-drawer-card-grid">{listings.map(listing=><ListingCard key={listing.id} listing={listing} compact/>)}</div>:<EmptyState title={'No approved '+label+' here yet'}>New places will appear after they are approved.</EmptyState>}
  <Button className="tm-nearby-destination-link" variant="outline" onClick={()=>navigate('/destination/'+destination)}>Explore {area||'this destination'}<ArrowUpRight/></Button>
 </section>;
}
