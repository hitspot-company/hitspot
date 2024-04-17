import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HSTheming extends GetxService {
  static HSTheming instance = Get.find();
  static const Color _mainColor = Color(0xFF04cc91);

  final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.light,
  );

  final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.dark,
  );

  ThemeData get currentTheme => Get.theme;
  TextTheme get textTheme => currentTheme.textTheme;

  @override
  void onReady() {
    print("HSTheming ready!");
    super.onReady();
  }
}

extension TextStyleAltering on TextStyle {
  TextStyle applyBold() {
    return copyWith(fontWeight: FontWeight.bold);
  }
}
