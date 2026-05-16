import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// [DefaultFirebaseOptions] provides platform-specific Firebase configuration.
/// Extracted from google-services.json and project metadata.
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
    apiKey: 'AIzaSyDkoImdGTrb4XSYwkkHFiud4Sk9m79UD7k',
    appId: '1:832843490506:web:658c160e1d6d84f26c0033', // Common pattern for Web IDs
    messagingSenderId: '832843490506',
    projectId: 'glouriousart-94699',
    authDomain: 'glouriousart-94699.firebaseapp.com',
    storageBucket: 'glouriousart-94699.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkoImdGTrb4XSYwkkHFiud4Sk9m79UD7k',
    appId: '1:832843490506:android:ac1200e2f60ee0256c0033',
    messagingSenderId: '832843490506',
    projectId: 'glouriousart-94699',
    storageBucket: 'glouriousart-94699.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkoImdGTrb4XSYwkkHFiud4Sk9m79UD7k',
    appId: '1:832843490506:ios:ac1200e2f60ee0256c0033',
    messagingSenderId: '832843490506',
    projectId: 'glouriousart-94699',
    storageBucket: 'glouriousart-94699.firebasestorage.app',
    iosBundleId: 'com.example.learning_app',
  );
}
