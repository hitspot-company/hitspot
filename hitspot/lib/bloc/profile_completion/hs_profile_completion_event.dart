part of 'hs_profile_completion_bloc.dart';

sealed class HSProfileCompletionEvent extends Equatable {
  final String fullname;
  final String username;
  final String bday;

  const HSProfileCompletionEvent(
      {this.bday = '', this.username = '', this.fullname = ''});

  @override
  List<Object> get props => [bday, username, fullname];
}

final class HSProfileCompletionChangeStep extends HSProfileCompletionEvent {
  final int step;

  const HSProfileCompletionChangeStep(this.step,
      {super.bday, super.fullname, super.username});

  @override
  List<Object> get props => [step, bday, fullname, username];
}

final class HSProfileCompletionPreviousStepEvent
    extends HSProfileCompletionEvent {
  final int step;

  const HSProfileCompletionPreviousStepEvent(this.step,
      {super.bday, super.fullname, super.username});

  @override
  List<Object> get props => [step, bday, fullname, username];
}
