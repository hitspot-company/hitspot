import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';

final class HSTheme {
  HSTheme._internal();

  static final HSTheme _instance = HSTheme._internal();
  static HSTheme get instance => _instance;

  static const Color _mainColor = Color(0xFF00c0ca);
  static const Color _textfieldFillColor = Color.fromARGB(57, 160, 160, 160);

  late String _mapStyleLightString;
  late String _mapStyleDarkString;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _mapStyleLightString =
        await rootBundle.loadString(HSAssets.instance.mapStyleLight);
    _mapStyleDarkString =
        await rootBundle.loadString(HSAssets.instance.mapStyleDark);
    _isInitialized = true;
  }

  String get mapStyleDark {
    _ensureInitialized();
    return _mapStyleDarkString;
  }

  String get mapStyleLight {
    _ensureInitialized();
    return _mapStyleLightString;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw 'HSTheme has not been initialized.';
    }
  }

  final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.light,
    textTheme: _HSTextThemes.lightTextTheme,
  );

  final ThemeData darkTheme = ThemeData(
    colorSchemeSeed: _mainColor,
    brightness: Brightness.dark,
    textTheme: _HSTextThemes.darkTextTheme,
  );

  Color get highlightColor => currentTheme.highlightColor;
  Color get mainColor => _mainColor;
  Color get textfieldFillColor => _textfieldFillColor;

  BuildContext get context => app.context;
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
