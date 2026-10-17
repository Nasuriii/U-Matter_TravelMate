import type {Stop} from './itinerary-engine';
export type BookingTrip={id:string;name:string;destination_id?:string|null;start_date:string;end_date:string;arrival_time?:string;departure_time?:string;budget:number|null;budget_currency:string;status:string};
export type TripBooking={destination_id?:string|null;is_test?:boolean;hold_expires_at?:string|null;id:string;trip_id:string;planned_date:string;booking_id:string|null;source:'travelmate'|'external';booking_type:'hotel'|'restaurant';name:string;address:string|null;listing_id:string|null;room:string|null;guest_count:number|null;start_date:string;end_date:string;start_time:string|null;end_time:string|null;amount:number;currency:string;status:string;payment_status:string;provider:string|null;reference:string;file_path:string|null;file_name:string|null};
export type PaidBooking=Omit<TripBooking,'id'|'trip_id'|'source'|'planned_date'|'provider'|'reference'|'file_path'|'file_name'> & {booking_id:string;attached_trip_id:string|null;attached_trip_name:string|null};
export type BookingCatalog={bookings:PaidBooking[];attachments:TripBooking[]};
export type BookingTripSeed={name:string;start_date:string;end_date:string;arrival_time:string;departure_time:string;party_size:number;budget_currency:string};
export function bookingVisitTimes(booking:Pick<PaidBooking,'booking_type'|'start_time'|'end_time'>){
 const start=booking.start_time?.slice(0,5)||(booking.booking_type==='hotel'?'14:00':'12:00');
 const endMinutes=Math.min(1439,Number(start.slice(0,2))*60+Number(start.slice(3,5))+60);
 return {start,end:booking.booking_type==='restaurant'&&booking.end_time&&booking.end_time.slice(0,5)>start?booking.end_time.slice(0,5):String(Math.floor(endMinutes/60)).padStart(2,'0')+':'+String(endMinutes%60).padStart(2,'0')};
}
export function bookingTripSeed(booking:PaidBooking):BookingTripSeed|null{
 const days=(Date.parse(booking.end_date)-Date.parse(booking.start_date))/86400000+1;
 if(!Number.isInteger(days)||days<1||days>14)return null;
 const times=bookingVisitTimes(booking);
 return {name:('Trip · '+booking.name).slice(0,150),start_date:booking.start_date,end_date:booking.end_date,arrival_time:times.start,departure_time:booking.booking_type==='hotel'?(booking.end_time?.slice(0,5)||'11:00'):booking.end_time?.slice(0,5)||times.end,party_size:Math.min(20,Math.max(1,booking.guest_count||1)),budget_currency:['PHP','USD','HKD'].includes(booking.currency)?booking.currency:'PHP'};
}
export function bookingScheduleCheck(booking:PaidBooking,trip:BookingTrip,day:string,start:string,end:string,items:Stop[]){
 const samePlace=items.filter(s=>s.planned_date===day&&!!booking.listing_id&&s.listing_id===booking.listing_id);
 // Scheduling reuses one matching stop, or an exact-time match when there are several.
 const reused=samePlace.length===1?samePlace[0]:samePlace.find(s=>s.planned_time.slice(0,5)===start&&s.planned_end_time.slice(0,5)===end);
 const overlaps=items.filter(s=>s!==reused&&s.planned_date===day&&s.planned_time.slice(0,5)<s.planned_end_time.slice(0,5)&&start<s.planned_end_time.slice(0,5)&&end>s.planned_time.slice(0,5));
 const outsideHours=(day===trip.start_date&&!!trip.arrival_time&&start<trip.arrival_time.slice(0,5))||(day===trip.end_date&&!!trip.departure_time&&end>trip.departure_time.slice(0,5));
 return {destinationMismatch:!!booking.destination_id&&!!trip.destination_id&&booking.destination_id!==trip.destination_id,outsideDates:bookingOutsideTrip(booking,trip),outsideHours,overlaps};
}
export const confirmationBucket='trip-confirmations';
export const confirmationTypes:Record<string,string>={'application/pdf':'pdf','image/jpeg':'jpg','image/png':'png','image/webp':'webp'};
export const confirmationLimit=10*1024*1024;
export function bookingOutsideTrip(booking:{start_date:string;end_date:string},trip:BookingTrip){return booking.start_date<trip.start_date||booking.end_date>trip.end_date;}
export function suggestedBookingDay(booking:{start_date:string},trip:BookingTrip){return booking.start_date<trip.start_date?trip.start_date:booking.start_date>trip.end_date?trip.end_date:booking.start_date;}
export function bookingOnDay(booking:TripBooking,date:string,trip?:BookingTrip){
 const planned=trip&&(booking.planned_date<trip.start_date||booking.planned_date>trip.end_date)?suggestedBookingDay(booking,trip):booking.planned_date;
 return date>=booking.start_date&&date<=booking.end_date||date===planned;
}
export function bookingBudget(items:TripBooking[],currency:string){
 const seen=new Set<string>();let cents=0;const other:Record<string,number>={};let external=0;
 for(const item of items){const key=item.booking_id?'booking:'+item.booking_id:'external:'+item.id;if(seen.has(key))continue;seen.add(key);
  if(item.is_test||!['confirmed','completed'].includes(item.status)||(item.source==='external'?item.payment_status!=='reported_paid':item.payment_status!=='paid'))continue;
  const amount=Number(item.amount);if(!Number.isFinite(amount)||amount<0)continue;
  if(item.currency===currency){cents+=Math.round(amount*100);if(item.source==='external')external+=Math.round(amount*100);}
  else other[item.currency]=(other[item.currency]||0)+Math.round(amount*100);
 }
 return {total:cents/100,external:external/100,other:Object.entries(other).map(([currency,cents])=>({currency,total:cents/100}))};
}
export function bookingMoney(amount:number,currency='PHP'){return new Intl.NumberFormat('en-PH',{style:'currency',currency,maximumFractionDigits:2}).format(amount);}
export function bookingDate(date:string){return new Date(date+'T12:00:00').toLocaleDateString('en-PH',{month:'short',day:'numeric',year:'numeric'});}
export function bookingTime(time:string|null){return time?new Date('2000-01-01T'+time.slice(0,5)+':00').toLocaleTimeString('en-PH',{hour:'numeric',minute:'2-digit'}):'Time not provided';}
export function confirmationFileError(file:Pick<File,'size'|'type'>){return !confirmationTypes[file.type]?'Choose a PDF, JPG, PNG or WebP confirmation.':file.size<=0?'Choose a file that is not empty.':file.size>confirmationLimit?'Your confirmation must be 10 MB or smaller.':'';}
