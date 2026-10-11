import {ChevronLeft,ChevronRight} from 'lucide-react';
import {Button} from '../components/ui/button';

export function PageNavigation({page,total,pageSize,onChange,label,noun,disabled=false}:{
 page:number;total:number;pageSize:number;onChange:(page:number)=>void;label:string;noun:string;disabled?:boolean;
}){
 const pages=Math.max(1,Math.ceil(total/pageSize)),current=Math.min(page,pages-1);
 const start=Math.max(0,Math.min(current-1,pages-3)),numbers=Array.from({length:Math.min(3,pages)},(_,index)=>start+index);
 return <nav className="tm-page-navigation" aria-label={label}>
  <span className="tm-page-range" aria-live="polite"><strong>{total?current*pageSize+1:0}–{Math.min((current+1)*pageSize,total)}</strong> of {total} {noun}</span>
  <div className="tm-page-controls">
   <Button variant="outline" className="tm-page-previous" aria-label="Previous page" disabled={disabled||current===0} onClick={()=>onChange(current-1)}><ChevronLeft aria-hidden="true"/><span>Previous</span></Button>
   {start>0&&<><Button className="tm-page-boundary" variant="outline" size="icon" aria-label="Go to page 1" disabled={disabled} onClick={()=>onChange(0)}>1</Button>{start>1&&<span className="tm-page-gap" aria-hidden="true">…</span>}</>}
   {numbers.map(number=><Button key={number} variant={number===current?'default':'outline'} size="icon" aria-label={'Go to page '+(number+1)} aria-current={number===current?'page':undefined} disabled={disabled} onClick={()=>onChange(number)}>{number+1}</Button>)}
   {start+numbers.length<pages&&<>{start+numbers.length<pages-1&&<span className="tm-page-gap" aria-hidden="true">…</span>}<Button className="tm-page-boundary" variant="outline" size="icon" aria-label={'Go to page '+pages} disabled={disabled} onClick={()=>onChange(pages-1)}>{pages}</Button></>}
   <Button variant="outline" className="tm-page-next" aria-label="Next page" disabled={disabled||current>=pages-1} onClick={()=>onChange(current+1)}><span>Next</span><ChevronRight aria-hidden="true"/></Button>
  </div>
 </nav>;
}
