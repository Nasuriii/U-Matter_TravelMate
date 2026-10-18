type Role='admin'|'owner'|'traveler'|'guest'|'loading';
/** Only local, role-appropriate destinations can be produced from notification text. */
export function notificationTarget(message:string,role:Role) {
 if(/booking|reservation|visit.*complete/i.test(message))return {path:role==='owner'?'/reservations':role==='traveler'?'/bookings':'/reports',label:role==='traveler'?'Open bookings':role==='owner'?'Open reservations':'Open reports'};
 if(/listing|approved|review|corrections/i.test(message)&&['owner','admin'].includes(role)){
  const name=message.match(/["“]([^"”]+)["”]|'([^']+)'/)?.slice(1).find(Boolean)?.slice(0,120).replace(/[\uD800-\uDBFF]$/,'');
  return {path:(role==='admin'?'/admin':'/owner')+(name?'?search='+encodeURIComponent(name):''),label:role==='admin'?'Open listing reviews':'Open my listings'};
 }
 return {path:'/home',label:'Open dashboard'};
}

/** Navigation must not wait for a best-effort read receipt. */
export async function followNotification(open:()=>void,markRead:()=>PromiseLike<{error:unknown}>,failed:()=>void){
 open();
 try{const result=await markRead();if(result.error)failed();}catch{failed();}
}
