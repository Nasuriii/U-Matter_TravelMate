import { test } from 'node:test';
import assert from 'node:assert/strict';
import { listingPage, listingRange } from '../src/listing-pagination.ts';

test('shows every listing once across the six-item pages', () => {
  const rows = Array.from({ length: 48 }, (_, id) => id);
  assert.equal(listingPage(rows, 1).pages, 8);
  assert.equal(listingRange(listingPage(rows, 2)), '7–12 of 48 listings');
  assert.deepEqual(Array.from({ length: 8 }, (_, index) => listingPage(rows, index + 1).items).flat(), rows);
});

test('clamps stale pages after filtering or deleting the final item', () => {
  assert.deepEqual(listingPage([1, 2], 8).items, [1, 2]);
  assert.equal(listingPage([1, 2], 8).page, 1);
  assert.equal(listingPage(Array.from({ length: 6 }), 2).page, 1);
  assert.equal(listingPage([1], -2).page, 1);
});

test('empty filters do not invent a row range or produce an invalid page', () => {
  const result = listingPage([], 8);
  assert.deepEqual(result, { items: [], total: 0, pages: 1, page: 1, start: 0, end: 0 });
  assert.equal(listingRange(result), 'No matching listings');
  assert.equal(listingPage([1, 2], NaN, 0).page, 1);
});
