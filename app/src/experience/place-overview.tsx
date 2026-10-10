import {useEffect,useState} from 'react';
import {MapPin,Phone,Mail,Globe,Star,Wifi,Car,Utensils,Waves,Wind,ShieldCheck,CheckCircle2} from 'lucide-react';
import {client,errorMessage} from './state';
import {ReviewText} from './reviews';
export function PlaceContact({address,phone,email,website}:{address:string;phone?:string|null;email?:string|null;website?:string|null}){
 const safeWebsite=website&&/^https?:\/\//i.test(website)?website:null;
 return <div className="tm-contact-lines"><p><MapPin size={17}/><strong>Address</strong><span>{address}</span><a href={'https://www.google.com/maps/search/?api=1&query='+encodeURIComponent(address)} target="_blank" rel="noreferrer">Show on map</a></p>{phone&&<p><Phone size={17}/><strong>Contact</strong><a href={'tel:'+phone.replace(/[^+\d]/g,'')}>{phone}</a></p>}{email&&<p><Mail size={17}/><a href={'mailto:'+email}>{email}</a></p>}{safeWebsite&&<p><Globe size={17}/><a href={safeWebsite} target="_blank" rel="noreferrer">Visit website</a></p>}{!phone&&!email&&!safeWebsite&&<p className="tm-muted"><Phone size={17}/>Contact details have not been added yet.</p>}</div>;
}
const iconFor=(name:string)=>/wi.fi|internet/i.test(name)?Wifi:/park|car/i.test(name)?Car:/pool|swim/i.test(name)?Waves:/air|cool/i.test(name)?Wind:/food|breakfast|restaurant/i.test(name)?Utensils:CheckCircle2;
export function AmenityGrid({items}:{items:string[]}){return <div className="tm-amenity-grid">{items.map(name=>{const Icon=iconFor(name);return <div key={name}><Icon size={22}/><span>{name}</span></div>;})}{!items.length&&<p className="tm-muted">Amenities will appear here when the owner adds them.</p>}</div>;}
type Review={id:string;author:string;rating:number;text:string|null;verified:boolean;avatar?:string};
export function ReviewHighlight({destination,listing}:{destination?:string;listing?:string}){
 const [feed,setFeed]=useState<{total:number;average:number|null;items:Review[];sample_items?:Review[]}|null>(null),[error,setError]=useState('');
 useEffect(()=>{let cancelled=false;setFeed(null);setError('');void Promise.resolve(client.rpc('place_reviews',{p_destination:destination??null,p_listing:listing??null,p_offset:0})).then(r=>{if(cancelled)return;if(r.error)setError(errorMessage(r.error));else setFeed(r.data);}).catch(e=>{if(!cancelled)setError(errorMessage(e));});return()=>{cancelled=true;};},[destination,listing]);
 const review=feed?.items[0]??feed?.sample_items?.[0],sample=!!review&&!feed?.items.length;
 return <section className="tm-review-highlight" aria-label="Visitor review highlight"><div className="tm-rating-summary"><strong>{feed?.average??(sample?review?.rating:'—')}</strong><div><b>{feed?.average?'Traveler rating':sample?'Example experience':'Traveler reviews'}</b><span>{feed?.total?feed.total+' reviews':sample?'Sample review':'No traveler ratings yet'}</span></div></div>{review?<div className="tm-highlight-quote"><div>{review.avatar&&<img src={review.avatar} alt=""/>}<strong>{review.author}</strong><span><Star size={15}/>{review.rating}/5</span>{review.verified&&<ShieldCheck size={16} aria-label="Verified booking"/>}</div><ReviewText text={review.text?.replace(/^Example experience:\s*/,'')||'This traveler left a rating.'}/></div>:<p className="tm-muted">{error?'Reviews could not be loaded. Open the Reviews tab to retry.':'Be the first to share a visit.'}</p>}</section>;
}
