import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/boards/create/view/create_board_provider.dart';
import 'package:hitspot/features/boards/invitation/view/board_invitation_page.dart';
import 'package:hitspot/features/boards/single/view/single_board_provider.dart';
import 'package:hitspot/features/complete_profile/view/complete_profile_provider.dart';
import 'package:hitspot/features/deep_link_error/view/deep_link_error_page.dart';
import 'package:hitspot/features/home/main/view/home_provider.dart';
import 'package:hitspot/features/home/update/view/home_provider_up.dart';
import 'package:hitspot/features/login/magic_link/view/magic_link_sent_provider.dart';
import 'package:hitspot/features/login/view/login_provider.dart';
import 'package:hitspot/features/map/cluster/view/cluster_map_provider.dart';
import 'package:hitspot/features/notifications/view/notifications_provider.dart';
import 'package:hitspot/features/saved/view/saved_provider.dart';
import 'package:hitspot/features/splash/view/splash_page.dart';
import 'package:hitspot/features/spots/create/images/view/create_spot_images_provider.dart';
import 'package:hitspot/features/spots/multiple/cubit/hs_multiple_spots_cubit.dart';
import 'package:hitspot/features/spots/multiple/view/multiple_spots_provider.dart';
import 'package:hitspot/features/spots/single/view/single_spot_provider.dart';
import 'package:hitspot/features/tags/explore/view/tags_explore_provider.dart';
import 'package:hitspot/features/user_profile/edit_profile/view/edit_profile_provider.dart';
import 'package:hitspot/features/user_profile/settings/view/settings_provider.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider_updated.dart';
import 'package:page_transition/page_transition.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSNavigation {
  HSNavigation._privateConstructor();
  static final HSNavigation _instance = HSNavigation._privateConstructor();

  factory HSNavigation() => _instance;

  BuildContext get context => router.configuration.navigatorKey.currentContext!;

  dynamic pop([dynamic value = false]) => router.pop(value);

  dynamic pushPage({required Widget page}) =>
      router.configuration.navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => page),
      );
  dynamic push(String location) => router.push(location);
  dynamic pushTransition(PageTransitionType transition, Widget page) =>
      router.configuration.navigatorKey.currentState!.push(
        PageTransition(
            curve: Curves.easeIn,
            type: transition,
            child: page,
            duration: const Duration(milliseconds: 350),
            reverseDuration: const Duration(milliseconds: 350),
            alignment: Alignment.bottomCenter),
      );
  dynamic go(String location) => context.go(location);
  dynamic replacePage({required Widget page}) =>
      router.configuration.navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );

  dynamic replace(String location) => GoRouter.of(context).replace(location);

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
          redirect: (context, state) {
            HSDebugLogger.logInfo("RECEIVED LINK!");
            return '/protected/home?from=${state.matchedLocation}';
          }),
      GoRoute(
        path: '/notifications',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/spot/:spotID',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/board/:boardID',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/create_board',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/create_spot',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/saved',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/edit_profile',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/settings',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/tags_explore/:tag',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
          path: '/invite/:boardId',
          redirect: (context, state) {
            HSDebugLogger.logInfo("RECEIVED INVITATION!");
            return '/protected/home?from=${state.matchedLocation}?token=${state.uri.queryParameters["token"]}';
          }),
      GoRoute(
        path: '/error',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/login-callback',
        redirect: (context, state) => '/protected/home',
      ),
      GoRoute(
        path: '/error',
        redirect: (context, state) =>
            '/protected/home?from=${state.matchedLocation}',
      ),
      GoRoute(
        path: '/login-callback',
        redirect: (context, state) => '/protected/home',
      ),
      GoRoute(
        path: "/protected",
        redirect: _protectedRedirect,
        routes: [
          GoRoute(
            path: "home",
            builder: (context, state) => const HomeProvider(),
            redirect: (context, state) {
              final String? from = state.uri.queryParameters["from"];
              if (from != null) {
                return '/protected/home$from';
              }
              return null;
            },
            routes: [
              // GoRoute(
              //   path: 'user/:userID',
              //   builder: (context, state) => UserProfileProvider(
              //       userID: state.pathParameters['userID']!),
              // ),
              GoRoute(
                  path: 'user/:userID',
                  builder: (context, state) => UserProfileProviderUpdated(
                      userID: state.pathParameters['userID']!)),
              GoRoute(
                path: 'edit_profile',
                builder: (context, state) => const EditProfileProvider(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsProvider(),
              ),
              GoRoute(
                path: 'error',
                builder: (context, state) => DeepLinkErrorPage(
                  title: state.uri.queryParameters['title'],
                  message: state.uri.queryParameters['message'],
                ),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const NotificationsProvider(),
              ),
              GoRoute(
                path: 'board/:boardID',
                builder: (context, state) => SingleBoardProvider(
                    boardID: state.pathParameters['boardID']!,
                    title: state.uri.queryParameters['title'] ?? "title :("),
              ),
              GoRoute(
                path: 'spot/:spotID',
                builder: (context, state) =>
                    SingleSpotProvider(spotID: state.pathParameters['spotID']!),
              ),
              GoRoute(
                path: 'create_board',
                builder: (context, state) => const CreateBoardProvider(),
              ),
              GoRoute(
                path: 'create_spot',
                builder: (context, state) => const CreateSpotImagesProvider(),
              ),
              GoRoute(
                path: 'saved',
                builder: (context, state) => const SavedProvider(),
              ),
              GoRoute(
                  path: 'tags_explore/:tag',
                  builder: (context, state) =>
                      TagsExploreProvider(tag: state.pathParameters['tag']!)),
              GoRoute(
                  path: 'invite/:boardId',
                  builder: (context, state) => BoardInvitationPage(
                      boardId: state.pathParameters['boardId'] ?? "",
                      token: state.uri.queryParameters['token'] ?? "")),
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
                MagicLinkSentProvider(email: state.uri.queryParameters["to"]!),
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
  dynamic toBoard({required String boardID, required String? title}) =>
      router.push('/board/$boardID${title != null ? "?title=$title" : ""}');
  dynamic toCreateBoard() => router.push('/create_board');
  dynamic toSettings() => router.push('/settings');
  dynamic toEditProfile() => router.push('/edit_profile');
  dynamic toCreateSpot() => router.push('/create_spot');
  dynamic toNotifications() => router.push('/notifications');
  dynamic toSpotsMap() => pushPage(page: const ClusterMapProvider());
  dynamic toMultipleSpots(HSMultipleSpotsType type, [String? userID]) =>
      pushPage(page: MultipleSpotsProvider(type: type, userID: userID));
  dynamic toTagsExplore(String tag) => router.push('/tags_explore/$tag');
  dynamic toSpot(
          {required String sid,
          String? authorID,
          bool isSubmit = false,
          String? spotID}) =>
      isSubmit ? router.go("/spot/$sid") : router.push('/spot/$sid');
  dynamic toError({String? title, String? message}) =>
      router.replace("/error?title=$title&message=$message");
  dynamic toCurrentUser() => router.push("/user/${currentUser.uid}");
}
