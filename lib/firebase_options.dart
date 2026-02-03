import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcxrvgGTcc-w2LgY1Hc1Jy6EPs7fJGFJs',
    appId: '1:178081719111:web:44e95480cff6df2a5a2262',
    messagingSenderId: '178081719111',
    projectId: 'fee-apk-1',
    authDomain: 'fee-apk-1.firebaseapp.com',
    storageBucket: 'fee-apk-1.firebasestorage.app',
    measurementId: 'G-EFWCZCJRSL',
  );
}
