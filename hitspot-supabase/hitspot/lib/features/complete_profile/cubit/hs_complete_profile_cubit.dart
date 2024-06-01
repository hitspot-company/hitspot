import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/forms/hs_birthdate.dart';
import 'package:hitspot/utils/forms/hs_full_name.dart';
import 'package:hitspot/utils/forms/hs_username.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
// import 'package:hs_toasts/hs_toasts.dart';
import 'package:image_cropper/image_cropper.dart';

part 'hs_complete_profile_state.dart';

class HSCompleteProfileCubit extends Cubit<HSCompleteProfileState> {
  HSCompleteProfileCubit() : super(const HSCompleteProfileState());

  final PageController pageController = PageController();
  final HSDatabaseRepsitory _databaseRepository = app.databaseRepository;

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

  void changeAvatar() async {
    final CroppedFile? chosenFile = await app.pickers.image(
      cropStyle: CropStyle.circle,
    );
    if (chosenFile != null) emit(state.copyWith(avatar: chosenFile.path));
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
          birthday: HSBirthdate.dirty(dateTime.toString()),
          error: "",
        ),
      );
    }
  }

  void updateName(String value) =>
      emit(state.copyWith(fullname: HSFullname.dirty(value)));

  void updateUsername(String value) => emit(state.copyWith(
      username: HSUsername.dirty(value),
      usernameValidationState: HSUsername.dirty(value).isValid
          ? HSUsernameValidationState.unknown
          : HSUsernameValidationState.empty));

  Future<void> isUsernameValid() async {
    if (state.username.value.isEmpty) {
      emit(state.copyWith(
        usernameValidationState: HSUsernameValidationState.empty,
      ));
    }
    emit(state.copyWith(
        usernameValidationState: HSUsernameValidationState.verifying));
    await Future.delayed(const Duration(seconds: 2));
    if (state.username.isNotValid) {
      emit(state.copyWith(
          usernameValidationState: HSUsernameValidationState.unknown));
      return;
    }
    if (!(await _databaseRepository.isUsernameAvailable(
        username: state.usernameVal!))) {
      emit(state.copyWith(
          usernameValidationState: HSUsernameValidationState.unavailable));
      return;
    }
    emit(state.copyWith(
        usernameValidationState: HSUsernameValidationState.available));
  }

  void submit() async {
    emit(
        state.copyWith(completeProfileStatus: HSCompleteProfileStatus.loading));
    await Future.delayed(const Duration(seconds: 3));
    emit(state.copyWith(completeProfileStatus: HSCompleteProfileStatus.idle));
    // try {
    //   String? avatarUrl;
    //   if (state.avatarVal != null) {
    //     final Reference ref = FirebaseStorage.instance
    //         .ref("users")
    //         .child(currentUser.uid!)
    //         .child("avatar");
    //     avatarUrl =
    //         await _databaseRepository.uploadFile(File(state.avatar), ref);
    //   }
    //   final HSUser user = currentUser.copyWith(
    //     username: state.usernameVal,
    //     fullName: state.fullnameVal,
    //     biogram: state.biogramVal,
    //     birthday: state.birthdayVal,
    //     profilePicture: avatarUrl,
    //     createdAt: Timestamp.now(),
    //     isProfileCompleted: true,
    //   );
    //   await Future.delayed(const Duration(seconds: 1));
    //   HSDebugLogger.logInfo(user.toString());
    //   await _databaseRepository.userUpdate(user);
    //   app.updateCurrentUser(user);
    // } catch (_) {
    //   HSDebugLogger.logError("Error submiting: $_");
    //   app.showToast(
    //       toastType: HSToastType.error,
    //       title: "Error",
    //       alignment: Alignment.bottomCenter,
    //       description: "Error submitting your data. Please try again later.");
    //   emit(
    //       state.copyWith(completeProfileStatus: HSCompleteProfileStatus.error));
    // }
  }
}
