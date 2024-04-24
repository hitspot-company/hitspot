import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_firebase_config/src/hs_firebase_config.dev.dart';
import 'package:hs_firebase_config/src/hs_firebase_config.prod.dart';
import 'package:hs_firebase_config/src/hs_firebase_config.staging.dart';

enum HSFirebaseEnvironment {
  development,
  staging,
  production,
}

class HSFirebaseConfigLoader {
  static FirebaseOptions load(HSFirebaseEnvironment env) {
    switch (env) {
      case HSFirebaseEnvironment.development:
        return HSDevelopmentFirebaseOptions.currentPlatform;
      case HSFirebaseEnvironment.staging:
        return HSStagingFirebaseOptions.currentPlatform;
      case HSFirebaseEnvironment.production:
        return HSProdFirebaseOptions.currentPlatform;
      default:
        throw Exception('Invalid environment');
    }
  }
}

class HSFirestore {
  static HSFirestore instance = HSFirestore();

  static final _fs = FirebaseFirestore.instance;
  final CollectionReference users = _fs.collection("users");
  final CollectionReference boards = _fs.collection("boards");
  final CollectionReference tags = _fs.collection("tags");
  final CollectionReference spots = _fs.collection("spots");
}
