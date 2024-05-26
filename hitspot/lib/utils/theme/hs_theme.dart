import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/navigation/hs_navigation_service.dart';

final class HSTheme {
  // SINGLETON
  HSTheme._internal();
  static final HSTheme _instance = HSTheme._internal();
  static HSTheme get instance => _instance;

  static const Color _mainColor = Color(0xFF04cc91);
  static const Color _textfieldFillColor = Color.fromARGB(16, 158, 158, 158);

  final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.light,
    textTheme: _HSTextThemes.lightTextTheme,
  ).copyWith(highlightColor: Colors.black);

  final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.dark,
    textTheme: _HSTextThemes.darkTextTheme,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
    scaffoldBackgroundColor: Colors.black,
  ).copyWith(highlightColor: Colors.black.withOpacity(.08));

  Color get highlightColor => currentTheme.highlightColor;
  Color get mainColor => _mainColor;
  Color get textfieldFillColor => _textfieldFillColor;

  BuildContext get context => app.navigation.navigatorKey.currentContext!;
  TextTheme get textTheme => Theme.of(context).textTheme;
  ThemeData get currentTheme => Theme.of(context);
}

extension TextStyleAltering on TextStyle {
  TextStyle get boldify {
    return copyWith(fontWeight: FontWeight.bold);
  }

  TextStyle get hintify {
    return copyWith(color: color!.withOpacity(.7));
  }

  TextStyle colorify(Color newColor) {
    return copyWith(color: newColor);
  }
}

class _HSTextThemes {
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );

  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  );
}
