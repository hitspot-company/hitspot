import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'hs_form_validator_state.dart';

class HSFormValidatorCubit extends Cubit<HSFormValidatorState> {
  HSFormValidatorCubit() : super(const HSFormValidatorUpdate());

  void initForm({
    String email = '',
    String password = '',
  }) {
    emit(state.copyWith(email: email, password: password));
  }

  void updateEmail(String newEmail) => emit(state.copyWith(email: newEmail));

  void updatePassword(String newPassword) =>
      emit(state.copyWith(password: newPassword));

  void updateAutovalidateMode(AutovalidateMode mode) =>
      emit(state.copyWith(autovalidateMode: mode));

  void toggleObscureText() {
    print("Toggled obscure: ${state.obscureText}");
    emit(state.copyWith(obscureText: !state.obscureText));
  }

  void reset() => emit(const HSFormValidatorUpdate());
}
