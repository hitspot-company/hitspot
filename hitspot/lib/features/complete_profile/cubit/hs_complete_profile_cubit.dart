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
import 'package:hs_storage_repository/hs_storage_repository.dart';
// import 'package:hs_toasts/hs_toasts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'hs_complete_profile_state.dart';

class HSCompleteProfileCubit extends Cubit<HSCompleteProfileState> {
  HSCompleteProfileCubit() : super(const HSCompleteProfileState());

  final PageController pageController = PageController();
  final HSDatabaseRepsitory _databaseRepository = app.databaseRepository;
  final HSStorageRepository _storageRepository = app.storageRepository;

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

    if (state.username.isNotValid) {
      emit(state.copyWith(
          usernameValidationState: HSUsernameValidationState.unknown));
      return;
    }
    if (!(await _databaseRepository.userIsUsernameAvailable(
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
    try {
      String? avatarUrl;
      if (state.avatarVal != null) {
        final File file = File(state.avatarVal!);
        avatarUrl = await _storageRepository.fileUploadAndFetchPublicUrl(
            file: file,
            bucketName: _storageRepository.avatarsBucket,
            uploadPath:
                _storageRepository.userAvatarUploadPath(uid: currentUser.uid!),
            fileOptions: const FileOptions(upsert: true));
      }

      final HSUser user = currentUser.copyWith(
        username: state.usernameVal,
        fullName: state.fullnameVal,
        biogram: state.biogramVal,
        birthday: state.birthdayVal,
        profilePicture: avatarUrl,
        createdAt: DateTime.now(),
        isProfileCompleted: true,
      );
      await _databaseRepository.userUpdate(user: user);
      app.authenticationBloc.userChangedEvent(user: user);
      return;
    } on HSFileException catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(
          state.copyWith(completeProfileStatus: HSCompleteProfileStatus.error));
    } catch (_) {
      HSDebugLogger.logError("Error submitting: $_");
      emit(
          state.copyWith(completeProfileStatus: HSCompleteProfileStatus.error));
    }
  }
}
