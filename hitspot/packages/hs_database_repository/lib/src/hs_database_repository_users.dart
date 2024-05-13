import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSUsersRepository {
  static final _db = FirebaseFirestore.instance;
  final _usersCollection = _db.collection("users");

  Future<void> updateField(HSUser user, String field, String newValue) async {
    try {
      await _usersCollection.doc(user.uid).update({
        field: newValue,
      }).timeout(const Duration(seconds: 3));
    } catch (_) {
      throw DatabaseConnectionFailure("The field $field could not be updated.");
    }
  }

  Future<void> completeUserProfile(HSUser user) async {
    final now = Timestamp.now();
    try {
      await _usersCollection
          .doc(user.uid)
          .update(user.copyWith(createdAt: now).serialize())
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      throw const DatabaseConnectionFailure('An unknown exception occured');
    }
  }

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
          .timeout(const Duration(seconds: 5));

      // If user is not in database return null
      if (!snapshot.exists) {
        return null;
      }

      Map<String, dynamic> snapshotInJson =
          snapshot.data() as Map<String, dynamic>;

      return HSUser.deserialize(snapshotInJson, uid: snapshot.id);
    } catch (_) {
      return null;
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
