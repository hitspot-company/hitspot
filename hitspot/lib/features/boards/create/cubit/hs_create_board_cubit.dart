import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_toasts/hs_toasts.dart';
import 'package:image_cropper/image_cropper.dart';

part 'hs_create_board_state.dart';

class HSCreateBoardCubit extends Cubit<HSCreateBoardState> {
  HSCreateBoardCubit({this.prototype})
      : super(prototype != null
            ? HSCreateBoardState.update(prototype)
            : const HSCreateBoardState()) {
    if (prototype != null) {
      pageTitle = "Update: ${prototype!.title}";
    } else {
      pageTitle = "New Board";
    }
  }

  final PageController pageController = PageController();
  final HSBoard? prototype;
  late final String pageTitle;

  void updateTitle(String value) => emit(state.copyWith(title: value.trim()));
  void updateVisibility(HSBoardVisibility? value) =>
      emit(state.copyWith(boardVisibility: value));
  void updateDescription(String value) =>
      emit(state.copyWith(description: value.trim()));

  void nextPage() => pageController.nextPage(
      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);

  void prevPage() => pageController.previousPage(
      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);

  final HSDatabaseRepsitory _databaseRepository = app.databaseRepository;

  Future<bool> pickColor(bool value) async {
    if (!value) {
      emit(state.copyWith(color: Colors.transparent));
      return false;
    }
    final Color? pickedColor = await app.pickers.color(state.color);
    if (pickedColor == null) return false;
    emit(state.copyWith(color: pickedColor));
    return true;
  }

  Future<void> chooseImage(bool value) async {
    try {
      if (!value) {
        emit(state.copyWith(image: ""));
        return;
      }
      final CroppedFile? file = await app.pickers
          .image(cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9));
      if (file == null) return;
      emit(state.copyWith(image: file.path));
    } catch (e) {
      HSDebugLogger.logError(e.toString());
    }
  }

  Future<String> uploadFile(File imageFile, String uploadPath) async {
    try {
      final String url =
          await app.storageRepository.fileUploadAndFetchPublicUrl(
        file: imageFile,
        bucketName: app.storageRepository.boardsBucket,
        uploadPath: uploadPath,
      );
      return url;
    } catch (_) {
      HSDebugLogger.logError("$_");
      rethrow;
    }
  }

  Future<void> _createBoard() async {
    try {
      final HSBoard board = HSBoard(
        createdBy: currentUser.uid,
        color: state.color,
        description: state.description,
        title: state.title,
        visibility: state.boardVisibility,
        createdAt: DateTime.now(),
      );
      final String boardID =
          await _databaseRepository.boardCreate(board: board);
      if (state.image.isNotEmpty) {
        // Create thubmnail from iamge
        final File thumbnail =
            await FlutterNativeImage.compressImage(state.image, quality: 25);

        final String uploadedFileUrl = await uploadFile(
            File(state.image),
            app.storageRepository
                .boardImageUploadPath(uid: currentUser.uid!, boardID: boardID));

        final String uploadedThumbnailUrl = await uploadFile(thumbnail,
            "${app.storageRepository.boardImageUploadPath(uid: currentUser.uid!, boardID: boardID)}_thumbnail");

        HSDebugLogger.logInfo(
            "serializing board: ${board.copyWith(id: boardID, image: uploadedFileUrl).serialize()}");
        await _databaseRepository.boardUpdate(
            board: board.copyWith(
                id: boardID,
                image: uploadedFileUrl,
                thumbnail: uploadedThumbnailUrl));
      }
      navi.router.pushReplacement("/board/$boardID?title=${state.title}");
    } on HSBoardException catch (_) {
      HSDebugLogger.logError("Error creating board: $_");
      emit(state.copyWith(uploadState: HSCreateBoardUploadState.error));
      _showError;
    } catch (_) {
      HSDebugLogger.logError("Unknown error: $_");
      emit(state.copyWith(uploadState: HSCreateBoardUploadState.error));
      _showError;
    }
  }

  Future<void> _updateBoard() async {
    try {
      late final String? uploadedFileUrl;
      if (state.image != prototype?.image) {
        uploadedFileUrl = await uploadFile(File(state.image), prototype!.id!);
      } else {
        uploadedFileUrl = null;
      }
      final HSBoard board = prototype!.copyWith(
        color: state.color,
        description: state.description,
        title: state.title,
        visibility: state.boardVisibility,
        image: uploadedFileUrl,
      );
      await _databaseRepository.boardUpdate(board: board);
      navi.go("/user/${currentUser.uid}");
      navi.toBoard(boardID: board.id!, title: board.title!);
    } on HSBoardException catch (_) {
      HSDebugLogger.logError("Error creating board: ${_.message}");
      emit(state.copyWith(uploadState: HSCreateBoardUploadState.error));
      _showError;
    } catch (_) {
      HSDebugLogger.logError("Unknown error: $_");
      emit(state.copyWith(uploadState: HSCreateBoardUploadState.error));
      _showError;
    }
  }

  Future<void> submit() async {
    emit(state.copyWith(uploadState: HSCreateBoardUploadState.uploading));
    try {
      if (prototype == null) {
        await _createBoard();
      } else {
        await _updateBoard();
      }
    } on HSBoardException catch (_) {
    } catch (_) {
      HSDebugLogger.logError("Error submitting: $_");
    }
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
