import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';

part 'hs_verify_email_state.dart';

class HSVerifyEmailCubit extends Cubit<HSVerifyEmailState> {
  HSVerifyEmailCubit(this._authenticationRepository)
      : super(const HSVerifyEmailState());

  final HSAuthenticationRepository _authenticationRepository;
  final HSApp _app = HSApp.instance;

  Future<void> isEmailVerified() async {
    emit(state.copyWith(
        emailVerificationState: HSEmailVerificationState.verifying));
    try {
      bool emailVerified = await _authenticationRepository.isEmailVerified();
      if (emailVerified) {
        emit(state.copyWith(
            emailVerificationState: HSEmailVerificationState.verified));
      }
      return;
    } catch (_) {
      _app.showToast(
          toastType: HSToastType.error,
          title: "Error",
          description: "Failed to check whether email is verified.");
    }
    emit(state.copyWith(
        emailVerificationState: HSEmailVerificationState.unverified));
  }

  Future<void> sendVerificationEmail() async {
    emit(state.copyWith(
        emailVerificationState: HSEmailVerificationState.sending));
    try {
      await _authenticationRepository.sendEmailVerification();
      emit(state.copyWith(
          emailVerificationState: HSEmailVerificationState.resent));
      return;
    } catch (_) {
      _app.showToast(
          toastType: HSToastType.error,
          title: "Error",
          description: "Failed to resend verification email");
    }
    emit(state.copyWith(
        emailVerificationState: HSEmailVerificationState.failedToResend));
  }
}
