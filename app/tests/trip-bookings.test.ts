import {test} from 'node:test';
import assert from 'node:assert/strict';
import {bookingBudget,bookingOutsideTrip,bookingOnDay,suggestedBookingDay,confirmationFileError,type BookingTrip,type TripBooking} from '../src/trip-booking-logic.ts';
const trip={id:'trip',start_date:'2026-11-01',end_date:'2026-11-04',budget_currency:'PHP'} as BookingTrip;
const paid={id:'link',booking_id:'booking',source:'travelmate',booking_type:'hotel',start_date:'2026-11-01',end_date:'2026-11-03',planned_date:'2026-11-01',amount:3600,currency:'PHP',status:'confirmed',payment_status:'paid'} as TripBooking;
test('multi-day hotel costs count once and repeated links cannot inflate the budget',()=>{
 const summary=bookingBudget([paid,paid,{...paid,id:'second-link'}],'PHP');assert.equal(summary.total,3600);
 assert.ok(bookingOnDay(paid,'2026-11-01'));assert.ok(bookingOnDay(paid,'2026-11-02'));assert.ok(bookingOnDay(paid,'2026-11-03'));assert.ok(!bookingOnDay(paid,'2026-11-04'));
});
test('refunds, cancellation and unpaid bookings are excluded; other currencies are separate',()=>{
 const rows=[paid,{...paid,id:'external',booking_id:null,source:'external' as const,amount:120.10,payment_status:'reported_paid'},
  {...paid,booking_id:'cancelled',status:'cancelled'},{...paid,booking_id:'refund',payment_status:'refunded'},
  {...paid,booking_id:'unpaid',payment_status:'unpaid'},{...paid,booking_id:'invalid-report',payment_status:'reported_paid'},{...paid,booking_id:'usd',amount:25,currency:'USD'}];
 assert.deepEqual(bookingBudget(rows,'PHP'),{total:3720.10,external:120.10,other:[{currency:'USD',total:25}]});
});
test('out-of-trip dates require a warning and still have a visible trip day',()=>{
 assert.equal(bookingOutsideTrip(paid,trip),false);const earlier={...paid,start_date:'2026-10-30',end_date:'2026-10-31'};
 assert.ok(bookingOutsideTrip(earlier,trip));assert.equal(suggestedBookingDay(earlier,trip),'2026-11-01');
 assert.ok(bookingOnDay({...earlier,planned_date:trip.start_date},trip.start_date));
 assert.equal(suggestedBookingDay({start_date:'2026-11-09'},trip),'2026-11-04');
});
test('restaurant attachments stay on their reservation day',()=>{
 const restaurant={...paid,booking_type:'restaurant' as const,start_date:'2026-11-02',end_date:'2026-11-02',planned_date:'2026-11-02'};
 assert.ok(bookingOnDay(restaurant,'2026-11-02'));assert.ok(!bookingOnDay(restaurant,'2026-11-03'));
});
test('moving a trip window keeps an outside booking visible with its original dates',()=>{
 const moved={...trip,start_date:'2026-12-01',end_date:'2026-12-04'};
 assert.ok(bookingOutsideTrip(paid,moved));assert.ok(bookingOnDay(paid,moved.start_date,moved));
 assert.equal(paid.start_date,'2026-11-01');assert.ok(!bookingOnDay(paid,moved.end_date,moved));
});
test('private confirmations reject executable, empty and oversized files',()=>{
 for(const type of ['application/pdf','image/jpeg','image/png','image/webp'])assert.equal(confirmationFileError({type,size:1024}), '');
 assert.ok(confirmationFileError({type:'text/html',size:100}));assert.ok(confirmationFileError({type:'image/svg+xml',size:100}));
 assert.ok(confirmationFileError({type:'application/pdf',size:0}));assert.ok(confirmationFileError({type:'application/pdf',size:10*1024*1024+1}));
});
