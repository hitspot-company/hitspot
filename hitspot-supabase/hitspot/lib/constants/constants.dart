import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/features/app/hs_app.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

HSApp get app => HSApp();
TextTheme get textTheme => app.textTheme;
ThemeData get currentTheme => app.currentTheme;
HSTheme get appTheme => app.theme;
HSNavigation get navi => app.navigation;
double get screenWidth => app.screenWidth;
double get screenHeight => app.screenHeight;
HSUser get currentUser => app.currentUser;
Icon get nextIcon => const Icon(FontAwesomeIcons.arrowRight);
Icon get backIcon => const Icon(FontAwesomeIcons.arrowLeft);
