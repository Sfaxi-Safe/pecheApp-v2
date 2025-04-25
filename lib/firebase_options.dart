import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration par défaut pour Firebase
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Configuration basée sur le fichier google-services.json
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDuLDIuB7ESQ1k9jG3oEUez-jaFQ5kyiIg',
    appId: '1:166323230772:android:ff7f377181381e90d0d261',
    messagingSenderId: '166323230772',
    projectId: 'peche-app-4d05d',
    authDomain: 'peche-app-4d05d.firebaseapp.com',
    storageBucket: 'peche-app-4d05d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDuLDIuB7ESQ1k9jG3oEUez-jaFQ5kyiIg',
    appId: '1:166323230772:android:ff7f377181381e90d0d261',
    messagingSenderId: '166323230772',
    projectId: 'peche-app-4d05d',
    storageBucket: 'peche-app-4d05d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuLDIuB7ESQ1k9jG3oEUez-jaFQ5kyiIg',
    appId: '1:166323230772:ios:ff7f377181381e90d0d261',
    messagingSenderId: '166323230772',
    projectId: 'peche-app-4d05d',
    storageBucket: 'peche-app-4d05d.firebasestorage.app',
    iosClientId: '166323230772-ios-client-id.apps.googleusercontent.com',
    iosBundleId: 'com.example.peche_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDuLDIuB7ESQ1k9jG3oEUez-jaFQ5kyiIg',
    appId: '1:166323230772:ios:ff7f377181381e90d0d261',
    messagingSenderId: '166323230772',
    projectId: 'peche-app-4d05d',
    storageBucket: 'peche-app-4d05d.firebasestorage.app',
    iosClientId: '166323230772-ios-client-id.apps.googleusercontent.com',
    iosBundleId: 'com.example.peche_app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDuLDIuB7ESQ1k9jG3oEUez-jaFQ5kyiIg',
    appId: '1:166323230772:android:ff7f377181381e90d0d261',
    messagingSenderId: '166323230772',
    projectId: 'peche-app-4d05d',
    storageBucket: 'peche-app-4d05d.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDuLDIuB7ESQ1k9jG3oEUez-jaFQ5kyiIg',
    appId: '1:166323230772:android:ff7f377181381e90d0d261',
    messagingSenderId: '166323230772',
    projectId: 'peche-app-4d05d',
    storageBucket: 'peche-app-4d05d.firebasestorage.app',
  );
}
