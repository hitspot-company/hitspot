part of 'hs_profile_completion_cubit.dart';

final class HSProfileCompletionState extends Equatable {
  const HSProfileCompletionState({
    this.step = 0,
    this.username = const Username.pure(),
    this.fullname = const Fullname.pure(),
    this.usernameAvailable = false,
    this.birthday = const Birthdate.pure(),
    this.pageComplete = false,
    this.error = "",
    this.loading = false,
  });

  final int step;
  final Username username;
  final Fullname fullname;
  final bool usernameAvailable;
  final Birthdate birthday;
  final bool pageComplete;
  final String error;
  final bool loading;

  @override
  List<Object?> get props => [
        step,
        username,
        fullname,
        birthday,
        usernameAvailable,
        pageComplete,
        error,
        loading,
      ];

  HSProfileCompletionState copyWith({
    int? step,
    Username? username,
    Fullname? fullname,
    bool? usernameAvailable,
    Birthdate? birthday,
    bool? pageComplete,
    String? error,
    bool? loading,
  }) {
    return HSProfileCompletionState(
      step: step ?? this.step,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      usernameAvailable: usernameAvailable ?? this.usernameAvailable,
      birthday: birthday ?? this.birthday,
      pageComplete: pageComplete ?? this.pageComplete,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
}
