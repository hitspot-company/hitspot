import 'package:flutter/material.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/utils/navigation/hs_navigation_service.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';

HSApp get app => HSApp.instance;
TextTheme get textTheme => app.textTheme;
HSTheme get currentTheme => app.theme;
HSNavigationService get navi => app.navigation;
