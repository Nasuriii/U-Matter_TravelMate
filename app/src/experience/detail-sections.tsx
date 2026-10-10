import {useEffect,useState,type ReactNode,type ComponentType} from 'react';
import {ChevronRight} from 'lucide-react';
import {Modal} from './modal';
type Section={key:string;label:string;icon:ComponentType<{size?:number}>;content:ReactNode};
export function DetailSections({items}:{items:Section[]}){
 const [selected,setSelected]=useState<string|null>(location.hash.includes('review=1')?'reviews':null);const item=items.find(i=>i.key===selected);
 const [exiting,setExiting]=useState(false);
 const finishClose=()=>{setSelected(null);setExiting(false);};
 const requestClose=()=>{if(exiting)return;if(matchMedia('(prefers-reduced-motion: reduce)').matches)finishClose();else setExiting(true);};
 // Keep focus and the backdrop until the animation finishes; the timeout also
 // covers interrupted animations and changes to the reduced-motion setting.
 useEffect(()=>{if(!exiting)return;const timer=window.setTimeout(finishClose,320);return()=>window.clearTimeout(timer);},[exiting]);
 return <><nav className="tm-detail-section-nav" aria-label="Place details">{items.map(({key,label,icon:Icon})=><button key={key} onClick={()=>{setExiting(false);setSelected(key);}} aria-haspopup="dialog"><Icon size={18}/>{label}<ChevronRight size={14}/></button>)}</nav>{item&&<Modal title={item.label} close={requestClose} closeOnOutside exiting={exiting} onExitComplete={finishClose} className="tm-detail-drawer"><div className="tm-drawer-body">{item.content}</div></Modal>}</>;
}
