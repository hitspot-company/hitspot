class LogInWithAppleFailure implements Exception {
  final String message;

  const LogInWithAppleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  factory LogInWithAppleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithAppleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithAppleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithAppleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithAppleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithAppleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithAppleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithAppleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithAppleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithAppleFailure();
    }
  }

  bool get isDefault => message == 'An unknown exception occurred.';
}
