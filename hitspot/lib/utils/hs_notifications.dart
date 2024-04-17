import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HSNotifications extends GetxService {
  static HSNotifications instance = Get.find();
  late HSSnackBarService snackbar;

  @override
  void onInit() {
    Get.put(HSSnackBarService());
    snackbar = HSSnackBarService.instance;
    super.onInit();
  }

  @override
  void onReady() {
    print("HSNotifications ready!");
    super.onReady();
  }
}

class HSSnackBarService extends GetxService {
  static HSSnackBarService instance = Get.find();
  final SnackPosition defaultSnackPosition = SnackPosition.BOTTOM;

  void success(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: defaultSnackPosition,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check));
  }

  void warning(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: defaultSnackPosition,
        backgroundColor: Colors.yellow,
        icon: const Icon(Icons.warning));
  }

  void error(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: defaultSnackPosition,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error));
  }
}
