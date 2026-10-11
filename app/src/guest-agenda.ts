export type GuestReservation={id:string;status:string;booking_type:string;starts_at:string|null;ends_at:string|null;guest_name:string;guest_count:number;listing_name:string;room_type:string|null;room_number:string|null};
export function localBookingDay(value:string|null){
 if(!value)return '';if(/^\d{4}-\d{2}-\d{2}$/.test(value))return value;
 const time=new Date(value);if(Number.isNaN(time.getTime()))return '';
 const parts=new Intl.DateTimeFormat('en-CA',{timeZone:'Asia/Manila',year:'numeric',month:'2-digit',day:'2-digit'}).formatToParts(time);
 return ['year','month','day'].map(type=>parts.find(part=>part.type===type)?.value).join('-');
}
export function guestAgenda(rows:GuestReservation[],now=new Date()){
 const today=localBookingDay(now.toISOString()),later=new Date(today+'T12:00:00+08:00');later.setUTCDate(later.getUTCDate()+7);const until=localBookingDay(later.toISOString());
 const confirmed=rows.filter(row=>row.status==='confirmed'&&localBookingDay(row.starts_at));
 const arrivals=confirmed.filter(row=>localBookingDay(row.starts_at)===today);
 const departures=confirmed.filter(row=>row.booking_type==='hotel'&&localBookingDay(row.ends_at)===today);
 const staying=confirmed.filter(row=>row.booking_type==='hotel'&&localBookingDay(row.starts_at)<=today&&localBookingDay(row.ends_at)>today);
 const upcoming=confirmed.filter(row=>localBookingDay(row.starts_at)>=today&&localBookingDay(row.starts_at)<until).sort((a,b)=>(a.starts_at||'').localeCompare(b.starts_at||''));
 return {today,arrivals,departures,staying,upcoming};
}
