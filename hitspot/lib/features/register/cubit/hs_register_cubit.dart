import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';
import 'package:hs_mailing_repository/hs_mailing_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';

part 'hs_register_state.dart';

class HSRegisterCubit extends Cubit<HSRegisterState> {
  HSRegisterCubit(this._authenticationRepository)
      : super(const HSRegisterState());

  final HSAuthenticationRepository _authenticationRepository;
  final HSNavigation _hsNavigationService = HSApp.instance.navigation;

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
    if (!Password.passwordRegExp.hasMatch(value)) {
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
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
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
    } on HSSendEmailException catch (e) {
      HSDebugLogger.logError("Error sending welcome email: ${e.message}");
      await _completeRegistration();
      return;
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> _completeRegistration() async {
    app.authBloc
        .add(HSAppUserChanged(currentUser.copyWith(isEmailVerified: false)));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(status: FormzSubmissionStatus.success));
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
