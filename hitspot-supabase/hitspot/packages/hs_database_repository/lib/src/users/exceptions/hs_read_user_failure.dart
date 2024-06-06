import 'package:hs_database_repository/src/users/exceptions/hs_user_exception.dart';

class HSReadUserFailure extends HSUserException {
  const HSReadUserFailure({
    this.customMessage = "Error reading user",
    this.customDetails,
    this.code,
  }) : super(message: customMessage, details: customDetails);

  final String customMessage;
  final String? customDetails;
  final int? code;
}
