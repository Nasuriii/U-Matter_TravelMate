import { strict as assert } from 'node:assert';
import { validateAuth } from '../src/auth-validation.ts';

const valid = { first: '  Alex  ', email: ' alex@example.com ', password: 'a long password', confirm: 'a long password' };
assert.deepEqual(validateAuth('register', valid), []);
assert.deepEqual(validateAuth('register', { ...valid, first: ' ' }).map(x => x.field), ['reg-first']);
assert.deepEqual(validateAuth('register', { ...valid, email: 'not an email' }).map(x => x.field), ['auth-email']);
assert.deepEqual(validateAuth('register', { ...valid, password: 'short', confirm: 'different' }).map(x => x.field), ['auth-password', 'auth-confirm']);
assert.deepEqual(validateAuth('register', { ...valid, confirm: '' }).map(x => x.field), ['auth-confirm']);
assert.deepEqual(validateAuth('login', { ...valid, first: '', password: 'x', confirm: '' }), []);
assert.deepEqual(validateAuth('login', { ...valid, password: '' }).map(x => x.field), ['auth-password']);
assert.deepEqual(validateAuth('forgot', { first: '', email: 'alex@example.com', password: '', confirm: '' }), []);
assert.deepEqual(validateAuth('reset', { ...valid, first: '', email: '' }), []);
assert.deepEqual(validateAuth('reset', { ...valid, confirm: 'a long password ' }).map(x => x.field), ['auth-confirm']);
console.log('10 auth validation scenarios passed.');
