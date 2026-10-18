/** Restaurant inventory always uses Philippine wall time, regardless of the owner's device. */
export function reservationSlotInput(start:string,end:string,capacity:string,now=Date.now()){
  const parse=(value:string)=>{if(!/^\d{4}-\d{2}-\d{2}T([01]\d|2[0-3]):([0-5]\d)$/.test(value))throw new Error('Choose a start and end date and time.');const date=new Date(value+':00+08:00');if(!Number.isFinite(date.getTime())||new Date(date.getTime()+8*60*60*1000).toISOString().slice(0,16)!==value)throw new Error('Choose a valid calendar date.');return date;};
  const a=parse(start),b=parse(end),seats=Number(capacity);
  if(a.getTime()<=now||b<=a)throw new Error('Choose a future start time and a later end time.');
  if(b.getTime()-a.getTime()>12*60*60*1000)throw new Error('A reservation slot can last up to 12 hours.');
  if(!Number.isInteger(seats)||seats<1||seats>500)throw new Error('Seat capacity must be a whole number from 1 to 500.');
  return {p_start:a.toISOString(),p_end:b.toISOString(),p_capacity:seats};
}
export function reservationSlotLabel(start:string,end:string){
  return new Date(start).toLocaleString('en-PH',{timeZone:'Asia/Manila',month:'short',day:'numeric',year:'numeric',hour:'numeric',minute:'2-digit'})+' – '+new Date(end).toLocaleTimeString('en-PH',{timeZone:'Asia/Manila',hour:'numeric',minute:'2-digit'});
}
