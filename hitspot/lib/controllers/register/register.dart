import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:hitspot/models/hs_user.dart';
import 'package:hitspot/screens/home/home.dart';
import 'package:hitspot/utils/hs_app.dart';

class RegisterController extends GetxController {
  final auth = HSApp.auth;
  final firestore = HSApp.firestore;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _loading = false.obs;

  String get email => emailController.text;
  String get password => passwordController.text;
  bool get loading => _loading.value;

  Future register() async {
    _toggleLoading();
    await Future.delayed(const Duration(seconds: 5));
    // try {
    //   await auth.registerWithEmailAndPassword(email, password);
    //   HSUser user = HSUser(
    //     email: email,
    //   );
    //   HSUser createdUser = await firestore.createUser(user, null);
    //   HSApp.currentUser.initCurrentUser(createdUser);
    //   Get.offAll(() => const HomePage());
    //   return;
    // } on FirebaseAuthException catch (fae) {
    //   HSApp.snackbars.error("Error", fae.message!);
    // } catch (e) {
    //   // await auth.signOut();
    //   print("Error registering: $e");
    // }
    _toggleLoading();
  }

  void _toggleLoading() => _loading.value = !_loading.value;
}
