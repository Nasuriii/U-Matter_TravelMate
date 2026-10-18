import {test} from 'node:test';import assert from 'node:assert/strict';
import {reservationSlotInput} from '../src/owner-slot-logic.ts';
const now=Date.parse('2026-10-18T00:00:00Z');
test('slot times use Philippine time and keep seat capacity numeric',()=>{assert.deepEqual(reservationSlotInput('2026-10-19T12:00','2026-10-19T13:30','20',now),{p_start:'2026-10-19T04:00:00.000Z',p_end:'2026-10-19T05:30:00.000Z',p_capacity:20});});
test('slots need valid future dates and increasing times',()=>{for(const [a,b]of [['',''],['2026-02-30T12:00','2026-10-19T13:00'],['2026-10-18T07:00','2026-10-18T08:00'],['2026-10-19T13:00','2026-10-19T12:00']])assert.throws(()=>reservationSlotInput(a,b,'20',now));});
test('slots enforce the database limits before saving',()=>{for(const seats of ['','0','501','1.5','NaN'])assert.throws(()=>reservationSlotInput('2026-10-19T12:00','2026-10-19T13:00',seats,now));assert.throws(()=>reservationSlotInput('2026-10-19T12:00','2026-10-20T01:00','20',now),/12 hours/);});
