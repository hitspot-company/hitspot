import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

final class HSTheme {
  // SINGLETON
  HSTheme._internal() {
    rootBundle.loadString(HSAssets.mapStyle).then((string) {
      _mapStyleString = string;
    });
  }
  static final HSTheme _instance = HSTheme._internal();
  static HSTheme get instance => _instance;

  static const Color _mainColor = Color(0xFF00c0ca);
  static const Color _textfieldFillColor = Color.fromARGB(57, 160, 160, 160);

  late String _mapStyleString;
  String get mapStyle => _mapStyleString;

  final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.light,
    textTheme: _HSTextThemes.lightTextTheme,
  ).copyWith(highlightColor: Colors.black);

  final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.dark,
    textTheme: _HSTextThemes.darkTextTheme,
  ).copyWith(highlightColor: Colors.black.withOpacity(.08));

  Color get highlightColor => currentTheme.highlightColor;
  Color get mainColor => _mainColor;
  Color get textfieldFillColor => _textfieldFillColor;

  BuildContext get context => app.context;
  TextTheme get textTheme => Theme.of(context).textTheme;
  ThemeData get currentTheme => Theme.of(context);

  Future<void> applyMapDarkStyle(
      Completer<GoogleMapController> controller) async {
    if (await app.themeRepository.isDark()) {
      controller.future.then((value) {
        value.setMapStyle(mapStyle);
      });
    }
  }
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
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.normal,
    ),
  );

  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.normal,
    ),
  );
}
