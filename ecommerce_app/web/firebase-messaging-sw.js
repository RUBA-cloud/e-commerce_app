/* web/firebase-messaging-sw.js */
/* IMPORTANT: Use COMPAT builds in a service worker */
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCtKdMoMf7oaT50Kfdl87Utb2G6MhvO6eo",
  authDomain: "e-commerce-5bb02.firebaseapp.com",
  projectId: "e-commerce-5bb02",
  storageBucket: "e-commerce-5bb02.appspot.com",
  messagingSenderId: "440816617373",
  appId: "1:440816617373:web:e-commerce-5bb02", // ← replace with real Web App ID
  // measurementId: "G-XXXXXXXXXX" // ← optional
});

// Minimal init (do not use modular imports here)
const messaging = firebase.messaging();

// Optional: show notifications for background messages
// (You can keep it minimal; add this only if you want custom UI)
messaging.onBackgroundMessage((payload) => {
  const title = payload?.notification?.title ?? 'New message';
  const options = {
    body: payload?.notification?.body ?? '',
    icon: '/icons/Icon-192.png',
    data: payload?.data || {},
  };
  self.registration.showNotification(title, options);
});
