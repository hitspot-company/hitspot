import 'package:flutter/material.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

HSApp get app => HSApp.instance;
TextTheme get textTheme => app.textTheme;
HSTheme get currentTheme => app.theme;
HSNavigation get navi => app.navigation;
double get screenWidth => app.screenWidth;
double get screenHeight => app.screenHeight;
HSUser get currentUser => app.currentUser;
