import 'package:formz/formz.dart';

/// Validation errors for the [Birthdate] [FormzInput].
enum HSBirthdateValidationError { none, empty, invalid, tooYoung }

/// {@template birthdate}
/// Form input for an Birthdate input.
/// {@endtemplate}
class HSBirthdate extends FormzInput<String, HSBirthdateValidationError> {
  /// {@macro birthdate}
  const HSBirthdate.pure() : super.pure('');

  /// {@macro birthdate}
  const HSBirthdate.dirty([super.value = '']) : super.dirty();

  DateTime get dateTime => value.stringToDateTime();
  String get readable => value.split(" ").elementAt(0);

  @override
  HSBirthdateValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return HSBirthdateValidationError.empty;
    return null;
  }
}

extension ProfileCompletionExtensions on String {
  String dateTimeToReadableString() {
    return toString().split(" ").elementAt(0);
  }

  DateTime stringToDateTime() {
    return DateTime.parse(this);
  }
}
