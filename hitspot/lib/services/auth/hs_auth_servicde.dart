import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitspot/data/models/user_model.dart';

class HSAuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserModel> retrieveCurrentUser() {
    return _auth.authStateChanges().map((User? user) {
      if (user != null) {
        return UserModel(uid: user.uid, email: user.email);
      } else {
        return UserModel(uid: "uid");
      }
    });
  }

  Future<UserCredential?> signUp(UserModel user) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: user.email!, password: user.password!);
      return (userCredential);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential?> signIn(UserModel user) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: user.email!, password: user.password!);
      return (userCredential);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      return await user.sendEmailVerification();
    }
  }

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
