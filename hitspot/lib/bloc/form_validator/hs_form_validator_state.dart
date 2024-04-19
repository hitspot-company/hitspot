part of 'hs_form_validator_cubit.dart';

sealed class HSFormValidatorState extends Equatable {
  final AutovalidateMode autovalidateMode;
  final String email, password;
  final bool obscureText;

  const HSFormValidatorState({
    this.autovalidateMode = AutovalidateMode.disabled,
    this.email = '',
    this.password = '',
    this.obscureText = true,
  });

  HSFormValidatorState copyWith(
      {AutovalidateMode? autovalidateMode,
      String? email,
      String? password,
      bool? obscureText});

  @override
  List<Object> get props => [autovalidateMode, email, password, obscureText];
}

final class HSFormValidatorUpdate extends HSFormValidatorState {
  const HSFormValidatorUpdate({
    super.autovalidateMode,
    super.email,
    super.password,
    super.obscureText,
  });

  @override
  HSFormValidatorUpdate copyWith(
      {AutovalidateMode? autovalidateMode,
      String? email,
      String? password,
      bool? obscureText}) {
    return HSFormValidatorUpdate(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      email: email ?? this.email,
      password: password ?? this.password,
      obscureText: obscureText ?? this.obscureText,
    );
  }
}
