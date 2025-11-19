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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAlpwxkjsw2CqZUavn2RliatAKzJciQzo0',
    appId: '1:739748566859:web:7e7644cfeacc93ddb37ace',
    messagingSenderId: '739748566859',
    projectId: 'pizza-delizza-prod',
    authDomain: 'pizza-delizza-prod.firebaseapp.com',
    storageBucket: 'pizza-delizza-prod.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5FY2HBjdv6b_CcRVwwh7xwr5RBap9TZ0',
    appId: '1:739748566859:android:fe25933be4d105b3b37ace',
    messagingSenderId: '739748566859',
    projectId: 'pizza-delizza-prod',
    storageBucket: 'pizza-delizza-prod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: '123456789',
    projectId: 'pizza-delizza-prod',
    storageBucket: 'pizza-delizza-prod.appspot.com',
    iosBundleId: 'com.pizzadelizza.app',
  );
}