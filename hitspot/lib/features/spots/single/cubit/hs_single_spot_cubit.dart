import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/spot/hs_spot_bottom_sheet.dart';
import 'package:hitspot/widgets/spot/hs_spot_delete_dialog.dart';
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
    } catch (_) {
      HSDebugLogger.logError("Error fetching spot: $_");
      emit(state.copyWith(status: HSSingleSpotStatus.error));
    }
  }

  Future<void> likeDislikeSpot() async {
    try {
      final bool isSpotLiked = await _databaseRepository.spotLikeDislike(
          spot: state.spot, userID: currentUser.uid);
      emit(state.copyWith(
          isSpotLiked: isSpotLiked, status: HSSingleSpotStatus.loaded));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> saveUnsaveSpot() async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.saving));
      final bool isSpotSaved = await _databaseRepository.spotSaveUnsave(
          spotID: spotID, userID: currentUser.uid);
      emit(state.copyWith(
          isSpotSaved: isSpotSaved, status: HSSingleSpotStatus.loaded));
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

  Future<void> _addToBoard(HSBoard board) async {
    try {
      emit(state.copyWith(status: HSSingleSpotStatus.addingToBoard));
      await _databaseRepository.boardAddSpot(
          board: board, spot: state.spot, addedBy: currentUser);
      emit(state.copyWith(status: HSSingleSpotStatus.loaded));
      app.showToast(
          toastType: HSToastType.success,
          title: "Spot added.",
          description: "Spot added to board ${board.title}");
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
        builder: (context) => const HSSpotDeleteDialog(),
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
}
