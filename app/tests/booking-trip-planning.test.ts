import {test} from 'node:test';
import assert from 'node:assert/strict';
import {bookingTripSeed,bookingVisitTimes,bookingScheduleCheck,type PaidBooking,type BookingTrip} from '../src/trip-booking-logic.ts';
import type {Stop} from '../src/itinerary-engine.ts';
const booking={booking_id:'reservation',listing_id:'hotel',name:'Coastal stay',booking_type:'hotel',destination_id:'agoo',start_date:'2026-11-03',end_date:'2026-11-05',start_time:'14:00:00',end_time:'11:00:00',guest_count:2,currency:'PHP'} as PaidBooking;
const trip={id:'trip',destination_id:'agoo',start_date:'2026-11-01',end_date:'2026-11-04',arrival_time:'09:00:00',departure_time:'18:00:00'} as BookingTrip;
const stop=(activity:string,start:string,end:string,listing:string|null=null):Stop=>({activity,planned_date:'2026-11-03',planned_time:start,planned_end_time:end,listing_id:listing,notes:'Keep this note',recommendation_reason:''});

test('new hotel plans include checkout and retain guests without assuming a budget',()=>{
 const seed=bookingTripSeed(booking)!;
 assert.deepEqual(seed,{name:'Trip · Coastal stay',start_date:'2026-11-03',end_date:'2026-11-05',arrival_time:'14:00',departure_time:'11:00',party_size:2,budget_currency:'PHP'});
 assert.equal('budget' in seed,false);assert.deepEqual(bookingVisitTimes(booking),{start:'14:00',end:'15:00'});
 assert.equal(bookingScheduleCheck(booking,trip,'2026-11-03','14:00','15:00',[]).outsideDates,true);
});
test('restaurant plans use reserved times and support a midnight departure on the next date',()=>{
 const restaurant={...booking,booking_type:'restaurant' as const,start_date:'2026-11-03',end_date:'2026-11-03',start_time:'12:30:00',end_time:'13:30:00'};
 assert.deepEqual(bookingVisitTimes(restaurant),{start:'12:30',end:'13:30'});
 assert.equal(bookingTripSeed(restaurant)!.departure_time,'13:30');
 const midnight={...restaurant,end_date:'2026-11-04',start_time:'23:30:00',end_time:'00:30:00'};
 assert.deepEqual(bookingVisitTimes(midnight),{start:'23:30',end:'23:59'});
 assert.equal(bookingTripSeed(midnight)!.departure_time,'00:30');
});
test('trip prefills respect planning limits without truncating reservation dates',()=>{
 assert.ok(bookingTripSeed({...booking,start_date:'2026-11-01',end_date:'2026-11-14'}));
 assert.equal(bookingTripSeed({...booking,start_date:'2026-11-01',end_date:'2026-11-15'}),null);
 assert.equal(bookingTripSeed({...booking,end_date:'2026-11-01'}),null);
 assert.equal(bookingTripSeed({...booking,start_date:'invalid'}),null);
 assert.equal(bookingTripSeed({...booking,guest_count:99})!.party_size,20);
});
test('schedule checks allow adjacent stops and arrival markers but detect overlaps',()=>{
 const items=[stop('Arrival','14:00:00','14:00:00'),stop('Lunch','13:00:00','14:00:00'),stop('Museum','15:00:00','16:00:00')];
 assert.equal(bookingScheduleCheck(booking,trip,'2026-11-03','14:00','15:00',items).overlaps.length,0);
 assert.deepEqual(bookingScheduleCheck(booking,trip,'2026-11-03','14:30','15:30',items).overlaps.map(s=>s.activity),['Museum']);
 assert.equal(items[2].notes,'Keep this note');
});
test('compatibility checks mirror the scheduler’s existing-place reuse rule',()=>{
 const existing=stop('Check in','13:30:00','14:30:00','hotel');
 assert.equal(bookingScheduleCheck(booking,trip,'2026-11-03','14:00','15:00',[existing]).overlaps.length,0);
 const second=stop('Visit again','14:15','14:45','hotel');
 assert.equal(bookingScheduleCheck(booking,trip,'2026-11-03','14:00','15:00',[existing,second]).overlaps.length,2);
 assert.equal(bookingScheduleCheck(booking,trip,'2026-11-03','13:30','14:30',[existing,second]).overlaps.length,1);
});
test('destination and arrival/departure checks include only the relevant dates',()=>{
 assert.equal(bookingScheduleCheck(booking,{...trip,destination_id:'baguio'},'2026-11-03','14:00','15:00',[]).destinationMismatch,true);
 assert.equal(bookingScheduleCheck(booking,trip,'2026-11-01','08:00','09:00',[]).outsideHours,true);
 assert.equal(bookingScheduleCheck(booking,trip,'2026-11-04','17:00','18:30',[]).outsideHours,true);
 assert.equal(bookingScheduleCheck(booking,trip,'2026-11-03','08:00','09:00',[]).outsideHours,false);
});
