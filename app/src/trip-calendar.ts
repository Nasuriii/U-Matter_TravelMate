/** Calendar dates stay local; day counts use UTC to avoid daylight-saving shifts. */
export function calendarDate(value:string):Date|null {
  if(!/^\d{4}-\d{2}-\d{2}$/.test(value))return null;
  const date=new Date(value+'T12:00:00');
  return !Number.isNaN(date.getTime())&&dateKey(date)===value?date:null;
}
export function dateKey(date:Date) {
  return `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}`;
}
export function tripDays(start:string,end:string) {
  const a=calendarDate(start),b=calendarDate(end);
  if(!a||!b)return 0;
  return (Date.UTC(b.getFullYear(),b.getMonth(),b.getDate())-Date.UTC(a.getFullYear(),a.getMonth(),a.getDate()))/86400000+1;
}
export function monthCells(month:Date) {
  const first=new Date(month.getFullYear(),month.getMonth(),1,12);
  const length=new Date(month.getFullYear(),month.getMonth()+1,0,12).getDate();
  return Array.from({length:42},(_,index)=>{
    const day=index-first.getDay()+1;
    return day>=1&&day<=length?dateKey(new Date(first.getFullYear(),first.getMonth(),day,12)):null;
  });
}
