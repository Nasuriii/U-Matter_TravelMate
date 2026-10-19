import {PhotoMosaic} from './photo-mosaic';
import {useRef,useState} from 'react';
import {ChevronLeft,ChevronRight,Images,MapPin,Pause,Play} from 'lucide-react';
import {destinationPhoto,type DestinationPhoto} from './destination-photos';
import galleries from './destination-galleries.json';
import {usePhotoRotation} from './use-photo-rotation';
import {showInlinePhotoCredits} from './destination-picture';

export function destinationGallery(name:string,province:string):DestinationPhoto[]{
 const cover=destinationPhoto(name,province);
 const key=name.toLowerCase()==='san fernando city'?'san fernando':name.toLowerCase();
 const extra=/la union|benguet/i.test(province)?(galleries as Record<string,DestinationPhoto[]>)[key]??[]:[];
 return [cover,...extra].filter((p):p is DestinationPhoto=>!!p).filter((p,i,all)=>all.findIndex(x=>x.source===p.source)===i);
}
export function DestinationCarousel({mosaic=false,...props}:{name:string;province:string;mosaic?:boolean;showThumbnails?:boolean;intervalMs?:number}){
 if(mosaic){const photos=destinationGallery(props.name,props.province);return <><PhotoMosaic photos={photos} name={props.name}/>{showInlinePhotoCredits&&<details className="travel-photo-credit"><summary aria-label="Photo information">ⓘ</summary>{photos.map(photo=><p key={photo.src}><a href={photo.source} target="_blank" rel="noreferrer">{photo.author||'Wikimedia Commons'}</a> · {photo.license}</p>)}</details>}</>;}
 return <DestinationSlides {...props}/>;
}
function DestinationSlides({name,province,showThumbnails=true,intervalMs}:{name:string;province:string;showThumbnails?:boolean;intervalMs?:number}){
 const photos=destinationGallery(name,province),[index,setIndex]=useState(0),[failed,setFailed]=useState<string[]>([]),pointer=useRef<number|null>(null);
 const available=photos.filter(p=>!failed.includes(p.src)),active=Math.min(index,Math.max(available.length-1,0));
 const rotation=usePhotoRotation(available.length,setIndex,intervalMs);
 const go=(delta:number)=>setIndex(i=>(Math.min(i,available.length-1)+delta+available.length)%available.length);

 return <section {...rotation.rootProps} className="travel-carousel" aria-label={name+' destination photos'} aria-roledescription="carousel"><div className="travel-carousel-stage" tabIndex={available.length>1?0:undefined} onKeyDown={e=>{if(available.length>1&&['ArrowLeft','ArrowRight'].includes(e.key)){e.preventDefault();go(e.key==='ArrowRight'?1:-1);}}} onPointerDown={e=>{if((e.target as Element).closest('button'))return;pointer.current=e.clientX;e.currentTarget.setPointerCapture(e.pointerId);}} onPointerUp={e=>{if(pointer.current!==null&&available.length>1&&Math.abs(e.clientX-pointer.current)>45)go(e.clientX<pointer.current?1:-1);pointer.current=null;}} onPointerCancel={()=>{pointer.current=null;}}>
 <div className="travel-carousel-track" style={{transform:`translateX(-${active*100}%)`}}>{available.map((p,i)=><div className="travel-carousel-slide" key={p.src} role="group" aria-roledescription="slide" aria-label={`${i+1} of ${available.length}`} aria-hidden={i!==active}><img src={p.src} alt={p.alt} draggable={false} loading={i===0?'eager':'lazy'} onError={()=>setFailed(v=>[...v,p.src])}/></div>)}</div>
 {!available.length&&<div className="travel-photo-fallback"><MapPin size={48}/><strong>{name}</strong><span>Destination photos are unavailable.</span></div>}
 <div className="travel-carousel-caption"><span><MapPin size={15}/>{name}</span><small>{province}</small></div>
 {available.length>1&&<><button type="button" className="travel-carousel-arrow prev" aria-label={'Previous photo of '+name} onClick={()=>go(-1)}><ChevronLeft size={20}/></button><button type="button" className="travel-carousel-arrow next" aria-label={'Next photo of '+name} onClick={()=>go(1)}><ChevronRight size={20}/></button><button type="button" className="travel-carousel-play" aria-label={rotation.paused?'Play destination slideshow':'Pause destination slideshow'} onClick={rotation.toggle}>{rotation.paused?<Play size={16}/>:<Pause size={16}/>}</button><span className="travel-photo-count"><Images size={14}/>{active+1} / {available.length}</span></>}
 </div>{showThumbnails&&available.length>1&&<div className="travel-carousel-thumbs" aria-label="Choose destination photo">{available.map((p,i)=><button type="button" key={p.src} aria-label={`Show photo ${i+1} of ${name}`} aria-pressed={i===active} onClick={()=>setIndex(i)}><img src={p.src} alt="" loading="lazy"/></button>)}<small>Swipe or use the arrows to explore</small></div>}
 {showInlinePhotoCredits&&available.some(p=>p.source)&&<details className="travel-photo-credit"><summary aria-label="Photo information" title="Photo information">ⓘ</summary>{available.map((p,i)=><p key={p.src}>Photo {i+1}: <a href={p.source} target="_blank" rel="noreferrer">{p.author||'Wikimedia Commons'}</a> · <a href={p.licenseUrl||p.source} target="_blank" rel="noreferrer">{p.license}</a> · cropped to fit</p>)}</details>}
 </section>;
}
