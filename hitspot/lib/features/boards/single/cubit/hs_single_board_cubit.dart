import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:share_plus/share_plus.dart';

part 'hs_single_board_state.dart';

class HSSingleBoardCubit extends Cubit<HSSingleBoardState> {
  HSSingleBoardCubit({required this.title, required this.boardID})
      : super(const HSSingleBoardState()) {
    _fetchInitial();
  }

  final String boardID;
  final String title;

  Future<void> _fetchInitial() async {
    try {
      emit(state.copyWith(status: HSSingleBoardStatus.loading));

      final HSBoard board =
          await app.databaseRepository.boardRead(boardID: boardID);

      final HSUser author =
          await app.databaseRepository.userRead(userID: board.createdBy);
      final collaborators = await app.databaseRepository
          .boardFetchBoardCollaborators(board: board, boardID: boardID);
      board.collaborators = collaborators;

      final bool isBoardSaved = await app.databaseRepository
          .boardIsBoardSaved(boardID: boardID, user: currentUser);

      final bool isEditor = await app.databaseRepository
          .boardIsEditor(boardID: boardID, user: currentUser);

      final bool isOwner = board.createdBy == currentUser.uid;

      final List<HSSpot> spots =
          await app.databaseRepository.boardFetchBoardSpots(boardID: boardID);

      emit(state.copyWith(
          status: HSSingleBoardStatus.idle,
          board: board.copyWith(collaborators: collaborators),
          spots: spots,
          author: author,
          isBoardSaved: isBoardSaved,
          isEditor: isEditor,
          isOwner: isOwner));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(state.copyWith(status: HSSingleBoardStatus.error));
    }
  }

  Future<void> saveUnsave() async {
    try {
      emit(state.copyWith(status: HSSingleBoardStatus.updating));
      final bool isBoardSaved = await app.databaseRepository
          .boardSaveUnsave(boardID: boardID, user: currentUser);
      emit(state.copyWith(
          status: HSSingleBoardStatus.idle, isBoardSaved: isBoardSaved));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> _removeSpotFromBoard(HSSpot spot) async {
    try {
      emit(state.copyWith(status: HSSingleBoardStatus.updating));
      await app.databaseRepository
          .boardRemoveSpot(boardID: boardID, spotID: spot.sid);
      state.spots.remove(spot);
      emit(state.copyWith(
        status: HSSingleBoardStatus.idle,
        spots: state.spots,
        board: state.board!,
      ));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> reorderSpots(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final spots = state.spots;
      final HSSpot spot = spots.removeAt(oldIndex);
      spots.insert(newIndex, spot);
      for (var element in spots) {
        await app.databaseRepository.boardUpdateSpotIndex(
            boardID: boardID,
            spotID: element.sid!,
            newIndex: spots.indexOf(element));
      }
      emit(state.copyWith(spots: spots));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }

  Future<void> shareInvitation(String? boardId) async {
    try {
      assert(boardId != null, 'Board ID cannot be null');

      final magicLink = await app.databaseRepository
          .boardGenerateBoardInvitation(boardId: boardId!);

      final String shareText =
          'Join our board collaboration! Click this link to accept the invitation: $magicLink';

      await Share.share(shareText, subject: 'Board Collaboration Invitation');
    } catch (error) {
      HSDebugLogger.logError('Error sharing invitation: $error');
    }
  }

  Future<void> removeCollaborator(String? boardId, String? userId) async {
    try {
      assert(userId != null, 'User ID cannot be null');

      emit(state.copyWith(status: HSSingleBoardStatus.updating));

      await app.databaseRepository
          .boardRemoveCollaborator(boardId: boardID, userId: userId!);

      state.board!.collaborators!
          .removeWhere((collaborator) => collaborator.uid == userId);

      emit(state.copyWith(
        status: HSSingleBoardStatus.idle,
        board: state.board!,
      ));
    } catch (error) {
      HSDebugLogger.logError('Error removing collaborator: $error');
    }
  }

  void toggleEditMode() =>
      emit(state.copyWith(status: HSSingleBoardStatus.editing));

  void exitEditMode() {
    HSDebugLogger.logInfo('Exiting edit mode');
    emit(state.copyWith(status: HSSingleBoardStatus.idle));
  }

  void removeSpot(int index) {
    _removeSpotFromBoard(state.spots[index]);
  }
}
