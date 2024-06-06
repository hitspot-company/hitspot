
class HSSendEmailException implements Exception {
  final String message;
  final int? code;

  const HSSendEmailException([
    this.message = 'An unknown exception occurred.',
    this.code,
  ]);

  factory HSSendEmailException.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return HSSendEmailException("The parameters are incorrect.");
      case 401:
        return HSSendEmailException("The API key used was missing.");
      case 403:
        return HSSendEmailException("The API key used was invalid.");
      case 404:
        return HSSendEmailException("The resource was not found.");
      case 422:
        return HSSendEmailException(
            "The request body is missing one or more required fields.");
      case 405:
        return HSSendEmailException(
            "This endpoint does not support the specified HTTP method");
      case 429:
        return HSSendEmailException("The rate limit was exceeded.");
      case >= 500:
        return HSSendEmailException("Resend servers error.");
      default:
        return HSSendEmailException();
    }
  }
}
