import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hitspot/models/hs_user.dart';

class HSFirestore extends GetxService {
  static HSFirestore instance = Get.find();
  late String cuid;
  static final _fs = FirebaseFirestore.instance;

  static final _spots = _fs.collection("spots");
  static final _users = _fs.collection("users_dev");
  // static final _users = _fs.collection("users");
  static final _boards = _fs.collection("boards");

  CollectionReference<Map<String, dynamic>> get spotsCollection => _spots;
  CollectionReference<Map<String, dynamic>> get usersCollection => _users;
  CollectionReference<Map<String, dynamic>> get boardsCollection => _boards;

  ///
  /// Identity provider ID is the ID supplied by
  /// -  FirebaseAuth when signing up with email and password
  /// -  Apple when using AppleSignIn
  /// -  Google when using GoogleSignIn
  /// -  etc.
  ///
  /// It can be later used to determine whether the same user uses different login methods.
  Future<HSUser> createUser(HSUser user, String? identityProviderID) async {
    assert(user.email != null || identityProviderID != null,
        "Either email or the identityProviderID has to be non-null. Otherwise the user cannot be verified upon next login");
    try {
      if (identityProviderID != null) {
        user.authProviderIDs!.add(identityProviderID);
      }
      DocumentReference doc = await _users.add(user.serialize());
      DocumentSnapshot data = await doc.get().then((value) => value);
      print("data: ${data.data()}");
      HSUser created = HSUser.fromFirestore(data);
      print("User id: ${created.docID}");
      return (created);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void onReady() {
    print("HSFirestore ready!");
    super.onReady();
  }
}
