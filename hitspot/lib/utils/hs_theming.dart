import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HSTheming extends GetxService {
  static HSTheming instance = Get.find();

  /// Light theme details (lt - lightTheme)
  // static const Color _ltPrimary = Color(0xFFf2f2f2),
  //     _ltSecondary = Color(0xFF04cc91),
  //     _ltAccent = Color(0xFFc2f8eb),
  //     _ltTileBg = Color.fromARGB(255, 28, 28, 28);

  static const Color _mainColor = Color(0xFF04cc91);

  final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.light,
  );

  final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.dark,
  );

  @override
  void onReady() {
    print("HSTheming ready!");
    super.onReady();
  }
}
