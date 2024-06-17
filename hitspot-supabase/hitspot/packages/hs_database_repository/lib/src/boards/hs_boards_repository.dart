import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/boards/hs_board.dart';
import 'package:hs_database_repository/src/boards/hs_board_exception.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSBoardsRepository {
  const HSBoardsRepository(this._supabase, this._boards);

  final SupabaseClient _supabase;
  final String _boards;
  final String _boardsSaves = "boards_saves";

  // CREATE
  Future<String> create(HSBoard board) async {
    try {
      HSDebugLogger.logInfo("Creating board: ${board.serialize()}");
      final insertedBoard =
          await _supabase.from(_boards).insert(board.serialize()).select();
      HSDebugLogger.logSuccess("Board created: ${insertedBoard.isNotEmpty}");
      return insertedBoard.first['id'];
    } catch (_) {
      throw HSBoardException.create(details: _.toString());
    }
  }

  // READ
  Future<HSBoard> read(HSBoard? board, String? boardID) async {
    assert(
        board != null || boardID != null, "Board or boardID must be provided");
    try {
      final fetchedBoard = await _supabase
          .from(_boards)
          .select()
          .eq("id", board?.id ?? boardID!);
      if (fetchedBoard.isEmpty)
        throw HSBoardException(type: HSBoardExceptionType.notFound);
      HSDebugLogger.logInfo("Fetched: ${fetchedBoard.toString()}");
      return HSBoard.deserialize(fetchedBoard.first);
    } on HSBoardException catch (_) {
      rethrow;
    } catch (_) {
      throw HSBoardException(details: _.toString());
    }
  }

  // UPDATE
  Future<void> update(HSBoard board) async {
    try {
      await _supabase
          .from(_boards)
          .update(board.serialize())
          .eq("id", board.id!);
      HSDebugLogger.logSuccess(
          "Board (${board.id}) data updated with image: (${board.image})!");
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.update, details: _.toString());
    }
  }

  // DELETE
  Future<void> delete(HSBoard board) async {
    try {
      await _supabase.from(_boards).delete().eq("id", board.id!);
      HSDebugLogger.logSuccess("Board (${board.id}) deleted!");
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.delete, details: _.toString());
    }
  }

  Future<List<HSBoard>> fetchSavedBoards(HSUser? user, String? userID) async {
    assert(user != null || userID != null, "User or userID must be provided");
    final uid = user?.uid ?? userID!;
    try {
      final fetchedBoards = await _supabase
          .from(_boards)
          .select('*, boards_saves!inner(board_id, user_id)')
          .eq("boards_saves.user_id", uid)
          .range(0, 10);
      return fetchedBoards.map((e) => HSBoard.deserialize(e)).toList();
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.read, details: _.toString());
    }
  }

  Future<bool> isBoardSaved(
      HSBoard? board, String? boardID, HSUser? user, String? userID) async {
    try {
      assert((board != null || boardID != null),
          "Either board or boardID has to be provided.");
      assert((user != null || userID != null),
          "Either user or userID has to be provided.");

      final uid = user?.uid ?? userID;
      final bid = board?.id ?? boardID;
      final bool is_saved = await _supabase.rpc("boards_is_board_saved",
          params: {'saved_by_id': uid, 'saved_board_id': bid});
      return is_saved;
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw HSBoardException(
        type: HSBoardExceptionType.read,
        details: _.toString(),
      );
    }
  }

  /// Saves or unsaves the board depending on the current state.

  Future<bool> saveUnsave(
    HSBoard? board,
    String? boardID,
    HSUser? user,
    String? userID,
  ) async {
    try {
      assert((board != null || boardID != null),
          "The board or the boardID has to be provided.");
      assert((user != null || userID != null),
          "The user or the userID has to be provided.");
      final bool isFollowed = await isBoardSaved(board, boardID, user, userID);
      final uid = user?.uid ?? userID;
      final bid = board?.id ?? boardID;
      await _supabase.rpc('boards_save_unsave_board', params: {
        "saved_board_id": bid,
        "saved_by_id": uid,
      });
      return !isFollowed;
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw HSBoardException(
        type: HSBoardExceptionType.update,
        message: "The board could not be saved / unsaved",
        details: _.toString(),
      );
    }
  }

  Future<bool> isEditor(
    HSBoard? board,
    String? boardID,
    HSUser? user,
    String? userID,
  ) async {
    try {
      assert((board != null || boardID != null),
          "The board or the boardID has to be provided.");
      assert((user != null || userID != null),
          "The user or the userID has to be provided.");
      final uid = user?.uid ?? userID;
      final bid = board?.id ?? boardID;
      final bool result = await _supabase.rpc('boards_is_editor',
          params: {"selected_board_id": bid, "selected_user_id": uid});
      return (result);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw HSBoardException(
        type: HSBoardExceptionType.update,
        message: "The board could determine ownership of the board.",
        details: _.toString(),
      );
    }
  }

  // READ ALL USER BOARDS
  Future<List<HSBoard>> fetchUserBoards(HSUser? user, String? userID) async {
    assert(user != null || userID != null, "User or userID must be provided");
    try {
      final fetchedBoards = await _supabase
          .from(_boards)
          .select()
          .eq("created_by", user?.uid ?? userID!)
          .range(0, 10);
      return fetchedBoards.map((e) => HSBoard.deserialize(e)).toList();
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.read, details: _.toString());
    }
  }

  // READ TRENDING BOARDS
  Future<List<HSBoard>> fetchTrendingBoards() async {
    try {
      final fetchedBoards = await _supabase.from(_boards).select().range(0, 16);
      return fetchedBoards.map(HSBoard.deserialize).toList();
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.read,
          message: "Failed fetching trending boards.",
          details: _.toString());
    }
  }
}

enum HSBoardSaveState { saved, updating, notSaved }
