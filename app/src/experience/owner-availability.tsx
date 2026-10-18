import {useEffect,useState} from 'react';
import {ArrowUpRight,BedDouble,CalendarDays,ChevronDown,Clock3,Plus,RefreshCw,Users,Utensils} from 'lucide-react';
import {Button} from '../components/ui/button';
import {DateRangeFields,DateTimeRangeFields} from '../trip-pickers';
import {reservationSlotInput,reservationSlotLabel} from '../owner-slot-logic';
import {confirmAction} from '../action-confirm';
import {placePreviewAttributes} from '../place-hover-preview';
import {toast} from '../ui';
import {client,currentIdentity,errorMessage,money,navigate,useIdentity} from './state';
import {FilterSelect} from './filter-select';
import {PageNavigation} from './page-navigation';

type Place={id:string;name:string;listing_type:string;status:string;address:string|null;destinations:{name:string;province:string}|null};
type Room={id:string;room_number:string;room_type:string;max_guests:number;base_nightly_rate:number;operational_status:string;available:boolean};
type Slot={id:string;starts_at:string;ends_at:string;capacity:number;remaining:number;is_open:number};
type Availability={rooms:Room[];slots:Slot[]};
const empty:Availability={rooms:[],slots:[]};
const statusName=(status:string)=>({approved:'Live',pending:'Awaiting review',inactive:'Inactive',rejected:'Changes needed'}[status]??status);
function stayDate(offset=0){const now=new Date();now.setUTCDate(now.getUTCDate()+offset);return new Intl.DateTimeFormat('en-CA',{timeZone:'Asia/Manila',year:'numeric',month:'2-digit',day:'2-digit'}).format(now);}

export function OwnerAvailability(){
 const identity=useIdentity(),[places,setPlaces]=useState<Place[]>([]),[error,setError]=useState(''),[loading,setLoading]=useState(true),[version,setVersion]=useState(0);
 useEffect(()=>{let cancelled=false;setPlaces([]);setLoading(true);setError('');void(async()=>{
  try{const owner=await client.from('business_owners').select('id').eq('profile_id',identity.id!).single();if(owner.error)throw owner.error;
   const result=await client.from('business_listings').select('id,name,listing_type,status,address,destinations(name,province)').eq('owner_id',owner.data.id).in('listing_type',['hotel','restaurant']).order('name');if(result.error)throw result.error;
   if(!cancelled)setPlaces(result.data as unknown as Place[]);
  }catch(e){if(!cancelled)setError(errorMessage(e));}finally{if(!cancelled)setLoading(false);}
 })();return()=>{cancelled=true;};},[identity.id,version]);
 if(loading)return <p role="status" className="tm-availability-note">Loading your availability tools…</p>;
 if(error)return <div role="alert" className="tm-error">{error}<Button variant="outline" onClick={()=>setVersion(v=>v+1)}>Try again</Button></div>;
 return <div className="tm-owner-availability">{(['restaurant','hotel'] as const).map(kind=>{const options=places.filter(place=>place.listing_type===kind);return options.length?<AvailabilityPanel key={kind+identity.id} kind={kind} places={options}/>:null;})}</div>;
}

function AvailabilityPanel({kind,places}:{kind:'restaurant'|'hotel';places:Place[]}){
 const identity=useIdentity(),hotel=kind==='hotel',Icon=hotel?BedDouble:Utensils;
 const [selected,setSelected]=useState(''),[dates,setDates]=useState({start:stayDate(),end:stayDate(1)}),[form,setForm]=useState({start:'',end:'',capacity:'20'});
 const [data,setData]=useState<Availability>(empty),[error,setError]=useState(''),[loading,setLoading]=useState(false),[busy,setBusy]=useState(false),[version,setVersion]=useState(0),[page,setPage]=useState(0);
 const place=places.find(p=>p.id===selected),validDates=!hotel||!!dates.start&&dates.end>dates.start;
 useEffect(()=>{let cancelled=false;setData(empty);setError('');if(!selected||!validDates){setLoading(false);return;}
  setLoading(true);void(async()=>{try{const result=await client.rpc('owner_availability',{p_listing:selected,p_start:hotel?dates.start:null,p_end:hotel?dates.end:null});if(result.error)throw result.error;if(!cancelled)setData(result.data as Availability);}catch(e){if(!cancelled)setError(errorMessage(e));}finally{if(!cancelled)setLoading(false);}})();return()=>{cancelled=true;};
 },[selected,dates.start,dates.end,validDates,hotel,identity.id,version]);
 useEffect(()=>setPage(0),[selected,dates.start,dates.end]);
 const rows=hotel?data.rooms:data.slots,total=rows.length,current=Math.min(page,Math.max(0,Math.ceil(total/4)-1));
 async function add(event:React.FormEvent){
  event.preventDefault();if(busy||!selected)return;const uid=identity.id;setBusy(true);setError('');
  try{const args=reservationSlotInput(form.start,form.end,form.capacity);
   if(!await confirmAction('Add table availability?',`${place?.name}\n${reservationSlotLabel(args.p_start,args.p_end)}\n${args.p_capacity} seats`,'Add time slot')||currentIdentity().id!==uid||currentIdentity().role!=='owner')return;
   const result=await client.rpc('owner_add_reservation_slot',{p_listing:selected,...args});if(result.error)throw result.error;if(currentIdentity().id!==uid)return;
   toast('Table availability added.');setForm(old=>({...old,start:'',end:''}));setVersion(v=>v+1);
  }catch(e){if(currentIdentity().id===uid)setError(errorMessage(e));}finally{setBusy(false);}
 }
 return <details className="tm-owner-slot-disclosure tm-availability-panel"><summary><Icon size={24}/><span>{hotel?'Hotel room availability':'Restaurant availability'}<small>{hotel?'Check room availability for a stay and manage your rooms.':'Create table times and see remaining seats.'}</small></span><ChevronDown size={20}/></summary>
  <div className="tm-availability-content"><div className="tm-availability-heading"><div><p className="tm-eyebrow">{hotel?'ROOMS & STAYS':'TABLES & RESERVATIONS'}</p><h2>{hotel?'Every room, ready for your guests.':'Make room for your next guests.'}</h2><p>{hotel?'Choose a hotel and stay dates. Availability includes confirmed bookings and active payment holds.':'Choose your restaurant, then add a date, time and seat capacity. All times are Philippine time.'}</p></div></div>
   <div className="tm-availability-choice"><FilterSelect label={hotel?'Hotel':'Restaurant'} value={selected} disabled={busy} searchable searchLabel={hotel?'Find your hotel':'Find your restaurant'} options={[{value:'',label:hotel?'Choose your hotel':'Choose your restaurant'},...places.map(p=>({value:p.id,label:p.name,previewId:p.id,previewKind:'listing' as const,area:p.address??p.destinations?.name??''}))]} onChange={setSelected}/><p className="tm-availability-hint">Hover or focus a place for photos. On a phone, hold to preview.</p></div>
   {place&&<><div className="tm-availability-place" tabIndex={0} ref={node=>{if(node)placePreviewAttributes(node,'listing',place.id,place.name,place.address??'');}}><span className="tm-availability-symbol"><Icon size={24}/></span><div><strong>{place.name}</strong><p>{[place.destinations?.name,place.destinations?.province].filter(Boolean).join(', ')||place.address||'Your listing'}</p></div><span className={'status s-'+place.status}>{statusName(place.status)}</span></div>
    {place.status!=='approved'&&<p className="tm-availability-note">You can prepare availability now. Travelers can book when this listing is live.</p>}
    {hotel?<section className="tm-availability-editor"><h3><CalendarDays size={20}/>Check a stay</h3><DateRangeFields start={dates.start} end={dates.end} onChange={(start,end)=>setDates({start,end})}/><p className="tm-availability-hint">Check-out day is available for another guest’s arrival.</p>{!validDates&&<p role="alert">Choose a check-out date after check-in.</p>}</section>:
     <form className="tm-availability-editor" onSubmit={add}><h3><Plus size={20}/>Add a table time</h3><fieldset disabled={busy}><DateTimeRangeFields start={form.start} end={form.end} disabled={busy} onChange={(start,end)=>setForm(old=>({...old,start,end}))}/><div className="tm-availability-submit"><label>Seat capacity<input required type="number" min="1" max="500" step="1" value={form.capacity} onChange={event=>setForm(old=>({...old,capacity:event.target.value}))}/></label><Button type="submit" disabled={busy}><Plus/>{busy?'Adding…':'Add time slot'}</Button></div><p className="tm-availability-hint">1–500 seats per slot · up to 12 hours</p></fieldset></form>}
    <div className="tm-availability-results-heading"><h3>{hotel?'Rooms for these dates':'Upcoming table times'}</h3><Button variant="outline" aria-label="Refresh availability" disabled={loading||busy} onClick={()=>setVersion(v=>v+1)}><RefreshCw size={17}/>Refresh</Button></div>
    {error&&<p role="alert" className="tm-error">{error}</p>}{loading?<p role="status">Checking availability…</p>:!error&&validDates?<>
     {hotel&&data.rooms.length>0&&<p className="tm-availability-note">{data.rooms.filter(room=>room.available).length} of {data.rooms.length} rooms available for this stay.</p>}
     <div className="tm-availability-results">{hotel?data.rooms.slice(current*4,(current+1)*4).map(room=><article key={room.id} className="tm-availability-result" data-available={room.available}><BedDouble size={24}/><div><h4>{room.room_type} <small>Room {room.room_number}</small></h4><p><Users size={16}/>{room.max_guests} guests · {money(room.base_nightly_rate)} / night</p></div><span className="tm-availability-badge">{room.operational_status!=='available'?room.operational_status.replaceAll('_',' '):room.available?'Available':'Reserved / on hold'}</span></article>):data.slots.slice(current*4,(current+1)*4).map(slot=><article className="tm-availability-result" data-available={!!slot.is_open&&slot.remaining>0} key={slot.id}><Clock3 size={24}/><div><h4>{reservationSlotLabel(slot.starts_at,slot.ends_at)}</h4><p>{slot.remaining} of {slot.capacity} seats remaining</p></div><span className="tm-availability-badge">{!slot.is_open?'Closed':slot.remaining===0?'Full':'Open'}</span></article>)}</div>
     {!total&&<p className="tm-availability-empty">{hotel?'No rooms added yet. Add your rooms in Manage hotel.':'No upcoming table times. Add your first slot above.'}</p>}
     {total>4&&<PageNavigation page={current} total={total} pageSize={4} onChange={setPage} label="Availability pages" noun={hotel?'rooms':'table times'}/>}
    </>:null}
    <div className="tm-availability-manage"><p>{hotel?'Update room details, nightly rates and operational status in your listing.':'Edit your menu, hours and listing details in your workspace.'}</p><Button variant="outline" onClick={()=>{const path='/owner?search='+encodeURIComponent(place.name);window.dispatchEvent(new CustomEvent('travelmate:notification-open',{detail:{path}}));navigate(path);}}>{hotel?'Manage hotel':'Manage restaurant'}<ArrowUpRight/></Button></div>
   </>}
  </div>
 </details>;
}
