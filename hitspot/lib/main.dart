import 'package:firebase_core/firebase_core.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/profile_incomplete/view/profile_completion_form.dart';
import 'package:hitspot/profile_incomplete/view/profile_completion_page.dart';
import 'package:hitspot/splash/view/splash_page.dart';
import 'package:hitspot/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/constants/hs_theme.dart';
import 'package:hitspot/login/view/login_page.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_theme_repository/hs_form_inputs.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_firebase_config/hs_firebase_config.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: HSFirebaseConfigLoader.loadOptions);
  await FlutterConfig.loadEnvVariables();
  final authenticationRepository = HSAuthenticationRepository();
  final databaseRepository = HSDatabaseRepository();
  final themeRepository = HSThemeRepository();

  // Bind Firebase authentication stream to our HSUser
  await authenticationRepository.user.first;
  runApp(App(
    themeRepository: themeRepository,
    authenticationRepository: authenticationRepository,
    databaseRepository: databaseRepository,
  ));
}

class App extends StatelessWidget {
  final HSAuthenticationRepository _authenticationRepository;
  final HSDatabaseRepository _databaseRepository;
  final HSThemeRepository _themeRepository;

  const App(
      {required HSThemeRepository themeRepository,
      required HSAuthenticationRepository authenticationRepository,
      required HSDatabaseRepository databaseRepository,
      super.key})
      : _themeRepository = themeRepository,
        _authenticationRepository = authenticationRepository,
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => HSAuthenticationBloc(
              authenticationRepository: _authenticationRepository,
              databaseRepository: _databaseRepository,
            ),
          ),
          BlocProvider(
            create: (_) =>
                HSThemeBloc(_themeRepository)..add(HSInitialThemeSetEvent()),
          ),
        ],
        child: BlocSelector<HSThemeBloc, HSThemeState, ThemeData>(
          selector: (state) => state.theme,
          builder: (context, currentTheme) {
            return MaterialApp(
              theme: currentTheme,
              title: "Hitspot",
              home: FlowBuilder<HSAppStatus>(
                state: context
                    .select((HSAuthenticationBloc bloc) => bloc.state.status),
                onGeneratePages: (appStatus, pages) => [
                  if (appStatus == HSAppStatus.loading) SplashPage.page(),
                  if (appStatus == HSAppStatus.unauthenticated)
                    LoginPage.page(),
                  if (appStatus == HSAppStatus.profileNotCompleted)
                    ProfileCompletionPage.page(),
                  if (appStatus == HSAppStatus.authenticated)
                    const MaterialPage(
                      child: Center(
                        child: Text("HOME PAGE"),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
