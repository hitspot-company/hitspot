import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';
import 'package:hs_toasts/hs_toasts.dart';

part 'hs_password_reset_state.dart';

class HSPasswordResetCubit extends Cubit<HSPasswordResetState> {
  HSPasswordResetCubit(this._authenticationRepository)
      : super(const HSPasswordResetState());
  final HSAuthenticationRepository _authenticationRepository;

  HSApp get _app => HSApp.instance;
  bool get valid => state.email.isValid;
  bool get sent => state.pageState == HSPasswordResetPageState.sent;
  bool get sending => state.pageState == HSPasswordResetPageState.sending;

  Future<void> sendResetPasswordEmail() async {
    try {
      if (!valid || state.email.value.isEmpty) {
        throw const SendResetPasswordEmailFailure(
            "The email address is not valid");
      }
      emit(state.copyWith(pageState: HSPasswordResetPageState.sending));
      await Future.delayed(const Duration(seconds: 2));
      await _authenticationRepository.sendResetPasswordEmail(state.email.value);
      _app.showToast(
          toastType: HSToastType.success,
          alignment: Alignment.bottomCenter,
          title: "Email Sent",
          description: "Please check your inbox for a reset link.");
      emit(state.copyWith(pageState: HSPasswordResetPageState.sent));
      return;
    } on SendResetPasswordEmailFailure catch (_) {
      HSDebugLogger.logError(_.message);
      emit(state.copyWith(errorMessage: _.message));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
    emit(state.copyWith(
        pageState: HSPasswordResetPageState.initial,
        errorMessage: state.errorMessage));
  }

  void emailChanged(String email) =>
      emit(state.copyWith(email: Email.dirty(email), errorMessage: null));
}
