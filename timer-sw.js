self.addEventListener('install', event => {
    self.skipWaiting();
});

self.addEventListener('activate', event => {
    event.waitUntil(clients.claim());
});

self.addEventListener('notificationclick', event => {
    event.notification.close();
    event.waitUntil(
        clients.matchAll({type: 'window'}).then(clientList => {
            if (clientList.length > 0) {
                clientList[0].focus();
            }
        })
    );
});

// Manejar mensajes del cliente
self.addEventListener('message', event => {
    if (event.data.type === 'SET_TIMER') {
        const duration = event.data.duration;
        setTimeout(() => {
            self.registration.showNotification('¡Tiempo completado!', {
                body: 'Tu sesión de estudio ha terminado',
                icon: 'https://example.com/icon.png',
                vibrate: [200, 100, 200]
            });
        }, duration * 1000);
    }
}); 