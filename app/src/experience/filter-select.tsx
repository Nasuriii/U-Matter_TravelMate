import {useEffect,useId,useRef,useState,type KeyboardEvent} from 'react';
import {Check,ChevronDown,ListFilter,Search} from 'lucide-react';
import {createRoot} from 'react-dom/client';

type Option={value:string;label:string;count?:number};

/** A themed, keyboard-accessible filter that stays above scrolling content. */
export function FilterSelect({label,value,options,onChange,disabled=false,searchable=false}:{
 label:string;value:string;options:Option[];onChange:(value:string)=>void;disabled?:boolean;searchable?:boolean;
}){
 const id=useId(),trigger=useRef<HTMLButtonElement>(null),panel=useRef<HTMLDivElement>(null),items=useRef<(HTMLButtonElement|null)[]>([]);
 const [open,setOpen]=useState(false);
 const [query,setQuery]=useState('');
 const visible=options.filter(option=>!query||!option.value||option.label.toLowerCase().includes(query.trim().toLowerCase()));
 const selected=options.findIndex(option=>option.value===value);
 const close=()=>{if(panel.current?.matches(':popover-open'))panel.current.hidePopover();};
 function show(index=selected){
  if(disabled||!trigger.current||!panel.current)return;
  const rect=trigger.current.getBoundingClientRect(),width=Math.min(Math.max(rect.width,240),window.innerWidth-24);
  const below=window.innerHeight-rect.bottom-20,above=rect.top-20,up=below<Math.min(options.length*46+18,300)&&above>below;
  const height=Math.min(options.length*46+18,330,Math.max(100,up?above:below));
  Object.assign(panel.current.style,{width:width+'px',maxHeight:height+'px',left:Math.max(12,Math.min(rect.left,window.innerWidth-width-12))+'px',top:Math.max(12,up?rect.top-height-8:rect.bottom+8)+'px'});
  panel.current.showPopover();setOpen(true);if(searchable)panel.current.querySelector('input')?.focus();else items.current[Math.max(0,index)]?.focus();
 }
 useEffect(()=>{
  const scroll=(event:Event)=>{if(!panel.current?.contains(event.target as Node))close();};
  window.addEventListener('resize',close);document.addEventListener('scroll',scroll,true);
  return()=>{window.removeEventListener('resize',close);document.removeEventListener('scroll',scroll,true);};
 },[]);
 useEffect(()=>{if(disabled)close();},[disabled]);
 function keys(event:KeyboardEvent<HTMLDivElement>){
  const index=items.current.indexOf(document.activeElement as HTMLButtonElement);
  if(event.key==='Escape'){event.preventDefault();event.stopPropagation();close();trigger.current?.focus();}
  else if(event.key==='Tab'){close();trigger.current?.focus();}
  else if(['ArrowDown','ArrowUp','Home','End'].includes(event.key)){
   if(event.target instanceof HTMLInputElement&&['Home','End'].includes(event.key))return;
   event.preventDefault();items.current[event.key==='Home'?0:event.key==='End'?visible.length-1:index<0?(event.key==='ArrowDown'?0:visible.length-1):(index+(event.key==='ArrowDown'?1:-1)+visible.length)%visible.length]?.focus();
  }else if(event.key.length===1&&!event.altKey&&!event.ctrlKey&&!event.metaKey&&event.key!==' '){
   if(event.target instanceof HTMLInputElement)return;
   const match=visible.findIndex(option=>option.label.toLowerCase().startsWith(event.key.toLowerCase()));
   if(match>=0){event.preventDefault();items.current[match]?.focus();}
  }
 }
 return <div className="tm-filter-select">
  <span id={id+'-label'} className="tm-filter-label">{label}</span>
  <button ref={trigger} type="button" className="tm-filter-trigger" role="combobox" aria-labelledby={id+'-label '+id+'-value'} aria-expanded={open} aria-controls={id} aria-haspopup="listbox" disabled={disabled}
   onClick={()=>open?close():show()} onKeyDown={event=>{if(event.key==='ArrowDown'||event.key==='ArrowUp'){event.preventDefault();show(event.key==='ArrowUp'?options.length-1:Math.max(0,selected));}}}>
   <ListFilter size={18} aria-hidden="true"/><span id={id+'-value'}>{options[selected]?.label||'Choose a filter'}</span><ChevronDown size={18} aria-hidden="true"/>
  </button>
  <div ref={panel} id={id+'-panel'} popover="auto" aria-labelledby={id+'-label'} className="tm-filter-options" onKeyDown={keys} onToggle={event=>{const shown=event.currentTarget.matches(':popover-open');setOpen(shown);if(!shown)setQuery('');}}>
   {searchable&&<label className="tm-filter-search"><Search size={18}/><input type="search" aria-label="Find a destination" placeholder="Find a destination" maxLength={120} value={query} onChange={event=>setQuery(event.target.value)}/></label>}
   <div id={id} role="listbox" aria-labelledby={id+'-label'} className="tm-filter-option-list">
   {visible.map((option,index)=><button key={option.value} ref={node=>{items.current[index]=node;}} type="button" role="option" aria-selected={value===option.value} tabIndex={-1}
    onClick={()=>{close();trigger.current?.focus();if(value!==option.value)onChange(option.value);}}>
    <span className="tm-filter-option-dot" data-value={option.value} aria-hidden="true"/><span>{option.label}</span>{option.count!==undefined&&<small>{option.count}</small>}{value===option.value&&<Check size={17} aria-hidden="true"/>}
   </button>)}
   </div>
  </div>
 </div>;
}

export function mountDestinationFilter(host:HTMLElement,options:Option[],onChange:(value:string)=>void){
 const root=createRoot(host);
 function DestinationFilter(){const [value,setValue]=useState('');return <FilterSelect label="Filter by destination" value={value} options={options} searchable onChange={next=>{setValue(next);onChange(next);}}/>;}
 root.render(<DestinationFilter/>);return()=>root.unmount();
}
