import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/route_manager.dart';
import 'package:hitspot/features/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:image_picker/image_picker.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(HSDatabaseRepository databaseRepository)
      : _databaseRepository = databaseRepository,
        super(const EditProfileState());

  final _picker = ImagePicker();
  final _firebaseStorage = FirebaseStorage.instance;
  final HSDatabaseRepository _databaseRepository;

  Future<CroppedFile?> _getCroppedFile(String sourcePath) async {
    late final CroppedFile? ret;
    ret = await ImageCropper().cropImage(
        cropStyle: CropStyle.circle,
        sourcePath: sourcePath,
        uiSettings: [
          IOSUiSettings(
            title: 'Your Avatar',
          ),
        ]);
    return ret;
  }

  Future<void> chooseImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return;
      final CroppedFile? croppedFile = await _getCroppedFile(image.path);
      if (croppedFile == null) return;
      final File file = File(croppedFile.path);
      emit(state.copy(imageChangeState: HSImageChangeState.uploading));
      final String url = await uploadFile(file);
      emit(state.copy(imageChangeState: HSImageChangeState.setting));
      await setProfilePicture(url);
      emit(state.copy(imageChangeState: HSImageChangeState.done));
      app.authBloc
          .add(HSAppUserChanged(currentUser.copyWith(profilePicture: url)));
      emit(state.copy(imageChangeState: HSImageChangeState.idle));
      app.showToast(
        toastType: HSToastType.success,
        title: "Success",
        description: "Your profile picture has been changed!",
        alignment: Alignment.bottomCenter,
      );
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
      final Reference ref = _firebaseStorage
          .ref("users")
          .child("profile_pictures")
          .child(currentUser.uid!);
      final UploadTask uploadTask = ref.putFile(imageFile);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        late final double progress;
        if (snapshot.bytesTransferred.isNaN || snapshot.totalBytes.isNaN) {
          progress = 0;
        } else {
          progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        }
        emit(state.copy(changeProgress: progress));
      });

      // Get the download URL
      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } catch (_) {
      HSDebugLogger.logError("$_");
      rethrow;
    }
  }

  Future<void> setProfilePicture(String url) async {
    try {
      await _databaseRepository.updateField(
          currentUser, HSUserField.profilePicture.name, url);
      HSDebugLogger.logSuccess("Profile picture changed!");
    } catch (_) {
      HSDebugLogger.logError("$_");
      rethrow;
    }
  }
}
