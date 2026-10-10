import {useRef,useState} from 'react';
import {ChevronLeft,ChevronRight,Images,Camera} from 'lucide-react';
import {Modal} from './modal';
export type GalleryPhoto={src:string;alt:string};
export function PhotoMosaic({photos,name,stacked=false}:{photos:GalleryPhoto[];name:string;stacked?:boolean}){
 const [index,setIndex]=useState(0),[open,setOpen]=useState(false),[failed,setFailed]=useState<string[]>([]),start=useRef<number|null>(null),swiped=useRef(false);
 const available=photos.filter(p=>!failed.includes(p.src)),active=Math.min(index,Math.max(0,available.length-1));
 const go=(delta:number)=>{if(available.length)setIndex(i=>(Math.min(i,available.length-1)+delta+available.length)%available.length);};
 const photo=(i:number)=>available[(i+available.length)%available.length];
 const image=(i:number)=>{const p=photo(i);return p&&<img src={p.src} alt={p.alt} draggable={false} loading={i===active?'eager':'lazy'} onError={()=>setFailed(v=>[...v,p.src])}/>;};
 return <section className={'tm-photo-mosaic '+(stacked?'stacked':'panorama')} aria-label={name+' photo gallery'}>
 {available.length?<div className="tm-mosaic-grid" data-count={available.length}>
 {stacked?<>{available.slice(0,6).map((p,i)=><button className={'tm-mosaic-tile '+(i===0?'hero':'')} key={p.src} aria-label={`Open photo ${i+1} of ${name}`} onClick={()=>{setIndex(i);setOpen(true);}}>{image(i)}</button>)}</>:<>
 {available.length>1&&<button className="tm-mosaic-tile side left" aria-label={'Previous photo of '+name} onClick={()=>go(-1)}>{image(active-1)}</button>}
 <div className="tm-mosaic-center" onPointerDown={e=>{start.current=e.clientX;swiped.current=false;}} onPointerUp={e=>{if(start.current!==null&&Math.abs(e.clientX-start.current)>45){swiped.current=true;go(e.clientX<start.current?1:-1);}start.current=null;}} onPointerCancel={()=>{start.current=null;}}><button className="tm-mosaic-tile hero" aria-label={'Open photo '+(active+1)+' of '+name} onClick={()=>{if(!swiped.current)setOpen(true);swiped.current=false;}}>{image(active)}</button>{available.length>1&&<div className="tm-mosaic-dots">{available.map((p,i)=><button key={p.src} aria-label={'Show photo '+(i+1)+' of '+name} aria-pressed={i===active} onClick={()=>setIndex(i)}/>)}</div>}</div>
 {available.length>1&&<button className="tm-mosaic-tile side right" aria-label={'Next photo of '+name} onClick={()=>go(1)}>{image(active+1)}</button>}
 </>}
 </div>:<div className="tm-mosaic-empty"><Camera/><p>Photos coming soon</p></div>}
 {available.length>0&&<button className="tm-mosaic-openall" onClick={()=>setOpen(true)}><Images size={17}/>See all {available.length} photos</button>}
 {open&&available.length>0&&<Modal title={name+' · '+(active+1)+' / '+available.length} close={()=>setOpen(false)} closeOnOutside className="tm-photo-viewer"><div className="tm-photo-view-stage" tabIndex={0} onKeyDown={e=>{if(['ArrowLeft','ArrowRight'].includes(e.key)){e.preventDefault();go(e.key==='ArrowRight'?1:-1);}}}>{image(active)}{available.length>1&&<><button aria-label="Previous full-size photo" onClick={()=>go(-1)}><ChevronLeft/></button><button aria-label="Next full-size photo" onClick={()=>go(1)}><ChevronRight/></button></>}</div><div className="tm-view-thumbnails">{available.map((p,i)=><button key={p.src} aria-label={'View photo '+(i+1)} aria-pressed={i===active} onClick={()=>setIndex(i)}><img src={p.src} alt=""/></button>)}</div></Modal>}
 </section>;
}
