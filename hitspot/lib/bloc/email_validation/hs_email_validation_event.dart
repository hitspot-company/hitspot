part of 'hs_email_validation_bloc.dart';

sealed class HSEmailValidationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class HSEmailValidationSendEmailEvent extends HSEmailValidationEvent {}

final class HSEmailValidationValidateEmail extends HSEmailValidationEvent {}
