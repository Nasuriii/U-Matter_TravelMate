import {test} from 'node:test';
import assert from 'node:assert/strict';
import {notificationTarget} from '../src/notification-target.ts';
test('notification links stay in the correct role workspace',()=>{assert.equal(notificationTarget('Reservation confirmed','owner').path,'/reservations');assert.equal(notificationTarget('Booking updated','traveler').path,'/bookings');assert.equal(notificationTarget('New listing “Pine Haven” awaiting review','admin').path,'/admin?search=Pine%20Haven');assert.equal(notificationTarget('Your listing "Pine Haven" was approved','owner').path,'/owner?search=Pine%20Haven');});
test('untrusted notification text cannot provide an external navigation URL',()=>{assert.equal(notificationTarget('Visit https://example.com','owner').path,'/home');assert.equal(notificationTarget('Listing "https://evil.example"','admin').path,'/admin?search=https%3A%2F%2Fevil.example');});
test('truncating a long listing name does not split an emoji in its link',()=>{const name='a'.repeat(119)+'😀';assert.equal(notificationTarget('Listing "'+name+'"','admin').path,'/admin?search='+'a'.repeat(119));});
