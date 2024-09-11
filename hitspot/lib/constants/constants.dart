import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/features/app/hs_app.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

HSApp get app => HSApp();
// TextTheme get textTheme => app.textTheme;
ThemeData get currentTheme => app.currentTheme;
HSTheme get appTheme => app.theme;
HSNavigation get navi => app.navigation;
double get screenWidth => app.screenWidth;
double get screenHeight => app.screenHeight;
HSUser get currentUser => app.currentUser;
Icon get nextIcon => const Icon(FontAwesomeIcons.chevronRight);
Icon get backIcon => const Icon(FontAwesomeIcons.chevronLeft);
double get kDefaultLatitude => 37.7749;
double get kDefaultLongitude => -122.4194;
Position get kDefaultPosition => Position(
      latitude: kDefaultLatitude,
      longitude: kDefaultLongitude,
      altitude: 0.0,
      accuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      heading: 0.0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
