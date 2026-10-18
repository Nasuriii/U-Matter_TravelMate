import {confirmAction} from './action-confirm';

const workspaces = new WeakMap<HTMLElement, ReturnType<typeof ownerWorkspaceDialog>>();
const fieldValue=(field:HTMLInputElement|HTMLTextAreaElement|HTMLSelectElement)=>field instanceof HTMLInputElement&&field.type==='file'?Array.from(field.files??[]).map(file=>file.name+':'+file.size).join('|'):field instanceof HTMLInputElement&&['checkbox','radio'].includes(field.type)?String(field.checked):field.value;
export function ownerWorkspaceDialog(content:HTMLElement, title:string) {
  const backdrop=document.createElement('div');backdrop.className='owner tm-react tm-owner-dialog-backdrop';backdrop.hidden=true;
  const dialog=document.createElement('section');dialog.className='tm-owner-dialog';dialog.setAttribute('role','dialog');dialog.setAttribute('aria-modal','true');dialog.tabIndex=-1;
  const header=document.createElement('header'),heading=document.createElement('h2'),caption=document.createElement('p'),closeButton=document.createElement('button');
  heading.textContent=title;heading.id='owner-workspace-'+content.id;dialog.setAttribute('aria-labelledby',heading.id);caption.textContent='Your business, one section at a time.';
  closeButton.type='button';closeButton.className='tm-owner-dialog-close';closeButton.setAttribute('aria-label','Close listing workspace');closeButton.textContent='×';
  const headingGroup=document.createElement('div'),headerActions=document.createElement('div'),saveAll=document.createElement('button');
  headerActions.className='tm-owner-dialog-actions';saveAll.type='button';saveAll.className='primary tm-owner-save-all';saveAll.textContent='Save all changes';saveAll.hidden=true;
  headingGroup.append(heading,caption);headerActions.append(saveAll,closeButton);header.append(headingGroup,headerActions);
  const nav=document.createElement('nav');nav.className='tm-owner-dialog-tabs';nav.setAttribute('role','tablist');nav.setAttribute('aria-label','Listing sections');
  const layout=document.createElement('div');layout.className='tm-owner-dialog-layout';const footer=document.createElement('footer');footer.className='tm-owner-dialog-footer';
  layout.append(nav,content);dialog.append(header,layout,footer);backdrop.append(dialog);document.body.append(backdrop);
  let previous:HTMLElement|null=null,overflow='',inert: [HTMLElement,boolean][]=[];let busy=false,extraDirty=()=>false,onDiscard=()=>{};
  const baseline=new WeakMap<Element,string>();
  const fields=(root:ParentNode)=>Array.from(root.querySelectorAll<HTMLInputElement|HTMLTextAreaElement|HTMLSelectElement>('input:not([type=search]),textarea,select'));
  const remember=(root:ParentNode)=>fields(root).forEach(field=>baseline.set(field,fieldValue(field)));
  const observe=new MutationObserver(()=>fields(content).forEach(field=>{if(!baseline.has(field))baseline.set(field,fieldValue(field));}));observe.observe(content,{childList:true,subtree:true});
  const changed=(root:ParentNode=content)=>fields(root).some(field=>baseline.has(field)&&fieldValue(field)!==baseline.get(field));
  const hide=()=>{if(backdrop.hidden)return;window.dispatchEvent(new CustomEvent('travelmate:owner-workspace-close',{detail:{content}}));backdrop.hidden=true;document.body.style.overflow=overflow;inert.forEach(([node,was])=>node.inert=was);inert=[];document.removeEventListener('keydown',key,true);previous?.isConnected&&previous.focus();};
  const requestClose=async()=>{if(busy)return;if(changed()||extraDirty()){if(!await confirmAction('Close without saving?','Unsaved changes in this popup will be discarded.','Discard changes','Keep editing'))return;onDiscard();}hide();};
  function key(event:KeyboardEvent){
    if(document.querySelector('.tm-shadcn-confirm,.tm-trip-picker-dialog[open]'))return;
    if(event.key==='Escape'){event.preventDefault();event.stopPropagation();void requestClose();return;}
    if(event.key!=='Tab')return;
    const targets=Array.from(dialog.querySelectorAll<HTMLElement>('button:not(:disabled),a[href],input:not(:disabled),textarea:not(:disabled),select:not(:disabled),[tabindex="0"]')).filter(node=>node.getClientRects().length&&!node.closest('[hidden],[inert]'));
    const first=targets[0],last=targets.at(-1);if(!first){event.preventDefault();dialog.focus();}else if(event.shiftKey&&(document.activeElement===first||document.activeElement===dialog)){event.preventDefault();last?.focus();}else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first.focus();}
  }
  closeButton.onclick=()=>void requestClose();backdrop.onpointerdown=event=>{if(event.target===backdrop)void requestClose();};
  window.addEventListener('hashchange',hide);window.addEventListener('travelmate:identity',hide);
  const api={
    content,footer,nav,get open(){return !backdrop.hidden;},get busy(){return busy;},
    show(nextTitle=title){heading.textContent=nextTitle;content.hidden=false;if(!backdrop.hidden)return;previous=document.activeElement as HTMLElement|null;overflow=document.body.style.overflow;inert=Array.from(document.body.children).filter(node=>node!==backdrop&&!node.hasAttribute('data-toast-root')).map(node=>[node as HTMLElement,(node as HTMLElement).inert]);inert.forEach(([node])=>node.inert=true);document.body.style.overflow='hidden';backdrop.hidden=false;fields(content).forEach(field=>{if(!baseline.has(field))baseline.set(field,fieldValue(field));});document.addEventListener('keydown',key,true);dialog.focus();},
    configureDraft(check:()=>boolean,discard:()=>void){extraDirty=check;onDiscard=discard;},
    hide,markSaved:remember,hasChanges:changed,
    configureSaveAll(save:()=>Promise<void>){saveAll.hidden=false;saveAll.onclick=()=>void save();},
    reveal(target:HTMLElement){const index=Array.from(content.children).findIndex(panel=>panel===target||panel.contains(target));if(index>=0)(nav.children[index] as HTMLButtonElement|undefined)?.click();},
    setBusy(value:boolean){busy=value;layout.inert=value;dialog.setAttribute('aria-busy',String(value));closeButton.disabled=value;saveAll.disabled=value;saveAll.textContent=value?'Saving…':'Save all changes';footer.querySelectorAll<HTMLButtonElement>('button').forEach(button=>button.disabled=value);},
    sections(sections:{label:string;content:HTMLElement}[],initial='Basic information'){
      nav.replaceChildren();const panels=sections.map(section=>section.content);content.replaceChildren(...panels);
      const choose=(index:number)=>{content.scrollTop=0;panels.forEach((panel,i)=>panel.hidden=i!==index);Array.from(nav.children).forEach((node,i)=>{node.setAttribute('aria-selected',String(i===index));(node as HTMLButtonElement).tabIndex=i===index?0:-1;});};
      sections.forEach((section,index)=>{const button=document.createElement('button');button.type='button';button.textContent=section.label;button.setAttribute('role','tab');button.id=heading.id+'-tab-'+index;section.content.id=heading.id+'-panel-'+index;button.setAttribute('aria-controls',section.content.id);section.content.setAttribute('role','tabpanel');section.content.setAttribute('aria-labelledby',button.id);button.onclick=()=>choose(index);button.onkeydown=event=>{if(['ArrowDown','ArrowUp','ArrowRight','ArrowLeft','Home','End'].includes(event.key)){event.preventDefault();const available=Array.from(nav.children).map((node,i)=>({node:node as HTMLElement,index:i})).filter(item=>!item.node.hidden),current=available.findIndex(item=>item.index===index),next=event.key==='Home'?available[0]:event.key==='End'?available.at(-1):available[(current+(['ArrowDown','ArrowRight'].includes(event.key)?1:-1)+available.length)%available.length];if(next){choose(next.index);next.node.focus();}}};nav.append(button);});
      choose(Math.max(0,sections.findIndex(section=>section.label===initial)));remember(content);
    },
    organize(){
      const sections=Array.from(content.querySelectorAll<HTMLDetailsElement>(':scope>details.acc')).map(details=>({label:details.querySelector('.acc-title')?.textContent??'Details',content:details.querySelector<HTMLElement>('.acc-body')!}));
      const extras=Array.from(content.children).filter(node=>!(node instanceof HTMLDetailsElement)&&node.tagName!=='H2');
      const basic=sections.find(section=>section.label==='Basic information');if(basic)basic.content.prepend(...extras);
      sections.sort((a,b)=>Number(b.label==='Basic information')-Number(a.label==='Basic information'));api.sections(sections,'Basic information');
    }
  };
  workspaces.set(backdrop,api);return api;
}
export function markOwnerFormSaved(root:HTMLElement){const backdrop=root.closest<HTMLElement>('.tm-owner-dialog-backdrop');if(backdrop)workspaces.get(backdrop)?.markSaved(root);}
