import 'package:formz/formz.dart';

/// Validation errors for the [Username] [FormzInput].
enum UsernameValidationError {
  none,
  invalid,
  short,
  long,
  notVerified,
  unavailable,
  notLowerCase,
}

enum UsernameValidationState {
  unknown,
  empty,
  verifying,
  unavailable,
  available
}

/// {@template usernmae}
/// Form input for an username input.
/// {@endtemplate}
class Username extends FormzInput<String, UsernameValidationError> {
  /// {@macro username}
  const Username.pure() : super.pure('');

  /// {@macro username}
  const Username.dirty([super.value = '']) : super.dirty();

  static final RegExp usernameRegExp = RegExp(
    r'^[a-z0-9_]{5,16}$',
  );

  @override
  UsernameValidationError? validator(String? value) {
    if (usernameRegExp.hasMatch(value ?? ''))
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

  static String validateUsername(String value) {
    String ret = "Username should be:";
    if (value.length < 5) ret += "\n· at least 5 characters long";
    if (value.length > 16)
      ret += "\n· at most 16 characters long";
    else if (value.contains(RegExp(r'[A-Z]'))) ret += "\n· lowercase";
    return ret;
  }
}
