import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/main.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSApp {
  HSApp._privateConstructor();
  static final HSApp _instance = HSApp._privateConstructor();
  factory HSApp() {
    return _instance;
  }

  // Navigation
  final HSNavigation navigation = HSNavigation();
  BuildContext get context => navigation.context;

  // Authentication
  final HSAuthenticationRepository authenticationRepository =
      HSAuthenticationRepository(supabase);
  HSAuthenticationBloc get authenticationBloc =>
      BlocProvider.of<HSAuthenticationBloc>(context);
  HSUser? get currentUser =>
      authenticationBloc.state is HSAuthenticationAuthenticatedState
          ? (authenticationBloc.state as HSAuthenticationAuthenticatedState)
              .currentUser
          : null;
  HSAuthenticationStatus get authenticationStatus =>
      authenticationBloc.state.authenticationStatus;
}
