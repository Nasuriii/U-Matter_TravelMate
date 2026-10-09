import {useState,type ReactNode,type ComponentType} from 'react';
import {ChevronRight} from 'lucide-react';
import {Modal} from './modal';
type Section={key:string;label:string;icon:ComponentType<{size?:number}>;content:ReactNode};
export function DetailSections({items}:{items:Section[]}){
 const [selected,setSelected]=useState<string|null>(location.hash.includes('review=1')?'reviews':null);const item=items.find(i=>i.key===selected);
 return <><nav className="tm-detail-section-nav" aria-label="Place details">{items.map(({key,label,icon:Icon})=><button key={key} onClick={()=>setSelected(key)} aria-haspopup="dialog"><Icon size={18}/>{label}<ChevronRight size={14}/></button>)}</nav>{item&&<Modal title={item.label} close={()=>setSelected(null)} className="tm-detail-drawer"><div className="tm-drawer-body">{item.content}</div></Modal>}</>;
}
