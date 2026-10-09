import type {SupabaseClient} from '@supabase/supabase-js';
export const itineraryMarkup='';
export function initItinerary(_client:SupabaseClient){return {open(id:string,transportId?:string){window.dispatchEvent(new CustomEvent('travelmate:open-planner',{detail:{id,transportId}}));},clear(){window.dispatchEvent(new Event('travelmate:close-planner'));}};}
