import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/login/view/login_provider.dart';
import 'package:hitspot/features/profile_incomplete/view/profile_completion_page.dart';
import 'package:hitspot/features/register/view/register_page.dart';
import 'package:hitspot/features/tmp/info_page/view/info_page.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider.dart';
import 'package:hitspot/features/user_profile/settings/view/settings_provider.dart';
import 'package:hitspot/main.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSNavigationService {
  // SINGLETON
  HSNavigationService._internal();
  static final HSNavigationService _instance = HSNavigationService._internal();
  static HSNavigationService get instance => _instance;
  static final routes = _HSRoutes.instance;

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
  dynamic toUserProfile(String uid) => router.push("/users/$uid");
  dynamic toSpot(String sid) => router.push("/spot/$sid");
}

class _HSRoutes {
  // SINGLETON
  _HSRoutes._internal();
  static final _HSRoutes _instance = _HSRoutes._internal();
  static _HSRoutes get instance => _instance;

  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HSFlowBuilder()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginProvider(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsProvider(),
      ),
      GoRoute(
        path: '/users/:userID',
        builder: (context, state) =>
            UserProfileProvider(userID: state.pathParameters['userID']!),
        redirect: (context, state) {
          //   final isLoggedIn =
          //       app.authBloc.state.status == HSAppStatus.authenticated;
          //   final isLoggingIn = state.matchedLocation == '/login';

          //   final savedLocation = state.matchedLocation == '/'
          //       ? ''
          //       : '?from=${state.matchedLocation}';

          //   if (!isLoggedIn) return isLoggingIn ? null : '/login$savedLocation';

          //   if (isLoggingIn) return state.uri.queryParameters['from'] ?? '/';

          //   return null;
          // TODO: Implement remembering destination
        },
      ),
      GoRoute(
        path: '/spot/:spotID',
        builder: (context, state) =>
            InfoPage(infoText: state.pathParameters['spotID']!),
      ),
    ],
  );
}
