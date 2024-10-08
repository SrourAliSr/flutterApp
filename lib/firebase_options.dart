// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBLMWMRjnumpLEXG9dBRAx9EGyARs0akU',
    appId: '1:552977255050:android:f8f244ea54686705343b73',
    messagingSenderId: '552977255050',
    projectId: 'flutterapp-126c1',
    storageBucket: 'flutterapp-126c1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAML0xaIPmMY5gIeil3UdfKgS2myQg5v3A',
    appId: '1:552977255050:ios:ce909e4889d88e64343b73',
    messagingSenderId: '552977255050',
    projectId: 'flutterapp-126c1',
    storageBucket: 'flutterapp-126c1.appspot.com',
    iosClientId:
        '552977255050-r6825qaen3ue76hn11tlnj2bft3qol7i.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterapp',
  );
}
