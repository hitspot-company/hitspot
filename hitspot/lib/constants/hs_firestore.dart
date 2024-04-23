import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hitspot/models/hs_user.dart';

class HSFirestore {
  static HSFirestore instance = HSFirestore();
  late String cuid;
  static final _fs = FirebaseFirestore.instance;

  static final _spots = _fs.collection("spots");
  static final _users = _fs.collection("users_dev");
  // static final _users = _fs.collection("users");
  static final _boards = _fs.collection("boards");

  CollectionReference<Map<String, dynamic>> get spotsCollection => _spots;
  CollectionReference<Map<String, dynamic>> get usersCollection => _users;
  CollectionReference<Map<String, dynamic>> get boardsCollection => _boards;
}
