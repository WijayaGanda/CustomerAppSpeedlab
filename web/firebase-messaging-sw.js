importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

// Masukkan konfigurasi Firebase Web Anda di sini
firebase.initializeApp({
    apiKey: 'AIzaSyBtPMDvmKWB-I5PzgMHJIDwpGRWfGL6GX8',
    appId: '1:397918798086:web:0efd14be04cf9f50cb5e87',
    messagingSenderId: '397918798086',
    projectId: 'speedlab-notif',
    authDomain: 'speedlab-notif.firebaseapp.com',
    storageBucket: 'speedlab-notif.firebasestorage.app',
    measurementId: 'G-RGH5TS33S3',
});

const messaging = firebase.messaging();