/** Restaurant inventory always uses Philippine wall time, regardless of the owner's device. */
export function reservationSlotInput(start:string,end:string,capacity:string,now=Date.now()){
  const parse=(value:string)=>{if(!/^\d{4}-\d{2}-\d{2}T([01]\d|2[0-3]):([0-5]\d)$/.test(value))throw new Error('Choose a reservation date, start time and duration.');const date=new Date(value+':00+08:00');if(!Number.isFinite(date.getTime())||new Date(date.getTime()+8*60*60*1000).toISOString().slice(0,16)!==value)throw new Error('Choose a valid calendar date.');return date;};
  const a=parse(start),b=parse(end),seats=Number(capacity);
  if(a.getTime()<=now||b<=a)throw new Error('Choose a future start time and a later end time.');
  if(b.getTime()-a.getTime()>12*60*60*1000)throw new Error('A reservation slot can last up to 12 hours.');
  if(!Number.isInteger(seats)||seats<1||seats>500)throw new Error('Seat capacity must be a whole number from 1 to 500.');
  return {p_start:a.toISOString(),p_end:b.toISOString(),p_capacity:seats};
}
export function reservationSlotLabel(start:string,end:string){
  const a=new Date(start),b=new Date(end),day=new Intl.DateTimeFormat('en-CA',{timeZone:'Asia/Manila'}),overnight=day.format(a)!==day.format(b);
  return a.toLocaleString('en-PH',{timeZone:'Asia/Manila',month:'short',day:'numeric',year:'numeric',hour:'numeric',minute:'2-digit'})+' – '+(overnight?b.toLocaleString('en-PH',{timeZone:'Asia/Manila',month:'short',day:'numeric',year:'numeric',hour:'numeric',minute:'2-digit'}):b.toLocaleTimeString('en-PH',{timeZone:'Asia/Manila',hour:'numeric',minute:'2-digit'}));
}

/** Add minutes to a Philippine wall-clock value without depending on the device timezone. */
export function reservationSlotRange(date:string,time:string,duration:number){
  const start=date+'T'+time;
  if(!/^\d{4}-\d{2}-\d{2}T([01]\d|2[0-3]):[0-5]\d$/.test(start))throw new Error('Choose a reservation date and start time.');
  const stamp=Date.parse(start+':00Z');
  if(!Number.isFinite(stamp)||new Date(stamp).toISOString().slice(0,16)!==start)throw new Error('Choose a valid reservation date.');
  if(!Number.isInteger(duration)||duration<1||duration>720)throw new Error('Choose a duration from 1 to 720 minutes (12 hours).');
  return {start,end:new Date(stamp+duration*60000).toISOString().slice(0,16)};
}
