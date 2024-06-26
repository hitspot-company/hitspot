import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/main.dart';
import 'package:hitspot/utils/forms/hs_email.dart';
import 'package:hitspot/utils/forms/hs_password.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_toasts/hs_toasts.dart';
import 'package:equatable/equatable.dart';

part 'hs_login_state.dart';

class HSLoginCubit extends Cubit<HSLoginState> {
  HSLoginCubit(this._authenticationRepository) : super(const HSLoginState());

  final HSAuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = HSEmail.dirty(value);
    emit(
      state.copyWith(
        email: email,
        errorMessage: null,
        isValid: Formz.validate([email]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = HSPassword.dirty(value);
    emit(
      state.copyWith(
        password: password,
        errorMessage: null,
        isValid: Formz.validate([state.email]),
      ),
    );
  }

  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));

  Future<void> logInWithCredentials() async {
    if (state.email.isNotValid) {
      emit(state.copyWith(errorMessage: "The email is not valid"));
      return;
    }
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signInWithMagicLink(
        email: state.email.value,
      );
      app.authenticationBloc
          .add(HSAuthenticationMagicLinkSentEvent(state.email.value));
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      _emitFailure();
    } catch (_) {
      HSDebugLogger.logError("Error: $_");
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithGoogleFailure catch (e) {
      if (!e.isDefault) _showErrorSnackbar(e.message);
      _emitFailure();
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> logInWithApple() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithApple();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithAppleFailure catch (e) {
      _emitFailure();
      HSDebugLogger.logError(e.message);
      // if (!e.isDefault) _showErrorSnackbar(e.message);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  void _showErrorSnackbar(String message) => app.showToast(
      toastType: HSToastType.error,
      title: "Authentication Error",
      description: message);

  void _emitFailure({String? message}) => emit(
        state.copyWith(
          errorMessage: message,
          status: FormzSubmissionStatus.failure,
        ),
      );
}
