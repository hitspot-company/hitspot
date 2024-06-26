import 'package:formz/formz.dart';

enum HSEmailValidationError { invalid }

class HSEmail extends FormzInput<String, HSEmailValidationError> {
  const HSEmail.pure() : super.pure('');
  const HSEmail.dirty([super.value = '']) : super.dirty();

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  @override
  String get value => super.value.trim();

  @override
  HSEmailValidationError? validator(String? value) {
    return _emailRegExp.hasMatch(value ?? '')
        ? null
        : HSEmailValidationError.invalid;
  }
}
