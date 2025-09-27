// Todo Universidad Service Worker v1.3.0 - PWA Avanzada
// Build: 26/09/2025
// Características: Caching inteligente, offline-first, favoritos sync

const APP_VERSION = '1.3.0';
const CACHE_NAME = `todo-universidad-v${APP_VERSION}`;
const STATIC_CACHE = `static-v${APP_VERSION}`;
const DYNAMIC_CACHE = `dynamic-v${APP_VERSION}`;
const FAVORITES_CACHE = `favorites-v${APP_VERSION}`;
const API_CACHE = `api-v${APP_VERSION}`;

// Configuración avanzada de caching
const CACHE_CONFIG = {
  staticMaxAge: 30 * 24 * 60 * 60 * 1000, // 30 días
  dynamicMaxAge: 7 * 24 * 60 * 60 * 1000,  // 7 días
  apiMaxAge: 60 * 60 * 1000,                // 1 hora
  maxEntries: {
    dynamic: 100,
    api: 50
  }
};

console.log(`Todo Universidad SW v${APP_VERSION} iniciado - PWA Avanzada`);

// Assets críticos para funcionamiento offline
const criticalAssets = [
  '/',
  '/index.html',
  '/style.css',
  '/assets/Todo_Universidad.png',
  '/assets/favicon_iotodo/favicon.ico',
  '/assets/favicon_iotodo/site.webmanifest',
  '/site.webmanifest'
];

// Assets importantes (se cachean después de los críticos)
const importantAssets = [
  '/assets/favicon_iotodo/android-chrome-192x192.png',
  '/assets/favicon_iotodo/android-chrome-512x512.png',
  '/assets/favicon_iotodo/apple-touch-icon.png',
  'https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap',
  'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'
];

// Herramientas más utilizadas (precachear para acceso rápido)
const popularTools = [
  '/promedio.html',
  '/cientifica.html',
  '/Calculadora_de_ahorros.html',
  '/cronometro.html',
  '/generar_qr.html'
];

// Combinar todos los assets estáticos
const staticAssets = [...criticalAssets, ...importantAssets];

// Utilidades de caching avanzadas
function cleanupCache(cacheName, maxEntries, maxAge) {
  return caches.open(cacheName).then(cache => {
    return cache.keys().then(keys => {
      const now = Date.now();
      const expiredKeys = [];
      const validKeys = [];
      
      return Promise.all(
        keys.map(key => {
          return cache.match(key).then(response => {
            const cached = new Date(response.headers.get('date')).getTime();
            if (now - cached > maxAge) {
              expiredKeys.push(key);
            } else {
              validKeys.push({ key, cached });
            }
          });
        })
      ).then(() => {
        // Eliminar entradas expiradas
        const deleteExpired = expiredKeys.map(key => cache.delete(key));
        
        // Si excedemos el límite, eliminar las más antigas
        if (validKeys.length > maxEntries) {
          validKeys.sort((a, b) => a.cached - b.cached);
          const toDelete = validKeys.slice(0, validKeys.length - maxEntries);
          const deleteOldest = toDelete.map(item => cache.delete(item.key));
          return Promise.all([...deleteExpired, ...deleteOldest]);
        }
        
        return Promise.all(deleteExpired);
      });
    });
  });
}

// Install event - PWA Avanzada con caching inteligente
self.addEventListener('install', event => {
  console.log('SW v1.3.0: Instalando service worker con PWA avanzada...');
  
  event.waitUntil(
    Promise.all([
      // Cachear assets críticos primero
      caches.open(STATIC_CACHE).then(cache => {
        console.log('SW: Cacheando assets críticos...');
        return cache.addAll(criticalAssets);
      }),
      
      // Cachear assets importantes después
      caches.open(STATIC_CACHE).then(cache => {
        console.log('SW: Cacheando assets importantes...');
        return Promise.allSettled(
          importantAssets.map(asset => 
            cache.add(asset).catch(err => 
              console.warn(`SW: No se pudo cachear ${asset}:`, err)
            )
          )
        );
      }),
      
      // Pre-cachear herramientas populares
      caches.open(DYNAMIC_CACHE).then(cache => {
        console.log('SW: Pre-cacheando herramientas populares...');
        return Promise.allSettled(
          popularTools.map(tool =>
            fetch(tool)
              .then(response => response.ok ? cache.put(tool, response) : null)
              .catch(err => console.warn(`SW: No se pudo pre-cachear ${tool}:`, err))
          )
        );
      })
    ])
    .then(() => {
      console.log('SW: Instalación completada exitosamente');
      return self.skipWaiting();
    })
    .catch(error => {
      console.error('SW: Error durante instalación:', error);
    })
  );
});

// Activate event - Limpieza inteligente de caché
self.addEventListener('activate', event => {
  console.log('SW v1.3.0: Activando service worker...');
  
  event.waitUntil(
    Promise.all([
      // Limpiar caches antiguos
      caches.keys().then(cacheNames => {
        const currentCaches = [STATIC_CACHE, DYNAMIC_CACHE, FAVORITES_CACHE, API_CACHE];
        return Promise.all(
          cacheNames
            .filter(cacheName => !currentCaches.includes(cacheName))
            .map(cacheName => {
              console.log('SW: Eliminando caché antiguo:', cacheName);
              return caches.delete(cacheName);
            })
        );
      }),
      
      // Limpiar entradas expiradas en caches existentes
      cleanupCache(DYNAMIC_CACHE, CACHE_CONFIG.maxEntries.dynamic, CACHE_CONFIG.dynamicMaxAge),
      cleanupCache(API_CACHE, CACHE_CONFIG.maxEntries.api, CACHE_CONFIG.apiMaxAge)
    ])
    .then(() => {
      console.log('SW: Activación completada, tomando control de clientes');
      return self.clients.claim();
    })
    .catch(error => {
      console.error('SW: Error durante activación:', error);
    })
  );
});

// Estrategias de caching inteligentes
function getStrategy(request) {
  const url = new URL(request.url);
  
  // API calls - Stale While Revalidate
  if (url.pathname.includes('/api/') || url.searchParams.has('api')) {
    return 'staleWhileRevalidate';
  }
  
  // Herramientas HTML - Network First con timeout
  if (url.pathname.endsWith('.html') && url.pathname !== '/') {
    return 'networkFirstWithTimeout';
  }
  
  // Assets estáticos - Cache First
  if (url.pathname.includes('/assets/') || 
      url.hostname.includes('fonts.googleapis.com') ||
      url.hostname.includes('cdnjs.cloudflare.com')) {
    return 'cacheFirst';
  }
  
  // Página principal - Network First
  if (url.pathname === '/' || url.pathname === '/index.html') {
    return 'networkFirst';
  }
  
  // Default - Cache First
  return 'cacheFirst';
}

// Fetch event - PWA Avanzada con estrategias inteligentes
self.addEventListener('fetch', event => {
  const { request } = event;
  
  // Skip non-GET requests
  if (request.method !== 'GET') return;
  
  // Skip chrome-extension and other non-http requests
  if (!request.url.startsWith('http')) return;
  
  const strategy = getStrategy(request);
  
  switch (strategy) {
    case 'networkFirst':
      event.respondWith(networkFirst(request));
      break;
      
    case 'networkFirstWithTimeout':
      event.respondWith(networkFirstWithTimeout(request, 3000));
      break;
      
    case 'cacheFirst':
      event.respondWith(cacheFirst(request));
      break;
      
    case 'staleWhileRevalidate':
      event.respondWith(staleWhileRevalidate(request));
      break;
      
    default:
      event.respondWith(cacheFirst(request));
  }
});

// Network First Strategy
async function networkFirst(request) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(DYNAMIC_CACHE);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // Fallback offline page for HTML requests
    if (request.destination === 'document') {
      return caches.match('/index.html');
    }
    
    throw error;
  }
}

// Network First with Timeout Strategy
async function networkFirstWithTimeout(request, timeout = 3000) {
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    const response = await fetch(request, { signal: controller.signal });
    clearTimeout(timeoutId);
    
    if (response.ok) {
      const cache = await caches.open(DYNAMIC_CACHE);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    console.log(`SW: Timeout o error de red para ${request.url}, usando cache`);
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    return caches.match('/index.html');
  }
}

// Cache First Strategy
async function cacheFirst(request) {
  const cachedResponse = await caches.match(request);
  if (cachedResponse) {
    return cachedResponse;
  }
  
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(
        request.url.includes('/api/') ? API_CACHE : DYNAMIC_CACHE
      );
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    console.error('SW: Error en cache first:', error);
    throw error;
  }
}

// Stale While Revalidate Strategy
async function staleWhileRevalidate(request) {
  const cache = await caches.open(API_CACHE);
  const cachedResponse = await cache.match(request);
  
  // Fetch en background para actualizar cache
  const fetchPromise = fetch(request).then(response => {
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  }).catch(error => {
    console.warn('SW: Error actualizando cache:', error);
  });
  
  // Retornar cache si existe, sino esperar fetch
  return cachedResponse || fetchPromise;
}

// Background Sync para favoritos y datos offline
self.addEventListener('sync', event => {
  console.log('SW: Background sync event:', event.tag);
  
  switch (event.tag) {
    case 'favorites-sync':
      event.waitUntil(syncFavorites());
      break;
    case 'usage-analytics':
      event.waitUntil(syncUsageAnalytics());
      break;
    case 'precache-favorites':
      event.waitUntil(precacheFavoriteTools());
      break;
    default:
      event.waitUntil(doBackgroundSync());
  }
});

async function syncFavorites() {
  try {
    console.log('SW: Sincronizando favoritos...');
    
    // Obtener favoritos del almacenamiento local
    const clients = await self.clients.matchAll();
    if (clients.length > 0) {
      clients[0].postMessage({
        type: 'SYNC_FAVORITES_REQUEST'
      });
    }
    
    return Promise.resolve();
  } catch (error) {
    console.error('SW: Error sincronizando favoritos:', error);
    throw error;
  }
}

async function syncUsageAnalytics() {
  try {
    console.log('SW: Sincronizando analytics de uso...');
    // Implementar envío de analytics cuando esté online
    return Promise.resolve();
  } catch (error) {
    console.error('SW: Error sincronizando analytics:', error);
    throw error;
  }
}

async function precacheFavoriteTools() {
  try {
    console.log('SW: Pre-cacheando herramientas favoritas...');
    
    const clients = await self.clients.matchAll();
    if (clients.length > 0) {
      clients[0].postMessage({
        type: 'GET_FAVORITES_FOR_PRECACHE'
      });
    }
    
    return Promise.resolve();
  } catch (error) {
    console.error('SW: Error pre-cacheando favoritos:', error);
    throw error;
  }
}

function doBackgroundSync() {
  console.log('SW: Ejecutando sync genérico...');
  return Promise.resolve();
}

// Comunicación bidireccional con la aplicación
self.addEventListener('message', event => {
  console.log('SW: Mensaje recibido:', event.data);
  
  switch (event.data.type) {
    case 'FAVORITES_UPDATE':
      handleFavoritesUpdate(event.data.favorites);
      break;
    case 'PRECACHE_TOOL':
      precacheTool(event.data.toolUrl);
      break;
    case 'GET_CACHE_STATUS':
      sendCacheStatus(event.ports[0]);
      break;
    case 'CLEAR_CACHE':
      clearSpecificCache(event.data.cacheType);
      break;
  }
});

async function handleFavoritesUpdate(favorites) {
  try {
    console.log('SW: Actualizando cache de favoritos...', favorites);
    
    const cache = await caches.open(FAVORITES_CACHE);
    
    // Pre-cachear las herramientas favoritas
    for (const toolId of favorites) {
      const toolUrl = `/${toolId}.html`;
      try {
        const response = await fetch(toolUrl);
        if (response.ok) {
          await cache.put(toolUrl, response);
          console.log(`SW: Herramienta favorita cacheada: ${toolUrl}`);
        }
      } catch (error) {
        console.warn(`SW: No se pudo cachear herramienta favorita ${toolUrl}:`, error);
      }
    }
  } catch (error) {
    console.error('SW: Error manejando actualización de favoritos:', error);
  }
}

async function precacheTool(toolUrl) {
  try {
    const cache = await caches.open(DYNAMIC_CACHE);
    const response = await fetch(toolUrl);
    if (response.ok) {
      await cache.put(toolUrl, response);
      console.log(`SW: Herramienta pre-cacheada: ${toolUrl}`);
    }
  } catch (error) {
    console.warn(`SW: Error pre-cacheando herramienta ${toolUrl}:`, error);
  }
}

async function sendCacheStatus(port) {
  try {
    const cacheNames = await caches.keys();
    const status = {
      caches: cacheNames,
      version: APP_VERSION,
      timestamp: Date.now()
    };
    
    port.postMessage({
      type: 'CACHE_STATUS',
      data: status
    });
  } catch (error) {
    console.error('SW: Error obteniendo estado de cache:', error);
  }
}

async function clearSpecificCache(cacheType) {
  try {
    let cacheName;
    switch (cacheType) {
      case 'dynamic':
        cacheName = DYNAMIC_CACHE;
        break;
      case 'favorites':
        cacheName = FAVORITES_CACHE;
        break;
      case 'api':
        cacheName = API_CACHE;
        break;
      default:
        return;
    }
    
    const success = await caches.delete(cacheName);
    console.log(`SW: Cache ${cacheName} ${success ? 'limpiado' : 'no encontrado'}`);
  } catch (error) {
    console.error('SW: Error limpiando cache:', error);
  }
}

// Push notification handler mejorado
self.addEventListener('push', event => {
  if (event.data) {
    const data = event.data.json();
    const options = {
      body: data.body || 'Nueva actualización disponible',
      icon: '/assets/favicon_iotodo/android-chrome-192x192.png',
      badge: '/assets/favicon_iotodo/android-chrome-192x192.png',
      vibrate: [100, 50, 100],
      data: {
        dateOfArrival: Date.now(),
        url: data.url || '/'
      },
      actions: [
        {
          action: 'explore',
          title: 'Ver herramientas',
          icon: '/assets/favicon_iotodo/android-chrome-192x192.png'
        },
        {
          action: 'close',
          title: 'Cerrar'
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
