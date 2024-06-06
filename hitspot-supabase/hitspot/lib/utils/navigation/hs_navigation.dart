import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/boards/create/view/create_board_provider.dart';
import 'package:hitspot/features/complete_profile/view/complete_profile_provider.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/login/view/login_provider.dart';
import 'package:hitspot/features/login/view/magic_link_sent_page.dart';
import 'package:hitspot/features/splash/view/splash_page.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider.dart';

class HSNavigation {
  HSNavigation._privateConstructor();
  static final HSNavigation _instance = HSNavigation._privateConstructor();
  factory HSNavigation() {
    return _instance;
  }

  BuildContext get context => router.configuration.navigatorKey.currentContext!;
  dynamic pop([bool value = false]) => router.pop(value);
  dynamic pushPage({required Widget page}) =>
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
        path: '/user/:userID',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/create_board',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: "/protected",
        redirect: _protectedRedirect,
        routes: [
          GoRoute(
            path: "home",
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
                path: 'create_board',
                builder: (context, state) => const CreateBoardProvider(),
              ),
            ],
          ),
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
            path: "magic_link_sent",
            builder: (context, state) =>
                MagicLinkSentPage(email: state.uri.queryParameters["to"]!),
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
    final HSAuthenticationState authenticationState =
        BlocProvider.of<HSAuthenticationBloc>(_).state;
    final HSAuthenticationStatus status =
        authenticationState.authenticationStatus;
    final String? path = state.uri.queryParameters['from'];
    final String from = path != null ? "?from=$path" : "";
    switch (status) {
      case HSAuthenticationStatus.unauthenitcated:
        return "/auth/login$from";
      case HSAuthenticationStatus.magicLinkSent:
        final String email =
            (authenticationState as HSAuthenticationMagicLinkSentState).email;
        final String to = "?to=$email";
        return "/auth/magic_link_sent$to";
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

  // Routes
  dynamic toUser({required String userID}) => router.push('/user/$userID');
  dynamic toBoard({required String boardID}) => router.push('/board/$boardID');
  dynamic toCreateBoard() => router.push('/create_board');
}
