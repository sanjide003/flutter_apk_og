import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDcxrvgGTcc-w2LgY1Hc1Jy6EPs7fJGFJs",
    authDomain: "fee-apk-1.firebaseapp.com",
    projectId: "fee-apk-1",
    storageBucket: "fee-apk-1.firebasestorage.app",
    messagingSenderId: "178081719111",
    appId: "1:178081719111:web:44e95480cff6df2a5a2262",
    measurementId: "G-EFWCZCJRSL",
  );

  // ANDROID: Web Key ഉപയോഗിക്കുന്നു (Testing Only)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDcxrvgGTcc-w2LgY1Hc1Jy6EPs7fJGFJs",
    appId: "1:178081719111:web:44e95480cff6df2a5a2262",
    messagingSenderId: "178081719111",
    projectId: "fee-apk-1",
    storageBucket: "fee-apk-1.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDcxrvgGTcc-w2LgY1Hc1Jy6EPs7fJGFJs",
    appId: "1:178081719111:web:44e95480cff6df2a5a2262",
    messagingSenderId: "178081719111",
    projectId: "fee-apk-1",
    storageBucket: "fee-apk-1.firebasestorage.app",
  );
}
