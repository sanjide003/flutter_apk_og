// ഫയർബേസ് കോൺഫിഗറേഷൻ ഫയൽ
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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // WEB CONFIGURATION (താങ്കൾ നൽകിയ കീ ഇവിടെ ചേർക്കുന്നു)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDcxrvgGTcc-w2LgY1Hc1Jy6EPs7fJGFJs",
    authDomain: "fee-apk-1.firebaseapp.com",
    projectId: "fee-apk-1",
    storageBucket: "fee-apk-1.firebasestorage.app",
    messagingSenderId: "178081719111",
    appId: "1:178081719111:web:44e95480cff6df2a5a2262",
    measurementId: "G-EFWCZCJRSL",
  );

  // ANDROID CONFIGURATION (Web key തന്നെ താൽക്കാലികമായി ഉപയോഗിക്കാം അല്ലെങ്കിൽ Android-ന് വേണ്ടിയുള്ളത് ഇവിടെ നൽകാം)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDcxrvgGTcc-w2LgY1Hc1Jy6EPs7fJGFJs", // Android API Key മാറ്റേണ്ടി വരും
    appId: "1:178081719111:android:xxxxxx", // Android App ID ഇവിടെ നൽകണം
    messagingSenderId: "178081719111",
    projectId: "fee-apk-1",
    storageBucket: "fee-apk-1.firebasestorage.app",
  );

  // iOS CONFIGURATION
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDcxrvgGTcc-w2LgY1Hc1Jy6EPs7fJGFJs", // iOS API Key
    appId: "1:178081719111:ios:xxxxxx", // iOS App ID
    messagingSenderId: "178081719111",
    projectId: "fee-apk-1",
    storageBucket: "fee-apk-1.firebasestorage.app",
    iosBundleId: "com.example.institutionOs",
  );
}
