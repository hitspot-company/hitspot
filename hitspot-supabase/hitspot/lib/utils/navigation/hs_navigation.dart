import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/complete_profile/view/complete_profile_provider.dart';
import 'package:hitspot/features/home/view/home_page.dart';
import 'package:hitspot/features/login_1/view/login_provider.dart';
import 'package:hitspot/features/splash/view/splash_page.dart';

class HSNavigation {
  HSNavigation._privateConstructor();
  static final HSNavigation _instance = HSNavigation._privateConstructor();
  factory HSNavigation() {
    return _instance;
  }

  BuildContext get context => router.configuration.navigatorKey.currentContext!;
  dynamic pop() => router.pop;
  dynamic pushPage(Widget page) =>
      router.configuration.navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => page),
      );

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
          if (status != HSAuthenticationStatus.unknown) {
            return "/protected/home";
          }
          return null;
        },
      ),
      GoRoute(path: "/", redirect: (context, state) => "/protected/home"),
      GoRoute(
        path: "/protected",
        redirect: _protectedRedirect,
        routes: [
          GoRoute(path: "home", builder: (context, state) => const HomePage())
        ],
      ),
      GoRoute(
        path: "/auth",
        redirect: _authRedirect,
        routes: [
          GoRoute(
            path: "login",
            builder: (context, state) => const LoginProvider(),
          ),
          GoRoute(
              path: "complete_profile",
              builder: (context, state) => const CompleteProfileProvider()),
        ],
      ),
    ],
  );

  static FutureOr<String?>? _protectedRedirect(
      BuildContext _, GoRouterState state) {
    final HSAuthenticationStatus status =
        BlocProvider.of<HSAuthenticationBloc>(_).state.authenticationStatus;
    final String? path = state.uri.queryParameters['from'];
    final String from = path != null ? "?from=$path" : "";
    if (status != HSAuthenticationStatus.authenticated) return "/auth$from";
    return null;
  }

  static FutureOr<String?>? _authRedirect(BuildContext _, GoRouterState state) {
    final HSAuthenticationStatus status =
        BlocProvider.of<HSAuthenticationBloc>(_).state.authenticationStatus;
    final String? path = state.uri.queryParameters['from'];
    final String from = path != null ? "?from=$path" : "";
    switch (status) {
      case HSAuthenticationStatus.unauthenitcated:
        return "/auth/login$from";
      case HSAuthenticationStatus.emailNotVerified:
        return "/auth/verify_email$from";
      case HSAuthenticationStatus.profileIncomplete:
        return "/auth/complete_profile$from";
      case HSAuthenticationStatus.authenticated:
        return "/protected/home$from";
      default:
        return "/auth/login$from";
    }
  }
}
