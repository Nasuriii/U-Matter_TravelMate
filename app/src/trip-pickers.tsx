import {useEffect,useRef,useState,type ReactNode,type KeyboardEvent} from 'react';
import {createRoot} from 'react-dom/client';
import {createPortal} from 'react-dom';
import {CalendarDays,Check,ChevronDown,ChevronLeft,ChevronRight,MapPin,Search,X,ArrowRight,Clock3,Sun,Moon,BedDouble,Utensils,Compass} from 'lucide-react';
import {calendarDate,dateKey,monthCells,tripDays} from './trip-calendar';
import {placePreviewAttributes} from './place-hover-preview';
import {clockLabel,clockMinutes,clockParts,clockValue,tripTimesValid} from './trip-clock';

const dateLabel=(value:string)=>calendarDate(value)?.toLocaleDateString('en-PH',{month:'short',day:'numeric',year:'numeric'})??'Choose date';
function PickerDialog({title,children,onClose,className=''}:{title:string;children:ReactNode;onClose:()=>void;className?:string}) {
  const ref=useRef<HTMLDialogElement>(null);
  useEffect(()=>{const dialog=ref.current!;dialog.showModal();dialog.querySelector<HTMLInputElement>('input[type=search]')?.focus();return()=>dialog.close();},[]);
  return <dialog ref={ref} className={'tm-trip-picker-dialog tm-react '+className} aria-label={title}
    onCancel={event=>{event.preventDefault();onClose();}} onClick={event=>{
      const bounds=event.currentTarget.getBoundingClientRect();
      if(event.target===event.currentTarget&&(event.clientX<bounds.left||event.clientX>bounds.right||event.clientY<bounds.top||event.clientY>bounds.bottom))onClose();
    }}>
    <div className="tm-picker-heading"><h2>{title}</h2><button type="button" className="tm-picker-icon-button" aria-label={'Close '+title.toLowerCase()} onClick={onClose}><X/></button></div>
    {children}
  </dialog>;
}
function DateCalendar({start,end,phase:initialPhase,onApply,onClose}:{start:string;end:string;phase:'start'|'end';onApply:(start:string,end:string)=>void;onClose:()=>void}) {
  const [range,setRange]=useState({start,end}),[phase,setPhase]=useState<'start'|'end'>(initialPhase==='end'&&start?'end':'start');
  const initial=calendarDate(initialPhase==='end'?end:start)||calendarDate(start)||new Date();
  const [month,setMonth]=useState(()=>new Date(initial.getFullYear(),initial.getMonth(),1,12));
  const [focusDate,setFocusDate]=useState(dateKey(initial)),[message,setMessage]=useState('');
  const grid=useRef<HTMLDivElement>(null),days=tripDays(range.start,range.end),valid=days>=1&&days<=14;
  const today=dateKey(new Date());
  function choose(value:string) {
    setMessage('');setFocusDate(value);
    if(phase==='start'){setRange({start:value,end:''});setPhase('end');return;}
    if(value<range.start){setMessage('Choose a departure on or after arrival.');return;}
    if(tripDays(range.start,value)>14){setMessage('Your day planner supports trips up to 14 days.');return;}
    setRange({...range,end:value});
  }
  function focus(value:string) {
    const date=calendarDate(value)!;setFocusDate(value);setMonth(new Date(date.getFullYear(),date.getMonth(),1,12));
    requestAnimationFrame(()=>grid.current?.querySelector<HTMLButtonElement>(`[data-date="${value}"]`)?.focus());
  }
  function keyboard(event:KeyboardEvent<HTMLButtonElement>,value:string) {
    const offsets:Record<string,number>={ArrowLeft:-1,ArrowRight:1,ArrowUp:-7,ArrowDown:7};
    const date=calendarDate(value)!;
    if(event.key in offsets)date.setDate(date.getDate()+offsets[event.key]);
    else if(event.key==='Home')date.setDate(date.getDate()-date.getDay());
    else if(event.key==='End')date.setDate(date.getDate()+6-date.getDay());
    else if(event.key==='PageUp'||event.key==='PageDown'){
      const day=date.getDate();date.setDate(1);date.setMonth(date.getMonth()+(event.key==='PageUp'?-1:1));
      date.setDate(Math.min(day,new Date(date.getFullYear(),date.getMonth()+1,0).getDate()));
    } else return;
    event.preventDefault();focus(dateKey(date));
  }
  function moveMonth(direction:number) {
    const next=new Date(month.getFullYear(),month.getMonth()+direction,1,12);
    setMonth(next);setFocusDate(dateKey(next));setMessage('');
  }
  const cells=monthCells(month),weeks=Math.ceil(cells.reduce((last,value,index)=>value?index+1:last,0)/7);
  return <PickerDialog title="Choose your trip dates" onClose={onClose} className="tm-calendar-dialog">
    <div className="tm-calendar-range" role="group" aria-label="Date to choose">
      <button type="button" aria-pressed={phase==='start'} onClick={()=>setPhase('start')}><small>Arrival</small><strong>{dateLabel(range.start)}</strong></button>
      <ArrowRight size={19}/>
      <button type="button" aria-pressed={phase==='end'} onClick={()=>{if(range.start)setPhase('end');}} disabled={!range.start}><small>Departure</small><strong>{dateLabel(range.end)}</strong></button>
    </div>
    <p className="tm-calendar-instruction" role="status">{phase==='start'?'Pick your arrival date.':'Pick your departure date.'} <span>Up to 14 days</span></p>
    <div className="tm-calendar-month-heading"><button type="button" className="tm-picker-icon-button" aria-label="Previous month" onClick={()=>moveMonth(-1)}><ChevronLeft/></button><h3 id="tm-calendar-month">{month.toLocaleDateString('en-PH',{month:'long',year:'numeric'})}</h3><button type="button" className="tm-picker-icon-button" aria-label="Next month" onClick={()=>moveMonth(1)}><ChevronRight/></button></div>
    <div className="tm-calendar-weekdays" aria-hidden="true">{['Sun','Mon','Tue','Wed','Thu','Fri','Sat'].map(day=><span key={day}>{day}</span>)}</div>
    <div className="tm-calendar-grid" ref={grid} role="grid" aria-labelledby="tm-calendar-month">
      {Array.from({length:weeks},(_,week)=><div role="row" key={week}>{cells.slice(week*7,week*7+7).map((value,index)=>{
        if(!value)return <span role="gridcell" key={'blank'+index}/>;
        const selected=value===range.start||value===range.end,inRange=!!range.start&&!!range.end&&value>range.start&&value<range.end;
        const unavailable=phase==='end'&&(value<range.start||tripDays(range.start,value)>14);
        return <div role="gridcell" key={value} aria-selected={selected||inRange} className={(inRange?'is-range ':'')+(value===range.start?'range-start ':'')+(value===range.end?'range-end':'')}>
          <button type="button" data-date={value} tabIndex={value===focusDate?0:-1} aria-label={calendarDate(value)!.toLocaleDateString('en-PH',{weekday:'long',month:'long',day:'numeric',year:'numeric'})+(value===range.start?' · Arrival':'')+(value===range.end?' · Departure':'')}
            aria-current={value===today?'date':undefined} aria-disabled={unavailable} className={(selected?'is-selected ':'')+(unavailable?'is-unavailable':'')}
            onKeyDown={event=>keyboard(event,value)} onClick={()=>choose(value)}>{Number(value.slice(-2))}</button>
        </div>;
      })}</div>)}
    </div>
    {message&&<p className="tm-calendar-error" role="alert">{message}</p>}
    <div className="tm-calendar-footer"><span>{valid?<><CalendarDays size={17}/>{days} {days===1?'day':'days'} away</>:'Choose arrival and departure'}</span><button type="button" className="tm-picker-apply" disabled={!valid} onClick={()=>onApply(range.start,range.end)}><Check size={18}/>Apply dates</button></div>
  </PickerDialog>;
}

function TimePicker({arrival,departure,phase:initialPhase,sameDay,onApply,onClose,hotel=false}:{arrival:string;departure:string;phase:'arrivalTime'|'departureTime';sameDay:boolean;onApply:(arrival:string,departure:string)=>void;onClose:()=>void;hotel?:boolean}) {
  const [draft,setDraft]=useState({arrivalTime:arrival,departureTime:departure});
  const [phase,setPhase]=useState(initialPhase),[part,setPart]=useState<'hour'|'minute'>('hour');
  const parts=clockParts(draft[phase])??{hour:9,minute:0,period:'AM' as const};
  const [focusIndex,setFocusIndex]=useState(parts.hour-1),options=useRef<HTMLDivElement>(null);
  const valid=tripTimesValid('start',sameDay?'start':'end',draft.arrivalTime,draft.departureTime) && (!hotel || clockMinutes(draft.departureTime)! < clockMinutes(draft.arrivalTime)!);
  function update(key:'hour'|'minute'|'period',value:number|'AM'|'PM') {
    const next={...parts,[key]:value};
    setDraft(previous=>({...previous,[phase]:clockValue(next.hour,next.minute,next.period)}));
  }
  useEffect(()=>{
    const index=part==='hour'?parts.hour-1:parts.minute;setFocusIndex(index);
    if(part==='minute')options.current?.querySelector<HTMLButtonElement>(`[data-time-option="${index}"]`)?.scrollIntoView({block:'nearest'});
  },[phase,part]);
  function keyboard(event:KeyboardEvent<HTMLButtonElement>,index:number) {
    const columns=part==='hour'?4:6,count=part==='hour'?12:60;
    const movement:Record<string,number>={ArrowLeft:-1,ArrowRight:1,ArrowUp:-columns,ArrowDown:columns};
    const next=event.key==='Home'?0:event.key==='End'?count-1:event.key in movement?Math.max(0,Math.min(count-1,index+movement[event.key])):null;
    if(next===null)return;event.preventDefault();setFocusIndex(next);
    requestAnimationFrame(()=>options.current?.querySelector<HTMLButtonElement>(`[data-time-option="${next}"]`)?.focus());
  }
  return <PickerDialog title={hotel?'Choose check-in & check-out times':'Choose your trip times'} onClose={onClose} className="tm-time-dialog">
    <div className="tm-calendar-range" role="group" aria-label="Time to choose">{(['arrivalTime','departureTime'] as const).map(key=><button key={key} type="button" aria-pressed={phase===key} onClick={()=>setPhase(key)}><small>{hotel?(key==='arrivalTime'?'Check-in':'Check-out'):(key==='arrivalTime'?'Arrival':'Departure')}</small><strong>{clockLabel(draft[key])}</strong></button>)}</div>
    <p className="tm-time-instruction"><Clock3 size={17}/>Local time at your destination</p>
    <div className="tm-clock-face" role="group" aria-label={hotel?(phase==='arrivalTime'?'Check-in time controls':'Check-out time controls'):(phase==='arrivalTime'?'Arrival time controls':'Departure time controls')}>
      <button type="button" className="tm-clock-digit" aria-label="Choose hour" aria-pressed={part==='hour'} onClick={()=>setPart('hour')}><strong>{String(parts.hour).padStart(2,'0')}</strong><small>Hour</small></button><span aria-hidden="true">:</span>
      <button type="button" className="tm-clock-digit" aria-label="Choose minutes" aria-pressed={part==='minute'} onClick={()=>setPart('minute')}><strong>{String(parts.minute).padStart(2,'0')}</strong><small>Minute</small></button>
      <div className="tm-clock-period" role="group" aria-label="AM or PM">{(['AM','PM'] as const).map(period=><button key={period} type="button" aria-pressed={parts.period===period} onClick={()=>update('period',period)}>{period==='AM'?<Sun size={17}/>:<Moon size={17}/>} {period}</button>)}</div>
    </div>
    <div className="tm-clock-options-heading"><h3>{part==='hour'?'Choose an hour':'Choose minutes'}</h3><span>{part==='hour'?'1–12':'00–59'}</span></div>
    <div className={'tm-clock-options '+(part==='minute'?'is-minutes':'')} ref={options} role="group" aria-label={part==='hour'?'Hours':'Minutes'}>
      {Array.from({length:part==='hour'?12:60},(_,index)=>{
        const value=part==='hour'?index+1:index,selected=value===parts[part];
        return <button type="button" key={part+index} data-time-option={index} tabIndex={focusIndex===index?0:-1} aria-label={part==='hour'?`${value} ${value===1?'hour':'hours'}`:`${value} ${value===1?'minute':'minutes'}`} aria-pressed={selected} onKeyDown={event=>keyboard(event,index)} onFocus={()=>setFocusIndex(index)} onClick={()=>{setFocusIndex(index);update(part,value);}}>{String(value).padStart(2,'0')}{selected&&<Check size={13}/>}</button>;
      })}
    </div>
    {!valid&&<p className="tm-calendar-error" role="alert">{hotel?'Choose both times. Check-out must be earlier on the clock than check-in, for the next morning.':'Departure must be after arrival on the same day.'}</p>}
    <div className="tm-calendar-footer"><span><Clock3 size={17}/>{clockLabel(draft[phase])}</span><button type="button" className="tm-picker-apply" disabled={!valid} onClick={()=>onApply(draft.arrivalTime,draft.departureTime)}><Check size={18}/>Apply times</button></div>
  </PickerDialog>;
}

function TripPickers({form,dateHost,timeHost}:{form:HTMLFormElement;dateHost:HTMLElement;timeHost:HTMLElement}) {
  const destination=form.elements.namedItem('destination_id') as HTMLSelectElement;
  const arrival=form.elements.namedItem('start_date') as HTMLInputElement,departure=form.elements.namedItem('end_date') as HTMLInputElement;
  const arrivalTime=form.elements.namedItem('arrival_time') as HTMLInputElement,departureTime=form.elements.namedItem('departure_time') as HTMLInputElement;
  const snapshot=()=>({options:Array.from(destination.options).filter(option=>option.value).map(option=>({id:option.value,label:option.text})),id:destination.value,start:arrival.value,end:departure.value,arrivalTime:arrivalTime.value,departureTime:departureTime.value,disabled:(form.querySelector('fieldset') as HTMLFieldSetElement).disabled});
  const [data,setData]=useState(snapshot),[open,setOpen]=useState<'destination'|'start'|'end'|'arrivalTime'|'departureTime'|null>(null),[query,setQuery]=useState('');
  const trigger=useRef<HTMLButtonElement|null>(null);
  function close(){setOpen(null);requestAnimationFrame(()=>trigger.current?.focus());}
  function show(mode:typeof open,button:HTMLButtonElement){trigger.current=button;setQuery('');setOpen(mode);}
  useEffect(()=>{
    const sync=()=>setData(snapshot());const reset=()=>requestAnimationFrame(sync);
    form.addEventListener('input',sync);form.addEventListener('change',sync);form.addEventListener('reset',reset);
    window.addEventListener('travelmate:trip-destination',sync);window.addEventListener('travelmate:trip-lock',sync);
    const observer=new MutationObserver(sync);observer.observe(destination,{childList:true});
    const editor=form.closest('dialog')!,editorObserver=new MutationObserver(()=>{if(!editor.open)setOpen(null);});editorObserver.observe(editor,{attributes:true,attributeFilter:['open']});
    return()=>{observer.disconnect();editorObserver.disconnect();form.removeEventListener('input',sync);form.removeEventListener('change',sync);form.removeEventListener('reset',reset);window.removeEventListener('travelmate:trip-destination',sync);window.removeEventListener('travelmate:trip-lock',sync);};
  },[form]);
  const selected=data.options.find(option=>option.id===data.id),results=data.options.filter(option=>option.label.toLocaleLowerCase().includes(query.trim().toLocaleLowerCase()));
  function chooseDestination(id:string){destination.value=id;destination.dispatchEvent(new Event('change',{bubbles:true}));close();}
  return <>
    <button type="button" className="tm-trip-destination-trigger" aria-haspopup="dialog" aria-labelledby="trip-destination-label tm-trip-selected-destination" disabled={data.disabled||!data.options.length} onClick={event=>show('destination',event.currentTarget)}><span className="tm-trip-field-icon"><MapPin/></span><span id="tm-trip-selected-destination">{selected?<><strong>{selected.label.split(' · ')[0]}</strong><small>{selected.label.split(' · ').slice(1).join(' · ')}</small></>:<strong>{data.options.length?'Choose a destination':'Loading destinations…'}</strong>}</span><ChevronDown size={20}/></button>
    {createPortal(<div className="tm-trip-date-fields">{(['start','end'] as const).map(key=><div key={key}><span id={'trip-'+key+'-label'}>{key==='start'?'Arrival date':'Departure date'}</span><button type="button" className="tm-trip-date-trigger" aria-haspopup="dialog" aria-labelledby={'trip-'+key+'-label trip-'+key+'-value'} disabled={data.disabled} onClick={event=>show(key,event.currentTarget)}><CalendarDays size={20}/><strong id={'trip-'+key+'-value'}>{dateLabel(data[key])}</strong><ChevronDown size={16}/></button></div>)}</div>,dateHost)}
    {createPortal(<div className="tm-trip-date-fields tm-trip-time-fields">{(['arrivalTime','departureTime'] as const).map(key=><div key={key}><span id={'trip-'+key+'-label'}>{key==='arrivalTime'?'Arrival time':'Departure time'}</span><button type="button" className="tm-trip-date-trigger tm-trip-time-trigger" aria-haspopup="dialog" aria-labelledby={'trip-'+key+'-label trip-'+key+'-value'} disabled={data.disabled} onClick={event=>show(key,event.currentTarget)}><Clock3 size={20}/><strong id={'trip-'+key+'-value'}>{clockLabel(data[key])}</strong><ChevronDown size={16}/></button></div>)}</div>,timeHost)}
    {open==='destination'&&<PickerDialog title="Where would you like to go?" onClose={close} className="tm-destination-dialog">
      <div className="tm-destination-search"><Search size={20}/><input type="search" autoFocus maxLength={100} value={query} aria-label="Search trip destinations" placeholder="Search a town or province" onChange={event=>setQuery(event.target.value)} onKeyDown={event=>{if(event.key==='Enter'){event.preventDefault();if(results.length===1)chooseDestination(results[0].id);else event.currentTarget.closest('dialog')?.querySelector<HTMLButtonElement>('.tm-destination-options>button')?.focus();}}}/></div>
      <p className="tm-destination-count" role="status">{results.length} {results.length===1?'destination':'destinations'}</p>
      <div className="tm-destination-options">{results.map((option,index)=><button type="button" key={option.id} ref={node=>{if(node)placePreviewAttributes(node,'destination',option.id,option.label.split(' · ')[0],option.label.split(' · ').slice(1).join(' · '));}} aria-pressed={option.id===data.id} onClick={()=>chooseDestination(option.id)}><span className={'tm-destination-marker tone-'+index%3}><MapPin size={22}/></span><span><strong>{option.label.split(' · ')[0]}</strong><small>{option.label.split(' · ').slice(1).join(' · ')}</small></span>{option.id===data.id?<Check size={20}/>:<ChevronRight size={18}/>}</button>)}{!results.length&&<p className="tm-destination-empty">No matching destinations. Try another town or province.</p>}</div>
    </PickerDialog>}
    {(open==='start'||open==='end')&&<DateCalendar start={data.start} end={data.end} phase={open} onClose={close} onApply={(start,end)=>{arrival.value=start;departure.value=end;arrival.dispatchEvent(new Event('change',{bubbles:true}));close();}}/>}
    {(open==='arrivalTime'||open==='departureTime')&&<TimePicker arrival={data.arrivalTime} departure={data.departureTime} phase={open} sameDay={!!data.start&&data.start===data.end} onClose={close} onApply={(start,end)=>{arrivalTime.value=start;departureTime.value=end;arrivalTime.dispatchEvent(new Event('change',{bubbles:true}));close();}}/>}
  </>;
}
export function mountTripPickers(form:HTMLFormElement){
  const host=form.querySelector<HTMLElement>('#react-trip-destination-picker'),dateHost=form.querySelector<HTMLElement>('#react-trip-date-picker'),timeHost=form.querySelector<HTMLElement>('#react-trip-time-picker');
  if(host&&dateHost&&timeHost)createRoot(host).render(<TripPickers form={form} dateHost={dateHost} timeHost={timeHost}/>);
}

/** Keep the owner's existing form values/events while sharing itinerary controls. */
export function mountOwnerListingPickers(form:HTMLFormElement) {
  if(form.querySelector('[data-owner-picker]'))return;
  const type=form.querySelector<HTMLSelectElement>('#ol-type')!,destination=form.querySelector<HTMLSelectElement>('#ol-dest')!;
  const checkIn=form.querySelector<HTMLInputElement>('#ol-checkin')!,checkOut=form.querySelector<HTMLInputElement>('#ol-checkout')!;
  const host=(field:HTMLElement)=>{const node=document.createElement('div');node.className='tm-react tm-owner-picker';node.dataset.ownerPicker='';field.before(node);return node;};
  const typeHost=host(type),destinationHost=host(destination),timeRow=checkIn.closest('.row2') as HTMLElement,timeHost=host(timeRow);
  timeHost.dataset.type='hotel';timeRow.style.display='none';
  for(const field of [type,destination,checkIn,checkOut]){field.hidden=true;const label=form.querySelector<HTMLLabelElement>(`label[for="${field.id}"]`);if(label)label.hidden=true;}
  function OwnerPickers(){
    const snapshot=()=>({type:type.value,destination:destination.value,options:Array.from(destination.options).filter(option=>option.value).map(option=>({value:option.value,label:option.text.replace(/\s*\(geographic location\)/i,'')})),checkIn:checkIn.value,checkOut:checkOut.value,disabled:type.disabled});
    const [data,setData]=useState(snapshot),[open,setOpen]=useState<'type'|'destination'|'arrivalTime'|'departureTime'|null>(null),[query,setQuery]=useState('');
    const trigger=useRef<HTMLButtonElement|null>(null);
    const close=()=>{setOpen(null);requestAnimationFrame(()=>trigger.current?.focus());};
    const show=(mode:typeof open,button:HTMLButtonElement)=>{trigger.current=button;setQuery('');setOpen(mode);};
    useEffect(()=>{
      const sync=()=>setData(snapshot()),reset=()=>requestAnimationFrame(sync),route=()=>setOpen(null);
      form.addEventListener('change',sync);form.addEventListener('input',sync);form.addEventListener('reset',reset);window.addEventListener('hashchange',route);window.addEventListener('travelmate:identity',route);window.addEventListener('travelmate:owner-workspace-close',route);
      const observer=new MutationObserver(sync);observer.observe(destination,{childList:true,attributes:true,attributeFilter:['disabled']});observer.observe(type,{attributes:true,attributeFilter:['disabled']});
      const details=form.closest('details'),toggle=()=>{if(!details?.open)setOpen(null);};details?.addEventListener('toggle',toggle);
      return()=>{observer.disconnect();form.removeEventListener('change',sync);form.removeEventListener('input',sync);form.removeEventListener('reset',reset);window.removeEventListener('hashchange',route);window.removeEventListener('travelmate:identity',route);window.removeEventListener('travelmate:owner-workspace-close',route);details?.removeEventListener('toggle',toggle);};
    },[]);
    const types=[{value:'hotel',label:'Hotel',copy:'Rooms and overnight stays',icon:BedDouble},{value:'restaurant',label:'Restaurant',copy:'Menus and table reservations',icon:Utensils},{value:'attraction',label:'Attraction',copy:'Places to visit and explore',icon:Compass}];
    const selectedType=types.find(option=>option.value===data.type)??types[0],TypeIcon=selectedType.icon,selectedDestination=data.options.find(option=>option.value===data.destination);
    useEffect(()=>{timeHost.hidden=data.type!=='hotel';},[data.type]);
    const results=data.options.filter(option=>option.label.toLowerCase().includes(query.trim().toLowerCase()));
    const choose=(field:HTMLSelectElement,value:string)=>{field.value=value;field.dispatchEvent(new Event('change',{bubbles:true}));close();};
    return <>
      <label id="owner-type-label">Business type</label><button type="button" className="tm-trip-destination-trigger" aria-label={'Business type: '+selectedType.label} aria-haspopup="dialog" disabled={data.disabled} onClick={event=>show('type',event.currentTarget)}><span className="tm-trip-field-icon"><TypeIcon/></span><span><strong>{selectedType.label}</strong><small>{selectedType.copy}</small></span><ChevronDown size={20}/></button>
      {createPortal(<><label>Destination</label><button type="button" className="tm-trip-destination-trigger" aria-label={'Destination: '+(selectedDestination?.label??'Choose a destination')} aria-haspopup="dialog" disabled={data.disabled||!data.options.length} onClick={event=>show('destination',event.currentTarget)}><span className="tm-trip-field-icon"><MapPin/></span><span><strong>{selectedDestination?.label.split(', ')[0]??(data.options.length?'Choose a destination':'Loading destinations…')}</strong>{selectedDestination&&<small>{selectedDestination.label.split(', ').slice(1).join(', ')}</small>}</span><ChevronDown size={20}/></button></>,destinationHost)}
      {createPortal(<div className="tm-trip-date-fields tm-trip-time-fields">{(['arrivalTime','departureTime'] as const).map(key=><div key={key}><label>{key==='arrivalTime'?'Check-in time':'Check-out time'}</label><button type="button" className="tm-trip-date-trigger" aria-label={(key==='arrivalTime'?'Check-in time: ':'Check-out time: ')+clockLabel(key==='arrivalTime'?data.checkIn:data.checkOut)} aria-haspopup="dialog" disabled={data.disabled} onClick={event=>show(key,event.currentTarget)}><Clock3 size={20}/><strong>{clockLabel(key==='arrivalTime'?data.checkIn:data.checkOut)}</strong><ChevronDown size={16}/></button></div>)}</div>,timeHost)}
      {open==='type'&&<PickerDialog title="Choose your business type" onClose={close} className="tm-destination-dialog"><div className="tm-destination-options">{types.map(({value,label,copy,icon:Icon})=><button key={value} type="button" aria-pressed={data.type===value} onClick={()=>choose(type,value)}><span className="tm-destination-marker"><Icon size={23}/></span><span><strong>{label}</strong><small>{copy}</small></span>{data.type===value?<Check size={20}/>:<ChevronRight size={18}/>}</button>)}</div></PickerDialog>}
      {open==='destination'&&<PickerDialog title="Choose your destination" onClose={close} className="tm-destination-dialog"><div className="tm-destination-search"><Search size={20}/><input type="search" autoFocus maxLength={100} aria-label="Search business destinations" placeholder="Search a town or province" value={query} onChange={event=>setQuery(event.target.value)} onKeyDown={event=>{if(event.key==='Enter'){event.preventDefault();if(results.length===1)choose(destination,results[0].value);}}}/></div><p className="tm-destination-count" role="status">{results.length} {results.length===1?'destination':'destinations'}</p><div className="tm-destination-options">{results.map((option,index)=><button type="button" key={option.value} ref={node=>{if(node)placePreviewAttributes(node,'destination',option.value,option.label.split(', ')[0],option.label.split(', ').slice(1).join(', '));}} aria-pressed={option.value===data.destination} onClick={()=>choose(destination,option.value)}><span className={'tm-destination-marker tone-'+index%3}><MapPin size={22}/></span><span><strong>{option.label.split(', ')[0]}</strong><small>{option.label.split(', ').slice(1).join(', ')}</small></span>{option.value===data.destination?<Check size={20}/>:<ChevronRight size={18}/>}</button>)}{!results.length&&<p className="tm-destination-empty">No matching destinations. Try another town or province.</p>}</div></PickerDialog>}
      {(open==='arrivalTime'||open==='departureTime')&&<TimePicker hotel arrival={data.checkIn} departure={data.checkOut} phase={open} sameDay={false} onClose={close} onApply={(arrival,departure)=>{checkIn.value=arrival;checkOut.value=departure;checkIn.dispatchEvent(new Event('input',{bubbles:true}));checkOut.dispatchEvent(new Event('input',{bubbles:true}));close();}}/>}
    </>;
  }
  createRoot(typeHost).render(<OwnerPickers/>);
}

/** Existing hotels use the same clock editor as the new-listing popup. */
export function mountOwnerDetailTimes(form:HTMLFormElement){
  const arrival=form.elements.namedItem('ci') as HTMLInputElement,departure=form.elements.namedItem('co') as HTMLInputElement;
  const host=document.createElement('div');host.className='tm-react';host.style.gridColumn='1 / -1';form.id='owner-details-form';form.prepend(host);arrival.closest('label')!.hidden=true;departure.closest('label')!.hidden=true;
  function HotelTimes(){
    const snapshot=()=>({arrival:arrival.value,departure:departure.value});const [data,setData]=useState(snapshot),[open,setOpen]=useState<'arrivalTime'|'departureTime'|null>(null),trigger=useRef<HTMLButtonElement|null>(null);
    useEffect(()=>{const sync=()=>setData(snapshot()),close=()=>setOpen(null);form.addEventListener('input',sync);window.addEventListener('travelmate:owner-workspace-close',close);window.addEventListener('hashchange',close);window.addEventListener('travelmate:identity',close);return()=>{form.removeEventListener('input',sync);window.removeEventListener('travelmate:owner-workspace-close',close);window.removeEventListener('hashchange',close);window.removeEventListener('travelmate:identity',close);};},[]);
    const close=()=>{setOpen(null);requestAnimationFrame(()=>trigger.current?.isConnected&&trigger.current.focus());};
    return <><div className="tm-trip-date-fields tm-trip-time-fields">{(['arrivalTime','departureTime'] as const).map(key=><div key={key}><label>{key==='arrivalTime'?'Check-in time':'Check-out time'}</label><button type="button" className="tm-trip-date-trigger" aria-label={(key==='arrivalTime'?'Check-in time: ':'Check-out time: ')+clockLabel(key==='arrivalTime'?data.arrival:data.departure)} aria-haspopup="dialog" onClick={event=>{trigger.current=event.currentTarget;setOpen(key);}}><Clock3 size={20}/><strong>{clockLabel(key==='arrivalTime'?data.arrival:data.departure)}</strong><ChevronDown size={16}/></button></div>)}</div>{open&&<TimePicker hotel arrival={data.arrival} departure={data.departure} phase={open} sameDay={false} onClose={close} onApply={(start,end)=>{arrival.value=start;departure.value=end;arrival.dispatchEvent(new Event('input',{bubbles:true}));departure.dispatchEvent(new Event('input',{bubbles:true}));close();}}/>}</>;
  }
  const root=createRoot(host);root.render(<HotelTimes/>);
  const observer=new MutationObserver(()=>{if(!form.isConnected){observer.disconnect();root.unmount();}});observer.observe(document.body,{childList:true,subtree:true});
}
