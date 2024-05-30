import 'package:formz/formz.dart';

/// Validation errors for the [Fullname] [FormzInput].
enum FullnameValidationError { invalid, short, long, unavailable, notLowerCase }

/// {@template usernmae}
/// Form input for an Fullname input.
/// {@endtemplate}
class Fullname extends FormzInput<String, FullnameValidationError> {
  /// {@macro fullname}
  const Fullname.pure() : super.pure('');

  /// {@macro fullname}
  const Fullname.dirty([super.value = '']) : super.dirty();

  /// The value is never null [pure state is '']
  @override
  FullnameValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return FullnameValidationError.invalid;
    return null;
  }
}
