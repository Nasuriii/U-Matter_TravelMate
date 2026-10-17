import {currentIdentity,navigate} from './experience/state';
import {toast} from './ui';
import type {BookingTripSeed} from './trip-booking-logic';
export type ItineraryChoice={destinationId:string;destinationName?:string;listingId?:string;listingName?:string;bookingId?:string;tripSeed?:BookingTripSeed};
export function startNewItinerary(request:ItineraryChoice){
 const identity=currentIdentity();if(identity.role!=='traveler')return;
 sessionStorage.setItem('travelmate:plan-destination',request.destinationId);
 sessionStorage.setItem('travelmate:new-trip-context',JSON.stringify({...request,profileId:identity.id}));
 navigate('/trips');window.dispatchEvent(new Event('travelmate:new-trip'));
}
export function chooseItinerary(request:ItineraryChoice){
 const identity=currentIdentity();
 if(identity.role==='guest'){sessionStorage.setItem('travelmate:pending-itinerary-choice',JSON.stringify(request));sessionStorage.setItem('travelmate:entry-intent','traveler');navigate('/register/traveler');return;}
 if(identity.role!=='traveler'){toast('Open a traveler account to plan a trip.',true);return;}
 window.dispatchEvent(new CustomEvent('travelmate:choose-itinerary',{detail:request}));
}
