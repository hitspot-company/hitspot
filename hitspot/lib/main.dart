import 'package:firebase_core/firebase_core.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hitspot/blocs/authentication/hs_app_bloc.dart';
import 'package:hitspot/blocs/theme/hs_theme_bloc.dart';
import 'package:hitspot/constants/hs_theme.dart';
import 'package:hitspot/login/view/login_page.dart';
import 'package:hitspot/repositories/hs_authentication_repository.dart';
import 'package:hitspot/repositories/hs_theme.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_firebase_config/hs_firebase_config.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: HSFirebaseConfigLoader.loadOptions);
  await FlutterConfig.loadEnvVariables();
  final authenticationRepository = HSAuthenticationRepository();
  final themeRepository = HSThemeRepository();

  // Bind Firebase authentication stream to our HSUser
  await authenticationRepository.user.first;
  runApp(App(
    themeRepository: themeRepository,
    authenticationRepository: authenticationRepository,
  ));
}

class App extends StatelessWidget {
  final HSAuthenticationRepository _authenticationRepository;
  final HSThemeRepository _themeRepository;

  const App(
      {required HSThemeRepository themeRepository,
      required HSAuthenticationRepository authenticationRepository,
      super.key})
      : _themeRepository = themeRepository,
        _authenticationRepository = authenticationRepository;
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => HSAuthenticationBloc(
              authenticationRepository: _authenticationRepository,
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
                state: context.read<HSAuthenticationBloc>().state.status,
                onGeneratePages: (appStatus, pages) => [
                  if (appStatus == HSAppStatus.loading)
                    MaterialPage(
                      child: HSScaffold(
                        body: Center(
                          child: LoadingAnimationWidget.beat(
                              color: HSTheme.instance.mainColor, size: 32.0),
                        ),
                      ),
                    ),
                  LoginPage.page(),
                  if (appStatus == HSAppStatus.profileNotCompleted)
                    const MaterialPage(
                      child: Center(
                        child: Text("PROFILE NOT COMPLETE"),
                      ),
                    ),
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
