part of 'hs_profile_completion_cubit.dart';

final class HSProfileCompletionState extends Equatable {
  const HSProfileCompletionState({
    this.step = 0,
    this.username = const Username.pure(),
    this.fullname = const Fullname.pure(),
    this.usernameAvailable = false,
    this.birthday = "",
    // this.password = const Password.pure(),
    // this.confirmedPassword = const ConfirmedPassword.pure(),
    // this.status = FormzSubmissionStatus.initial,
    // this.isValid = false,
    // this.errorMessage,
    // this.isPasswordVisible = false,
  });

  final int step;
  final Username username;
  final Fullname fullname;
  final bool usernameAvailable;
  final String birthday;
  // final Password password;
  // final ConfirmedPassword confirmedPassword;
  // final FormzSubmissionStatus status;
  // final bool isValid;
  // final bool isPasswordVisible;
  // final String? errorMessage;

  @override
  List<Object?> get props => [
        step,
        username,
        fullname,
        birthday,
        // password,
        // confirmedPassword,
        // status,
        // isValid,
        // errorMessage,
        // isPasswordVisible,
      ];

  HSProfileCompletionState copyWith({
    int? step,
    Username? username,
    Fullname? fullname,
    bool? usernameAvailable,
    String? birthday,
    // Email? email,
    // Password? password,
    // ConfirmedPassword? confirmedPassword,
    // FormzSubmissionStatus? status,
    // bool? isValid,
    // String? errorMessage,
    // bool? isPasswordVisible,
  }) {
    return HSProfileCompletionState(
      step: step ?? this.step, username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      usernameAvailable: usernameAvailable ?? this.usernameAvailable,
      birthday: birthday ?? this.birthday,
      // email: email ?? this.email,
      // password: password ?? this.password,
      // confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      // status: status ?? this.status,
      // isValid: isValid ?? this.isValid,
      // isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      // errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
