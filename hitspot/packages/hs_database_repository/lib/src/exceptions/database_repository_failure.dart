import 'package:hs_debug_logger/hs_debug_logger.dart';

class DatabaseRepositoryFailure implements Exception {
  final String message;

  DatabaseRepositoryFailure([
    this.message = 'An unknown exception occurred.',
  ]) {
    HSDebugLogger.logError(message);
  }
}
