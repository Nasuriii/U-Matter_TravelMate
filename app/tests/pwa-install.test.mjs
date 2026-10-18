import assert from 'node:assert/strict';
import test from 'node:test';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';

const origin = 'https://travelmate-android-ginoki.snowydrake.chatgpt.site';
const workerSource = readFileSync(new URL('../public/sw.js', import.meta.url), 'utf8');
function worker(network = async () => new Response('live')) {
  const events = {}, added = [], deleted = [];
  const cache = {add: async request => added.push(request.url), match: async () => new Response('offline')};
  vm.runInNewContext(workerSource, {
    self: {location: {origin}, addEventListener: (name, fn) => {events[name] = fn;}, skipWaiting: async () => {}, clients: {claim: async () => {}}},
    caches: {open: async () => cache, keys: async () => ['travelmate-install-v0', 'other-feature-cache'], delete: async name => deleted.push(name)},
    Request: class {constructor(url) {this.url = url;}}, URL, Response, fetch: network,
  });
  return {events, added, deleted};
}
function navigate(events, request) {
  let result;
  events.fetch({request, respondWith: value => {result = value;}});
  return result;
}
test('only the generic offline page is stored; activation preserves other caches', async () => {
  const {events, added, deleted} = worker();
  let done;
  events.install({waitUntil: p => {done = p;}}); await done;
  assert.deepEqual(added, ['/offline.html']);
  events.activate({waitUntil: p => {done = p;}}); await done;
  assert.deepEqual(deleted, ['travelmate-install-v0']);
});
test('API responses, private uploads and mutations bypass the worker', () => {
  const {events} = worker();
  for (const request of [
    {method: 'GET', mode: 'cors', url: 'https://example.supabase.co/rest/v1/bookings'},
    {method: 'GET', mode: 'cors', url: origin + '/private/receipt.pdf'},
    {method: 'GET', mode: 'navigate', url: 'https://example.supabase.co/storage/v1/object/sign/receipt'},
    {method: 'POST', mode: 'navigate', url: origin + '/reservation'},
  ]) assert.equal(navigate(events, request), undefined);
});
test('online navigation returns fresh network content without storing it', async () => {
  const {events, added} = worker(async () => new Response('fresh account page'));
  const response = await navigate(events, {method: 'GET', mode: 'navigate', url: origin + '/'});
  assert.equal(await response.text(), 'fresh account page');
  assert.deepEqual(added, []);
});
test('offline navigation returns the generic connection guide', async () => {
  const {events} = worker(async () => {throw new Error('offline');});
  const response = await navigate(events, {method: 'GET', mode: 'navigate', url: origin + '/'});
  assert.equal(await response.text(), 'offline');
});

const installSource = readFileSync(new URL('../public/pwa-install.js', import.meta.url), 'utf8');
function installation() {
  const events = {}, elements = {};
  for (const id of ['install', 'install-status', 'manual-install']) elements[id] = {
    dataset: {}, disabled: false, textContent: '', open: false, listeners: {},
    addEventListener(name, fn) {this.listeners[name] = fn;}, querySelector() {return {focus() {}};},
  };
  vm.runInNewContext(installSource, {
    window: {addEventListener: (name, fn) => {events[name] = fn;}, isSecureContext: true},
    document: {getElementById: id => elements[id], addEventListener() {}},
    navigator: {userAgent: 'Android Chrome', serviceWorker: {register: async () => {}}},
    location: {origin, href: origin + '/install'}, matchMedia: () => ({matches: false}), URL,
  });
  return {events, elements};
}
test('Install remains visible and offers manual steps when the browser has no prompt', () => {
  const {elements} = installation();
  assert.equal(elements.install.disabled, false);
  assert.equal(elements.install.textContent, 'Install TravelMate');
  elements.install.listeners.click();
  assert.equal(elements['manual-install'].open, true);
  assert.match(elements['install-status'].textContent, /Add to Home screen/);
});
test('a browser prompt is offered once and installed state follows the browser confirmation', async () => {
  const {events, elements} = installation();
  let prompts = 0;
  events.beforeinstallprompt({preventDefault() {}, prompt: async () => {prompts++;}, userChoice: Promise.resolve({outcome: 'accepted'})});
  assert.equal(elements.install.dataset.state, 'ready');
  elements.install.listeners.click();
  elements.install.listeners.click();
  await new Promise(resolve => setImmediate(resolve));
  assert.equal(prompts, 1);
  assert.match(elements['install-status'].textContent, /requested/);
  assert.equal(elements.install.disabled, false);
  events.appinstalled();
  assert.equal(elements.install.disabled, true);
  assert.equal(elements.install.textContent, 'TravelMate is installed');
});
