class HSSendEmailException implements Exception {
  final String message;
  final int? code;

  const HSSendEmailException([
    this.message = 'An unknown exception occurred.',
    this.code,
  ]);

  // TODO: Add .fromResponseCode builder with specific error messages and codes (read RESEND docs)
}
