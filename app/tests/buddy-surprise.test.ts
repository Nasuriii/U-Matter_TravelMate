import {test} from 'node:test';
import assert from 'node:assert/strict';
import {buddyHoldDuration,buddyShuffleInterval,chooseSurpriseCards,surpriseKey,type SurprisePick} from '../src/buddy-surprise-logic.ts';
const pick=(kind:SurprisePick['kind'],id:string):SurprisePick=>({id,kind,name:id,path:'/'+kind+'/'+id,area:'La Union'});
const pool=[...['destination','restaurant','meal'].flatMap(kind=>[1,2,3].map(n=>pick(kind as SurprisePick['kind'],kind+n)))];
test('sticker changes accelerate smoothly through the hold',()=>{
 assert.equal(buddyHoldDuration,2400);assert.equal(buddyShuffleInterval(0),500);assert.equal(buddyShuffleInterval(1),45);
 assert.ok(buddyShuffleInterval(.25)>buddyShuffleInterval(.5));assert.ok(buddyShuffleInterval(.5)>buddyShuffleInterval(.9));
 assert.equal(buddyShuffleInterval(-1),500);assert.equal(buddyShuffleInterval(2),45);
});
test('a mixed draw includes one destination, restaurant and meal',()=>{
 const cards=chooseSurpriseCards(pool,'all',[],()=>.4);assert.equal(cards.length,3);assert.deepEqual(cards.map(c=>c.kind),['destination','restaurant','meal']);
});
test('shuffling favors unseen cards within each category',()=>{
 const previous=chooseSurpriseCards(pool,'all',[],()=>.4),next=chooseSurpriseCards(pool,'all',previous.map(surpriseKey),()=>.4);
 assert.ok(next.every(card=>!previous.some(old=>surpriseKey(old)===surpriseKey(card))));
});
test('category draws return three unique matching ideas',()=>{
 const cards=chooseSurpriseCards([...pool,...pool],'meal',[],()=>.3);assert.equal(cards.length,3);assert.ok(cards.every(c=>c.kind==='meal'));assert.equal(new Set(cards.map(surpriseKey)).size,3);
});
test('sparse catalogs fill from available kinds without inventing or repeating cards',()=>{
 assert.deepEqual(chooseSurpriseCards([]),[]);const only=pick('destination','one');assert.deepEqual(chooseSurpriseCards([only,only]),[only]);
 const cards=chooseSurpriseCards(pool.filter(c=>c.kind!=='meal'),'all',[],()=>.2);assert.equal(cards.length,3);assert.equal(new Set(cards.map(surpriseKey)).size,3);assert.ok(cards.some(c=>c.kind==='restaurant'));
 assert.deepEqual(chooseSurpriseCards([only],'meal'),[]);
});
