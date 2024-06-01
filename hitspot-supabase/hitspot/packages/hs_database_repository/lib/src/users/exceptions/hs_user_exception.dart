class HSUserException implements Exception {
  const HSUserException(
      {this.message = "An unknown exception occured.", this.details});

  final String message;
  final String? details;

  @override
  String toString() {
    if (details == null) return this.message;
    return "$message: $details";
  }
}
