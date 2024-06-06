import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/boards/hs_board.dart';
import 'package:hs_database_repository/src/boards/hs_board_exception.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSBoardsRepository {
  const HSBoardsRepository(this._supabase, this._boards);

  final SupabaseClient _supabase;
  final String _boards;

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
      HSDebugLogger.logSuccess("Board (${board.id}) data updated!");
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

  // READ ALL USER BOARDS
  Future<List<HSBoard>> fetchUserBoards(HSUser? user, String? userID) async {
    assert(user != null || userID != null, "User or userID must be provided");
    try {
      final fetchedBoards = await _supabase
          .from(_boards)
          .select()
          .eq("created_by", user?.uid ?? userID!);
      // TODO: Implement visibility filtering
      // TODO: Implement pagination
      return fetchedBoards.map((e) => HSBoard.deserialize(e)).toList();
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.read, details: _.toString());
    }
  }
}
