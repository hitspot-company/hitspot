import 'package:formz/formz.dart';

enum HSPasswordValidationError { tooShort, tooLong, invalid, atLeastOneCapital }

class HSPassword extends FormzInput<String, HSPasswordValidationError> {
  const HSPassword.pure() : super.pure('');
  const HSPassword.dirty([super.value = '']) : super.dirty();

  static final passwordRegExp =
      RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$");
  static const minLen = 8;
  static const maxLen = 24;

  @override
  String get value => super.value.trim();

  @override
  HSPasswordValidationError? validator(String? value) {
    if (value == null) return HSPasswordValidationError.invalid;
    if (value.length < minLen) return HSPasswordValidationError.tooShort;
    if (value.length > maxLen) return HSPasswordValidationError.tooLong;
    // TODO: add other guidelines checks
    return passwordRegExp.hasMatch(value)
        ? null
        : HSPasswordValidationError.invalid;
  }
}
