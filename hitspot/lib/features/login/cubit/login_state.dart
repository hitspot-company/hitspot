part of 'login_cubit.dart';

final class HSLoginState extends Equatable {
  const HSLoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.isPasswordVisible = false,
  });

  final Email email;
  final Password password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;
  final bool isPasswordVisible;

  @override
  List<Object?> get props =>
      [email, password, status, isValid, errorMessage, isPasswordVisible];

  HSLoginState copyWith(
      {Email? email,
      Password? password,
      FormzSubmissionStatus? status,
      bool? isValid,
      String? errorMessage,
      bool? isPasswordVisible}) {
    return HSLoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}
