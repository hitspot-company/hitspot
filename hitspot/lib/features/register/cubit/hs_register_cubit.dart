import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/forms/hs_email.dart';
import 'package:hitspot/utils/forms/hs_password.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
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
    final email = HSEmail.dirty(value);
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
    final password = HSPassword.dirty(value);
    emit(
      state.copyWith(
        errorMessage: getPasswordErrorText(value),
        password: password,
        isValid: Formz.validate([
          state.email,
          password,
        ]),
      ),
    );
  }

  String? getPasswordErrorText(String value) {
    String? ret;
    if (!HSPassword.passwordRegExp.hasMatch(value)) {
      ret = "The password has to: ";
      if (value.length < 8) {
        ret += "\n at least 8 characters long";
      }
      if (value.length > 24) {
        ret += "\n at most 24 characters long";
      }
      ret += "\n other cases";
    }
    return (ret);
    // TODO: Others
//     The string contains at least one letter ((?=.*[A-Za-z])).
//     The string contains at least one digit ((?=.*\d)).
//     The string is at least 8 characters long ([A-Za-z\d]{8,}).
//     The string only contains letters and digits.
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: "",
      );
      await _completeRegistration();
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      HSDebugLogger.logError(e.message);
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
      return;
    }
  }

  Future<void> _completeRegistration() async {
    app.authenticationBloc
        .userChangedEvent(user: currentUser.copyWith(isEmailVerified: false));
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

  void _showErrorSnackbar(String message) => app.showToast(
      toastType: HSToastType.error,
      title: "Authentication Error",
      description: message);
}
