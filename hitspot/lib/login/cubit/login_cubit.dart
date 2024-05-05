import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';
import 'package:hs_toasts/hs_toasts.dart';

part 'login_state.dart';

class HSLoginCubit extends Cubit<HSLoginState> {
  HSLoginCubit(this._authenticationRepository) : super(const HSLoginState());

  final HSAuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        errorMessage: null,
        isValid: Formz.validate([email]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
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
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      _emitFailure();
    } catch (_) {
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
      if (!e.isDefault) _showErrorSnackbar(e.message);
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  void _showErrorSnackbar(String message) => HSApp.instance.showToast(
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
