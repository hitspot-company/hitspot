import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hs_firebase_config/src/hs_firebase_config.dev.dart';

enum Environment {
  development,
  staging,
  production,
}

class HSFirebaseConfigLoader {
  static FirebaseOptions load() {
    final environment = _getEnvironment();
    switch (environment) {
      case Environment.development:
        return HSDevelopmentFirebaseOptions.currentPlatform;
      case Environment.staging:
        return FirebaseConfigStaging();
      case Environment.production:
        return FirebaseConfigProd();
      default:
        throw Exception('Invalid environment');
    }
  }

  static Environment _getEnvironment() {
    // Use environment variables or any other mechanism to determine the current environment
    // For simplicity, this example uses kReleaseMode from flutter/foundation
    return kReleaseMode ? Environment.production : Environment.development;
  }
}
