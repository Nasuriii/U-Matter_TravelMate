import {client,currentIdentity,isSuspended} from './state';

export function rememberTripCheckout(tripId:string,day?:string){
 sessionStorage.setItem('travelmate:checkout-trip',JSON.stringify({tripId,day,profileId:currentIdentity().id}));
}
export async function checkout(bookingId:string){
 if(isSuspended())throw new Error('Bookings and payments are paused while your account is suspended.');
 const uid=currentIdentity().id;
 const {data,error}=await client.functions.invoke('create-checkout',{body:{bookingId,returnOrigin:location.origin}});
 if(error){let message=error.message;if('context' in error&&error.context instanceof Response){const body=await error.context.json().catch(()=>null);if(body?.error)message=body.error;}throw new Error(message);}
 if(currentIdentity().id!==uid||isSuspended())throw new Error('Your account changed. Reopen your reservation to continue.');
 if(data?.error)throw new Error(data.error);
 const url=new URL(data?.url);if(url.protocol!=='https:'||url.hostname!=='checkout.stripe.com')throw new Error('The payment provider returned an unexpected checkout URL.');
 sessionStorage.setItem('travelmate:checkout-booking',JSON.stringify({bookingId,profileId:uid}));
 location.assign(url.href);
}
export function offerBookingToTrip(bookingId:string){
 window.dispatchEvent(new CustomEvent('travelmate:attach-booking',{detail:{bookingId,prompt:true}}));
}
