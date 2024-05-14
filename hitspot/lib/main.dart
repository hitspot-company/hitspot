import 'package:firebase_core/firebase_core.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/home/view/home_page.dart';
import 'package:hitspot/profile_incomplete/view/profile_completion_page.dart';
import 'package:hitspot/splash/view/splash_page.dart';
import 'package:hitspot/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/login/view/login_page.dart';
import 'package:hitspot/utils/navigation/hs_navigation_service.dart';
import 'package:hitspot/verify_email/view/verify_email_page.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_firebase_config/hs_firebase_config.dart';
import 'package:hs_mailing_repository/hs_mailing_repository.dart';
import 'package:hs_search_repository/hs_search.dart';
import 'package:hs_theme_repository/hs_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: HSFirebaseConfigLoader.loadOptions);
  await FlutterConfig.loadEnvVariables();
  final authenticationRepository = HSAuthenticationRepository();
  final databaseRepository = HSDatabaseRepository();
  final themeRepository = HSThemeRepository();
  final mailingRepository = HSMailingRepository();
  final searchRepository = HSSearchRepository();
  Animate.restartOnHotReload = true;

  // Bind Firebase authentication stream to our HSUser
  await authenticationRepository.user.first;
  runApp(App(
    mailingRepository: mailingRepository,
    searchRepository: searchRepository,
    themeRepository: themeRepository,
    authenticationRepository: authenticationRepository,
    databaseRepository: databaseRepository,
  ));
}

class App extends StatelessWidget {
  final HSAuthenticationRepository _authenticationRepository;
  final HSDatabaseRepository _databaseRepository;
  final HSThemeRepository _themeRepository;
  final HSMailingRepository _mailingRepository;
  final HSSearchRepository _searchRepository;

  const App(
      {required HSThemeRepository themeRepository,
      required HSAuthenticationRepository authenticationRepository,
      required HSDatabaseRepository databaseRepository,
      required HSMailingRepository mailingRepository,
      required HSSearchRepository searchRepository,
      super.key})
      : _themeRepository = themeRepository,
        _authenticationRepository = authenticationRepository,
        _mailingRepository = mailingRepository,
        _searchRepository = searchRepository,
        _databaseRepository = databaseRepository;
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => HSAuthenticationRepository(),
        ),
        RepositoryProvider(
          create: (context) => HSDatabaseRepository(),
        ),
        RepositoryProvider(
          create: (context) => HSMailingRepository(),
        ),
        RepositoryProvider(
          create: (context) => HSSearchRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => HSAuthenticationBloc(
                authenticationRepository: _authenticationRepository,
                databaseRepository: _databaseRepository,
                mailingRepository: _mailingRepository),
          ),
          BlocProvider(
              create: (_) =>
                  HSThemeBloc(_themeRepository)..add(HSInitialThemeSetEvent())),
        ],
        child: BlocSelector<HSThemeBloc, HSThemeState, ThemeData>(
          selector: (state) => state.theme,
          builder: (context, currentTheme) {
            return MaterialApp(
              theme: currentTheme,
              title: "Hitspot",
              navigatorKey: HSNavigationService.instance.navigatorKey,
              builder: (context, child) => Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) =>
                        child ??
                        const Center(
                          child: Text("OVERLAY ERROR"),
                        ),
                  ),
                ],
              ),
              home: const _HSFlowBuilder(),
            );
          },
        ),
      ),
    );
  }
}

class _HSFlowBuilder extends StatelessWidget {
  const _HSFlowBuilder();

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<HSAppStatus>(
      state: context.select((HSAuthenticationBloc bloc) => bloc.state.status),
      onGeneratePages: (appStatus, pages) => [
        if (appStatus == HSAppStatus.loading)
          SplashPage.page()
        else if (appStatus == HSAppStatus.unauthenticated)
          LoginPage.page()
        else if (appStatus == HSAppStatus.emailNotVerified)
          VerifyEmailPage.page()
        else if (appStatus == HSAppStatus.profileNotCompleted)
          ProfileCompletionPage.page()
        else if (appStatus == HSAppStatus.authenticated)
          HomePage.page(),
      ],
    );
  }
}
