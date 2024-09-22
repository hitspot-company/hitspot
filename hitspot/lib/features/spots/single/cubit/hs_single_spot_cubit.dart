import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/spot/hs_spot_bottom_sheet.dart';
import 'package:hitspot/widgets/hs_adaptive_dialog.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

part 'hs_single_spot_state.dart';

class HSSingleSpotCubit extends Cubit<HSSingleSpotState> {
  HSSingleSpotCubit({required this.spotID}) : super(const HSSingleSpotState()) {
    fetchSpot();
  }

  final _databaseRepository = app.databaseRepository;
  final String spotID;

  LatLng? get spotLocation =>
      state.spot.latitude == null || state.spot.longitude == null
          ? null
          : LatLng(state.spot.latitude!, state.spot.longitude!);

  Future<void> fetchSpot() async {
    try {
      HSSpot spot =
          await _databaseRepository.spotfetchSpotWithAuthor(spotID: spotID);
      final bool isSpotLiked = await _databaseRepository.spotIsSpotLiked(
          spotID: spotID, userID: currentUser.uid);
      final bool isSpotSaved = await _databaseRepository.spotIsSaved(
          spotID: spotID, userID: currentUser.uid);
      final bool isAuthor =
          spot.createdBy == currentUser.uid && currentUser.uid != null;
      final List<HSTag> tags =
          await _databaseRepository.tagFetchSpotTags(spotID: spotID);
      emit(state.copyWith(
        spot: spot,
        isSpotLiked: isSpotLiked,
        isSpotSaved: isSpotSaved,
        isAuthor: isAuthor,
        tags: tags,
        status: HSSingleSpotStatus.loaded,
      ));
      HSDebugLogger.logInfo(spot.images.toString());
    } catch (_) {
      HSDebugLogger.logError("Error fetching spot: $_");
      navi.toError(
          title: "Error fetching spot",
          message: "Could not fetch spot. Please try again later.");
    }
  }

  Future<void> likeDislikeSpot() async {
    try {
      final bool isSpotLiked = await _databaseRepository.spotLikeDislike(
          spot: state.spot, userID: currentUser.uid);
      final newLikesCount =
          isSpotLiked ? state.spot.likesCount! + 1 : state.spot.likesCount! - 1;
      final HSSpot spot = state.spot.copyWith(likesCount: newLikesCount);
      emit(state.copyWith(
          isSpotLiked: isSpotLiked,
          status: HSSingleSpotStatus.loaded,
          spot: spot));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> saveUnsaveSpot() async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.saving));
      final bool isSpotSaved = await _databaseRepository.spotSaveUnsave(
          spotID: spotID, userID: currentUser.uid);
      final newSavesCount =
          isSpotSaved ? state.spot.savesCount! + 1 : state.spot.savesCount! - 1;
      final HSSpot spot = state.spot.copyWith(savesCount: newSavesCount);
      emit(state.copyWith(
          isSpotSaved: isSpotSaved,
          status: HSSingleSpotStatus.loaded,
          spot: spot));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<List<HSBoard>> fetchUserBoards() async {
    try {
      return await _databaseRepository.boardFetchUserBoards(
          user: currentUser, userID: currentUser.uid);
    } catch (e) {
      HSDebugLogger.logError(e.toString());
      return [];
    }
  }

  Future<void> saveOnLongPress() async {
    final List<HSBoard> boards = await fetchUserBoards();
    await _addToBoardPrompt(boards);
  }

  Future<void> _addToBoard(HSBoard board) async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.addingToBoard));
      bool result = await _databaseRepository.boardAddSpot(
          board: board, spot: state.spot, addedBy: currentUser);
      emit(state.copyWith(status: HSSingleSpotStatus.loaded));
      if (result) {
        app.showToast(
            toastType: HSToastType.success,
            title: "Spot added.",
            description: "Spot added to board ${board.title}");
      } else {
        app.showToast(
            toastType: HSToastType.error,
            title: "Error",
            description: "Board ${board.title} already contains this spot!");
      }
      navi.pop();
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> _addToBoardPrompt(List<HSBoard> boards) async {
    try {
      await showCupertinoModalBottomSheet(
          context: app.context,
          duration: const Duration(milliseconds: 200),
          builder: (context) => HSSpotAddToBoardSheet(
              spot: state.spot, boards: boards, addToBoard: _addToBoard));
    } catch (e) {
      HSDebugLogger.logError(e.toString());
    }
  }

  Future<void> showBottomSheet() async {
    return showCupertinoModalBottomSheet(
      context: app.context,
      builder: (context) => HSSpotBottomSheet(
          isAuthor: state.isAuthor,
          spot: state.spot,
          addToBoard: () async {
            final List<HSBoard> boards = await fetchUserBoards();
            await _addToBoardPrompt(boards);
          },
          shareSpot: shareSpot,
          deleteSpot: _deleteSpot),
    );
  }

  Future<void> shareSpot() async {
    try {
      await Share.share("https://hitspot.app/spot/${state.spot.sid}",
          subject:
              "Check out this spot: ${state.spot.title} by ${state.spot.author!.username}");
    } catch (_) {
      HSDebugLogger.logError("Could not share spot: $_");
    }
  }

  Future<void> _deleteSpot() async {
    try {
      final bool? isDelete = await showAdaptiveDialog(
        context: app.context,
        builder: (context) => const HSAdaptiveDialog(
          title: "Delete Spot",
          content: "This spot will be deleted permanently.",
        ),
      );
      if (isDelete == true) {
        HSDebugLogger.logSuccess("Delete");
        emit(state.copyWith(status: HSSingleSpotStatus.deleting));
        await _databaseRepository.spotDelete(spot: state.spot);
        HSDebugLogger.logSuccess("Spot deleted successfully");
        navi.router.go('/');
        return;
      } else {
        HSDebugLogger.logError("Cancelled");
      }
    } catch (e) {
      HSDebugLogger.logError(e.toString());
    }
  }

  Future<void> refresh() async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.loading));
      await fetchSpot();
    } catch (e) {
      HSDebugLogger.logError("Error refreshing spot: $e");
      rethrow;
    }
  }
}
