import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/utils/navigation/hs_navigation_service.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';

class HSApp {
  // SINGLETON
  HSApp._internal();
  static final HSApp _instance = HSApp._internal();
  static HSApp get instance => _instance;

  // NAVIGATION
  HSNavigationService get navigation => HSNavigationService.instance;
  GlobalKey<NavigatorState> get navigatorKey => navigation.navigatorKey;
  BuildContext? get context => navigatorKey.currentContext;

  // THEMING
  HSThemeBloc get themeBloc => BlocProvider.of<HSThemeBloc>(context!);
  HSTheme get theme => HSTheme.instance;
  ThemeData get currentTheme => theme.currentTheme(context);
  TextTheme get textTheme => theme.textTheme(context);
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  Color? get textFieldFillColor => theme.textfieldFillColor;
  void changeTheme() => themeBloc.add(HSThemeSwitchEvent());

  // POPUPS
  HSToasts get toasts => HSToasts.instance;
  void showToast(
          {required HSSnackType snackType,
          required String title,
          String? description}) =>
      toasts.snack(context!,
          snackType: snackType, title: title, descriptionText: description);

  // ASSETS
  HSAssets get assets => HSAssets.instance;

  // AUTHENTICATION
  HSAuthenticationBloc get authBloc =>
      BlocProvider.of<HSAuthenticationBloc>(context!);
  void logout() => authBloc.add(const HSAppLogoutRequested());

  // CURRENT USER
  HSUser get currentUser => authBloc.state.user;
  String? get username => currentUser.username;
}
