/// {@template send_reset_password_email}
/// Thrown during the reset password process if a failure occurs.
/// {@endtemplate}
class IsEmailVerifiedFailure implements Exception {
  final String message;

  const IsEmailVerifiedFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  @override
  String toString() {
    return message;
  }
}
