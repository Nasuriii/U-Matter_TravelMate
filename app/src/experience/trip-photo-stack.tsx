import {useRef,useState,type CSSProperties} from 'react';
import {ChevronLeft,ChevronRight,MapPin,Images,Pause,Play} from 'lucide-react';
import {destinationGallery} from './destination-carousel';
import {usePhotoRotation} from './use-photo-rotation';

/** Existing destination photos arranged like a stack of travel postcards. */
export function TripPhotoStack({name,province}:{name:string;province:string}){
 const [index,setIndex]=useState(0),[failed,setFailed]=useState<string[]>([]);
 const photos=destinationGallery(name,province).filter(photo=>!failed.includes(photo.src));
 const active=Math.min(index,Math.max(0,photos.length-1)),rotation=usePhotoRotation(photos.length,setIndex,5000);
 const pointer=useRef<number|null>(null),swiped=useRef(false);
 const go=(delta:number)=>{if(photos.length>1)setIndex((active+delta+photos.length)%photos.length);};
 return <section {...rotation.rootProps} className="trip-photo-stack" aria-label={name+' destination photos'} aria-roledescription="carousel"
  onKeyDown={event=>{if(['ArrowLeft','ArrowRight'].includes(event.key)&&photos.length>1){event.preventDefault();go(event.key==='ArrowRight'?1:-1);}}}>
  <div className="trip-photo-stack-stage" onPointerDown={event=>{pointer.current=event.clientX;swiped.current=false;}}
   onPointerUp={event=>{if(pointer.current!==null&&Math.abs(event.clientX-pointer.current)>45){swiped.current=true;go(event.clientX<pointer.current?1:-1);}pointer.current=null;}}
   onPointerCancel={()=>{pointer.current=null;}}>
   {photos.map((photo,i)=>{
    let offset=(i-active+photos.length)%photos.length;
    if(offset>photos.length/2)offset-=photos.length;
    const depth=Math.abs(offset),visible=depth<=2;
    return <button type="button" key={photo.src} className="trip-photo-frame" data-active={i===active} data-visible={visible}
     style={{'--photo-offset':offset,'--photo-depth':depth,zIndex:5-depth} as CSSProperties}
     aria-label={`Show photo ${i+1} of ${name}`} aria-pressed={i===active} aria-hidden={!visible} tabIndex={i===active?0:-1}
     onClick={()=>{if(!swiped.current)setIndex(i);}}>
     <img src={photo.src} alt={i===active?photo.alt:''} draggable={false} loading={visible?'eager':'lazy'} onError={()=>setFailed(values=>[...values,photo.src])}/>
     <span>{photo.caption||name}</span>
    </button>;
   })}
   {!photos.length&&<div className="trip-photo-stack-fallback"><MapPin size={36}/><strong>{name}</strong><p>Destination photos are unavailable.</p></div>}
  </div>
  <div className="trip-photo-stack-footer">
   <div className="trip-photo-stack-place"><MapPin size={18}/><span><strong>{name}</strong><small>{province}</small></span></div>
   {photos.length>1&&<div className="trip-photo-stack-controls"><button type="button" aria-label={rotation.paused?'Play destination slideshow':'Pause destination slideshow'} onClick={rotation.toggle}>{rotation.paused?<Play size={18}/>:<Pause size={18}/>}</button>
    <button type="button" aria-label={'Previous photo of '+name} onClick={()=>go(-1)}><ChevronLeft size={20}/></button>
    <span><Images size={15}/>{active+1} / {photos.length}</span>
    <button type="button" aria-label={'Next photo of '+name} onClick={()=>go(1)}><ChevronRight size={20}/></button>
   </div>}
  </div>
 </section>;
}
