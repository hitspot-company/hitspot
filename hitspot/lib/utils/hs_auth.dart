import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hitspot/screens/home/home.dart';
import 'package:hitspot/screens/register/register.dart';

class HSAuth extends GetxController {
  static HSAuth instance = Get.find();
  late Rx<User?> firebaseUser;
  final auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const RegisterPage());
    } else {
      Get.offAll(() => const HomePage());
    }
  }

  void register(String email, password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (firebaseAuthException) {
      print("Error registering user: $firebaseAuthException");
    }
  }

  void login(String email, password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (firebaseAuthException) {
      print("Error registering user: $firebaseAuthException");
    }
  }

  void signOut() async {
    await auth.signOut();
  }
}
