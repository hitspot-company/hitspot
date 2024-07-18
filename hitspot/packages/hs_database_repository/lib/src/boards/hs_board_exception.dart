enum HSBoardExceptionType { unknown, notFound, create, read, update, delete }

class HSBoardException implements Exception {
  const HSBoardException(
      {this.message = "An unknown exception occured.",
      this.details,
      this.type = HSBoardExceptionType.unknown});

  final String message;
  final String? details;
  final HSBoardExceptionType type;

  @override
  String toString() {
    return """
HSBoardException
message: $message
details: $details
type: $type
""";
  }

  factory HSBoardException.create({required String details}) {
    return HSBoardException(
      message: "An unknown board creation exception occured.",
      details: details,
      type: HSBoardExceptionType.create,
    );
  }
}
