part of 'hs_profile_completion_bloc.dart';

sealed class HSProfileCompletionState extends Equatable {
  const HSProfileCompletionState(
      {this.step = 0, this.bday = '', this.fullname = '', this.username = ''});

  final String bday;
  final String fullname;
  final String username;
  final int step;

  @override
  List<Object> get props => [step, bday, username, fullname];
}

final class HSProfileCompletionInitialStep extends HSProfileCompletionState {}

final class HSProfileCompletionBirtdayStep extends HSProfileCompletionState {}

final class HSProfileCompletionFullnameStep extends HSProfileCompletionState {
  const HSProfileCompletionFullnameStep() : super(step: 1);
}

final class HSProfileCompletionUsernameStep extends HSProfileCompletionState {
  const HSProfileCompletionUsernameStep() : super(step: 2);
}

final class HSProfileCompletionConfirmationStep
    extends HSProfileCompletionState {
  const HSProfileCompletionConfirmationStep() : super(step: 3);
}
