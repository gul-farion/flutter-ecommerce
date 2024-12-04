import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAd4pRN3lwLMxdENIlijccsgssVz2xEQYo',
    appId: '1:937310847204:web:81030a275dc1a0cdd1acf1',
    messagingSenderId: '937310847204',
    projectId: 'flutter-pizza-abc5c',
    authDomain: 'flutter-pizza-abc5c.firebaseapp.com',
    storageBucket: 'flutter-pizza-abc5c.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXRG5Ki6UYv3Hm5KANzXQjDywu-cpwUKw',
    appId: '1:937310847204:ios:ec0e39619ee7fe3bd1acf1',
    messagingSenderId: '937310847204',
    projectId: 'flutter-pizza-abc5c',
    storageBucket: 'flutter-pizza-abc5c.firebasestorage.app',
    iosBundleId: 'com.example.pizzeriaApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAd4pRN3lwLMxdENIlijccsgssVz2xEQYo',
    appId: '1:937310847204:web:dcdb8a86e9bccd68d1acf1',
    messagingSenderId: '937310847204',
    projectId: 'flutter-pizza-abc5c',
    authDomain: 'flutter-pizza-abc5c.firebaseapp.com',
    storageBucket: 'flutter-pizza-abc5c.firebasestorage.app',
  );
}
