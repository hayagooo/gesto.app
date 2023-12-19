// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAddK_k3o5pebPzBrTOdJl3XcT9qpnAUZc',
    appId: '1:772924726267:web:fe4485d308822b59bec95e',
    messagingSenderId: '772924726267',
    projectId: 'gesto-d6223',
    authDomain: 'gesto-d6223.firebaseapp.com',
    databaseURL: 'https://gesto-d6223-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gesto-d6223.appspot.com',
    measurementId: 'G-SNWQNS7GMV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3Qi19ElpoK3aab1m2XR2Yl2Vv6C1OXe4',
    appId: '1:772924726267:android:a2e284761e9313d0bec95e',
    messagingSenderId: '772924726267',
    projectId: 'gesto-d6223',
    databaseURL: 'https://gesto-d6223-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gesto-d6223.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAugsVPGpRLRjAEl_BSznnI13Zq50OZZ6M',
    appId: '1:772924726267:ios:9a671ed40819924fbec95e',
    messagingSenderId: '772924726267',
    projectId: 'gesto-d6223',
    databaseURL: 'https://gesto-d6223-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gesto-d6223.appspot.com',
    iosBundleId: 'com.example.gestoapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAugsVPGpRLRjAEl_BSznnI13Zq50OZZ6M',
    appId: '1:772924726267:ios:6a869dfc64bad87bbec95e',
    messagingSenderId: '772924726267',
    projectId: 'gesto-d6223',
    databaseURL: 'https://gesto-d6223-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gesto-d6223.appspot.com',
    iosBundleId: 'com.example.gestoapp.RunnerTests',
  );
}
