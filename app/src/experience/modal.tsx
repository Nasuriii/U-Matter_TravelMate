import {useEffect,useId,useRef,type ReactNode} from 'react';
import {createPortal} from 'react-dom';
import {X} from 'lucide-react';
import {Button} from '../components/ui/button';
const modalStack:HTMLElement[]=[];
const originalInert=new Map<HTMLElement,boolean>();
let originalOverflow='';
function syncModalInert(){
 const active=modalStack.at(-1);
 for(const child of Array.from(document.body.children) as HTMLElement[]){
  if(!originalInert.has(child))originalInert.set(child,child.inert);
  if(!child.hasAttribute('data-toast-root'))child.inert=!!active&&child!==active;
 }
 if(!active){for(const [node,inert] of originalInert)node.inert=inert;originalInert.clear();document.body.style.overflow=originalOverflow;}
 else document.body.style.overflow='hidden';
}
export function Modal({title,children,close,className='',closeOnOutside=false,exiting=false,onExitComplete}:{title:string;children:ReactNode;close:()=>void;className?:string;closeOnOutside?:boolean;exiting?:boolean;onExitComplete?:()=>void}){
 const id=useId(),ref=useRef<HTMLElement>(null),closer=useRef(close);closer.current=close;
 useEffect(()=>{const previous=document.activeElement as HTMLElement|null,wrapper=ref.current?.parentElement;if(!wrapper)return;if(!modalStack.length)originalOverflow=document.body.style.overflow;originalInert.set(wrapper,false);modalStack.push(wrapper);syncModalInert();ref.current?.focus();const focus=()=>{if(!ref.current?.closest('[inert]')&&!document.querySelector('.tm-shadcn-confirm')&&!ref.current?.contains(document.activeElement)&&!document.activeElement?.closest('[data-toast-root]'))ref.current?.focus();};const key=(e:KeyboardEvent)=>{if(ref.current?.closest('[inert]')||document.querySelector('.tm-shadcn-confirm')||document.activeElement?.closest('dialog[open]'))return;if(e.key==='Escape'){e.preventDefault();e.stopPropagation();closer.current();}if(e.key!=='Tab')return;const nodes=Array.from(ref.current?.querySelectorAll<HTMLElement>('button:not(:disabled),a[href],input:not(:disabled),textarea:not(:disabled),select:not(:disabled),[tabindex="0"]')??[]).filter(n=>n.getClientRects().length);if(!nodes.length){e.preventDefault();ref.current?.focus();return;}const first=nodes[0],last=nodes[nodes.length-1];if(e.shiftKey&&(document.activeElement===first||document.activeElement===ref.current)){e.preventDefault();last.focus();}else if(!e.shiftKey&&(document.activeElement===last||document.activeElement===ref.current)){e.preventDefault();first.focus();}};const observer=new MutationObserver(focus);if(ref.current)observer.observe(ref.current,{childList:true,subtree:true});document.addEventListener('focusin',focus);document.addEventListener('keydown',key,true);return()=>{observer.disconnect();document.removeEventListener('focusin',focus);document.removeEventListener('keydown',key,true);const index=modalStack.indexOf(wrapper);if(index>=0)modalStack.splice(index,1);syncModalInert();if(previous?.isConnected&&!previous.closest('[inert]'))previous.focus();};},[]);
 return createPortal(<div className={'tm-react tm-modal-backdrop '+className+(exiting?' tm-modal-exiting':'')} onPointerDown={e=>{if(closeOnOutside&&e.target===e.currentTarget&&!document.querySelector('.tm-shadcn-confirm'))close();}}><section ref={ref} inert={exiting} onAnimationEnd={e=>{if(exiting&&e.target===e.currentTarget&&e.animationName==='tm-drawer-out')onExitComplete?.();}} tabIndex={-1} role="dialog" aria-modal="true" aria-labelledby={id} className="tm-modal"><header className="tm-modal-header"><h2 id={id}>{title}</h2><Button variant="ghost" size="icon" aria-label="Close window" disabled={exiting} onClick={close}><X/></Button></header>{children}</section></div>,document.body);
}
