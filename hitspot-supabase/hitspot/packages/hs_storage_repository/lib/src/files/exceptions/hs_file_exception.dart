enum HSFileExceptionType {
  unknown,
  upload,
  download,
  fetchPublicUrl,
  update,
  delete
}

class HSFileException implements Exception {
  const HSFileException(
      {this.message = "An unknown exception occured.",
      this.exceptionType = HSFileExceptionType.unknown,
      this.details});

  final String message;
  final String? details;
  final HSFileExceptionType exceptionType;

  @override
  String toString() {
    return """
[!] HSFileException
Type: $exceptionType
Message: $message
Details: $details
""";
  }

  factory HSFileException.upload({String? message, String? details}) {
    return HSFileException(
      message: message ?? "Error uploading file",
      details: details,
      exceptionType: HSFileExceptionType.upload,
    );
  }

  factory HSFileException.download({String? message, String? details}) {
    return HSFileException(
      message: message ?? "Error downloading file",
      details: details,
      exceptionType: HSFileExceptionType.download,
    );
  }

  factory HSFileException.update({String? message, String? details}) {
    return HSFileException(
      message: message ?? "Error updating bucket",
      details: details,
      exceptionType: HSFileExceptionType.update,
    );
  }
  factory HSFileException.delete({String? message, String? details}) {
    return HSFileException(
      message: message ?? "Error deleting bucket",
      details: details,
      exceptionType: HSFileExceptionType.delete,
    );
  }

  factory HSFileException.fetchPublicUrl({String? message, String? details}) {
    return HSFileException(
      message: message ?? "Error fetching file public url",
      details: details,
      exceptionType: HSFileExceptionType.fetchPublicUrl,
    );
  }
}
