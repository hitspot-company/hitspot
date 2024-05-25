import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/boards/add_board/view/add_board_provider.dart';
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

  // UPDATED NAVI
  dynamic newPush(String location) => router.push(location);

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
        redirect: (context, state) {
          final authBloc = context.read<HSAuthenticationBloc>();
          if (authBloc.state.status != HSAppStatus.loading) {
            return "/protected/home";
          }
          return null;
        },
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/protected/home',
      ),
      GoRoute(
        path: '/user/:userID',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/spot/:spotID',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/add_board',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
          path: '/protected',
          redirect: (context, state) {
            final authBloc = context.read<HSAuthenticationBloc>();
            final String from = "?from=${state.uri}";
            final loggedIn = authBloc.state.status == HSAppStatus.authenticated;
            if (!loggedIn) {
              final String ret = "/auth$from";
              return ret;
            }
            return null;
          },
          routes: [
            GoRoute(
              path: 'home',
              builder: (context, state) => const HomePage(),
              redirect: (context, state) {
                final String? from = state.uri.queryParameters["from"];
                if (from != null) {
                  return '/protected/home$from';
                }
                return null;
              },
              routes: [
                GoRoute(
                  path: 'user/:userID',
                  builder: (context, state) => UserProfileProvider(
                      userID: state.pathParameters['userID']!),
                ),
                GoRoute(
                  path: 'spot/:spotID',
                  builder: (context, state) =>
                      InfoPage(infoText: state.pathParameters['spotID']!),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsProvider(),
                ),
                GoRoute(
                  path: 'add_board',
                  builder: (context, state) => const AddBoardProvider(),
                ),
              ],
            ),
          ]),
      GoRoute(
        path: '/auth',
        redirect: (context, state) {
          final String from = "?from=${state.uri.queryParameters["from"]}";
          final authBloc = context.read<HSAuthenticationBloc>();
          final appStatus = authBloc.state.status;
          late final String ret;
          switch (appStatus) {
            case HSAppStatus.emailNotVerified:
              ret = "/auth/verify_email$from";
            case HSAppStatus.profileNotCompleted:
              ret = "/auth/complete_profile$from";
            case HSAppStatus.authenticated:
              ret = state.uri.queryParameters["from"] ?? "/protected/home";
            default:
              ret = "/auth/login$from";
          }
          return ret;
        },
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterPage(),
          ),
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginProvider(),
          ),
          GoRoute(
            path: 'verify_email',
            builder: (context, state) => const VerifyEmailPage(),
          ),
          GoRoute(
            path: 'complete_profile',
            builder: (context, state) => const ProfileCompletionPage(),
          ),
        ],
      ),
    ],
  );
}
