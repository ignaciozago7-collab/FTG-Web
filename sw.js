// Service Worker para FTG Fitness (PWA)
const CACHE_NAME = 'ftg-cache-v1';
const STATIC_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
  './logo.png'
];

// Instalación: cachear archivos estáticos esenciales de la interfaz
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch((err) => {
        console.warn('Error en pre-cacheo de assets estáticos:', err);
      });
    })
  );
  self.skipWaiting();
});

// Activación: limpiar versiones anteriores de caché si se actualiza la app
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch: estrategia Network-First para datos y assets
// IMPORTANTE: Todas las llamadas a Supabase y APIs externas SIEMPRE van directo a la red (100% en vivo)
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // 1. Si es llamada a Supabase, cdn externo o métodos que no sean GET -> directo a internet
  if (
    event.request.method !== 'GET' ||
    url.hostname.includes('supabase.co') ||
    url.pathname.includes('/rest/v1/') ||
    url.pathname.includes('/auth/v1/')
  ) {
    return; // El navegador realiza la petición normal a la red
  }

  // 2. Para archivos propios de la app: intentar red primero, con respaldo en caché si no hay conexión
  event.respondWith(
    fetch(event.request)
      .then((networkResponse) => {
        if (networkResponse && networkResponse.status === 200 && networkResponse.type === 'basic') {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      })
      .catch(() => {
        return caches.match(event.request).then((cachedResponse) => {
          if (cachedResponse) return cachedResponse;
          if (event.request.mode === 'navigate') {
            return caches.match('./index.html');
          }
        });
      })
  );
});
