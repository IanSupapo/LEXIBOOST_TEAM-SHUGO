// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyAjlu_d1T3MBlNrpdefh2mMkycj0OJGWqs',
    appId: '1:303696333249:web:a999b16984515765d60740',
    messagingSenderId: '303696333249',
    projectId: 'lexiboost-7de91',
    authDomain: 'lexiboost-7de91.firebaseapp.com',
    storageBucket: 'lexiboost-7de91.firebasestorage.app',
    measurementId: 'G-54FTGB3MMZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0MICtWDTp87TJt4q7u4VRrOJma7KEacE',
    appId: '1:303696333249:android:073df7535bc1b041d60740',
    messagingSenderId: '303696333249',
    projectId: 'lexiboost-7de91',
    storageBucket: 'lexiboost-7de91.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7kems8idqzhotrsV6cBABIi1U0Ems9S0',
    appId: '1:303696333249:ios:52ae793d2591d84ed60740',
    messagingSenderId: '303696333249',
    projectId: 'lexiboost-7de91',
    storageBucket: 'lexiboost-7de91.firebasestorage.app',
    androidClientId: '303696333249-4eu409etavn6j0p8qscfbjbcbmp74g6d.apps.googleusercontent.com',
    iosClientId: '303696333249-i5t2gnjo28ujof46069ou73vftk1453p.apps.googleusercontent.com',
    iosBundleId: 'com.example.shugo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC7kems8idqzhotrsV6cBABIi1U0Ems9S0',
    appId: '1:303696333249:ios:52ae793d2591d84ed60740',
    messagingSenderId: '303696333249',
    projectId: 'lexiboost-7de91',
    storageBucket: 'lexiboost-7de91.firebasestorage.app',
    androidClientId: '303696333249-4eu409etavn6j0p8qscfbjbcbmp74g6d.apps.googleusercontent.com',
    iosClientId: '303696333249-i5t2gnjo28ujof46069ou73vftk1453p.apps.googleusercontent.com',
    iosBundleId: 'com.example.shugo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAjlu_d1T3MBlNrpdefh2mMkycj0OJGWqs',
    appId: '1:303696333249:web:e4d19aa61f9601c9d60740',
    messagingSenderId: '303696333249',
    projectId: 'lexiboost-7de91',
    authDomain: 'lexiboost-7de91.firebaseapp.com',
    storageBucket: 'lexiboost-7de91.firebasestorage.app',
    measurementId: 'G-DXDBYF9BE2',
  );
}
