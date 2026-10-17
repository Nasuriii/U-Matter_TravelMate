import {useEffect,useId,useRef,useState,type CSSProperties,type PointerEvent} from 'react';
import {buddyHoldDuration,buddyShuffleInterval} from '../buddy-surprise-logic';
import {BuddySurprise} from './buddy-surprise';

export function TravelBuddy({image}:{image:string}){
 const [charge,setCharge]=useState<{progress:number;sticker:number}|null>(null),[open,setOpen]=useState(false),[revealedSticker,setRevealedSticker]=useState(1);
 const help=useId(),frame=useRef(0),ignoreClickUntil=useRef(0),gesture=useRef<{source:number|'keyboard';x:number;y:number}|null>(null);
 function cancel(){cancelAnimationFrame(frame.current);gesture.current=null;setCharge(null);}
 function reveal(sticker=1){cancel();ignoreClickUntil.current=performance.now()+1000;setRevealedSticker(sticker);setOpen(true);}
 function begin(source:number|'keyboard',x=0,y=0){
  if(open||gesture.current)return;gesture.current={source,x,y};ignoreClickUntil.current=performance.now()+1000;
  const started=performance.now(),reduced=matchMedia('(prefers-reduced-motion:reduce)').matches;let sticker=1,nextSwap=500,lastPaint=0;
  setCharge({progress:0,sticker});
  const tick=(now:number)=>{
   if(!gesture.current)return;const elapsed=now-started,progress=Math.min(1,elapsed/buddyHoldDuration);
   if(progress>=1){reveal(sticker);return;}
   if(!reduced&&elapsed>=nextSwap){sticker=sticker%6+1;nextSwap=elapsed+buddyShuffleInterval(progress);}
   if(now-lastPaint>=40){setCharge({progress,sticker});lastPaint=now;}
   frame.current=requestAnimationFrame(tick);
  };frame.current=requestAnimationFrame(tick);
 }
 function pointerDown(event:PointerEvent<HTMLButtonElement>){if(event.button!==0||!event.isPrimary)return;event.preventDefault();event.currentTarget.focus();event.currentTarget.setPointerCapture(event.pointerId);begin(event.pointerId,event.clientX,event.clientY);}
 useEffect(()=>{for(let n=1;n<=6;n++){const img=new Image();img.src='/marsey/marsey-sticker-'+n+'.png';}
  const stop=()=>cancel(),navigate=()=>{cancel();setOpen(false);},hidden=()=>{if(document.hidden)cancel();};
  window.addEventListener('blur',stop);window.addEventListener('hashchange',navigate);document.addEventListener('visibilitychange',hidden);
  return()=>{cancelAnimationFrame(frame.current);gesture.current=null;window.removeEventListener('blur',stop);window.removeEventListener('hashchange',navigate);document.removeEventListener('visibilitychange',hidden);};
 },[]);
 useEffect(()=>{cancel();setOpen(false);},[image]);
 const message=charge?(charge.progress>.75?'Almost there…':'Keep holding…'):'Surprise me!';
 return <>
  <button type="button" className="tm-travel-buddy" data-noload data-charging={!!charge} aria-label="Surprise me: hold to shuffle, or press Enter for three ideas" aria-describedby={help} aria-busy={!!charge} aria-haspopup="dialog" aria-expanded={open}
   style={{'--buddy-charge':(charge?.progress||0)*360+'deg'} as CSSProperties}
   onPointerDown={pointerDown} onPointerMove={event=>{const active=gesture.current;if(active?.source===event.pointerId&&Math.hypot(event.clientX-active.x,event.clientY-active.y)>20)cancel();}}
   onPointerUp={()=>{ignoreClickUntil.current=performance.now()+1000;cancel();}} onPointerCancel={cancel} onLostPointerCapture={cancel} onContextMenu={event=>event.preventDefault()} onBlur={cancel}
   onKeyDown={event=>{if(event.key===' '){event.preventDefault();if(!event.repeat)begin('keyboard');}else if(event.key==='Enter'){event.preventDefault();if(!event.repeat)reveal();}else if(event.key==='Escape')cancel();}}
   onKeyUp={event=>{if(event.key===' '){event.preventDefault();cancel();}}}
   onClick={event=>{event.preventDefault();if(event.detail===0&&performance.now()>ignoreClickUntil.current)reveal();}}>
   <span className="tm-buddy-avatar">{charge?<img className="tm-buddy-shuffle" src={'/marsey/marsey-sticker-'+charge.sticker+'.png'} alt="Marsey shuffling ideas"/>:<><img className="tm-buddy-motion" src={image} alt="Your animated Marsey travel buddy"/><img className="tm-buddy-still" src="/marsey/marsey-sticker-1.png" alt="Marsey travel buddy"/></>}</span>
   <span className="tm-buddy-prompt"><strong>{message}</strong><small>{charge?'Shuffling your next adventure':'Hold to shuffle ideas'}</small></span>
  </button>
  <span id={help} className="sr-only">Hold for a moment to reveal three ideas. Release or move away to cancel. You can also press Enter to reveal them immediately.</span>
  <span className="sr-only" role="status">{charge?(charge.progress>.75?'Almost ready. Keep holding.':'Marsey is shuffling. Keep holding.'):''}</span>
  {open&&<BuddySurprise sticker={revealedSticker} close={()=>setOpen(false)}/>}
 </>;
}
