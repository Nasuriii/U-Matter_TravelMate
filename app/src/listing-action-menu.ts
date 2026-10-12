const paths = {
 edit: '<path d="m16 3 5 5-13 13H3v-5L16 3Z"/><path d="m14 5 5 5"/>',
 more: '<path d="m6 9 6 6 6-6"/>',
 send: '<path d="m22 2-7 20-4-9-9-4 20-7Z"/><path d="m22 2-11 11"/>',
 power: '<path d="M12 2v10"/><path d="M5 5a10 10 0 1 0 14 0"/>',
 trash: '<path d="M3 6h18M9 6V3h6v3M5 6l1 15h12l1-15M10 10v7M14 10v7"/>',
 check: '<path d="m5 12 4 4L19 6"/>',
 alert: '<path d="m12 3 10 18H2L12 3ZM12 9v4M12 17h.01"/>',
 eye: '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/>',
 refresh: '<path d="M3 4v6h6M3 10a9 9 0 1 1 2 8"/>',
};
export type ActionIcon = keyof typeof paths;
export function actionIcon(name: ActionIcon) {
 const icon=document.createElement('span');icon.className='tm-action-icon';icon.setAttribute('aria-hidden','true');
 icon.innerHTML=`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" focusable="false">${paths[name]}</svg>`;
 return icon;
}
export function labelAction(button: HTMLElement, name: ActionIcon, label: string) {button.replaceChildren(actionIcon(name),document.createTextNode(label));}
let nextMenu=0;
/** Native top-layer popovers do not expand rows or get clipped by the directory. */
export function listingActionMenu(host:HTMLElement,name:string,actions:{label:string;icon:ActionIcon;danger?:boolean;run:()=>void}[]) {
 const trigger=document.createElement('button'),panel=document.createElement('div');
 trigger.type='button';trigger.className='quiet o-more-button';trigger.setAttribute('aria-label','More actions for '+name);trigger.setAttribute('aria-haspopup','menu');trigger.setAttribute('aria-expanded','false');
 trigger.append(document.createTextNode('More'),actionIcon('more'));panel.className='tm-listing-menu';panel.id='listing-actions-'+(++nextMenu);panel.popover='auto';panel.setAttribute('role','menu');panel.setAttribute('aria-label','Actions for '+name);trigger.setAttribute('aria-controls',panel.id);
 let focusOnOpen=0,openAtPointerDown=false;
 const close=()=>{if(panel.matches(':popover-open'))panel.hidePopover();};
 const buttons=actions.map(action=>{const b=document.createElement('button');b.type='button';b.setAttribute('role','menuitem');b.tabIndex=-1;b.className=action.danger?'tm-action-destructive':'';labelAction(b,action.icon,action.label);b.onclick=()=>{close();trigger.focus();action.run();};panel.append(b);return b;});
 // Remember the state before the browser's outside-pointer light dismissal.
 // By click time the menu may already be closed; that same click must not reopen it.
 trigger.onpointerdown=()=>{openAtPointerDown=panel.matches(':popover-open');};
 trigger.onpointercancel=()=>{openAtPointerDown=false;};
 trigger.onclick=()=>{const shouldClose=openAtPointerDown||panel.matches(':popover-open');openAtPointerDown=false;if(shouldClose){close();return;}const rect=trigger.getBoundingClientRect(),width=Math.min(240,window.innerWidth-24),height=actions.length*44+16;panel.style.width=width+'px';panel.style.left=Math.max(12,Math.min(rect.right-width,window.innerWidth-width-12))+'px';panel.style.top=Math.max(12,rect.bottom+height+8>window.innerHeight?rect.top-height-8:rect.bottom+8)+'px';panel.showPopover();};
 trigger.onkeydown=e=>{if(e.key==='ArrowDown'||e.key==='ArrowUp'){e.preventDefault();focusOnOpen=e.key==='ArrowUp'?buttons.length-1:0;if(!panel.matches(':popover-open'))trigger.click();else buttons[focusOnOpen]?.focus();}};
 panel.addEventListener('toggle',()=>{const open=panel.matches(':popover-open');trigger.setAttribute('aria-expanded',String(open));if(open){buttons[focusOnOpen]?.focus();focusOnOpen=0;}});
 panel.onkeydown=e=>{const index=buttons.indexOf(document.activeElement as HTMLButtonElement);if(e.key==='Escape'){e.preventDefault();e.stopPropagation();close();trigger.focus();}else if(e.key==='Tab'){close();trigger.focus();}else if(['ArrowDown','ArrowUp','Home','End'].includes(e.key)){e.preventDefault();buttons[e.key==='Home'?0:e.key==='End'?buttons.length-1:(index+(e.key==='ArrowDown'?1:-1)+buttons.length)%buttons.length]?.focus();}};
 const scroll=(e:Event)=>{if(!panel.contains(e.target as Node))close();};window.addEventListener('resize',close);document.addEventListener('scroll',scroll,true);window.addEventListener('hashchange',close);
 document.body.append(panel);host.append(trigger);
 return ()=>{close();panel.remove();window.removeEventListener('resize',close);document.removeEventListener('scroll',scroll,true);window.removeEventListener('hashchange',close);};
}
