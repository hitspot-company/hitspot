import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:formz/formz.dart';

/// Validation errors for the [Birthdate] [FormzInput].
enum BirthdateValidationError { none, empty, invalid, tooYoung }

/// {@template birthdate}
/// Form input for an Birthdate input.
/// {@endtemplate}
class Birthdate extends FormzInput<String, BirthdateValidationError> {
  /// {@macro birthdate}
  const Birthdate.pure() : super.pure('');

  /// {@macro birthdate}
  const Birthdate.dirty([super.value = '']) : super.dirty();

  DateTime get dateTime => this.value.stringToDateTime();
  String get readable => this.value.split(" ").elementAt(0);

  @override
  BirthdateValidationError? validator(String? value) {
    if (value?.isEmpty ?? true) return BirthdateValidationError.empty;
    return null;
  }
}

extension ProfileCompletionExtensions on String {
  String dateTimeToReadableString() {
    return toString().split(" ").elementAt(0);
  }

  Timestamp? dateTimeStringToTimestamp() {
    final DateTime date = DateTime.parse(this);
    final Timestamp ts = Timestamp.fromDate(date);
    return (ts);
  }

  DateTime stringToDateTime() {
    return DateTime.parse(this);
  }
}
