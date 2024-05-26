import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/pickers/hs_pickers.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:hs_toasts/hs_toasts.dart';
import 'package:location/location.dart';

class HSApp {
  // SINGLETON
  HSApp._internal();
  static final HSApp _instance = HSApp._internal();
  static HSApp get instance => _instance;

  // Pickers
  HSPickers get pickers => HSPickers.instance;

  // NAVIGATION
  HSNavigation get navigation => HSNavigation.instance;
  GlobalKey<NavigatorState> get navigatorKey => navigation.navigatorKey;
  BuildContext? get context => navigatorKey.currentContext;

  // THEMING
  HSThemeBloc get themeBloc => BlocProvider.of<HSThemeBloc>(context!);
  HSTheme get theme => HSTheme.instance;
  ThemeData get currentTheme => theme.currentTheme;
  TextTheme get textTheme => theme.textTheme;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  Color? get textFieldFillColor => theme.textfieldFillColor;

  void changeTheme() => themeBloc.add(HSThemeSwitchEvent());

  double get screenWidth => MediaQuery.of(context!).size.width;
  double get screenHeight => MediaQuery.of(context!).size.height;

  HSThemeRepository get themeRepository => HSThemeRepository.instance;

  // POPUPS
  HSToasts get toasts => HSToasts.instance;
  void showToast(
          {required HSToastType toastType,
          required String title,
          String? description,
          Alignment? alignment}) =>
      toasts.toast(
        context!,
        toastType: toastType,
        title: title,
        descriptionText: description,
        alignment: alignment,
      );

  // ASSETS
  HSAssets get assets => HSAssets.instance;

  // AUTHENTICATION
  HSAuthenticationRepository get authRepository =>
      context!.read<HSAuthenticationRepository>();
  HSAuthenticationBloc get authBloc =>
      BlocProvider.of<HSAuthenticationBloc>(context!);

  void logout() {
    authBloc.add(const HSAppLogoutRequested());
    navi.logout();
  }

  // DATABASE
  HSDatabaseRepository get databaseRepository =>
      context!.read<HSDatabaseRepository>();

  // CURRENT USER
  HSUser get currentUser => authBloc.state.user;
  String? get username => currentUser.username;
  void updateCurrentUser(HSUser user) => authBloc.updateCurrentUser(user);

  // DATABASE
  HSDatabaseRepository get databaseRepository =>
      context!.read<HSDatabaseRepository>();

  // Full Text Search
  HSSearchRepository get searchRepository =>
      context!.read<HSSearchRepository>();

  // LOCATION
  HSLocationRepository get locationRepository =>
      context!.read<HSLocationRepository>();
}
