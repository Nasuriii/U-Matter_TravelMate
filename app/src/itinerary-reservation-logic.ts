import type {Stop} from './itinerary-engine';

export const destinationDate=(value:string)=>new Date(value).toLocaleDateString('en-CA',{timeZone:'Asia/Manila',year:'numeric',month:'2-digit',day:'2-digit'});
export const destinationTime=(value:string)=>new Date(value).toLocaleTimeString('en-GB',{timeZone:'Asia/Manila',hour:'2-digit',minute:'2-digit',hour12:false});
export function proposedReservationStop(stop:Stop,slot?:{starts_at:string;ends_at:string}):Stop{
 return slot?{...stop,planned_date:destinationDate(slot.starts_at),planned_time:destinationTime(slot.starts_at),planned_end_time:destinationTime(slot.ends_at)}:stop;
}
export function reservationConflicts(stop:Stop,others:Stop[]){
 return others.filter(s=>s.planned_date===stop.planned_date&&s.planned_time<stop.planned_end_time&&s.planned_end_time>stop.planned_time&&s.activity!=='Arrive at destination'&&s.activity!=='Depart destination').map(s=>s.activity);
}
