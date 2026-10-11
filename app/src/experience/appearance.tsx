import {toast} from '../ui';
import {BuddySurprise} from './buddy-surprise';
import { useEffect, useState } from 'react';
import { Sun, Moon, Monitor, Sparkles, Cat, Check, Palette } from 'lucide-react';
import { useIdentity } from './state';
type Theme = 'light' | 'dark' | 'system';
type ColorStyle = 'classic' | 'ocean' | 'warm';
type Settings = {theme:Theme;palette:ColorStyle;buddy:boolean;sticker:number;character:string};
const colorStyles = [
 {value:'classic',label:'Classic Green',description:'Forest green & cream'},
 {value:'ocean',label:'Ocean Blue',description:'Fresh white & blue'},
 {value:'warm',label:'Warm Terracotta',description:'The current TravelMate style'},
] as const;
const key = (id:string|null) => 'travelmate:appearance:'+(id||'guest');
function read(id:string|null, admin:boolean):Settings {
 try { const value=JSON.parse(localStorage.getItem(key(id))||'null');return {theme:['light','dark','system'].includes(value?.theme)?value.theme:admin?'dark':'light',palette:colorStyles.some(style=>style.value===value?.palette)?value.palette:'warm',buddy:value?.buddy===true,sticker:Number.isInteger(value?.sticker)&&value.sticker>=1&&value.sticker<=6?value.sticker:1,character:['marsey','cat','turtle'].includes(value?.character)?value.character:'marsey'}; }
 catch{return {theme:admin?'dark':'light',palette:'warm',buddy:false,sticker:1,character:'marsey'};}
}
export function AppearanceSettings(){
 const identity=useIdentity(); const [settings,setSettings]=useState<Settings>(()=>read(identity.id,identity.role==='admin'));
 const [saved,setSaved]=useState('');
 useEffect(()=>{setSettings(read(identity.id,identity.role==='admin'));setSaved('');},[identity.id,identity.role]);
 function update(next:Settings){try{localStorage.setItem(key(identity.id),JSON.stringify(next));setSettings(next);setSaved('Saved on this browser.');toast(next.palette!==settings.palette?colorStyles.find(style=>style.value===next.palette)!.label+' applied.':'Appearance saved on this browser.');window.dispatchEvent(new Event('travelmate:appearance'));}catch{setSaved('Your browser could not save this preference.');toast('Your browser could not save this preference.',true);}}
 if(!identity.id)return null;
 return <div className="tm-appearance">
  <section className="tm-appearance-card">
   <div className="tm-appearance-heading"><Palette size={22}/><div><h2>Appearance</h2><p>Choose the colors and view that feel right for you.</p></div></div>
   <div className="tm-appearance-group">
    <h3><Palette size={18}/>Color style</h3>
    <div className="tm-palette-options" role="group" aria-label="Color style">
     {colorStyles.map(({value,label,description})=><button type="button" key={value} className="tm-palette-card" data-palette={value} aria-pressed={settings.palette===value} onClick={()=>update({...settings,palette:value})}>
      <span className="tm-palette-mini" aria-hidden="true"><i className="tm-mini-rail"/><span className="tm-mini-page"><i className="tm-mini-heading"/><span className="tm-mini-cards"><i/><i/></span><i className="tm-mini-action"/></span></span>
      <span className="tm-palette-caption"><strong>{label}</strong><small>{description}</small><span className="tm-palette-swatches" aria-hidden="true"><i/><i/><i/></span></span>
      {settings.palette===value&&<span className="tm-palette-check" aria-hidden="true"><Check size={15}/></span>}
     </button>)}
    </div>
   </div>
   <div className="tm-appearance-group tm-display-group">
    <h3><Monitor size={18}/>Display mode</h3>
    <div className="tm-theme-options" role="group" aria-label="Display mode">{([{value:'light',label:'Light',icon:Sun},{value:'dark',label:'Dark',icon:Moon},{value:'system',label:'Device',icon:Monitor}] as const).map(({value,label,icon:Icon})=><button key={value} type="button" aria-pressed={settings.theme===value} onClick={()=>update({...settings,theme:value})}><span className={'tm-theme-preview '+value}><i/><i/><i/></span><span><Icon size={16}/>{label}{settings.theme===value&&<Check size={15}/>}</span></button>)}</div>
   </div>
   <p className="tm-data-note">Device follows your system’s light or dark setting. Your choices are saved for this account on this browser.</p><p className="tm-appearance-status" role="status">{saved}</p>
  </section>
  <section className="tm-appearance-card tm-marsey-card"><div><div className="tm-appearance-heading"><Cat size={22}/><div><h2>Meet Marsey</h2><p>A little company for your next adventure.</p></div></div><div className="tm-marsey-motion"><img className="tm-marsey-animated" src="/marsey/marsey-happy.gif" alt="Marsey the cat waving"/><img className="tm-marsey-static" src={'/marsey/marsey-sticker-'+settings.sticker+'.png'} alt="Marsey the cat"/></div><label className="tm-buddy-toggle"><input type="checkbox" checked={settings.buddy} onChange={e=>update({...settings,buddy:e.target.checked})}/><span>Show my travel buddy</span><Sparkles size={17}/></label><div className="tm-character-picker" role="group" aria-label="Choose animated travel buddy">{['marsey','cat','turtle'].map(character=><button type="button" key={character} aria-label={character+' travel buddy'} aria-pressed={settings.character===character} onClick={()=>update({...settings,character})}><img src={character==='marsey'?'/marsey/marsey-happy.gif':'/buddies/'+character+'.gif'} alt=""/><span>{character==='marsey'?'Marsey':character==='cat'?'Sunny cat':'Turtle'}</span></button>)}</div><div className="tm-sticker-picker" role="group" aria-label="Choose a Marsey sticker">{[1,2,3,4,5,6].map(n=><button type="button" key={n} aria-label={'Marsey sticker '+n} aria-pressed={settings.sticker===n} onClick={()=>update({...settings,sticker:n})}><img src={'/marsey/marsey-sticker-'+n+'.png'} alt="" loading="lazy"/></button>)}</div><details className="tm-data-note"><summary>Sticker sources & downloads</summary><p>Marsey stickers from <a href="https://www.sigstick.com/pack/Oev5POIKDurX1BddZTh5-marsey-the-cat" target="_blank" rel="noreferrer">Sigstick</a>; animations from <a href="https://tenor.com/view/marsey-the-cat-marsey-kitten-cat-kitty-gif-27663408" target="_blank" rel="noreferrer">Tenor</a>.</p><a href="/marsey/marsey-spin.gif" download>Download spinning GIF</a> · <a href="/marsey/marsey-happy.gif" download>Download happy GIF</a></details></div></section></div>;
}
export function AppearanceManager(){
 const identity=useIdentity();const [surprise,setSurprise]=useState(false);const [settings,setSettings]=useState<Settings>(()=>read(identity.id,identity.role==='admin'));
 useEffect(()=>{const media=matchMedia('(prefers-color-scheme: dark)');function apply(){const next=read(identity.id,identity.role==='admin');const dark=next.theme==='dark'||next.theme==='system'&&media.matches;document.body.dataset.theme=dark?'dark':'light';document.body.dataset.palette=next.palette;document.documentElement.classList.toggle('dark',dark);setSettings(next);}
 apply();media.addEventListener('change',apply);window.addEventListener('travelmate:appearance',apply);window.addEventListener('storage',apply);return()=>{media.removeEventListener('change',apply);window.removeEventListener('travelmate:appearance',apply);window.removeEventListener('storage',apply);};},[identity.id,identity.role]);
 return identity.id&&settings.buddy?<><button type="button" className="tm-travel-buddy" aria-label="Get a surprise destination, food or hotel" onClick={()=>setSurprise(true)}><img className="tm-buddy-motion" src={settings.character==='marsey'?'/marsey/marsey-happy.gif':'/buddies/'+settings.character+'.gif'} alt="Your animated travel buddy"/><img className="tm-buddy-still" src={'/marsey/marsey-sticker-'+settings.sticker+'.png'} alt=""/><span>Surprise me!</span></button>{surprise&&<BuddySurprise close={()=>setSurprise(false)}/>}</>:null;
}
