enum HSBucketExceptionType { unknown, create, read, update, delete }

class HSBucketException implements Exception {
  const HSBucketException(
      {this.message = "An unknown exception occured.",
      this.exceptionType = HSBucketExceptionType.unknown,
      this.details});

  final String message;
  final String? details;
  final HSBucketExceptionType exceptionType;

  @override
  String toString() {
    if (details == null) return this.message;
    return "$message: $details";
  }

  factory HSBucketException.create({String? message, String? details}) {
    return HSBucketException(
      message: message ?? "Error creating bucket",
      details: details,
      exceptionType: HSBucketExceptionType.create,
    );
  }

  factory HSBucketException.read({String? message, String? details}) {
    return HSBucketException(
      message: message ?? "Error fetching bucket",
      details: details,
      exceptionType: HSBucketExceptionType.read,
    );
  }

  factory HSBucketException.update({String? message, String? details}) {
    return HSBucketException(
      message: message ?? "Error updating bucket",
      details: details,
      exceptionType: HSBucketExceptionType.update,
    );
  }
  factory HSBucketException.delete({String? message, String? details}) {
    return HSBucketException(
      message: message ?? "Error deleting bucket",
      details: details,
      exceptionType: HSBucketExceptionType.delete,
    );
  }
}
