import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitspot/data/models/user_model.dart';
import 'package:hitspot/services/auth/hs_db.dart';

import '../../../services/auth/hs_auth_servicde.dart';

class HSAuthenticationRepository {
  HSAuthenticationService service = HSAuthenticationService();
  DatabaseService dbService = DatabaseService();

  Stream<UserModel> getCurrentUser() {
    return service.retrieveCurrentUser();
  }

  Future<UserCredential?> signUp(UserModel user) {
    try {
      return service.signUp(user);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential?> signIn(UserModel user) {
    try {
      return service.signIn(user);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() {
    return service.signOut();
  }

  Future<String?> retrieveUsername(UserModel user) {
    return dbService.retrieveUserName(user);
  }
}
