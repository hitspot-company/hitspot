import 'package:hs_database_repository/hs_database_repository.dart';

class HSUpdateUserFailure extends HSUserException {
  const HSUpdateUserFailure({
    this.customMessage = "Error updating user",
    this.customDetails,
  }) : super(message: customMessage, details: customDetails);

  final String customMessage;
  final String? customDetails;
}
