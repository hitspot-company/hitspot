class UserDoesNotExistException implements Exception {
  final String message;

  const UserDoesNotExistException([
    this.message = 'An unknown exception occurred.',
  ]);
}
