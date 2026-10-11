/** Trip times have minute precision and stay in the destination's local time. */
export function clockMinutes(value:string):number|null {
  const match=/^(\d{2}):(\d{2})(?::(\d{2})(?:\.\d{1,6})?)?$/.exec(value);
  if(!match)return null;
  const hour=Number(match[1]),minute=Number(match[2]),second=Number(match[3]??0);
  return hour<=23&&minute<=59&&second<=59?hour*60+minute:null;
}
export function clockValue(hour:number,minute:number,period:'AM'|'PM') {
  return `${String(hour%12+(period==='PM'?12:0)).padStart(2,'0')}:${String(minute).padStart(2,'0')}`;
}
export function clockParts(value:string) {
  const total=clockMinutes(value);
  if(total===null)return null;
  const hour=Math.floor(total/60);
  return {hour:hour%12||12,minute:total%60,period:hour<12?'AM' as const:'PM' as const};
}
export function clockLabel(value:string) {
  const parts=clockParts(value);
  return parts?`${parts.hour}:${String(parts.minute).padStart(2,'0')} ${parts.period}`:'Choose time';
}
export function tripTimesValid(start:string,end:string,arrival:string,departure:string) {
  const a=clockMinutes(arrival),b=clockMinutes(departure);
  return a!==null&&b!==null&&(start!==end||b>a);
}
