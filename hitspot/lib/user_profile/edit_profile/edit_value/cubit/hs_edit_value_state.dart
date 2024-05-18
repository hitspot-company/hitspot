part of 'hs_edit_value_cubit.dart';

enum HSEditValueStatus { idle, loading, failed, updated }

final class HSEditValueState extends Equatable {
  const HSEditValueState({
    this.initialValue = "",
    this.value = "",
    this.errorText,
    this.fieldDescription,
    this.fieldName,
    this.status = HSEditValueStatus.updated,
  });

  final HSEditValueStatus status;
  final String value;
  final String? fieldName;
  final String? fieldDescription;
  final String initialValue;
  final String? errorText;

  @override
  List<Object?> get props => [value, initialValue, status, errorText];

  HSEditValueState copyWith(
          {String? value, String? errorText, HSEditValueStatus? status}) =>
      HSEditValueState(
        fieldDescription: fieldDescription,
        fieldName: fieldName,
        initialValue: initialValue,
        value: value ?? this.value,
        status: status ?? this.status,
        errorText: errorText,
      );
}
