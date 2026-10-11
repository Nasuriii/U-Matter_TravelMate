import {test} from 'node:test';
import assert from 'node:assert/strict';
import {clockMinutes,clockValue,clockLabel,tripTimesValid} from '../src/trip-clock.ts';

test('time controls distinguish midnight, noon, and evening',()=>{
  assert.equal(clockValue(12,0,'AM'),'00:00');
  assert.equal(clockValue(12,0,'PM'),'12:00');
  assert.equal(clockValue(6,17,'PM'),'18:17');
  assert.equal(clockLabel('00:00'),'12:00 AM');
  assert.equal(clockLabel('12:00:00'),'12:00 PM');
  assert.equal(clockLabel('18:17'),'6:17 PM');
});
test('stored times load and malformed times cannot be saved',()=>{
  assert.equal(clockMinutes('09:05:00'),545);
  for(const value of ['', '24:00', '09:60', '09:05:60', '9:00', 'noon'])assert.equal(clockMinutes(value),null);
});
test('same-day departure must be later, while an overnight trip can depart in the morning',()=>{
  assert.equal(tripTimesValid('2026-11-01','2026-11-01','09:00','09:00'),false);
  assert.equal(tripTimesValid('2026-11-01','2026-11-01','09:00','08:59'),false);
  assert.equal(tripTimesValid('2026-11-01','2026-11-01','09:00','09:01'),true);
  assert.equal(tripTimesValid('2026-11-01','2026-11-02','18:00','08:00'),true);
  assert.equal(tripTimesValid('2026-11-01','2026-11-02','','08:00'),false);
});
