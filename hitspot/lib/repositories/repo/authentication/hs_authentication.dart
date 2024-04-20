import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitspot/services/authentication/hs_authentication.dart';

class HSAuthenticationRepository {
  final HSAuthenticationService authenticationService;

  HSAuthenticationRepository({required this.authenticationService});

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await authenticationService.signUpWithEmailAndPassword(
          email, password);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print("Unknown error: $e");
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await authenticationService.signInWithEmailAndPassword(
          email, password);
    } catch (_) {
      print("Error signing in: $_");
      rethrow;
    }
  }

  Future<void> signOutUser() async {
    await authenticationService.signOutUser();
  }
}
