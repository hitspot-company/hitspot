part of 'hs_profile_completion_bloc.dart';

sealed class HSProfileCompletionState extends Equatable {
  const HSProfileCompletionState(
      {this.step = 0, this.bday = '', this.fullname = '', this.username = ''});

  final String bday;
  final String fullname;
  final String username;
  final int step;

  HSProfileCompletionState copyWith({
    String? fullname,
    String? username,
    String? bday,
    required int step,
  });

  @override
  List<Object> get props => [step, bday, username, fullname];
}

final class HSProfileCompletionUpdateState extends HSProfileCompletionState {
  const HSProfileCompletionUpdateState(
      {super.bday, super.fullname, super.step, super.username});

  @override
  HSProfileCompletionUpdateState copyWith({
    String? fullname,
    String? username,
    String? bday,
    required int step,
  }) {
    return HSProfileCompletionUpdateState(
        step: step,
        fullname: fullname ?? this.fullname,
        username: username ?? this.username,
        bday: bday ?? this.bday);
  }
}
