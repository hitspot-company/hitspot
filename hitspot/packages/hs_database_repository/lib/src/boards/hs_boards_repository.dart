import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
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
  Future<List<HSBoard>> fetchUserBoards(
      HSUser? user, String? userID, int batchOffset, int batchSize) async {
    assert(user != null || userID != null, "User or userID must be provided");
    try {
      final uid = user?.uid ?? userID!;
      final List<Map<String, dynamic>> fetchedBoards =
          await _supabase.rpc("fetch_user_boards", params: {
        "user_id": uid,
        "batch_offset": batchOffset,
        "batch_size": batchSize,
      });
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

  // READ BOARD SPOTS
  Future<List<HSSpot>> fetchBoardSpots(HSBoard? board, String? boardID,
      [int batchSize = 20, int batchOffset = 0]) async {
    try {
      final bid = board?.id ?? boardID!;
      final List<Map<String, dynamic>> fetchedSpots = await _supabase
          .rpc('boards_fetch_board_spots', params: {
        'board_id_input': bid,
        "batch_size": batchSize,
        "batch_offset": batchOffset
      });
      HSDebugLogger.logSuccess("Fetched spots of board: $fetchedSpots");

      final List<HSSpot> spots = [];
      for (var spotData in fetchedSpots) {
        final spot = HSSpot.deserialize(spotData);
        spots.add(spot);
      }

      // Sort the list of spots by spot index
      spots.sort((a, b) => a.spotIndex ?? 0.compareTo(b.spotIndex ?? 0));

      // Spot index is no longer needed, proceed without it
      final List<HSSpot> sortedSpotsWithDetails = [];
      for (var spot in spots) {
        final detailedSpot = await HSDatabaseRepsitory(_supabase)
            .spotfetchSpotWithAuthor(spot: spot, spotID: spot.sid);
        sortedSpotsWithDetails.add(detailedSpot);
      }

      return sortedSpotsWithDetails;
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.read, details: _.toString());
    }
  }

  Future<List<HSUser>> fetchBoardCollaborators(HSBoard? board, String? boardID,
      [int batchSize = 20, int batchOffset = 0]) async {
    try {
      assert((board != null || boardID != null),
          "The board or the boardID has to be provided.");

      final bid = board?.id ?? boardID!;
      final List fetchedCollaborators = await _supabase
          .rpc('boards_fetch_board_collaborators', params: {
        'requested_board_id': bid,
        "batch_size": batchSize,
        "batch_offset": batchOffset
      });

      HSDebugLogger.logSuccess(
          "Fetched collaborators of board: $fetchedCollaborators");

      final deserializedFetchedCollaborators =
          fetchedCollaborators.map((user) => HSUser.deserialize(user)).toList();
      board?.copyWith(collaborators: deserializedFetchedCollaborators);

      return deserializedFetchedCollaborators;
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.read, details: _.toString());
    }
  }

  Future<List<HSUser>> fetchBoardCollaborators(HSBoard? board, String? boardID,
      [int batchSize = 20, int batchOffset = 0]) async {
    try {
      assert((board != null || boardID != null),
          "The board or the boardID has to be provided.");

      final bid = board?.id ?? boardID!;
      final List fetchedCollaborators = await _supabase
          .rpc('boards_fetch_board_collaborators', params: {
        'requested_board_id': bid,
        "batch_size": batchSize,
        "batch_offset": batchOffset
      });

      HSDebugLogger.logSuccess(
          "Fetched collaborators of board: $fetchedCollaborators");

      final deserializedFetchedCollaborators =
          fetchedCollaborators.map((user) => HSUser.deserialize(user)).toList();
      board?.copyWith(collaborators: deserializedFetchedCollaborators);

      return deserializedFetchedCollaborators;
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.read, details: _.toString());
    }
  }

  Future<void> addSpot(HSBoard? board, String? boardID, HSSpot? spot,
      String? spotID, HSUser? addedBy, String? addedByID) async {
    try {
      assert(board != null || boardID != null,
          "Board or boardID must be provided");
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      assert(addedBy != null || addedByID != null,
          "AddedBy or addedByID must be provided");
      final bid = board?.id ?? boardID!;
      final sid = spot?.sid ?? spotID!;
      final uid = addedBy?.uid ?? addedByID!;
      await _supabase.rpc('boards_add_spot_to_board', params: {
        "board_id_input": bid,
        "spot_id_input": sid,
        "added_by_input": uid,
      });
    } catch (_) {
      throw Exception("Error adding spot: $_");
    }
  }

  Future<void> removeSpot(
      HSBoard? board, String? boardID, HSSpot? spot, String? spotID) async {
    try {
      assert(board != null || boardID != null,
          "Board or boardID must be provided");
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final bid = board?.id ?? boardID!;
      final sid = spot?.sid ?? spotID!;
      await _supabase.rpc('boards_delete_spot_from_board', params: {
        "board_id_input": bid,
        "spot_id_input": sid,
      });
    } catch (_) {
      throw Exception("Error adding spot: $_");
    }
  }

  Future<List<HSUser>> fetchCollaborators(
      HSBoard? board, String? boardID, int? batchOffset, int? batchSize) async {
    final bid = board?.id ?? boardID;
    try {
      assert(board != null || boardID != null,
          "Either the board or the boardID has to be provided.");
      final List<Map<String, dynamic>> fetchedCollaborators =
          await _supabase.rpc('boards_fetch_board_collaborators', params: {
        "requested_board_id": bid,
        "batch_offset": batchOffset,
        "batch_size": batchSize,
      });
      return fetchedCollaborators.map(HSUser.deserialize).toList();
    } catch (_) {
      HSDebugLogger.logError("Failed to fetch board: ($bid) collaborators: $_");
      throw Exception("Failed to fetch board: ($bid) collaborators");
    }
  }

  Future<void> updateSpotIndex(HSBoard? board, String? boardID, HSSpot? spot,
      String? spotID, int newIndex) async {
    try {
      assert(board != null || boardID != null,
          "Board or boardID must be provided");

      assert(spot != null || spotID != null, "Spot or spotID must be provided");

      await _supabase.rpc('boards_update_spot_index', params: {
        "board_id_input": board?.id ?? boardID!,
        "spot_id_input": spot?.sid ?? spotID!,
        "new_index_input": newIndex,
      });
    } catch (_) {
      throw Exception("Error updating spots: $_");
    }
  }
}

enum HSBoardSaveState { saved, updating, notSaved }
