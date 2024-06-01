import 'dart:async';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_authentication_repository/src/exceptions/send_verification_email.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart';

class HSAuthenticationRepository {
  HSAuthenticationRepository(this._supabaseClient);
  final supabase.SupabaseClient _supabaseClient;

  HSUser? currentUser;

  Stream<HSUser?> get user {
    return _supabaseClient.auth.onAuthStateChange.map((supabaseUser) {
      currentUser = supabaseUser.session?.user.toUser ?? null;
      return currentUser;
    });
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (_) {
      throw LogOutFailure();
    }
  }

  Future<bool> isEmailVerified() async {
    // TODO: Implement real check
    return true;
    // try {
    //   if (_supabaseClient.auth.currentUser == null)
    //     throw IsEmailVerifiedFailure("The user is not signed in.");
    //   return _firebaseAuth.currentUser!.emailVerified;
    // } catch (_) {
    //   throw IsEmailVerifiedFailure();
    // }
  }

  Future<void> sendEmailVerification() async {
    try {
      // TODO: Implement real email verification
      return;
      // await _supabaseClient.auth.
      // await _firebaseAuth.currentUser!.sendEmailVerification();
    } catch (_) {
      throw SendVerificationEmailFailure();
    }
  }

  Future<void> sendResetPasswordEmail(String email) async {
    try {
      // TODO: Implement real password reset
      // await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (_) {
      throw SendResetPasswordEmailFailure();
    }
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signUp({required String email, required String password}) async {
    try {
      await logInWithEmailAndPassword(email: email, password: password);
      // await _firebaseAuth.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      // await _firebaseAuth.currentUser!.sendEmailVerification();
    } on supabase.AuthException catch (_) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(_.message);
    } catch (_) {
      throw SignUpWithEmailAndPasswordFailure(_.toString());
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
      await _supabaseClient.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? null : 'app.hitspot://login-callback/',
      );
    } on supabase.AuthException catch (_) {
      HSDebugLogger.logError("Error: ${_.toString()}");
      throw LogInWithEmailAndPasswordFailure(_.message);
    } catch (_) {
      HSDebugLogger.logError("Error: ${_.toString()}");
      throw LogInWithEmailAndPasswordFailure(_.toString());
    }

    /// Starts the Sign In with Google Flow.
    ///
    /// Throws a [LogInWithGoogleFailure] if an exception occurs.
    Future<void> logInWithGoogle() async {
      try {
        await _supabaseClient.auth.signInWithOAuth(
          supabase.OAuthProvider.google,
          redirectTo: 'app.hitspot://login-callback/',
        );
      } on supabase.AuthException catch (_) {
        throw LogInWithGoogleFailure(_.message);
      } catch (_) {
        throw LogInWithGoogleFailure(_.toString());
      }
    }

    /// Starts the Sign In with Apple Flow.
    ///
    /// Throws a [LogInWithAppleFailure] if an exception occurs.
    Future<void> logInWithApple() async {
      try {
        await _supabaseClient.auth.signInWithOAuth(
          supabase.OAuthProvider.apple,
          redirectTo: 'app.hitspot://login-callback/',
        );
      } on supabase.AuthException catch (_) {
        throw LogInWithGoogleFailure(_.message);
      } catch (_) {
        throw LogInWithGoogleFailure(_.toString());
      }
    }

    Future<void> deleteAccount() async {
      try {
        // TODO: Implement
      } catch (_) {
        rethrow;
      }
    }
  }
}

extension on supabase.User {
  /// Maps a [firebase_auth.User] into a [User].
  HSUser get toUser {
    return HSUser(
      uid: this.id,
      email: this.email,
      isEmailVerified: this.userMetadata?["is_email_verified"] ?? false,
    );
  }
}
