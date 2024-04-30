import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'exceptions/database_connection_failure.dart';

class HSDatabaseRepository {
  static final _usersRepository = _HSUsersRepository();

  Future<void> updateUserInfoInDatabase(HSUser user) async =>
      _usersRepository.updateUserInfoInDatabase(user);

  Future<HSUser?> getUserFromDatabase(String uid) async =>
      _usersRepository.getUserFromDatabase(uid);

  Future<bool> isUsernameAvailable(String username) async =>
      _usersRepository.isUsernameAvailable(username);
}

class _HSUsersRepository {
  static final _db = FirebaseFirestore.instance;
  final _usersCollection = _db.collection("users");

  // If user does not exist in database, it wil create a new document
  Future<void> updateUserInfoInDatabase(HSUser user) async {
    try {
      await _usersCollection
          .doc(user.uid)
          .set(user.serialize())
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      throw const DatabaseConnectionFailure('An unknown exception occured');
    }
  }

  Future<HSUser?> getUserFromDatabase(String uid) async {
    try {
      DocumentSnapshot snapshot = await _usersCollection
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 3));

      // If user is not in database return null
      if (!snapshot.exists) {
        return null;
      }

      Map<String, dynamic> snapshotInJson =
          snapshot.data() as Map<String, dynamic>;

      return HSUser.deserialize(snapshotInJson);
    } catch (_) {
      throw const DatabaseConnectionFailure('An unknown exception occured');
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      AggregateQuerySnapshot query = await _usersCollection
          .where("username", isEqualTo: username)
          .count()
          .get();
      return (query.count == 0);
    } catch (_) {
      throw const DatabaseConnectionFailure('An unknown exception occured');
    }
  }
}
