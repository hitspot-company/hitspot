import 'package:flutter/material.dart';

final class HSTheme {
  static HSTheme instance = HSTheme();
  static const Color _mainColor = Color(0xFF04cc91);
  static const Color _textfieldFillColor = Color.fromARGB(16, 158, 158, 158);

  final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.light,
  );

  final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.dark,
  );

  Color get mainColor => _mainColor;
  Color get textfieldFillColor => _textfieldFillColor;

  TextTheme textTheme(context) => Theme.of(context).textTheme;
}

extension TextStyleAltering on TextStyle {
  TextStyle boldify() {
    return copyWith(fontWeight: FontWeight.bold);
  }

  TextStyle hintify() {
    return copyWith(color: color!.withOpacity(.7));
  }

  TextStyle colorify(Color newColor) {
    return copyWith(color: newColor);
  }
}
