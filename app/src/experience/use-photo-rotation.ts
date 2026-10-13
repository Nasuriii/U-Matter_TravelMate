import {useEffect,useRef,useState,type Dispatch,type SetStateAction,type FocusEvent} from 'react';

/** Rotate destination photos while they are visible and idle. */
export function usePhotoRotation(count:number,setIndex:Dispatch<SetStateAction<number>>,intervalMs=1000){
 const root=useRef<HTMLElement>(null);
 const [paused,setPaused]=useState(()=>window.matchMedia('(prefers-reduced-motion: reduce)').matches);
 const [hovered,setHovered]=useState(false),[focused,setFocused]=useState(false),[visible,setVisible]=useState(false);
 useEffect(()=>{
  const element=root.current;if(!element)return;
  const observer=new IntersectionObserver(entries=>setVisible(entries[0]?.isIntersecting??false));observer.observe(element);
  const motion=window.matchMedia('(prefers-reduced-motion: reduce)'),change=()=>{if(motion.matches)setPaused(true);};
  motion.addEventListener('change',change);
  return()=>{observer.disconnect();motion.removeEventListener('change',change);};
 },[]);
 useEffect(()=>{
  if(count<2||paused||hovered||focused||!visible)return;
  const timer=window.setInterval(()=>{if(document.visibilityState==='visible')setIndex(value=>(value+1)%count);},intervalMs);
  return()=>window.clearInterval(timer);
 },[count,paused,hovered,focused,visible,setIndex,intervalMs]);
 return {paused,toggle:()=>setPaused(value=>!value),rootProps:{ref:root,onMouseEnter:()=>setHovered(true),onMouseLeave:()=>setHovered(false),onFocusCapture:()=>setFocused(true),onBlurCapture:(event:FocusEvent<HTMLElement>)=>{if(!event.currentTarget.contains(event.relatedTarget))setFocused(false);}}};
}
