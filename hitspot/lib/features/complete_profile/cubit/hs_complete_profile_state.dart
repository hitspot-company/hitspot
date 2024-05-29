part of 'hs_complete_profile_cubit.dart';

final class HSCompleteProfileState extends Equatable {
  const HSCompleteProfileState({
    this.username = const Username.pure(),
    this.fullname = const Fullname.pure(),
    this.usernameValidationState = UsernameValidationState.unknown,
    this.birthday = const Birthdate.pure(),
    this.error = "",
    this.loading = false,
  });

  final Username username;
  final Fullname fullname;
  final UsernameValidationState usernameValidationState;
  final Birthdate birthday;
  final String error;
  final bool loading;

  @override
  List<Object?> get props => [
        username,
        fullname,
        birthday,
        usernameValidationState,
        error,
        loading,
      ];

  HSCompleteProfileState copyWith({
    Username? username,
    Fullname? fullname,
    UsernameValidationState? usernameValidationState,
    Birthdate? birthday,
    String? error,
    bool? loading,
  }) {
    return HSCompleteProfileState(
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      usernameValidationState:
          usernameValidationState ?? this.usernameValidationState,
      birthday: birthday ?? this.birthday,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
}
