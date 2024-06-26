import 'package:formz/formz.dart';

/// Validation errors for the [Username] [FormzInput].
enum HSUsernameValidationError {
  none,
  invalid,
  short,
  long,
  notVerified,
  unavailable,
  notLowerCase,
}

enum HSUsernameValidationState {
  unknown,
  empty,
  verifying,
  unavailable,
  available
}

/// {@template usernmae}
/// Form input for an username input.
/// {@endtemplate}
class HSUsername extends FormzInput<String, HSUsernameValidationError> {
  /// {@macro username}
  const HSUsername.pure() : super.pure('');

  /// {@macro username}
  const HSUsername.dirty([super.value = '']) : super.dirty();

  static final RegExp usernameRegExp = RegExp(
    r'^[a-z0-9_]{5,16}$',
  );

  @override
  HSUsernameValidationError? validator(String? value) {
    if (usernameRegExp.hasMatch(value ?? '')) {
      return null;
    } else if (value!.length < 5) {
      return HSUsernameValidationError.short;
    } else if (value.length > 16) {
      return HSUsernameValidationError.long;
    } else if (value.contains(RegExp(r'[A-Z]'))) {
      return HSUsernameValidationError.notLowerCase;
    } else {
      return HSUsernameValidationError.invalid;
    }
  }

  static String validateUsername(String value) {
    String ret = "Username should be:";
    if (value.length < 5) ret += "\n· at least 5 characters long";
    if (value.length > 16) {
      ret += "\n· at most 16 characters long";
    } else if (value.contains(RegExp(r'[A-Z]'))) {
      ret += "\n· lowercase";
    }
    return ret;
  }
}
