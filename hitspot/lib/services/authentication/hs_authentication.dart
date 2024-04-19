import 'package:firebase_auth/firebase_auth.dart';

class HSAuthenticationService {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      return (userCredential);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print("Unknown error: $e");
      rethrow;
    }
  }

  Future<void> signOutUser() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await _firebaseAuth.signOut();
    }
  }
}
