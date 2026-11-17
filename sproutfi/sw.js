// Guarda o app no aparelho para abrir rápido e sem internet. Os dados vêm sempre do Supabase.
const V = 'sproutfi-v1';
const FILES = ['./', './index.html', './config.js', './manifest.webmanifest', './icon-192.png', './icon-512.png', './icon-maskable-512.png', './apple-touch-icon.png', './logo.png', './logo-mark.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(V).then(c => c.addAll(FILES)).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(k => Promise.all(k.filter(x => x.startsWith('sproutfi-') && x !== V).map(x => caches.delete(x)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', e => {
  const r = e.request;
  if (r.method !== 'GET' || !r.url.startsWith('http')) return;
  const host = new URL(r.url).hostname;
  if (/supabase\.(co|in)$/.test(host)) return;
  // Página e configuração: tenta a rede primeiro, para pegar versões novas; sem internet, usa a cópia.
  if (r.mode === 'navigate' || r.url.endsWith('/config.js')) {
    e.respondWith(fetch(r).then(res => { if (res.ok) { const c = res.clone(); caches.open(V).then(x => x.put(r.mode === 'navigate' ? './index.html' : r, c)); } return res; })
      .catch(() => caches.match(r.mode === 'navigate' ? './index.html' : r, { ignoreSearch: true })));
    return;
  }
  e.respondWith(caches.match(r).then(hit => hit || fetch(r).then(res => { if (res.ok || res.type === 'opaque') { const c = res.clone(); caches.open(V).then(x => x.put(r, c)); } return res; })));
});
