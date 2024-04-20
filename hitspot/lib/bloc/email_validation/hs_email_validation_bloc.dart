import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/repositories/email_validation/hs_email_validation_repo.dart';

part 'hs_email_validation_event.dart';
part 'hs_email_validation_state.dart';

class HSEmailValidationBloc
    extends Bloc<HSEmailValidationEvent, HSEmailValidationState> {
  final HSEmailValidationRepo _repo;

  HSEmailValidationBloc(this._repo) : super(HSEmailValidationInitialState()) {
    on<HSEmailValidationEvent>((event, emit) {});
    on<HSEmailValidationSendEmailEvent>((event, emit) async {
      emit(HSEmailValidationLoadingState());
      try {
        await _repo.resendVerificationEmail();
        emit(HSEmailValidationEmailSentState());
      } catch (e) {
        print("Error: $e");
        emit(const HSEmailValidationErrorState(
            "Error", "Verification email could not be sent"));
      }
      emit(HSEmailValidationEmailNotValidatedState());
    });
    on<HSEmailValidationValidateEmail>((event, emit) async {
      emit(HSEmailValidationLoadingState());
      try {
        bool verified = await _repo.isEmailVerified();
        if (verified) {
          emit(HSEmailValidationEmailValidatedState());
        } else {
          emit(const HSEmailValidationErrorState(
              "Email not verified", "Please verify your email first."));
        }
      } catch (_) {
        emit(const HSEmailValidationErrorState(
            "Error", "Could not check if the email is verified"));
      }
      emit(HSEmailValidationEmailNotValidatedState());
    });
  }
}
