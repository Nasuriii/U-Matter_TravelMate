import {test} from 'node:test';import assert from 'node:assert/strict';
import {reservationSlotInput,reservationSlotRange,reservationSlotLabel} from '../src/owner-slot-logic.ts';
const now=Date.parse('2026-10-18T00:00:00Z');
test('slot times use Philippine time and keep seat capacity numeric',()=>{assert.deepEqual(reservationSlotInput('2026-10-19T12:00','2026-10-19T13:30','20',now),{p_start:'2026-10-19T04:00:00.000Z',p_end:'2026-10-19T05:30:00.000Z',p_capacity:20});});
test('slots need valid future dates and increasing times',()=>{for(const [a,b]of [['',''],['2026-02-30T12:00','2026-10-19T13:00'],['2026-10-18T07:00','2026-10-18T08:00'],['2026-10-19T13:00','2026-10-19T12:00']])assert.throws(()=>reservationSlotInput(a,b,'20',now));});
test('slots enforce the database limits before saving',()=>{for(const seats of ['','0','501','1.5','NaN'])assert.throws(()=>reservationSlotInput('2026-10-19T12:00','2026-10-19T13:00',seats,now));assert.throws(()=>reservationSlotInput('2026-10-19T12:00','2026-10-20T01:00','20',now),/12 hours/);});

test('duration choices calculate the end time on the same day',()=>{assert.deepEqual(reservationSlotRange('2026-10-19','12:00',90),{start:'2026-10-19T12:00',end:'2026-10-19T13:30'});});
test('overnight and year-boundary slots calculate the next date automatically',()=>{assert.deepEqual(reservationSlotRange('2026-12-31','23:30',90),{start:'2026-12-31T23:30',end:'2027-01-01T01:00'});const range=reservationSlotRange('2026-10-19','20:00',720);assert.equal(range.end,'2026-10-20T08:00');assert.doesNotThrow(()=>reservationSlotInput(range.start,range.end,'20',now));});
test('incomplete times, invalid dates and excessive durations cannot produce a slot',()=>{for(const [date,time,minutes]of [['2026-02-30','09:00',60],['','09:00',60],['2026-10-19','24:00',60],['2026-10-19','',60],['2026-10-19','09:00',0],['2026-10-19','09:00',721],['2026-10-19','09:00',1.5]] as const)assert.throws(()=>reservationSlotRange(date,time,minutes));});
test('saved overnight slot labels show both Philippine dates',()=>{const label=reservationSlotLabel('2026-10-20T15:30:00Z','2026-10-20T17:00:00Z');assert.match(label,/Oct 20/);assert.match(label,/Oct 21/);});
