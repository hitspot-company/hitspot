part of 'hs_profile_completion_cubit.dart';

final class HSProfileCompletionState extends Equatable {
  const HSProfileCompletionState({
    this.step = 0,
    this.username = const Username.pure(),
    this.fullname = const Fullname.pure(),
    this.usernameValidationState = UsernameValidationState.unknown,
    this.birthday = const Birthdate.pure(),
    this.pageComplete = false,
    this.error = "",
    this.loading = false,
    this.birthdayError = "",
  });

  final int step;
  final Username username;
  final Fullname fullname;
  final UsernameValidationState usernameValidationState;
  final Birthdate birthday;
  final bool pageComplete;
  final String error;
  final bool loading;
  final String birthdayError;

  @override
  List<Object?> get props => [
        step,
        username,
        fullname,
        birthday,
        usernameValidationState,
        pageComplete,
        error,
        loading,
        birthdayError,
      ];

  HSProfileCompletionState copyWith({
    int? step,
    Username? username,
    Fullname? fullname,
    UsernameValidationState? usernameValidationState,
    Birthdate? birthday,
    bool? pageComplete,
    String? error,
    bool? loading,
    String? birthdayError,
  }) {
    return HSProfileCompletionState(
      step: step ?? this.step,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      usernameValidationState:
          usernameValidationState ?? this.usernameValidationState,
      birthday: birthday ?? this.birthday,
      pageComplete: pageComplete ?? this.pageComplete,
      error: error ?? this.error,
      loading: loading ?? this.loading,
      birthdayError: birthdayError ?? this.birthdayError,
    );
  }
}
