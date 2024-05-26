import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSBoardsRepository {
  static final _db = FirebaseFirestore.instance;
  final collection = _db.collection("boards");

  Future<String> createBoard(HSBoard board) async {
    try {
      DocumentReference ref = await collection.add(board.serialize());
      return (ref.id);
    } catch (_) {
      throw DatabaseConnectionFailure("An error occured creating board: $_");
    }
  }
}
