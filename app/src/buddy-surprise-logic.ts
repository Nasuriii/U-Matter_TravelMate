export const buddyHoldDuration=2400;
export type SurpriseCategory='all'|'destination'|'restaurant'|'meal';
export type SurprisePick={id:string;name:string;kind:Exclude<SurpriseCategory,'all'>;path:string;image?:string;area:string;description?:string;price?:number};
export const surpriseKey=(pick:SurprisePick)=>pick.kind+':'+pick.id;
export function buddyShuffleInterval(progress:number){const remaining=1-Math.max(0,Math.min(1,progress));return 45+455*remaining*remaining;}
export function chooseSurpriseCards(pool:SurprisePick[],category:SurpriseCategory='all',previous:string[]=[],random=()=>crypto.getRandomValues(new Uint32Array(1))[0]/4294967296){
 const unique=[...new Map(pool.filter(p=>category==='all'||p.kind===category).map(p=>[surpriseKey(p),p])).values()];
 for(let i=unique.length-1;i>0;i--){const j=Math.floor(random()*(i+1));[unique[i],unique[j]]=[unique[j],unique[i]];}
 // Favor fresh ideas while keeping a destination, restaurant and meal in a mixed draw.
 unique.sort((a,b)=>Number(previous.includes(surpriseKey(a)))-Number(previous.includes(surpriseKey(b))));
 const selected:SurprisePick[]=[];
 if(category==='all')for(const kind of ['destination','restaurant','meal'] as const){const pick=unique.find(p=>p.kind===kind);if(pick)selected.push(pick);}
 for(const pick of unique){if(selected.length===3)break;if(!selected.includes(pick))selected.push(pick);}
 return selected;
}
