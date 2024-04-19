import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hitspot/screens/home/home.dart';
import 'package:hitspot/screens/register/register.dart';
import 'package:hitspot/utils/hs_app.dart';

class HSAuth extends GetxService {
  static HSAuth instance = Get.find();
  late Rx<User?> firebaseUser;
  final auth = FirebaseAuth.instance;
  static final app = HSApp.instance;

  @override
  void onInit() {
    print("HSAuth ready!");
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    // firebaseUser = Rx<User?>(auth.currentUser);
    // firebaseUser.bindStream(auth.userChanges());
    // ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const RegisterPage());
    } else {
      Get.offAll(() => const HomePage());
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(
      String email, password) async {
    try {
      UserCredential createdUser = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return (createdUser);
    } catch (firebaseAuthException) {
      printError(info: "$firebaseAuthException");
      rethrow;
    }
  }

  void loginWithEmailAndPassword(String email, password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (firebaseAuthException) {
      print("Error registering user: $firebaseAuthException");
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    app.currentUser.disposeCurrentUser();
    Get.offAndToNamed("/login");
  }
}
