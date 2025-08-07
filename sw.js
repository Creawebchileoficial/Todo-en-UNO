// Todo Universidad Service Worker v1.2.0
// Build: 06/08/2025

const APP_VERSION = '1.2.0';
const CACHE_NAME = `todo-universidad-v${APP_VERSION}`;
const STATIC_CACHE = `static-v${APP_VERSION}`;
const DYNAMIC_CACHE = `dynamic-v${APP_VERSION}`;

console.log(`Todo Universidad SW v${APP_VERSION} iniciado`);

const staticAssets = [
  '/',
  '/index.html',
  '/style.css',
  '/assets/Todo_Universidad.png',
  '/assets/favicon_iotodo/android-chrome-192x192.png',
  '/assets/favicon_iotodo/android-chrome-512x512.png',
  '/assets/favicon_iotodo/apple-touch-icon.png',
  '/assets/favicon_iotodo/favicon.ico',
  '/assets/favicon_iotodo/site.webmanifest',
  '/site.webmanifest',
  'https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap',
  'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'
];

// Install event - Mejorado para PWA
self.addEventListener('install', event => {
  console.log('SW: Instalando service worker...');
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then(cache => {
        console.log('SW: Cacheando archivos estáticos...');
        return cache.addAll(staticAssets);
      })
      .then(() => {
        console.log('SW: Archivos cacheados exitosamente');
        return self.skipWaiting();
      })
      .catch(error => {
        console.error('SW: Error al cachear archivos:', error);
      })
  );
});

// Activate event
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(cacheName => cacheName !== STATIC_CACHE && cacheName !== DYNAMIC_CACHE)
          .map(cacheName => caches.delete(cacheName))
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event with Network First strategy for HTML, Cache First for assets
self.addEventListener('fetch', event => {
  const { request } = event;
  
  // Skip non-GET requests
  if (request.method !== 'GET') return;
  
  // Skip external requests (except for fonts and icons)
  if (!request.url.startsWith(self.location.origin) && 
      !request.url.includes('fonts.googleapis.com') && 
      !request.url.includes('cdnjs.cloudflare.com')) {
    return;
  }

  // HTML files - Network First strategy
  if (request.destination === 'document') {
    event.respondWith(
      fetch(request)
        .then(response => {
          // Clone response before putting in cache
          const responseClone = response.clone();
          caches.open(DYNAMIC_CACHE)
            .then(cache => cache.put(request, responseClone));
          return response;
        })
        .catch(() => caches.match(request))
    );
    return;
  }

  // Assets - Cache First strategy
  event.respondWith(
    caches.match(request)
      .then(response => {
        if (response) {
          return response;
        }
        
        return fetch(request)
          .then(response => {
            // Don't cache non-successful responses
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            const responseToCache = response.clone();
            caches.open(DYNAMIC_CACHE)
              .then(cache => cache.put(request, responseToCache));
            
            return response;
          });
      })
  );
});

// Handle background sync for offline actions
self.addEventListener('sync', event => {
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

function doBackgroundSync() {
  // Implement background sync logic here if needed
  return Promise.resolve();
}

// Push notification handler
self.addEventListener('push', event => {
  if (event.data) {
    const options = {
      body: event.data.text(),
      icon: '/assets/favicon_iotodo/android-chrome-192x192.png',
      badge: '/assets/favicon_iotodo/android-chrome-192x192.png',
      vibrate: [100, 50, 100],
      data: {
        dateOfArrival: Date.now(),
        primaryKey: 1
      },
      actions: [
        {
          action: 'explore',
          title: 'Ver herramientas',
          icon: '/assets/favicon_iotodo/android-chrome-192x192.png'
        },
        {
          action: 'close',
          title: 'Cerrar',
          icon: '/assets/favicon_iotodo/android-chrome-192x192.png'
        }
      ]
    };
    
    event.waitUntil(
      self.registration.showNotification('Todo Universidad', options)
    );
  }
});

// Notification click handler
self.addEventListener('notificationclick', event => {
  event.notification.close();
  
  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});
