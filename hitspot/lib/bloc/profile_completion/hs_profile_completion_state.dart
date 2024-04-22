part of 'hs_profile_completion_cubit.dart';

sealed class HSProfileCompletionState extends Equatable {
  final int step;
  final String fullname;
  final String username;
  final String bday;
  final List<Object?> preferences;

  const HSProfileCompletionState(
      {this.step = 0,
      this.bday = '',
      this.username = '',
      this.fullname = '',
      this.preferences = const []});

  HSProfileCompletionState copyWith({
    int? step,
    String? fullname,
    String? username,
    String? bday,
    List<Object?>? preferences,
  });

  @override
  List<Object> get props => [step, bday, username, fullname, preferences];
}

final class HSProfileCompletionUpdate extends HSProfileCompletionState {
  const HSProfileCompletionUpdate(
      {super.step,
      super.bday,
      super.fullname,
      super.username,
      super.preferences});

  @override
  HSProfileCompletionUpdate copyWith({
    int? step,
    String? fullname,
    String? username,
    String? bday,
    List<Object?>? preferences,
  }) {
    return HSProfileCompletionUpdate(
      step: step ?? this.step,
      fullname: fullname ?? this.fullname,
      username: username ?? this.username,
      bday: bday ?? this.bday,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object> get props => [step, bday, fullname, username, preferences];
}
