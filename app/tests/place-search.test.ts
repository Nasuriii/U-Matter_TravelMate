import {strict as assert} from 'node:assert';
import {normalizePlaceQuery, placeContainsFilter, selectSearchPreviews, type SearchPlace} from '../src/place-search-results.ts';

assert.equal(normalizePlaceQuery('  Ｓａｎ\tJuan  '), 'San Juan');
assert.equal(normalizePlaceQuery('x'.repeat(150)).length, 100);
assert.equal(placeContainsFilter('San Juan'), '"%San Juan%"');
assert.equal(placeContainsFilter('a,b).or(name.eq."all")'), '"%a,b).or(name.eq.\\"all\\")%"');
assert.equal(placeContainsFilter('50%_'), '"%50\\\\%\\\\_%"');
assert.equal(placeContainsFilter('C:\\place'), '"%C:\\\\\\\\place%"');

const place = (name: string, kind: SearchPlace['kind'], id = name): SearchPlace => ({id, name, kind, area: 'San Juan', path: '/' + kind + '/' + id});
const candidates = [place('San Juan cafe', 'restaurant'), place('A little San Juan stop', 'attraction'), place('San Juan', 'destination'), place('Other guesthouse', 'hotel'), ...Array.from({length: 10}, (_, i) => place('San Juan kitchen ' + i, 'restaurant'))];
const previews = selectSearchPreviews('san juan', candidates);
assert.equal(previews.length, 8);
assert.equal(previews[0].name, 'San Juan');
assert.deepEqual(new Set(previews.map(item => item.kind)), new Set(['destination', 'restaurant', 'attraction', 'hotel']));
assert.ok(previews.findIndex(item => item.name === 'San Juan cafe') < previews.findIndex(item => item.name === 'A little San Juan stop'));
assert.equal(selectSearchPreviews('San Juan', [candidates[0], candidates[0]]).length, 1);
assert.deepEqual(selectSearchPreviews('missing', []), []);
console.log('12 place-search assertions passed.');
