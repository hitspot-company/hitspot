import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/main.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hitspot/utils/pickers/hs_pickers.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_storage_repository/hs_storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  HSUser? get currentUser {
    if (authenticationState is HSAuthenticationAuthenticatedState) {
      return (authenticationState as HSAuthenticationAuthenticatedState)
          .currentUser;
    } else if (authenticationState is HSAuthenticationProfileIncompleteState) {
      return (authenticationState as HSAuthenticationProfileIncompleteState)
          .currentUser;
    }
    return null;
  }

  HSAuthenticationStatus get authenticationStatus =>
      authenticationBloc.state.authenticationStatus;
  void signOut() => authenticationRepository.signOut();

  // Database
  HSDatabaseRepsitory get databaseRepository =>
      RepositoryProvider.of<HSDatabaseRepsitory>(context);

  // Theme
  // HSThemeBloc get themeBloc => BlocProvider.of<HSThemeBloc>(context!);
  HSTheme get theme => HSTheme.instance;
  ThemeData get currentTheme => theme.currentTheme;
  TextTheme get textTheme => theme.textTheme;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  Color get textFieldFillColor => theme.textfieldFillColor;
  // void changeTheme() => themeBloc.add(HSThemeSwitchEvent());
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  // HSThemeRepository get themeRepository => HSThemeRepository.instance;

  // Storage
  HSStorageRepository get storageRepository =>
      RepositoryProvider.of<HSStorageRepository>(context);
}
