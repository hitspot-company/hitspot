import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';
import 'package:hs_toasts/hs_toasts.dart';

part 'hs_register_state.dart';

class HSRegisterCubit extends Cubit<HSRegisterState> {
  HSRegisterCubit(this._authenticationRepository)
      : super(const HSRegisterState());

  final HSAuthenticationRepository _authenticationRepository;

  double get opacity =>
      state.registerPageState == HSRegisterPageState.initial ? 0.0 : 1.0;

  bool get passwordInputVisible => opacity != 0.0;

  void changeRegisterPageState(HSRegisterPageState pageState) {
    if (state.email.value.isEmpty) {
      emit(state.copyWith(errorMessage: "Email cannot be empty"));
    } else if (state.email.isNotValid) {
      emit(state.copyWith(errorMessage: "Invalid email address"));
    } else {
      emit(state.copyWith(errorMessage: null, registerPageState: pageState));
    }
  }

  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        errorMessage: null,
        isValid: Formz.validate([
          email,
          state.password,
        ]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        errorMessage: null,
        password: password,
        isValid: Formz.validate([
          state.email,
          password,
        ]),
      ),
    );
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      // TODO: Handle redirection to email verification after sign up
      HSApp.instance.authBloc.add(HSAppUserChanged(HSApp.instance.currentUser));
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      HSDebugLogger.logError(e.message);
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
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
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
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
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
      if (!e.isDefault) _showErrorSnackbar(e.message);
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  void _showErrorSnackbar(String message) => HSApp.instance.showToast(
      toastType: HSToastType.error,
      title: "Authentication Error",
      description: message);
}
