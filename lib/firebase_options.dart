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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3QM8gpicZrFdfatO-12HboBobL-b-ur4',
    appId: '1:1005188439450:android:8c6bb5d5000efd90d6ae23',
    messagingSenderId: '1005188439450',
    projectId: 'soft-ride-driver',
    databaseURL: 'https://soft-ride-driver-default-rtdb.firebaseio.com',
    storageBucket: 'soft-ride-driver.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8SJh30TFFC1vI9MuV49E_fYnMOq_VU7Q',
    appId: '1:1005188439450:ios:25246b14c0bc11f1d6ae23',
    messagingSenderId: '1005188439450',
    projectId: 'soft-ride-driver',
    databaseURL: 'https://soft-ride-driver-default-rtdb.firebaseio.com',
    storageBucket: 'soft-ride-driver.appspot.com',
    iosClientId: '1005188439450-qu06954kko634vmjjjur9ahdf27ld74v.apps.googleusercontent.com',
    iosBundleId: 'com.example.softRide',
  );
}
