part of 'hs_register_cubit.dart';

enum HSRegisterPageState {
  initial,
  emailEntered,
  passwordFadingIn,
  passwordFadedIn
}

final class HSRegisterState extends Equatable {
  const HSRegisterState({
    this.email = const HSEmail.pure(),
    this.password = const HSPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.registerPageState = HSRegisterPageState.initial,
  });

  final HSEmail email;
  final HSPassword password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final bool isPasswordVisible;
  final String? errorMessage;
  final HSRegisterPageState registerPageState;

  @override
  List<Object?> get props => [
        email,
        password,
        status,
        isValid,
        errorMessage,
        isPasswordVisible,
        registerPageState,
      ];

  HSRegisterState copyWith({
    HSEmail? email,
    HSPassword? password,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
    bool? isPasswordVisible,
    HSRegisterPageState? registerPageState,
  }) {
    return HSRegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage,
      registerPageState: registerPageState ?? this.registerPageState,
    );
  }
}
