/* web/firebase-messaging-sw.js */
/* Use the COMPAT builds inside a Service Worker */
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js');

/**
 * IMPORTANT:
 * Copy these EXACT values from Firebase Console → Project Settings → Your web app.
 * appId MUST look like: 1:<SENDER_ID>:web:<RANDOM_HASH>
 */
firebase.initializeApp({
  apiKey: "AIzaSyCtKdMoMf7oaT50Kfdl87Utb2G6MhvO6eo",
  authDomain: "e-commerce-5bb02.firebaseapp.com",
  projectId: "e-commerce-5bb02",
  storageBucket: "e-commerce-5bb02.appspot.com",
  messagingSenderId: "440816617373",
  appId: "1:440816617373:web:REPLACE_WITH_YOUR_WEB_APP_HASH", // ← put the real Web appId here
  // measurementId: "G-XXXXXXXXXX", // optional
});

/**
 * Some browsers/environments don’t support FCM on the web.
 * Guard to avoid “messaging is undefined” errors.
 */
if (firebase.messaging.isSupported && firebase.messaging.isSupported()) {
  const messaging = firebase.messaging();

  // Receive background messages (when the page is not focused/closed)
  messaging.onBackgroundMessage((payload) => {
    try {
      const notif = payload && payload.notification ? payload.notification : {};
      const title = notif.title || 'New message';
      const options = {
        body: notif.body || '',
        // Use a relative path so this works under subfolders too
        icon: 'icons/Icon-192.png',
        data: payload && payload.data ? payload.data : {},
      };
      self.registration.showNotification(title, options);
    } catch (err) {
      // Avoid breaking the SW if payload is malformed
      // (You can remove this log in production)
      console.error('[FCM SW] onBackgroundMessage error:', err);
    }
  });

  // Optional: Handle notification clicks (deep link into your app)
  self.addEventListener('notificationclick', (event) => {
    event.notification.close();
    // Open a URL from the notification data if present
    const targetUrl = event.notification?.data?.click_action ||
                      event.notification?.data?.url ||
                      './';
    event.waitUntil(
      self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientsArr) => {
        // Focus an open tab if one exists, otherwise open a new one
        for (const client of clientsArr) {
          if ('focus' in client && client.url && client.url.indexOf(targetUrl) >= 0) {
            return client.focus();
          }
        }
        if (self.clients.openWindow) {
          return self.clients.openWindow(targetUrl);
        }
      })
    );
  });
} else {
  // Fallback if messaging isn’t supported: keep SW valid but do nothing
  // (You can remove this log in production)
  console.warn('[FCM SW] firebase.messaging is not supported in this browser.');
}
