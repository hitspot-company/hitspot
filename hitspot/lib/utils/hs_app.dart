import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hitspot/utils/hs_auth.dart';
import 'package:hitspot/utils/hs_config.dart';
import 'package:hitspot/utils/hs_current_user.dart';
import 'package:hitspot/utils/hs_firestore.dart';
import 'package:hitspot/utils/hs_images.dart';
import 'package:hitspot/utils/hs_notifications.dart';
import 'package:hitspot/utils/hs_theming.dart';

class HSApp extends GetxService {
  static HSApp instance = Get.find();

  late HSAuth auth;
  late HSConfig config;
  late HSNotifications notifications;
  late HSTheming theming;
  late HSCurrentUser currentUser;
  late HSImages images;
  late HSFirestore firestore;

  TextTheme get textTheme => theming.textTheme;
  HSSnackBarService get snackbars => notifications.snackbar;

  @override
  void onInit() {
    Get.put(HSAuth());
    Get.put(HSConfig());
    Get.put(HSNotifications());
    Get.put(HSTheming());
    Get.put(HSCurrentUser());
    Get.put(HSImages());
    Get.put(HSFirestore());
    super.onInit();
  }

  @override
  void onReady() {
    auth = HSAuth.instance;
    config = HSConfig.instance;
    notifications = HSNotifications.instance;
    theming = HSTheming.instance;
    currentUser = HSCurrentUser.instance;
    images = HSImages.instance;
    firestore = HSFirestore.instance;
    print("HSApp ready!");
    super.onReady();
  }
}
