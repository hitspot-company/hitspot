class HSSearchException implements Exception {
  final String message;

  const HSSearchException([
    this.message = 'An unknown exception occurred.',
  ]);

  factory HSSearchException.users() =>
      HSSearchException("Users could not be fetched");

  factory HSSearchException.spots() =>
      HSSearchException("Spots could not be fetched");
}
