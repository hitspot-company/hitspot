import 'package:cloud_firestore/cloud_firestore.dart';

class HSBoardsRepository {
  static final _db = FirebaseFirestore.instance;
  final _boardsCollection = _db.collection("boards");
}
