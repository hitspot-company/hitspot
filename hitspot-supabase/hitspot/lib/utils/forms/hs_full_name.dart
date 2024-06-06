import 'package:formz/formz.dart';

enum HSFullnameValidationError {
  invalid,
  short,
  long,
  unavailable,
  notLowerCase
}

class HSFullname extends FormzInput<String, HSFullnameValidationError> {
  const HSFullname.pure() : super.pure('');

  const HSFullname.dirty([super.value = '']) : super.dirty();
  @override
  HSFullnameValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return HSFullnameValidationError.invalid;
    return null;
  }
}
