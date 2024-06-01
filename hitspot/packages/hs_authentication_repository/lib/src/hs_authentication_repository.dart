import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_authentication_repository/src/exceptions/is_email_verified_failure.dart';
import 'package:hs_authentication_repository/src/exceptions/send_verification_email.dart';

class HSAuthenticationRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  HSUser? currentUser;

  HSAuthenticationRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  Future<void> reloadCurrentUser() async {
    try {
      await _firebaseAuth.currentUser!.reload();
    } catch (e) {
      rethrow;
    }
  }

  Stream<HSUser?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      currentUser = firebaseUser?.toUser;
      return currentUser;
    });
  }

  Future<bool> isEmailVerified() async {
    try {
      if (_firebaseAuth.currentUser == null)
        throw IsEmailVerifiedFailure("The user is not signed in.");
      await _firebaseAuth.currentUser!.reload();
      return _firebaseAuth.currentUser!.emailVerified;
    } catch (_) {
      throw IsEmailVerifiedFailure();
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser!.sendEmailVerification();
    } catch (_) {
      throw SendVerificationEmailFailure();
    }
  }

  Future<void> sendResetPasswordEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (_) {
      throw SendResetPasswordEmailFailure();
    }
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firebaseAuth.currentUser!.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      print(e.message);
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<void> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;

      credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  /// Starts the Sign In with Apple Flow.
  ///
  /// Throws a [LogInWithAppleFailure] if an exception occurs.
  Future<void> logInWithApple() async {
    try {
      final appleProvider = firebase_auth.AppleAuthProvider();
      await _firebaseAuth.signInWithProvider(appleProvider);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithAppleFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithAppleFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } catch (_) {
      rethrow;
    }
  }
}

extension on firebase_auth.User {
  /// Maps a [firebase_auth.User] into a [User].
  HSUser get toUser {
    return HSUser(
      uid: uid,
      email: email,
      isEmailVerified: this.emailVerified,
    );
  }
}
