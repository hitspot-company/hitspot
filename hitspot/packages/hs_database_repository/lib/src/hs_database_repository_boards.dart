import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSBoardsRepository {
  const HSBoardsRepository(this._boards, this._users);
  final CollectionReference _boards;
  final CollectionReference _users;

  Future<HSBoard> getBoard(String boardID) async {
    try {
      DocumentSnapshot snap = await _boards.doc(boardID).get();
      if (!snap.exists)
        throw DatabaseConnectionFailure("The board does not exist.");
      return HSBoard.deserialize(snap.data() as Map<String, dynamic>, snap.id);
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
}
