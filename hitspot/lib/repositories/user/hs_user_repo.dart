import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hitspot/constants/hs_app.dart';
import 'package:hitspot/models/hs_user.dart';

class HSUserRepo {
  final _users = HSApp.firestore.usersCollection;

  /// Identity provider ID is the ID supplied by
  /// -  FirebaseAuth when signing up with email and password
  /// -  Apple when using AppleSignIn
  /// -  Google when using GoogleSignIn
  /// -  etc.
  ///
  /// It can be later used to determine whether the same user uses different login methods.
  Future<HSUser> createUser(HSUser user, String identityProviderID) async {
    try {
      await _users.doc(identityProviderID).set(user.serialize());
      DocumentSnapshot data =
          await _users.doc(identityProviderID).get().then((value) => value);
      print("data: ${data.data()}");
      HSUser created = HSUser.fromFirestore(data);
      print("User id: ${created.docID}");
      return (created);
    } catch (e) {
      rethrow;
    }
  }
}
