import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitspot/services/authentication/hs_authentication.dart';

class HSAuthenticationRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final HSAuthenticationService authenticationService;

  HSAuthenticationRepository({required this.authenticationService});

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await authenticationService.registerWithEmailAndPassword(
          email, password);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print("Unknown error: $e");
      rethrow;
    }
  }

  Future<void> signOutUser() async {
    await authenticationService.signOutUser();
  }
}
