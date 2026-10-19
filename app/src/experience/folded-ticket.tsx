import {useId,useState,type ReactNode} from 'react';
import {ChevronDown,BedDouble,Utensils} from 'lucide-react';
import {Card} from '../components/ui/card';

/** Details unfold independently of the always-visible reservation actions. */
export function FoldedTicket({name,kind,type,status,dates,amount,payment,reference,actions,children,preview=false,listingId}: {
  name:string;kind:string;type:'hotel'|'restaurant';status:string;dates:string;amount:string;payment:string;
  reference?:string;actions?:ReactNode;children:ReactNode;preview?:boolean;listingId?:string;
}) {
  const [open,setOpen]=useState(false),id=useId(),Icon=type==='hotel'?BedDouble:Utensils;
  return <Card className={'tm-booking-ticket tm-folded-ticket tm-ticket-'+type+(open?' is-open':'')+(preview?' tm-preview-ticket':'')}>
    <button type="button" className="tm-ticket-fold-toggle" aria-expanded={open} aria-controls={id}
      data-place-preview={listingId?'listing':undefined} data-place-id={listingId} data-place-name={name}
      aria-label={(open?'Fold ticket for ':'Unfold ticket for ')+name} onClick={()=>setOpen(value=>!value)}>
      <span className="tm-ticket-fold-top"><span className="tm-ticket-kind"><Icon size={24}/><span><strong>{type==='hotel'?'Hotel stay':'Restaurant table'}</strong><small>{kind}</small></span></span><span className={'tm-status tm-status-'+status}>{status}</span></span>
      <span className="tm-ticket-title">{name}</span>
      <span className="tm-ticket-date-line">{dates}</span>
      {reference&&<span className="tm-ticket-reference">Reference · {reference}</span>}
      <span className="tm-ticket-fold-bottom"><span className="tm-ticket-amount">{amount}<small>{payment}</small></span><span className="tm-ticket-fold-cue">{open?'Fold ticket':'Unfold ticket'}<ChevronDown size={19}/></span></span>
    </button>
    <span className="tm-ticket-crease" aria-hidden="true"/>
    {actions&&<div className="tm-ticket-quick-actions">{actions}</div>}
    <div className="tm-ticket-unfold" id={id} aria-hidden={!open} inert={!open}>
      <div className="tm-ticket-unfold-inner"><div className="tm-ticket-unfold-content">{children}</div></div>
    </div>
  </Card>;
}

export function ticketDate(value:string|null,includeTime=false) {
  if(!value)return 'Date not set';
  const date=new Date(value.length===10?value+'T12:00:00':value);
  return Number.isNaN(date.getTime())?'Date not set':date.toLocaleString('en-PH',{
    month:'short',day:'numeric',year:'numeric',...(includeTime&&value.length>10?{hour:'numeric',minute:'2-digit'}:{})
  });
}
