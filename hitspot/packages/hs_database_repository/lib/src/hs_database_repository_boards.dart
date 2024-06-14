import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/exceptions/database_connection_failure.dart';

class HSBoardsRepository {
  const HSBoardsRepository(this._boards, this._users);
  final CollectionReference _boards;
  final CollectionReference _users;

  Future<void> deleteBoard({required HSBoard board}) async {
    try {
      // 1. Remove board from boards collection
      await _boards.doc(board.bid).delete();
      // 2. Remove board from authors profile
      await _users.doc(board.authorID).update({
        "boards": FieldValue.arrayRemove([board.bid])
      });
      // 3. Remove board from editors' profiles
      final List? editors = board.editors;
      if (editors != null) {
        for (var i = 0; i < editors.length; i++) {
          final String uid = editors[i];
          await _users.doc(uid).update({
            "boards": FieldValue.arrayRemove([board.bid])
          });
        }
      }
      // 4. If the board had an image, remove the image
      if (board.image != null) {
        final Reference imageRef =
            FirebaseStorage.instance.refFromURL(board.image!);
        await imageRef.delete();
      }
      // 5. Remove from saved
      final List? saves = board.saves;
      if (saves != null) {
        for (var i = 0; i < saves.length; i++) {
          final String uid = saves[i];
          await _users.doc(uid).update({
            "saves": FieldValue.arrayRemove([board.bid])
          });
        }
      }
    } catch (_) {
      throw DatabaseConnectionFailure("Could not delete board: ${board.bid}");
    }
  }

  bool hasAccess(HSUser user, HSBoard board) {
    try {
      return board.authorID == user.uid ||
          (board.editors != null && board.editors!.contains(user.uid));
    } catch (_) {
      throw const DatabaseConnectionFailure();
    }
  }

  bool isSaved({required HSUser user, required HSBoard board}) {
    try {
      return (board.saves != null && board.saves!.contains(user.uid));
    } catch (_) {
      throw const DatabaseConnectionFailure();
    }
  }

  Future<void> saveBoard(HSBoard board, HSUser user) async {
    try {
      await _boards.doc(board.bid).update({
        "saves": FieldValue.arrayUnion([user.uid])
      });
      await _users.doc(user.uid).update({
        "saves": FieldValue.arrayUnion([board.bid])
      });
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not save board: ${board.bid} to user: ${user.uid}");
    }
  }

  Future<void> unsaveBoard(HSBoard board, HSUser user) async {
    try {
      await _boards.doc(board.bid).update({
        "saves": FieldValue.arrayRemove([user.uid])
      });
      await _users.doc(user.uid).update({
        "saves": FieldValue.arrayRemove([board.bid])
      });
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not unsave board: ${board.bid} from user: ${user.uid}");
    }
  }

  Future<void> addToEditors(
      {required HSBoard board, required HSUser user}) async {
    try {
      await _boards.doc(board.bid).update({
        "editors": FieldValue.arrayUnion([user.uid])
      });
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not add user: ${user.uid} to editors of board: ${board.bid}");
    }
  }

  Future<void> removeFromEditors(
      {required HSBoard board, required HSUser user}) async {
    try {
      await _boards.doc(board.bid).update({
        "editors": FieldValue.arrayRemove([user.uid])
      });
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not remove user: ${user.uid} from editors of board: ${board.bid}");
    }
  }

  Future<List<HSBoard>> getUserBoards(HSUser user) async {
    try {
      final List boardsIDs = user.boards ?? [];
      final List<HSBoard> boards = [];
      for (var i = 0; i < boardsIDs.length; i++) {
        boards.add(await getBoard(boardsIDs[i]));
      }
      return boards;
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not get user's: ${user.uid} boards");
    }
  }

  Future<List<HSBoard>> getSavedBoards(HSUser user) async {
    try {
      final List boardsIDs = user.saves ?? [];
      final List<HSBoard> boards = [];
      for (var i = 0; i < boardsIDs.length; i++) {
        boards.add(await getBoard(boardsIDs[i]));
      }
      return boards;
    } catch (_) {
      throw DatabaseConnectionFailure(
          "Could not get user's: ${user.uid} saved boards");
    }
  }

  Future<HSBoard> getBoard(String boardID) async {
    try {
      DocumentSnapshot snap = await _boards.doc(boardID).get();
      if (!snap.exists)
        throw DatabaseConnectionFailure("The board does not exist.");
      return HSBoard.deserialize(snap.data() as Map<String, dynamic>, snap.id);
    } on DatabaseConnectionFailure catch (_) {
      rethrow;
    } catch (_) {
      throw DatabaseConnectionFailure();
    }
  }

  Future<String> createBoard(HSBoard board) async {
    try {
      DocumentReference ref = await _boards.add(board.serialize());
      await _assignBoardToUser(board.copyWith(bid: ref.id));
      return (ref.id);
    } catch (_) {
      throw DatabaseConnectionFailure("An error occured creating board: $_");
    }
  }

  Future<void> updateBoard(HSBoard board) async {
    try {
      await _boards.doc(board.bid!).update(board.serialize());
    } catch (_) {
      throw DatabaseConnectionFailure("An error occured creating board: $_");
    }
  }

  Future<void> _assignBoardToUser(HSBoard board) async {
    try {
      await _users.doc(board.authorID!).update({
        "boards": FieldValue.arrayUnion([board.bid]),
      });
    } catch (_) {
      throw DatabaseConnectionFailure("Error assigning board to user: $_");
    }
  }

  Future<void> _unassignBoardFromUser(HSBoard board) async {
    try {
      await _users.doc(board.authorID!).update({
        "boards": FieldValue.arrayRemove([board.bid]),
      });
    } catch (_) {
      throw DatabaseConnectionFailure("Error unassigning board to user: $_");
    }
  }

  Future<void> deleteBoardImage(HSBoard board) async {
    try {
      await _boards.doc(board.bid!).update({"image": null});
      if (board.image != null) {
        final Reference imageRef =
            FirebaseStorage.instance.refFromURL(board.image!);
        await imageRef.delete();
      }
    } catch (_) {
      throw DatabaseConnectionFailure("The board image could not be deleted.");
    }
  }
}
