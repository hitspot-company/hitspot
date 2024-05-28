import 'package:auto_size_text/auto_size_text.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/single_board/view/board_page.dart';
import 'package:hitspot/features/boards/single_board/view/board_provider.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

part 'hs_board_event.dart';
part 'hs_board_state.dart';

class HSBoardBloc extends Bloc<HSBoardEvent, HSBoardState> {
  HSBoardBloc({required this.boardID}) : super(HSBoardInitialState()) {
    on<HSBoardInitialEvent>(_fetchInitialData);
    on<HSBoardSaveUnsaveEvent>(_saveUnsaveBoard);
    on<HSBoardDeleteBoardEvent>(_deleteBoard);
  }

  final HSDatabaseRepository _databaseRepository = app.databaseRepository;

  final String boardID;
  Future<void> _fetchInitialData(event, emit) async {
    try {
      final HSBoard board = await _databaseRepository.getBoard(boardID);
      final HSUser? author =
          await _databaseRepository.getUserFromDatabase(board.authorID!);
      if (author == null) throw "The author could not be fetched";
      emit(HSBoardReadyState(
          author: author,
          board: board,
          boardSaveState: board.isSaved(currentUser)
              ? HSBoardSaveState.saved
              : HSBoardSaveState.unsaved));
    } on DatabaseConnectionFailure catch (_) {
      navi.toError("404: Not Found", _.message);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      emit(const HSBoardErrorState("An error occured"));
      navi.toError("404: Not Found", _.toString());
    }
  }

  Future<List> _fetchSpots(event, emit) async {
    try {
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

  void showModalSheet() => showMaterialModalBottomSheet(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        context: app.context!,
        builder: (context) => HSBoardModalBottonSheet(
          items: [
            ModalBottomSheetItem(
              text: "Delete",
              icon: const Icon(FontAwesomeIcons.trash),
              onPressed: _showDeleteConfirmationDialog,
            ),
          ],
        ),
      );

  Future<void> _showDeleteConfirmationDialog() {
    final HSBoard board = (state as HSBoardReadyState).board;
    return showDialog<bool>(
      context: app.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(14.0)),
          title: const Text('Confirm Deletion'),
          content: Text.rich(
            TextSpan(
              text: "Are you sure you want to delete the ",
              children: [
                TextSpan(
                  text: board.title,
                  style: TextStyle(color: currentTheme.mainColor).boldify,
                ),
                const TextSpan(text: " board?"),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed No
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => add(HSBoardDeleteBoardEvent()),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBoard(event, emit) async {
    try {
      final HSBoard board = (state as HSBoardReadyState).board;
      navi.pop();
      navi.pop();
      ScaffoldMessenger.of(app.context!).clearSnackBars();
      emit(HSBoardInitialState());
      await Future.delayed(const Duration(seconds: 1));
      await _databaseRepository.deleteBoard(board: board);
      navi.router.go("/");
    } catch (_) {
      HSDebugLogger.logError("Error deleting board: $_");
      emit(const HSBoardErrorState("Error deleting board"));
    }
  }

  Future<void> share() async {
    const website = "https://hitspot.app";
    const path = "/board";
    final subpath = "/$boardID";
    final url = "$website$path$subpath";
    try {
      if (state is! HSBoardReadyState) {
        throw "Wrong state";
      }
      final HSUser author = (state as HSBoardReadyState).author;
      final HSBoard board = (state as HSBoardReadyState).board;
      await Share.share("""
Check out the awesome ${board.title} board!📍
by @${author.username}
$url
""");
    } catch (_) {
      HSDebugLogger.logError("Error sharing board: $_");
    }
  }

  void saveUnsaveBoard() => add(HSBoardSaveUnsaveEvent());
}
