class DatabaseConnectionFailure implements Exception {
  final String message;

  const DatabaseConnectionFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  @override
  String toString() => this.message;
}
