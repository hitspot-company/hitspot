import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

import 'exceptions/database_connection_failure.dart';

class HSDatabaseRepository {
  static final db = FirebaseFirestore.instance;
  static final usersCollection = db.collection("users");

  // If user does not exist in database, it wil create a new document
  Future<void> updateUserInfoInDatabase(HSUser user) async {
    try {
      await usersCollection
          .doc(user.uid)
          .set(user.serialize())
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      throw const DatabaseConnectionFailure('An unknown exception occured');
    }
  }

  Future<HSUser?> getUserFromDatabase(String uid) async {
    try {
      DocumentSnapshot snapshot = await usersCollection
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
}
