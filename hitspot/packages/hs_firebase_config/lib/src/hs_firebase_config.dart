import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_firebase_config/src/hs_firebase_config.dev.dart' as dev;
import 'package:hs_firebase_config/src/hs_firebase_config.prod.dart' as prod;
import 'package:hs_firebase_config/src/hs_firebase_config.staging.dart'
    as staging;

enum HSFirebaseEnvironment {
  development,
  staging,
  production,
  invalid;
}

class HSFirebaseConfigLoader {
  static FirebaseOptions get loadOptions {
    switch (fromEnvironment) {
      case HSFirebaseEnvironment.development:
        return dev.DefaultFirebaseOptions.currentPlatform;
      case HSFirebaseEnvironment.staging:
        return staging.DefaultFirebaseOptions.currentPlatform;
      case HSFirebaseEnvironment.production:
        return prod.DefaultFirebaseOptions.currentPlatform;
      default:
        throw Exception(
            'Invalid environment. Please use one of the available options: dev, staging or prod.');
    }
  }

  static HSFirebaseEnvironment get fromEnvironment {
    const env = String.fromEnvironment("ENVIRONMENT");
    switch (env) {
      case "dev" || "development":
        return HSFirebaseEnvironment.development;
      case "prod" || "production":
        return HSFirebaseEnvironment.production;
      case "stage" || "staging":
        return HSFirebaseEnvironment.staging;
      default:
        return HSFirebaseEnvironment.invalid;
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
