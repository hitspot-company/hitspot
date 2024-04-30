part of 'hs_profile_completion_cubit.dart';

final class HSProfileCompletionState extends Equatable {
  const HSProfileCompletionState({
    this.step = 0,
    this.username = const Username.pure(),
    this.fullname = const Fullname.pure(),
    this.usernameAvailable = false,
    this.birthday = "",
  });

  final int step;
  final Username username;
  final Fullname fullname;
  final bool usernameAvailable;
  final String birthday;

  @override
  List<Object?> get props => [
        step,
        username,
        fullname,
        birthday,
        usernameAvailable,
      ];

  HSProfileCompletionState copyWith({
    int? step,
    Username? username,
    Fullname? fullname,
    bool? usernameAvailable,
    String? birthday,
  }) {
    return HSProfileCompletionState(
      step: step ?? this.step,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      usernameAvailable: usernameAvailable ?? this.usernameAvailable,
      birthday: birthday ?? this.birthday,
    );
  }
}
