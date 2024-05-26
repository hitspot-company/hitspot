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
      emit(HSBoardReadyState(author: author, board: board));
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
}
