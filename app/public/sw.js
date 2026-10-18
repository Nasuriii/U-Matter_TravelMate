// Only a generic offline page is stored. Private pages, API responses and uploads
// always use the network and are never written to Cache Storage.
const CACHE = 'travelmate-install-v3';
const OFFLINE = '/offline.html';
self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    await cache.add(new Request(OFFLINE, { cache: 'reload' }));
    await self.skipWaiting();
  })());
});
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    for (const name of await caches.keys()) {
      if (name.startsWith('travelmate-install-') && name !== CACHE) await caches.delete(name);
    }
    await self.clients.claim();
  })());
});
self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET' || request.mode !== 'navigate' || new URL(request.url).origin !== self.location.origin) return;
  event.respondWith((async () => {
    try { return await fetch(request); }
    catch {
      const cache = await caches.open(CACHE);
      return await cache.match(OFFLINE) || Response.error();
    }
  })());
});
