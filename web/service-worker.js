// Saltamos a la v10 para forzar el rediseño total en el iPhone
const CACHE_NAME = 'zou-remote-v10';

const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './style.css',
  './remote.js',
  './manifest.json'
];

// Instalación: Forzamos que el nuevo worker tome el control sin esperar
self.addEventListener('install', (event) => {
  self.skipWaiting(); 
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('ZouRemote: Instalando Versión v10 (Pantalla Completa)');
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
});

// Activación: Borramos TODAS las cachés antiguas (v1 a v9) de raíz
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cache) => {
          if (cache !== CACHE_NAME) {
            console.log('ZouRemote: Limpieza de caché antigua:', cache);
            return caches.delete(cache);
          }
        })
      );
    })
  );
  // Toma el control de la página inmediatamente para aplicar el CSS nuevo
  return self.clients.claim();
});

// Estrategia: Intentar red siempre para que el botón SSH funcione, si no hay red, caché
self.addEventListener('fetch', (event) => {
  event.respondWith(
    fetch(event.request).catch(() => {
      return caches.match(event.request);
    })
  );
});
