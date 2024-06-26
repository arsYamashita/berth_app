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
  // ars
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALtX2cGYh364HZtHv8lCoxMrEICyOtFlA',
    appId: '1:279365426275:web:c6f6c3d7513c2d519cec56',
    messagingSenderId: '279365426275',
    projectId: 'berthapp-c3c59',
    authDomain: 'berthapp-c3c59.firebaseapp.com',
    storageBucket: 'berthapp-c3c59.appspot.com',
    measurementId: 'G-FWKBLVLC0Y',
  );
  // bita
  // static const FirebaseOptions web = FirebaseOptions(
  //     apiKey: "AIzaSyAJrJTsl2uOG_4zZqqWaEkBOj9wSGuqSJY",
  //     authDomain: "nohinctrl-test.firebaseapp.com",
  //     projectId: "nohinctrl-test",
  //     storageBucket: "nohinctrl-test.appspot.com",
  //     messagingSenderId: "630263066288",
  //     appId: "1:630263066288:web:39a54b3f82764355361575"
  // );
  // honban
  // static const FirebaseOptions web = FirebaseOptions(
  //     apiKey: "AIzaSyCIaNv8FRpZfasblIDUt-dCcIUKftWi55s",
  //     authDomain: "nohinctrl-48ee8.firebaseapp.com",
  //     projectId: "nohinctrl-48ee8",
  //     storageBucket: "nohinctrl-48ee8.appspot.com",
  //     messagingSenderId: "555460993061",
  //     appId: "1:555460993061:web:4d4a4ccbf366ce8964dfcc"
  // );
}
