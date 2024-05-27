import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_board_event.dart';
part 'hs_board_state.dart';

class HSBoardBloc extends Bloc<HSBoardEvent, HSBoardState> {
  HSBoardBloc({required this.boardID}) : super(HSBoardInitialState()) {
    on<HSBoardInitialEvent>(_fetchInitialData);
    on<HSBoardSaveUnsaveEvent>(_saveUnsaveBoard);
  }

  final HSDatabaseRepository _databaseRepository = app.databaseRepository;

  final String boardID;
  Future<void> _fetchInitialData(event, emit) async {
    try {
      final HSBoard board = await _databaseRepository.getBoard(boardID);
      HSDebugLogger.logInfo("Author ID: ${board.authorID}");
      final HSUser? author =
          await _databaseRepository.getUserFromDatabase(board.authorID!);
      if (author == null) throw "The author could not be fetched";
      emit(HSBoardReadyState(
          author: author,
          board: board,
          boardSaveState: board.isSaved(currentUser)
              ? HSBoardSaveState.saved
              : HSBoardSaveState.unsaved));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(const HSBoardErrorState("An error occured"));
    }
  }

  Future<List> _fetchSpots(event, emit) async {
    try {
      // await _databaseRepository.
      return [];
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(const HSBoardErrorState(
          "Could not get spots. Please try again later."));
      return [];
    }
  }

  Future<void> _saveUnsaveBoard(event, emit) async {
    try {
      if (state is! HSBoardReadyState) return;
      final currentState = state as HSBoardReadyState;
      emit(HSBoardReadyState(
          boardSaveState: HSBoardSaveState.updating,
          author: currentState.author,
          board: currentState.board));
      final bool isSaved = currentState.board.isSaved(currentUser);
      final List saves = currentState.board.saves ?? [];
      if (!isSaved) {
        await _saveAndEmit(currentState, saves, event, emit);
      } else {
        await _unsaveAndEmit(currentState, saves, event, emit);
      }
    } on DatabaseConnectionFailure catch (_) {
      HSDebugLogger.logError(_.message);
    } catch (_) {
      HSDebugLogger.logError("An error occured: $_");
    }
  }

  Future<void> _saveAndEmit(
      HSBoardReadyState currentState, List saves, event, emit) async {
    try {
      await _databaseRepository.saveBoard(
          board: currentState.board, user: currentUser);
      saves.add(currentUser.uid);
      HSDebugLogger.logSuccess("The board has been saved");
      emit(HSBoardReadyState(
          boardSaveState: HSBoardSaveState.saved,
          author: currentState.author,
          board: currentState.board.copyWith(saves: saves)));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _unsaveAndEmit(
      HSBoardReadyState currentState, List saves, event, emit) async {
    try {
      await _databaseRepository.unsaveBoard(
          board: currentState.board, user: currentUser);
      saves.remove(currentUser.uid);
      HSDebugLogger.logSuccess("The board has been unsaved");
      emit(HSBoardReadyState(
          boardSaveState: HSBoardSaveState.unsaved,
          author: currentState.author,
          board: currentState.board.copyWith(saves: saves)));
    } catch (_) {
      rethrow;
    }
  }

  void saveUnsaveBoard() => add(HSBoardSaveUnsaveEvent());
}
