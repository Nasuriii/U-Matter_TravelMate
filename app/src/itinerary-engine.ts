export type Brief={id:string;name:string;destination_id:string;start_date:string;end_date:string;arrival_time:string;departure_time:string;travel_pace:string;interests:string[];budget:number|null;budget_currency:string;updated_at:string};
export type Venue={id:string;name:string;listing_type:string;description:string|null;address:string|null};
export type Stop={planned_date:string;planned_time:string;planned_end_time:string;activity:string;listing_id:string|null;recommendation_reason:string;notes:string};
const minutes=(s:string)=>{const [h,m]=s.split(':').map(Number);return h*60+m};
const clock=(n:number)=>`${Math.floor(n/60).toString().padStart(2,'0')}:${(n%60).toString().padStart(2,'0')}`;
const DAY=86400000;
export function buildItinerary(trip:Brief,venues:Venue[]):Stop[]{
 const start=Date.parse(trip.start_date+'T00:00:00Z'),end=Date.parse(trip.end_date+'T00:00:00Z');
 const days=(end-start)/DAY+1;
 if(!Number.isInteger(days)||days<1||days>14)throw Error('Choose a trip of 1–14 calendar days for this itinerary release.');
 const arrival=minutes(trip.arrival_time),departure=minutes(trip.departure_time);
 if(!Number.isFinite(arrival)||!Number.isFinite(departure)||(days===1&&departure<=arrival))throw Error('Complete valid arrival and departure times first.');
 const stops:Stop[]=[];const used=new Set<string>();const restaurants=venues.filter(v=>v.listing_type==='restaurant');
 const interests=trip.interests??[];const keywords:Record<string,RegExp>={nature:/beach|garden|nature|park|trail|mountain|falls|scenery/i,history:/history|historic|heritage|museum|church/i,shopping:/shop|market|mall|craft/i};
 const matches=(v:Venue)=>interests.filter(i=>keywords[i]?.test(v.name+' '+(v.description??'')));
 const sights=venues.filter(v=>v.listing_type==='attraction').sort((a,b)=>matches(b).length-matches(a).length||a.name.localeCompare(b.name));
 const maxSights=trip.travel_pace==='relaxed'?1:trip.travel_pace==='active'?3:2;
 const duration=trip.travel_pace==='relaxed'?120:90;
 for(let d=0;d<days;d++){
  const date=new Date(start+d*DAY).toISOString().slice(0,10);
  const lower=d===0?Math.min(arrival+60,1439):480;
  const upper=d===days-1?Math.max(departure-120,0):1200;
  const add=(from:number,to:number,title:string,venue:Venue|null,reason:string,notes:string)=>stops.push({planned_date:date,planned_time:clock(from),planned_end_time:clock(to),activity:title.slice(0,255),listing_id:venue?.id??null,recommendation_reason:reason,notes});
  if(d===0)add(arrival,arrival,'Arrive at destination',null,'Your saved arrival time.','Travel boundary, not a flight booking.');
  let cursor=Math.max(480,lower),count=0;
  while(cursor<upper){
   if(cursor>=720&&cursor<840&&cursor+60<=upper){
    const venue=restaurants.find(v=>!used.has(v.id));if(venue)used.add(venue.id);
    add(cursor,cursor+60,venue?`Lunch · ${venue.name}`:'Lunch break · choose a place',venue??null,venue?(interests.includes('food')?'An approved restaurant at your destination, supporting your food interest.':'An approved local restaurant for a meal break.'):'No unused restaurant suggestion is available in this catalog.','Allow 60 minutes for lunch. Opening hours, menu prices and availability need confirmation.');cursor+=90;continue;
   }
   const venue=sights.find(v=>!used.has(v.id));
   // Leave room for lunch instead of scheduling a visit across it.
   const lunchBoundary=cursor<720?720:upper;
   if(venue&&count<maxSights&&cursor+duration<=Math.min(upper,lunchBoundary)){
    used.add(venue.id);count++;
    const tags=matches(venue);
    add(cursor,cursor+duration,venue.name,venue,tags.length?`Its catalog name or description matches your ${tags.join(', ')} interest. Fits the proposed ${trip.travel_pace} pace.`:`An approved attraction at your destination, selected for variety at a ${trip.travel_pace} pace.`,`${duration}-minute visit estimate. Allow 30 minutes afterward for travel or rest; this is not a route estimate. Confirm opening hours, access and costs. ${venue.address?'Address: '+venue.address:''}`);
    cursor+=duration+30;continue;
   }
   const next=cursor<720?Math.min(720,upper):upper;
   if(next>cursor)add(cursor,next,'Flexible time · choose your own activity',null,!venue?'More approved attractions are needed for additional suggestions.':'Keep free time for your chosen pace or a slot too short for another visit.','No venue or booking is implied. Use for rest, exploring nearby, or a manually chosen activity.');
   cursor=next;
  }
  if(upper<=Math.max(480,lower))add(d===0?arrival:Math.max(0,departure-120),d===0?arrival:Math.max(0,departure-120),'No sightseeing window',null,'Arrival and departure allowances leave insufficient daytime for scheduled visits.','Adjust travel times or keep this day for transfers.');
  if(d===days-1)add(departure,departure,'Depart destination',null,'Your saved departure time.','The two hours before departure are reserved as a planning allowance. Confirm your actual check-in and transfer requirements.');
 }
 return stops;
}

// Validate and sort a manually edited proposal before it reaches the database.
export function validateSchedule(trip:Brief,items:Stop[]):Stop[]{
 if(!items.length)throw Error('Add at least one activity before saving.');
 const stamp=(date:string,time:string)=>{
  if(!/^\d{4}-\d{2}-\d{2}$/.test(date)||!/^([01]\d|2[0-3]):[0-5]\d(:00)?$/.test(time))throw Error('Each activity needs a valid date and time.');
  const value=Date.parse(`${date}T${time.slice(0,5)}:00Z`);
  if(!Number.isFinite(value)||new Date(value).toISOString().slice(0,10)!==date)throw Error('An activity has an invalid calendar date.');return value;
 };
 const lower=stamp(trip.start_date,trip.arrival_time),upper=stamp(trip.end_date,trip.departure_time);
 const sorted=items.map(x=>({...x,planned_time:x.planned_time.slice(0,5),planned_end_time:(x.planned_end_time??x.planned_time).slice(0,5)})).sort((a,b)=>stamp(a.planned_date,a.planned_time)-stamp(b.planned_date,b.planned_time)||stamp(a.planned_date,a.planned_end_time)-stamp(b.planned_date,b.planned_end_time));
 let last=-Infinity;
 for(const x of sorted){const start=stamp(x.planned_date,x.planned_time),end=stamp(x.planned_date,x.planned_end_time);
  if(!x.activity.trim()||x.activity.length>255)throw Error('Activity names must contain 1–255 characters.');
  if(end<start)throw Error(`“${x.activity}” ends before it starts.`);
  if(start<lower||end>upper)throw Error(`“${x.activity}” is outside your arrival and departure window.`);
  if(start<last)throw Error(`“${x.activity}” overlaps an earlier activity. Choose another time.`);
  last=end;
 }
 return sorted;
}
