/// {@template send_reset_password_email}
/// Thrown during the reset password process if a failure occurs.
/// {@endtemplate}
class SendVerificationEmailFailure implements Exception {
  final String message;

  const SendVerificationEmailFailure([
    this.message = 'An unknown exception occurred.',
  ]);
}
