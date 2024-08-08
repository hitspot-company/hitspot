import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/connectivity/bloc/hs_connectivity_bloc.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/assets/hs_assets.dart';
import 'package:hitspot/utils/gallery/hs_gallery.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hitspot/utils/pickers/hs_pickers.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:hs_storage_repository/hs_storage_repository.dart';
import 'package:hs_theme_repository/hs_theme.dart';
import 'package:hs_toasts/hs_toasts.dart';

class HSApp {
  HSApp._privateConstructor();
  static final HSApp _instance = HSApp._privateConstructor();
  factory HSApp() {
    return _instance;
  }

  // Pickers
  HSPickers get pickers => HSPickers.instance;

  // Navigation
  final HSNavigation navigation = HSNavigation();
  BuildContext get context => navigation.context;

  // Authentication
  HSAuthenticationRepository get authenticationRepository =>
      RepositoryProvider.of<HSAuthenticationRepository>(context);
  HSAuthenticationBloc get authenticationBloc =>
      BlocProvider.of<HSAuthenticationBloc>(context);
  HSAuthenticationState get authenticationState => authenticationBloc.state;
  HSUser get currentUser {
    if (authenticationState is HSAuthenticationAuthenticatedState) {
      return (authenticationState as HSAuthenticationAuthenticatedState)
          .currentUser;
    } else if (authenticationState is HSAuthenticationProfileIncompleteState) {
      return (authenticationState as HSAuthenticationProfileIncompleteState)
          .currentUser;
    }
    return const HSUser();
  }

  HSAuthenticationStatus get authenticationStatus =>
      authenticationBloc.state.authenticationStatus;
  void signOut() => authenticationRepository.signOut();

  // Database
  HSDatabaseRepsitory get databaseRepository =>
      RepositoryProvider.of<HSDatabaseRepsitory>(context);

  // Theme
  HSThemeBloc get themeBloc => BlocProvider.of<HSThemeBloc>(context);
  HSTheme get theme => HSTheme.instance;
  ThemeData get currentTheme => theme.currentTheme;
  TextTheme get textTheme => theme.textTheme;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  Color get textFieldFillColor => theme.textfieldFillColor;
  void switchTheme() => themeBloc.add(HSThemeSwitchEvent());
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  HSThemeRepository get themeRepository =>
      RepositoryProvider.of<HSThemeRepository>(context);

  // Storage
  HSStorageRepository get storageRepository =>
      RepositoryProvider.of<HSStorageRepository>(context);

  // POPUPS
  HSToasts get toasts => HSToasts.instance;
  void showToast(
          {required HSToastType toastType,
          required String title,
          String? description,
          Color? primaryColor,
          Alignment? alignment}) =>
      toasts.toast(
        context,
        toastType: toastType,
        title: title,
        primaryColor: primaryColor,
        descriptionText: description,
        alignment: alignment,
      );

  // ASSETS
  HSAssets get assets => HSAssets.instance;

  // Location
  HSLocationRepository get locationRepository =>
      RepositoryProvider.of<HSLocationRepository>(context);

  // Location and connectivity
  HSConnectivityLocationBloc get connectivityBloc =>
      BlocProvider.of<HSConnectivityLocationBloc>(context);
  Position? get currentPosition => connectivityBloc.state.location;
  bool get isLocationServiceEnabled =>
      connectivityBloc.state.isLocationServiceEnabled;
  bool get isConnected => connectivityBloc.state.isConnected;
  bool get isCurrentPositionAvailable => currentPosition != null;

  HSGallery get gallery => HSGallery();
}
