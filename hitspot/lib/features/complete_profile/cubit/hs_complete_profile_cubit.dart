import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

part 'hs_complete_profile_state.dart';

class HSCompleteProfileCubit extends Cubit<HSCompleteProfileState> {
  HSCompleteProfileCubit() : super(const HSCompleteProfileState());

  final PageController pageController = PageController();
  final HSDatabaseRepository _databaseRepository = app.databaseRepository;

  void nextPage() {
    HSScaffold.hideInput();
    pageController.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void prevPage() {
    HSScaffold.hideInput();
    pageController.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void updateBiogram(String value) => emit(state.copyWith(biogram: value));

  void updateBirthday() async {
    final DateTime? dateTime = await app.pickers.date(
      lastDate: app.pickers.minAge,
      firstDate: app.pickers.maxAge,
      currentDate: app.pickers.minAge,
    );
    if (dateTime != null) {
      emit(
        state.copyWith(
          birthday: Birthdate.dirty(dateTime.toString()),
          error: "",
        ),
      );
    }
  }

  void updateName(String value) =>
      emit(state.copyWith(fullname: Fullname.dirty(value)));

  void updateUsername(String value) => emit(state.copyWith(
      username: Username.dirty(value),
      usernameValidationState: Username.dirty(value).isValid
          ? UsernameValidationState.unknown
          : UsernameValidationState.empty));

  Future<void> isUsernameValid() async {
    if (state.username.value.isEmpty) {
      emit(state.copyWith(
        usernameValidationState: UsernameValidationState.empty,
      ));
    }
    emit(state.copyWith(
        usernameValidationState: UsernameValidationState.verifying));
    await Future.delayed(const Duration(seconds: 2));
    if (state.username.isNotValid) {
      emit(state.copyWith(
          usernameValidationState: UsernameValidationState.unknown));
      return;
    }
    if (!(await _databaseRepository
        .userIsUsernameAvailable(state.username.value))) {
      emit(state.copyWith(
          usernameValidationState: UsernameValidationState.unavailable));
      return;
    }
    emit(state.copyWith(
        usernameValidationState: UsernameValidationState.available));
  }
}
