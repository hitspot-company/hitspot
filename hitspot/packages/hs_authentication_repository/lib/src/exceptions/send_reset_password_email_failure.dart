/// {@template send_reset_password_email}
/// Thrown during the reset password process if a failure occurs.
/// {@endtemplate}
class SendResetPasswordEmailFailure implements Exception {
  final String message;

  const SendResetPasswordEmailFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  @override
  String toString() {
    return message;
  }
}
