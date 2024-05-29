import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_toasts/hs_toasts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

part 'hs_add_board_state.dart';

class HSAddBoardCubit extends Cubit<HSAddBoardState> {
  HSAddBoardCubit({this.prototype})
      : super(prototype != null
            ? HSAddBoardState.update(prototype)
            : const HSAddBoardState());

  final PageController pageController = PageController();
  final HSBoard? prototype;

  void updateTitle(String value) => emit(state.copyWith(title: value.trim()));
  void updateVisibility(HSBoardVisibility? value) =>
      emit(state.copyWith(boardVisibility: value));
  void updateDescription(String value) =>
      emit(state.copyWith(description: value.trim()));

  void nextPage() {
    if (pageController.page == 0 &&
        (state.title.isEmpty || state.description.isEmpty)) {
      emit(state.copyWith(
          errorText: "The title and description cannot be empty."));
      return;
    }
    pageController.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void prevPage() => pageController.previousPage(
      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);

  final HSDatabaseRepository _databaseRepository = app.databaseRepository;

  Future<bool> pickColor(bool value) async {
    if (!value) {
      emit(state.copyWith(color: Colors.transparent));
      return false;
    }
    return ColorPicker(
      color: state.color ?? currentTheme.mainColor.withOpacity(.6),
      onColorChanged: (Color color) => emit(state.copyWith(color: color)),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: textTheme.titleSmall,
      ),
      subheading: Text(
        'Select color shade',
        style: textTheme.titleSmall,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: textTheme.bodySmall,
      colorNameTextStyle: textTheme.bodySmall,
      colorCodeTextStyle: textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      app.context!,
      surfaceTintColor: Colors.transparent,
      transitionBuilder: (BuildContext context, Animation<double> a1,
          Animation<double> a2, Widget widget) {
        final double curvedValue =
            Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }

  Future<void> chooseImage(bool value) async {
    try {
      if (!value) {
        emit(state.copyWith(image: ""));
        return;
      }
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return;
      final CroppedFile? croppedFile = await _getCroppedFile(image.path);
      if (croppedFile == null) return;
      emit(state.copyWith(image: croppedFile.path));
    } catch (e) {
      HSDebugLogger.logError(e.toString());
    }
  }

  Future<CroppedFile?> _getCroppedFile(String sourcePath) async {
    late final CroppedFile? ret;
    final ImageCropper cropper = ImageCropper();
    ret = await cropper.cropImage(
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      sourcePath: sourcePath,
      uiSettings: [
        IOSUiSettings(
          title: 'Board Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    return ret;
  }

  Future<String> uploadFile(File imageFile, String docID) async {
    try {
      final Reference ref = FirebaseStorage.instance
          .ref("boards")
          .child(currentUser.uid!)
          .child(docID);
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } catch (_) {
      HSDebugLogger.logError("$_");
      rethrow;
    }
  }

  Future<void> _createBoard() async {
    try {
      final HSBoard board = HSBoard(
        authorID: currentUser.uid,
        color: state.color,
        description: state.description,
        title: state.title,
        boardVisibility: state.boardVisibility,
        createdAt: Timestamp.now(),
      );
      final String boardID = await _databaseRepository.boardCreate(board);
      if (state.image.isNotEmpty) {
        final String uploadedFileUrl =
            await uploadFile(File(state.image), boardID);
        await _databaseRepository
            .boardUpdate(board.copyWith(bid: boardID, image: uploadedFileUrl));
      }
      await Future.delayed(const Duration(seconds: 1));
      navi.router.go("/board/$boardID");
    } on DatabaseConnectionFailure catch (_) {
      HSDebugLogger.logError("Error creating board: ${_.message}");
      emit(state.copyWith(uploadState: HSAddBoardUploadState.error));
      _showError;
    } catch (_) {
      HSDebugLogger.logError("Unknown error: $_");
      emit(state.copyWith(uploadState: HSAddBoardUploadState.error));
      _showError;
    }
  }

  Future<void> _updateBoard() async {
    try {
      late final String? uploadedFileUrl;
      if (state.image != prototype?.image) {
        uploadedFileUrl = await uploadFile(File(state.image), prototype!.bid!);
      } else {
        uploadedFileUrl = null;
      }
      final HSBoard board = prototype!.copyWith(
        color: state.color,
        description: state.description,
        title: state.title,
        boardVisibility: state.boardVisibility,
        image: uploadedFileUrl,
      );
      await _databaseRepository.boardUpdate(board);
      navi.router.go("/board/${board.bid}");
    } on DatabaseConnectionFailure catch (_) {
      HSDebugLogger.logError("Error creating board: ${_.message}");
      emit(state.copyWith(uploadState: HSAddBoardUploadState.error));
      _showError;
    } catch (_) {
      HSDebugLogger.logError("Unknown error: $_");
      emit(state.copyWith(uploadState: HSAddBoardUploadState.error));
      _showError;
    }
  }

  Future<void> submit() async {
    emit(state.copyWith(uploadState: HSAddBoardUploadState.uploading));
    try {
      if (prototype == null) {
        await _createBoard();
        HSDebugLogger.logSuccess("Board Created");
      } else {
        await _updateBoard();
        HSDebugLogger.logSuccess("Board Updated");
      }
    } on DatabaseConnectionFailure catch (_) {
    } catch (_) {}
  }

  void get _showError => app.showToast(
      alignment: Alignment.bottomCenter,
      toastType: HSToastType.error,
      title: "Error",
      description: "An error occured. Please try again later.");

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
