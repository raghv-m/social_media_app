import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBuUEal_CKo1iAJcnGmOvjpBaCiwRmOSwg',
    appId: '1:1092034131124:web:538acc962a1b9d78bb13e1',
    messagingSenderId: '1092034131124',
    projectId: 'smapp-a4dc6',
    authDomain: 'smapp-a4dc6.firebaseapp.com',
    storageBucket: 'smapp-a4dc6.firebasestorage.app',
    measurementId: 'G-BP541CWR7N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMt_poaseUUeqf9OvFfHhXW39BEOeUky4',
    appId: '1:1092034131124:android:3a9d16f41d6abc69bb13e1',
    messagingSenderId: '1092034131124',
    projectId: 'smapp-a4dc6',
    storageBucket: 'smapp-a4dc6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCaX0buNoo9DVKPqIpiyf677V_Y13THYjQ',
    appId: '1:1092034131124:ios:10d0973e53539e60bb13e1',
    messagingSenderId: '1092034131124',
    projectId: 'smapp-a4dc6',
    storageBucket: 'smapp-a4dc6.firebasestorage.app',
    iosBundleId: 'com.example.socialMediaApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCaX0buNoo9DVKPqIpiyf677V_Y13THYjQ',
    appId: '1:1092034131124:ios:10d0973e53539e60bb13e1',
    messagingSenderId: '1092034131124',
    projectId: 'smapp-a4dc6',
    storageBucket: 'smapp-a4dc6.firebasestorage.app',
    iosBundleId: 'com.example.socialMediaApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBuUEal_CKo1iAJcnGmOvjpBaCiwRmOSwg',
    appId: '1:1092034131124:web:a6a3fc8ad0dd4135bb13e1',
    messagingSenderId: '1092034131124',
    projectId: 'smapp-a4dc6',
    authDomain: 'smapp-a4dc6.firebaseapp.com',
    storageBucket: 'smapp-a4dc6.firebasestorage.app',
    measurementId: 'G-QJ11VNMWTE',
  );
}
