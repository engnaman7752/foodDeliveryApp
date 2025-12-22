import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAmb-b_VZNkXyRZaPsL7o_uUcitZbwIyb0',
    appId: '1:663924851624:web:2247e4cf19d9d16648139d',
    messagingSenderId: '663924851624',
    projectId: 'rider-abe4b',
    authDomain: 'rider-abe4b.firebaseapp.com',
    storageBucket: 'rider-abe4b.firebasestorage.app',
    measurementId: 'G-9FC8LVLZE2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1qYsf4Z9geBkYiW1IYZGJpGTC-PMYOKs',
    appId: '1:663924851624:android:2469ba343040ee6c48139d',
    messagingSenderId: '663924851624',
    projectId: 'rider-abe4b',
    storageBucket: 'rider-abe4b.firebasestorage.app',
  );
}