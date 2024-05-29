import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

  final HSDatabaseRepository _databaseRepository = app.databaseRepository;

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
      navi.toBoard(boardID);
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
      navi.toBoard(board.bid!);
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
