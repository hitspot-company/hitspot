part of 'hs_profile_completion_cubit.dart';

final class HSProfileCompletionState extends Equatable {
  const HSProfileCompletionState({
    this.step = 0,
    this.username = const Username.pure(),
    this.fullname = const Fullname.pure(),
    this.usernameAvailable = false,
    this.birthday = "",
    this.pageComplete = false,
    this.error = "",
  });

  final int step;
  final Username username;
  final Fullname fullname;
  final bool usernameAvailable;
  final String birthday;
  final bool pageComplete;
  final String error;

  @override
  List<Object?> get props => [
        step,
        username,
        fullname,
        birthday,
        usernameAvailable,
        pageComplete,
        error,
      ];

  HSProfileCompletionState copyWith({
    int? step,
    Username? username,
    Fullname? fullname,
    bool? usernameAvailable,
    String? birthday,
    bool? pageComplete,
    String? error,
  }) {
    return HSProfileCompletionState(
      step: step ?? this.step,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      usernameAvailable: usernameAvailable ?? this.usernameAvailable,
      birthday: birthday ?? this.birthday,
      pageComplete: pageComplete ?? this.pageComplete,
      error: error ?? this.error,
    );
  }
}
