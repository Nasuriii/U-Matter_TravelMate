import {test} from 'node:test';
import assert from 'node:assert/strict';
import {calendarDate,monthCells,tripDays} from '../src/trip-calendar.ts';

test('trip dates reject empty and impossible calendar dates',()=>{
  for(const value of ['', '2026-02-29', '2026-04-31', '2026-13-01', '2026-1-2'])assert.equal(calendarDate(value),null);
  assert.ok(calendarDate('2028-02-29'));
});
test('trip duration counts calendar days across months and year boundaries',()=>{
  assert.equal(tripDays('2026-12-31','2027-01-01'),2);
  assert.equal(tripDays('2026-11-01','2026-11-14'),14);
  assert.equal(tripDays('2026-11-01','2026-11-15'),15);
  assert.equal(tripDays('2026-11-02','2026-11-01'),0);
  assert.equal(tripDays('2026-11-01','2026-11-01'),1);
  assert.equal(tripDays('','2026-11-01'),0);
});
test('calendar aligns weekdays and includes leap-month final day',()=>{
  const cells=monthCells(new Date(2028,1,1,12));
  assert.equal(cells.length,42);
  assert.equal(cells[2],'2028-02-01');
  assert.equal(cells.filter(Boolean).length,29);
  assert.ok(cells.includes('2028-02-29'));
});
