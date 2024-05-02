import 'package:formz/formz.dart';

/// Validation errors for the [Username] [FormzInput].
enum UsernameValidationError {
  none,
  invalid,
  short,
  long,
  unavailable,
  notLowerCase
}

/// {@template usernmae}
/// Form input for an username input.
/// {@endtemplate}
class Username extends FormzInput<String, UsernameValidationError> {
  /// {@macro username}
  const Username.pure() : super.pure('');

  /// {@macro username}
  const Username.dirty([super.value = '']) : super.dirty();

  static final RegExp _usernameRegExp = RegExp(
    r'^[a-z0-9_]{5,16}$',
  );

  @override
  UsernameValidationError? validator(String? value) {
    if (_usernameRegExp.hasMatch(value ?? ''))
      return null;
    else if (value!.length < 5)
      return UsernameValidationError.short;
    else if (value.length > 16)
      return UsernameValidationError.long;
    else if (value.contains(RegExp(r'[A-Z]')))
      return UsernameValidationError.notLowerCase;
    else
      return UsernameValidationError.invalid;
  }
}
