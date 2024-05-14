import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          textTheme: _HSTextThemes.lightTextTheme)
      .copyWith(highlightColor: Colors.black);

  final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.dark,
    textTheme: _HSTextThemes.darkTextTheme,
    typography: Typography(white: Typography.whiteCupertino),
  ).copyWith(highlightColor: Colors.black.withOpacity(.08));

  Color get highlightColor => currentTheme.highlightColor;
  Color get mainColor => _mainColor;
  Color get textfieldFillColor => _textfieldFillColor;

  BuildContext get context =>
      HSNavigationService.instance.navigatorKey.currentContext!;
  TextTheme get textTheme => Theme.of(context).textTheme;
  ThemeData get currentTheme => Theme.of(context);
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

class _HSTextThemes {
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.lilitaOne(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displayMedium: GoogleFonts.lilitaOne(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displaySmall: GoogleFonts.lilitaOne(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineLarge: GoogleFonts.lilitaOne(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineMedium: GoogleFonts.lilitaOne(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineSmall: GoogleFonts.lilitaOne(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleLarge: GoogleFonts.lilitaOne(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    titleSmall: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelLarge: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    labelMedium: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelSmall: GoogleFonts.roboto(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );

  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.lilitaOne(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.lilitaOne(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.lilitaOne(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineLarge: GoogleFonts.lilitaOne(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.lilitaOne(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.lilitaOne(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.lilitaOne(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    titleSmall: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.aBeeZee(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.aBeeZee(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.aBeeZee(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    labelLarge: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    labelMedium: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    labelSmall: GoogleFonts.roboto(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  );
}
