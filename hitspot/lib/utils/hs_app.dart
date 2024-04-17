import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hitspot/utils/hs_auth.dart';
import 'package:hitspot/utils/hs_config.dart';
import 'package:hitspot/utils/hs_current_user.dart';
import 'package:hitspot/utils/hs_images.dart';
import 'package:hitspot/utils/hs_notifications.dart';
import 'package:hitspot/utils/hs_theming.dart';

class HSApp extends GetxService {
  static HSApp instance = Get.find();

  static final auth = HSAuth.instance;
  static final config = HSConfig.instance;
  static final notifications = HSNotifications.instance;
  static final theming = HSTheming.instance;
  static final currentUser = HSCurrentUser.instance;
  static final images = HSImages.instance;

  static TextTheme get textTheme => theming.textTheme;

  @override
  void onInit() {
    Get.put(HSAuth());
    Get.put(HSConfig());
    Get.put(HSNotifications());
    Get.put(HSTheming());
    Get.put(HSCurrentUser());
    Get.put(HSImages());
    super.onInit();
  }

  @override
  void onReady() {
    print("HSApp ready!");
    super.onReady();
  }
}
