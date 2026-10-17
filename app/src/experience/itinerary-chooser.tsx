import {useEffect,useState} from 'react';
import {Plus,Map,MapPin,CalendarDays,ArrowRight,Paperclip} from 'lucide-react';
import {Button} from '../components/ui/button';
import {Modal} from './modal';
import {AttachBookingDialog} from './trip-bookings';
import {startNewItinerary,type ItineraryChoice} from '../itinerary-choice';
import {type BookingTrip,type BookingCatalog,bookingDate} from '../trip-booking-logic';
import {client,currentIdentity,useIdentity,errorMessage,navigate} from './state';

type DestinationTrip=BookingTrip&{destination_id:string;destinations?:{name:string;province:string}|null};
export function ItineraryFlow(){
 const identity=useIdentity(),[request,setRequest]=useState<ItineraryChoice|null>(null),[attachment,setAttachment]=useState<{bookingId:string;trip?:BookingTrip;prompt?:boolean}|null>(null),[error,setError]=useState('');
 useEffect(()=>{const choose=(event:Event)=>{if(currentIdentity().role==='traveler'){setAttachment(null);setRequest((event as CustomEvent<ItineraryChoice>).detail);}};
  const attach=(event:Event)=>{const input=(event as CustomEvent<{bookingId:string;tripId?:string;prompt?:boolean}>).detail,uid=currentIdentity().id;if(currentIdentity().role!=='traveler')return;setRequest(null);setError('');
   if(!input.tripId){setAttachment({bookingId:input.bookingId,prompt:input.prompt});return;}
   void client.from('trips').select('id,name,destination_id,start_date,end_date,arrival_time,departure_time,budget,budget_currency,status').eq('id',input.tripId).eq('profile_id',uid!).single().then(({data,error})=>{if(currentIdentity().id!==uid)return;if(error)setError(errorMessage(error));else setAttachment({bookingId:input.bookingId,trip:data as BookingTrip});});
  };
  window.addEventListener('travelmate:choose-itinerary',choose);window.addEventListener('travelmate:attach-booking',attach);
  return()=>{window.removeEventListener('travelmate:choose-itinerary',choose);window.removeEventListener('travelmate:attach-booking',attach);};
 },[]);
 useEffect(()=>{setRequest(null);setAttachment(null);setError('');if(identity.role==='traveler'){try{const raw=sessionStorage.getItem('travelmate:pending-itinerary-choice');if(raw){sessionStorage.removeItem('travelmate:pending-itinerary-choice');setRequest(JSON.parse(raw));}}catch{/* Invalid old draft context can be ignored. */}}},[identity.id,identity.role]);
 useEffect(()=>{
  if(identity.role!=='traveler'||location.pathname!=='/payment-success')return;
  let context:{profileId?:string;bookingId?:string};try{context=JSON.parse(sessionStorage.getItem('travelmate:checkout-booking')||'null');}catch{return;}
  if(!context||context.profileId!==identity.id||!context.bookingId)return;
  let live=true,timer=0,tries=0;
  const check=async()=>{try{const r=await client.rpc('my_trip_booking_catalog',{p_trip:null});if(!live)return;
   const booking=!r.error?(r.data as BookingCatalog).bookings.find(b=>b.booking_id===context.bookingId):undefined;
   // A checkout redirect alone is never proof of payment.
   if(booking&&booking.payment_status==='paid'&&['confirmed','completed'].includes(booking.status)){
    sessionStorage.removeItem('travelmate:checkout-booking');if(!booking.attached_trip_id)setAttachment({bookingId:booking.booking_id,prompt:true});return;
   }
  }catch{/* A delayed webhook or connection can be retried without reserving again. */}
   if(live&&++tries<12)timer=window.setTimeout(()=>void check(),5000);
  };void check();return()=>{live=false;clearTimeout(timer);};
 },[identity.id,identity.role]);
 if(identity.role!=='traveler')return null;
 return <>{request&&<ItineraryChooser request={request} close={()=>setRequest(null)} attach={(trip,bookingId)=>{setRequest(null);setAttachment({trip,bookingId});}}/>}{attachment&&<AttachBookingDialog trip={attachment.trip} bookingId={attachment.bookingId} prompt={attachment.prompt} close={()=>setAttachment(null)} saved={result=>{setAttachment(null);if(result?.trip_id)window.dispatchEvent(new CustomEvent('travelmate:open-planner',{detail:{id:result.trip_id,day:result.planned_date}}));}}/>}{error&&<Modal title="Open your trip" close={()=>setError('')}><div className="tm-itinerary-chooser"><p role="alert">{error}</p><Button onClick={()=>{setError('');navigate('/trips');}}>My trips</Button></div></Modal>}</>;
}
function ItineraryChooser({request,close,attach}:{request:ItineraryChoice;close:()=>void;attach:(trip:BookingTrip,bookingId:string)=>void}){
 const identity=useIdentity(),[trips,setTrips]=useState<DestinationTrip[]>([]),[destination,setDestination]=useState(request.destinationName||''),[loading,setLoading]=useState(true),[error,setError]=useState(''),[version,setVersion]=useState(0),[showExisting,setShowExisting]=useState(false);
 useEffect(()=>{let live=true;setLoading(true);setError('');void(async()=>{try{
  const [rows,area]=await Promise.all([client.from('trips').select('id,name,destination_id,start_date,end_date,arrival_time,departure_time,budget,budget_currency,status').eq('profile_id',identity.id!).eq('destination_id',request.destinationId).eq('status','draft').not('start_date','is',null).order('start_date',{ascending:false}),client.from('destinations').select('name,province').eq('id',request.destinationId).single()]);
  if(rows.error)throw rows.error;if(area.error)throw area.error;if(live){setTrips(rows.data as DestinationTrip[]);setDestination([area.data.name,area.data.province].filter(Boolean).join(' · '));}
 }catch(e){if(live)setError(errorMessage(e));}finally{if(live)setLoading(false);}})();return()=>{live=false;};},[request.destinationId,identity.id,version]);
 function create(){close();startNewItinerary(request);}
 function existing(trip:DestinationTrip){if(request.bookingId){attach(trip,request.bookingId);return;}close();window.dispatchEvent(new CustomEvent('travelmate:open-planner',{detail:{id:trip.id,listingId:request.listingId}}));}
 return <Modal title="Add to an itinerary" close={close} closeOnOutside className="tm-itinerary-choice-modal"><div className="tm-itinerary-chooser"><p>{request.listingName?<><strong>{request.listingName}</strong> · choose where to plan this stop.</>:'Choose a new itinerary or continue one you already saved.'}</p><div className="tm-itinerary-destination"><MapPin size={20}/><strong>{destination||'Loading destination…'}</strong></div><div className="tm-itinerary-choice-grid"><button onClick={create}><Plus size={28}/><strong>New itinerary</strong><span>Choose dates and start a new trip here.</span><ArrowRight size={20}/></button><button aria-expanded={showExisting} onClick={()=>setShowExisting(v=>!v)}><Map size={28}/><strong>Existing itinerary</strong><span>Add this to a saved trip for this destination.</span><ArrowRight size={20}/></button></div>{showExisting&&<section aria-label="Existing itineraries"><h3>Your trips to {destination}</h3>{loading?<p role="status">Loading saved itineraries…</p>:error?<><p role="alert">{error}</p><Button onClick={()=>setVersion(v=>v+1)}>Try again</Button></>:trips.length?<div className="tm-existing-trip-choices">{trips.map(trip=><button key={trip.id} onClick={()=>existing(trip)}><CalendarDays size={22}/><span><strong>{trip.name}</strong><small>{bookingDate(trip.start_date)} – {bookingDate(trip.end_date)}</small><small><MapPin size={14}/>{destination}</small></span>{request.bookingId?<Paperclip size={21}/>:<ArrowRight size={21}/>}</button>)}</div>:<p>No saved itineraries for this destination yet. Choose New itinerary to start one.</p>}</section>}</div></Modal>;
}
