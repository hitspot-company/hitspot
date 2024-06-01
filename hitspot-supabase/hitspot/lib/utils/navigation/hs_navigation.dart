import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/login/view/login_page.dart';
import 'package:hitspot/features/login/view/login_provider.dart';
import 'package:hitspot/features/splash/view/splash_page.dart';

class HSNavigation {
  HSNavigation._privateConstructor();
  static final HSNavigation _instance = HSNavigation._privateConstructor();
  factory HSNavigation() {
    return _instance;
  }

  BuildContext get context => router.configuration.navigatorKey.currentContext!;

  final GoRouter router = GoRouter(
    initialLocation: "/splash",
    routes: [
      GoRoute(
        path: "/splash",
        builder: (context, state) => const SplashPage(),
        redirect: (context, state) {
          final HSAuthenticationStatus status =
              BlocProvider.of<HSAuthenticationBloc>(context)
                  .state
                  .authenticationStatus;
          if (status != HSAuthenticationStatus.unknown) return "/";
          return null;
        },
      ),
      GoRoute(
          path: "/login", builder: (context, state) => const LoginProvider()),
      GoRoute(path: "/", redirect: (context, state) => "/protected/home"),
      GoRoute(
        path: "/protected",
        redirect: _protectedRedirect,
      ),
      GoRoute(path: "/home", builder: (context, state) => const LoginPage())
    ],
  );

  static FutureOr<String?>? _protectedRedirect(
      BuildContext _, GoRouterState state) {
    final HSAuthenticationStatus status =
        BlocProvider.of<HSAuthenticationBloc>(_).state.authenticationStatus;
    final String? path = state.uri.queryParameters['from'];
    final String from = path != null ? "?from=$path" : "null";
    switch (status) {
      case HSAuthenticationStatus.unknown:
        return "/auth/splash$from";
      case HSAuthenticationStatus.unauthenitcated:
        return "/auth/login$from";
      case HSAuthenticationStatus.emailNotVerified:
        return "/auth/verify_email$from";
      case HSAuthenticationStatus.profileIncomplete:
        return "/auth/complete_profile$from";
      case HSAuthenticationStatus.authenticated:
        return "/protected/home$from";
    }
  }
}
