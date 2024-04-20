import 'package:firebase_auth/firebase_auth.dart';

class HSEmailValidationService {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<bool> isEmailVerified() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) throw "User is not signed in.";
      await user.reload();
      return (user.emailVerified);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) throw "User is not signed in";
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (_) {
      rethrow;
    }
  }
}
