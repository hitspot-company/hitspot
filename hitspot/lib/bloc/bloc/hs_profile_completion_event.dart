part of 'hs_profile_completion_bloc.dart';

sealed class HSProfileCompletionEvent extends Equatable {
  const HSProfileCompletionEvent();
  // final String fullname;
  // final String username;
  // final DateTime bday;

  @override
  List<Object> get props => [];
}

final class HSProfileCompletionNextStepEvent extends HSProfileCompletionEvent {
  final int step;

  const HSProfileCompletionNextStepEvent(this.step);

  @override
  List<Object> get props => [step];
}

final class HSProfileCompletionPreviousStepEvent
    extends HSProfileCompletionEvent {
  final int step;

  const HSProfileCompletionPreviousStepEvent(this.step);

  @override
  List<Object> get props => [step];
}

final class HSProfileCompletionUpdateDetailsEvent
    extends HSProfileCompletionEvent {}
