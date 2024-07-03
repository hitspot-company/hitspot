import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(HSDatabaseRepsitory databaseRepository)
      : _databaseRepository = databaseRepository,
        super(const EditProfileState());

  final _picker = ImagePicker();
  // final _firebaseStorage = FirebaseStorage.instance;
  final HSDatabaseRepsitory _databaseRepository;
  bool shouldUpdate = false;

  Future<CroppedFile?> _getCroppedFile(String sourcePath) async {
    late final CroppedFile? ret;
    ret = await ImageCropper().cropImage(sourcePath: sourcePath, uiSettings: [
      IOSUiSettings(
        title: 'Your Avatar',
      ),
    ]);
    return ret;
  }

  Future<void> chooseImage() async {
    try {
      final CroppedFile? image =
          await app.pickers.image(cropStyle: CropStyle.circle);
      if (image == null) return;
      final File file = File(image.path);
      emit(state.copy(imageChangeState: HSImageChangeState.uploading));
      final String url = await uploadFile(file);
      emit(state.copy(imageChangeState: HSImageChangeState.setting));
      await setProfilePicture(url);
      emit(state.copy(imageChangeState: HSImageChangeState.done));
      app.authenticationBloc.add(HSAuthenticationUserChangedEvent(
          user: currentUser.copyWith(profilePicture: url)));
      emit(state.copy(imageChangeState: HSImageChangeState.idle));
      app.showToast(
        toastType: HSToastType.success,
        title: "Success",
        description: "Your profile picture has been changed!",
        alignment: Alignment.bottomCenter,
      );
      shouldUpdate = true;
    } catch (_) {
      HSDebugLogger.logError("$_");
      app.showToast(
          toastType: HSToastType.error,
          title: "Error",
          description:
              "The profile picture could not be changed. Please try again soon.");
    }
    emit(state.copy(imageChangeState: HSImageChangeState.idle));
  }

  Future<String> uploadFile(File imageFile) async {
    try {
      final String url = await app.storageRepository
          .fileUploadAndFetchPublicUrl(
              file: imageFile,
              bucketName: app.storageRepository.avatarsBucket,
              uploadPath: app.storageRepository
                  .userAvatarUploadPath(uid: currentUser.uid!),
              fileOptions: const FileOptions(upsert: true));
      return url;
    } catch (_) {
      HSDebugLogger.logError("$_");
      rethrow;
    }
  }

  Future<void> setProfilePicture(String url) async {
    try {
      await _databaseRepository.userUpdate(
          user: currentUser.copyWith(profilePicture: url));
      HSDebugLogger.logSuccess("Profile picture changed!");
    } catch (_) {
      HSDebugLogger.logError("$_");
      rethrow;
    }
  }
}
