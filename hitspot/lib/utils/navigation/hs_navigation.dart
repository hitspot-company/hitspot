import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/boards/add_board/view/add_board_provider.dart';
import 'package:hitspot/features/boards/single_board/view/board_provider.dart';
import 'package:hitspot/features/error/view/error_page.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/login/view/login_provider.dart';
import 'package:hitspot/features/profile_incomplete/view/profile_completion_page.dart';
import 'package:hitspot/features/register/view/register_page.dart';
import 'package:hitspot/features/saved/view/saved_provider.dart';
import 'package:hitspot/features/splash/view/splash_page.dart';
import 'package:hitspot/features/tmp/info_page/view/info_page.dart';
import 'package:hitspot/features/trips/create_trip/view/create_trip_provider.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider.dart';
import 'package:hitspot/features/user_profile/settings/view/settings_provider.dart';
import 'package:hitspot/features/verify_email/view/verify_email_page.dart';
import 'package:hitspot/utils/navigation/transitions/bottom_to_top.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSNavigation {
  // SINGLETON
  HSNavigation._internal();
  static final HSNavigation _instance = HSNavigation._internal();
  static HSNavigation get instance => _instance;
  static final routing = HSRouting.instance;
  static final routes = _HSRoutes();

  GlobalKey<NavigatorState> get navigatorKey =>
      routing.router.routerDelegate.navigatorKey;
  GoRouter get router => routing.router;

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
  dynamic toUserProfile(String userID) => routes.toUserProfile(userID);
  dynamic toError(String headingText, String bodyText) =>
      routes.toError(headingText, bodyText);
  dynamic toBoard(String boardID) => routes.toBoard(boardID);
  dynamic toCreateTrip({HSBoard? board}) => routes.toCreateTrip(board: board);
}

class HSRouting {
  // SINGLETON
  HSRouting._internal();
  static final HSRouting _instance = HSRouting._internal();
  static HSRouting get instance => _instance;

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
        path: '/saved',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/spot/:spotID',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/info/:text',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/board/:boardID',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/add_board',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
          path: '/error',
          redirect: (context, state) {
            final headingText = state.uri.queryParameters["headingText"];
            final bodyText = state.uri.queryParameters["bodyText"];
            if (headingText == null || bodyText == null) {
              HSDebugLogger.logError(
                  "No headingText and bodyText provided, redirecting to /");
            }
            return '/protected/home/error?headingText=$headingText&bodyText=$bodyText';
          }),
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
                path: 'board/:boardID',
                builder: (context, state) =>
                    BoardProvider(boardID: state.pathParameters['boardID']!),
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
              GoRoute(
                path: 'saved',
                builder: (context, state) => const SavedProvider(),
              ),
              GoRoute(
                  path: 'info/:text',
                  builder: (context, state) =>
                      InfoPage(infoText: state.pathParameters['text']!)),
              GoRoute(
                  path: 'error',
                  builder: (context, state) {
                    final headingText =
                        state.uri.queryParameters["headingText"] ?? "";
                    final bodyText =
                        state.uri.queryParameters["bodyText"] ?? "";
                    return ErrorPage(
                        headingText: headingText, bodyText: bodyText);
                  }),
            ],
          ),
        ],
      ),
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

class _HSRoutes {
  dynamic toError(String headingText, String bodyText) =>
      navi.router.go("/error?headingText=$headingText&bodyText=$bodyText");
  dynamic toUserProfile(String userID) => navi.router.push("/user/$userID");
  dynamic toBoard(String boardID) => navi.router.push("/board/$boardID");
  dynamic toCreateTrip({HSBoard? board}) =>
      navi.push(BottomToTopPage(child: const CreateTripProvider())
          .createRoute(app.context!));
}
