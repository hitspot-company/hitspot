import 'package:hitspot/services/email_validation/hs_email_validation_service.dart';

class HSEmailValidationRepo {
  final HSEmailValidationService _service;

  const HSEmailValidationRepo(this._service);

  Future<void> resendVerificationEmail() async =>
      _service.resendVerificationEmail();

  Future<bool> isEmailVerified() async => await _service.isEmailVerified();
}
