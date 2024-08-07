import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/notifications/hs_notifications_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class HSBoardsRepository {
  const HSBoardsRepository(
      this._supabase, this._boards, this._notificationsRepository);

  final SupabaseClient _supabase;
  final String _boards;
  final String _boardsSaves = "boards_saves";
  final HSNotificationsRepository _notificationsRepository;

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
      final bool is_saved = await _supabase
          .rpc("board_is_saved", params: {'p_user_id': uid, 'p_board_id': bid});
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
      await _supabase.rpc('board_save_unsave', params: {
        "p_user_id": uid,
        "p_board_id": bid,
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
      final bool result = await _supabase.rpc('board_is_editor',
          params: {"p_board_id": bid, "p_user_id": uid});
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
          await _supabase.rpc("board_fetch_user_boards", params: {
        "p_user_id": uid,
        "p_batch_offset": batchOffset,
        "p_batch_size": batchSize,
      });
      return fetchedBoards.map(HSBoard.deserialize).toList();
    } catch (_) {
      throw HSBoardException(
          type: HSBoardExceptionType.read, details: _.toString());
    }
  }

  // READ TRENDING BOARDS
  Future<List<HSBoard>> fetchTrendingBoards(
      [int batchOffset = 0, int batchSize = 10]) async {
    try {
      final List<Map<String, dynamic>> fetchedBoards = await _supabase.rpc(
          'board_fetch_trending',
          params: {'p_batch_offset': batchOffset, 'p_batch_size': batchSize});
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
          .rpc('board_fetch_spots', params: {
        'p_board_id': bid,
        "p_batch_size": batchSize,
        "p_batch_offset": batchOffset
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
          .rpc('board_fetch_collaborators', params: {
        'p_board_id': bid,
        "p_batch_size": batchSize,
        "p_batch_offset": batchOffset
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
      await _supabase.rpc('board_add_spot', params: {
        "p_board_id": bid,
        "p_spot_id": sid,
        "p_added_by": uid,
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
      await _supabase.rpc('board_delete_spot', params: {
        "p_board_id": bid,
        "p_spot_id": sid,
      });
    } catch (_) {
      throw Exception("Error removing spot from board: $_");
    }
  }

  Future<void> updateSpotIndex(HSBoard? board, String? boardID, HSSpot? spot,
      String? spotID, int newIndex) async {
    try {
      assert(board != null || boardID != null,
          "Board or boardID must be provided");

      assert(spot != null || spotID != null, "Spot or spotID must be provided");

      await _supabase.rpc('board_update_spot_index', params: {
        "p_board_id": board?.id ?? boardID!,
        "p_spot_id": spot?.sid ?? spotID!,
        "p_new_spot_index": newIndex,
      });
    } catch (_) {
      throw Exception("Error updating spots: $_");
    }
  }

  Future<String> generateBoardInvitation(String boardId) async {
    try {
      // TODO: Talk with Kuba about it
      late String token;
      bool isUnique = false;

      // Generate a unique token and ensure it's not already in the database
      while (!isUnique) {
        token = Uuid().v4();

        final existingInvitation = await _supabase
            .from('board_invitations')
            .select()
            .eq('token', token)
            .maybeSingle();

        if (existingInvitation == null) {
          isUnique = true;
        }
      }

      // Store the invitation details
      await _supabase.from('board_invitations').insert({
        'board_id': boardId,
        'token': token,
        'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      });

      // Generate the magic link
      final magicLink = 'app.hitspot://invite/$boardId?token=$token';

      HSDebugLogger.logSuccess('Generated new invitation: $magicLink');
      return magicLink;
    } catch (error) {
      HSDebugLogger.logError('Error generating invitation: $error');
      throw error;
    }
  }

  Future<bool> checkIfInvitationIsValid(
      String boardId, String token, String userId) async {
    try {
      return await _supabase.rpc('check_board_invitation', params: {
        'input_board_id': boardId,
        'input_token': token,
        'input_user_id': userId
      });
    } catch (error) {
      HSDebugLogger.logError('Error checking invitation: $error');
      return false;
    }
  }

  Future<void> addCollaborator(String boardId, String userId) async {
    try {
      // Add the user to the board collaborators
      final response = await _supabase
          .from('boards_permissions')
          .update({
            'permission_level': 'editor',
          })
          .eq('user_id', userId)
          .eq('board_id', boardId);

      HSDebugLogger.logInfo("Adding collaborator: $response");

      // TODO: Mark the invitation as used or delete it or decrement invitation count
    } catch (error) {
      HSDebugLogger.logError('Error adding collaborator: $error');
    }
  }

  Future<void> removeCollaborator(String boardId, String userId) async {
    try {
      await _supabase
          .from('boards_permissions')
          .delete()
          .match({'board_id': boardId, 'user_id': userId});
    } catch (error) {
      HSDebugLogger.logError('Error removing collaborator: $error');
    }
  }

  Future<void> addPotentialCollaboratorAsInvited(
      String boardId, String userId) async {
    try {
      // Check if the entry already exists
      final existingEntry = await _supabase
          .from('boards_permissions')
          .select()
          .eq('user_id', userId)
          .eq('board_id', boardId)
          .maybeSingle();

      if (existingEntry == null) {
        // Insert the new entry if it doesn't exist
        await _supabase.from('boards_permissions').insert({
          'user_id': userId,
          'board_id': boardId,
          'permission_level': 'invited',
        });
      } else {
        HSDebugLogger.logInfo(
            'Entry already exists in board_permissions for user $userId and board $boardId');
      }
    } catch (error) {
      HSDebugLogger.logError('Error adding potential collaborator: $error');
    }
  }

  Future<void> removePotentialCollaboratorFromInvited(
      String boardId, String userId) async {
    try {
      final response = await _supabase
          .from('boards_permissions')
          .delete()
          .eq('user_id', userId)
          .eq('board_id', boardId);
    } catch (error) {
      HSDebugLogger.logError('Error adding potential collaborator: $error');
    }
  }

  Future<HSBoard?> fetchBoardForInvitation(String boardId) async {
    try {
      final board = await _supabase.rpc('board_fetch_invitation_details',
          params: {'p_board_id': boardId});

      HSDebugLogger.logSuccess('Fetched board for invitation: $board');

      return HSBoard(
          id: boardId,
          createdBy: board.first['created_by'],
          image: board.first['image'],
          title: board.first['title']);
    } catch (error) {
      HSDebugLogger.logError('Error fetching board for invitation: $error');
      return null;
    }
  }
}

enum HSBoardSaveState { saved, updating, notSaved }
