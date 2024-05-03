import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSUsersRepository {
  static final _db = FirebaseFirestore.instance;
  final _usersCollection = _db.collection("users");

  Future<void> followUser(HSUser currentUser, HSUser user) async {
    try {
      await _usersCollection.doc(user.uid).update({
        HSUserField.followers.name: FieldValue.arrayUnion([currentUser.uid])
      });
      await _usersCollection.doc(currentUser.uid).update({
        HSUserField.following.name: FieldValue.arrayUnion([user.uid])
      });
    } catch (_) {
      throw DatabaseConnectionFailure("The user could not be followed.");
    }
  }

  Future<void> unfollowUser(HSUser currentUser, HSUser user) async {
    try {
      await _usersCollection.doc(user.uid).update({
        HSUserField.followers.name: FieldValue.arrayRemove([currentUser.uid])
      });
      await _usersCollection.doc(currentUser.uid).update({
        HSUserField.following.name: FieldValue.arrayRemove([user.uid])
      });
    } catch (_) {
      throw DatabaseConnectionFailure("The user could not be unfollowed.");
    }
  }

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
      throw DatabaseRepositoryFailure('An unknown exception occured');
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
      throw DatabaseRepositoryFailure('An unknown exception occured');
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
      throw DatabaseRepositoryFailure('An unknown exception occured');
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
      throw DatabaseRepositoryFailure('An unknown exception occured');
    }
  }

  Future<void> _removeProperty(
      {required List? ids, required CollectionReference collection}) async {
    try {
      if (ids == null || ids.length == 0) return;
      for (var i = 0; i < ids.length; i++) {
        await collection.doc(ids[i]).delete();
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _removeLinked({
    required List? ids,
    required CollectionReference collection,
    required String fieldName,
    required String userID,
  }) async {
    try {
      if (ids == null || ids.isEmpty) return;
      for (var i = 0; i < ids.length; i++) {
        await collection.doc(ids[i]).update({
          fieldName: FieldValue.arrayRemove([userID])
        });
      }
    } catch (_) {}
  }

  Future<void> delete(HSUser user) async {
    try {
      final HSUser? updatedUser = await getUserFromDatabase(user.uid!);
      if (updatedUser == null) return;
      await _removeProperty(
          ids: updatedUser.trips, collection: _db.collection("trips"));
      await _removeProperty(
          ids: updatedUser.boards, collection: _db.collection("boards"));
      await _removeProperty(
          ids: updatedUser.spots, collection: _db.collection("spots"));
      await _removeLinked(
          ids: updatedUser.followers,
          collection: _usersCollection,
          fieldName: "following",
          userID: updatedUser.uid!);
      await _removeLinked(
          ids: updatedUser.following,
          collection: _usersCollection,
          fieldName: "followers",
          userID: updatedUser.uid!);
      await _usersCollection.doc(updatedUser.uid!).delete();
    } catch (_) {
      throw DatabaseConnectionFailure("The user could not be deleted: $_");
    }
  }
}
