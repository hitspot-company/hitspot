import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

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
      final bool isBoardSaved = await app.databaseRepository
          .boardIsBoardSaved(boardID: boardID, user: currentUser);
      final bool isEditor = await app.databaseRepository
          .boardIsEditor(boardID: boardID, user: currentUser);
      emit(state.copyWith(
          status: HSSingleBoardStatus.idle,
          board: board,
          author: author,
          isBoardSaved: isBoardSaved,
          isEditor: isEditor));
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
}
