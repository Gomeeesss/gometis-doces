// Remove a versão antiga guardada no aparelho.
self.addEventListener('install',()=>self.skipWaiting());
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x.startsWith('bolso-')).map(x=>caches.delete(x)))).then(()=>self.registration.unregister()))});
