enum HSAuthenticationExceptionType {
  invalidCredentials,
  userNotFound,
  userDisabled,
  userAlreadyExists,
  unknown,
  apple,
  google,
  magicLink,
}

class HSAuthenticationException implements Exception {
  const HSAuthenticationException({
    this.message = "An unknown authentication exception occured.",
    this.details,
    this.exceptionType = HSAuthenticationExceptionType.unknown,
  });

  final String message;
  final String? details;
  final HSAuthenticationExceptionType exceptionType;

  @override
  String toString() {
    return """
HSAuthenticationException
message: $message
details: $details
type: $exceptionType
""";
  }

  factory HSAuthenticationException.magicLink({required String details}) {
    return HSAuthenticationException(
      message: "An unknown magic link exception occured.",
      details: details,
      exceptionType: HSAuthenticationExceptionType.magicLink,
    );
  }
}
