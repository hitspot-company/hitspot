import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/login/view/login_provider.dart';
import 'package:hitspot/features/profile_incomplete/view/profile_completion_page.dart';
import 'package:hitspot/features/register/view/register_page.dart';
import 'package:hitspot/features/splash/view/splash_page.dart';
import 'package:hitspot/features/tmp/info_page/view/info_page.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider.dart';
import 'package:hitspot/features/user_profile/settings/view/settings_provider.dart';
import 'package:hitspot/features/verify_email/view/verify_email_page.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSNavigationService {
  // SINGLETON
  HSNavigationService._internal();
  static final HSNavigationService _instance = HSNavigationService._internal();
  static HSNavigationService get instance => _instance;
  static final routes = _HSRoutes.instance;

  GlobalKey<NavigatorState> get navigatorKey =>
      routes.router.routerDelegate.navigatorKey;
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
  // dynamic toUserProfile(String uid) => router.push("/users/$uid");
  // dynamic toSpot(String sid) => router.push("/spot/$sid");
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
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginProvider(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/verify_email',
        builder: (context, state) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: '/complete_profile',
        builder: (context, state) => const ProfileCompletionPage(),
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
            path: 'user/:userID',
            builder: (context, state) =>
                UserProfileProvider(userID: state.pathParameters['userID']!),
          ),
          GoRoute(
            path: 'spot/:spotID',
            builder: (context, state) =>
                InfoPage(infoText: state.pathParameters['spotID']!),
            // redirect: _authGuardRedirect,
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = context.read<HSAuthenticationBloc>().state.status ==
          HSAppStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      final appStatus = context.read<HSAuthenticationBloc>().state.status;
      late final String ret;
      HSDebugLogger.logInfo("REQUEST: ${state.matchedLocation}");
      switch (appStatus) {
        case HSAppStatus.loading || HSAppStatus.splash:
          ret = "/splash";
        case HSAppStatus.unauthenticated:
          ret = "/login";
        case HSAppStatus.emailNotVerified:
          ret = "/verify_email";
        case HSAppStatus.profileNotCompleted:
          ret = "/complete_profile";
        case HSAppStatus.authenticated:
          if (state.matchedLocation != '/' &&
              state.matchedLocation != '/splash') return state.matchedLocation;
          ret = '/';
      }
      return ret;
    },
  );
}

// String? _authGuardRedirect(context, GoRouterState state) {
//   if (app.authBloc.state.status != HSAppStatus.authenticated) {
//     HSDebugLogger.logError("The user is not authenticated");
//     HSDebugLogger.logError("Matched Location: ${state.matchedLocation}");
//     return "/login?from=${state.matchedLocation}";
//   }
//   return null;
// }

// String? _handleInitialRedirect(HSAppStatus appStatus, [String? savedLocation]) {
//   final String suffix = savedLocation != null ? "?from=$savedLocation" : "";
//   switch (appStatus) {
//     case HSAppStatus.unauthenticated:
//       return "/login$suffix";
//     case HSAppStatus.emailNotVerified:
//       return "/verify_email$suffix";
//     case HSAppStatus.profileNotCompleted:
//       return "/complete_profile$suffix";
//     case HSAppStatus.authenticated:
//       if (savedLocation != null) {
//         // HSDebugLogger.logInfo("SAVED LOCATION PROVIDED 1: $savedLocation");
//         return savedLocation;
//       }
//       // HSDebugLogger.logInfo("SAVED LOCATION NOT PROVIDED");
//       return "/";
//     default:
//       return null;
//   }
// }
