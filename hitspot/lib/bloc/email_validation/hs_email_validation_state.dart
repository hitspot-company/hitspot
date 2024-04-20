part of 'hs_email_validation_bloc.dart';

sealed class HSEmailValidationState extends Equatable {
  const HSEmailValidationState();

  @override
  List<Object> get props => [];
}

final class HSEmailValidationInitialState extends HSEmailValidationState {}

final class HSEmailValidationLoadingState extends HSEmailValidationState {}

final class HSEmailValidationErrorState extends HSEmailValidationState {
  final String errorTitle;
  final String errorMessage;

  const HSEmailValidationErrorState(this.errorTitle, this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class HSEmailValidationEmailSentState extends HSEmailValidationState {}

final class HSEmailValidationEmailValidatedState
    extends HSEmailValidationState {}

final class HSEmailValidationEmailNotValidatedState
    extends HSEmailValidationState {}
