import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCiL-e4P24Syt9j8FyUBGklaR_5gpzNvtc',
    appId: '1:1026261229878:android:682de1486c13d810fb9397',
    messagingSenderId: '1026261229878',
    projectId: 'domino-history',
    storageBucket: 'domino-history.firebasestorage.app',
  );
}
