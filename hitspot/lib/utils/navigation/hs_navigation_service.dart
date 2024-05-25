import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/login/view/login_provider.dart';
import 'package:hitspot/features/register/view/register_page.dart';
import 'package:hitspot/features/splash/view/splash_page.dart';
import 'package:hitspot/features/tmp/info_page/view/info_page.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider.dart';
import 'package:hitspot/features/user_profile/settings/view/settings_provider.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSNavigationService {
  // SINGLETON
  HSNavigationService._internal();
  static final HSNavigationService _instance = HSNavigationService._internal();
  static HSNavigationService get instance => _instance;
  static final routes = _HSRoutes.instance;

  // GlobalKey<NavigatorState> get navigatorKey =>
  //     routes.router.configuration.navigatorKey;

  GlobalKey<NavigatorState> get navigatorKey =>
      routes.router.configuration.navigatorKey;
  GoRouter get router => routes.router;

  dynamic push(Route<void> route, {dynamic arguments}) =>
      navigatorKey.currentState?.push(route);

  dynamic pushReplacement(Route<void> route, {dynamic arguments}) =>
      navigatorKey.currentState?.pushReplacement(route);

  dynamic pushNamed(String route, {dynamic arguments}) {
    return navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  dynamic pop([bool shouldUpdate = false]) {
    return navigatorKey.currentState?.pop(shouldUpdate);
  }

  dynamic logout() =>
      navigatorKey.currentState?.popUntil((route) => route.isFirst);

  // PREDEFINED ROUTES
  dynamic toUserProfile(String uid) {
    final path = "/users/$uid";
    HSDebugLogger.logInfo("Navigating to: $path");
    return router.push(path);
  }

  dynamic toSpot(String sid) => router.push("spot/$sid");
}

class _HSRoutes {
  // SINGLETON
  _HSRoutes._internal();
  static final _HSRoutes _instance = _HSRoutes._internal();
  static _HSRoutes get instance => _instance;

  final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
        redirect: (context, state) {
          final authBloc = context.watch<HSAuthenticationBloc>();
          return _handleInitialRedirect(authBloc.state.status);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          HSDebugLogger.logInfo(
              "Current state (builder): ${state.matchedLocation}");
          return const LoginProvider();
        },
        redirect: (context, state) {
          HSDebugLogger.logInfo("Current state (redirect): ${state.uri}");
          final authBloc = app.authBloc;
          final String? from = state.uri.queryParameters['from'];
          return _handleInitialRedirect(authBloc.state.status, from);
        },
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const PopScope(canPop: false, child: HomePage()),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsProvider(),
          ),
          GoRoute(
            path: 'home',
            redirect: (context, state) => "/",
          ),
          GoRoute(
            path: 'users/:userID',
            builder: (context, state) =>
                UserProfileProvider(userID: state.pathParameters['userID']!),
            redirect: _authGuardRedirect,
          ),
          GoRoute(
            path: 'spots/:spotID',
            builder: (context, state) =>
                InfoPage(infoText: state.pathParameters['spotID']!),
            redirect: _authGuardRedirect,
          ),
        ],
      ),
    ],
  );
}

String? _authGuardRedirect(context, GoRouterState state) {
  if (app.authBloc.state.status != HSAppStatus.authenticated) {
    HSDebugLogger.logError("The user is not authenticated");
    HSDebugLogger.logError("Matched Location: ${state.matchedLocation}");
    return "/login?from=${state.matchedLocation}";
  }
  return null;
}

String? _handleInitialRedirect(HSAppStatus appStatus, [String? savedLocation]) {
  final String suffix = savedLocation != null ? "?from=$savedLocation" : "";
  switch (appStatus) {
    case HSAppStatus.unauthenticated:
      return "/login$suffix";
    case HSAppStatus.emailNotVerified:
      return "/verify_email$suffix";
    case HSAppStatus.profileNotCompleted:
      return "/complete_profile$suffix";
    case HSAppStatus.authenticated:
      if (savedLocation != null) {
        HSDebugLogger.logInfo("SAVED LOCATION PROVIDED 1: $savedLocation");
        return savedLocation;
      }
      HSDebugLogger.logInfo("SAVED LOCATION NOT PROVIDED");
      return "/";
    default:
      return null;
  }
}
