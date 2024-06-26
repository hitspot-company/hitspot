import 'package:hs_database_repository/src/users/exceptions/hs_user_exception.dart';

class HSCreateUserFailure extends HSUserException {
  const HSCreateUserFailure({
    this.customMessage = "Error creating user",
    this.customDetails,
  }) : super(message: customMessage, details: customDetails);

  final String customMessage;
  final String? customDetails;
}
