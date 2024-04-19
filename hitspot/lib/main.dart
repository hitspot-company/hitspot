import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hitspot/bloc/theme/theme_bloc.dart';
import 'package:hitspot/constants/hs_const.dart';
import 'package:hitspot/presentation/screens/home/home.dart';
import 'package:hitspot/presentation/screens/register/register.dart';
import 'package:hitspot/repositories/repo/auth/hs_auth.dart';
import 'package:hitspot/repositories/repo/theme/hs_theme.dart';
import 'package:hitspot/services/theme/hs_theme.dart';
import 'package:hitspot/utils/hs_app_bloc_observer.dart';

import 'bloc/auth/authentication_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterConfig.loadEnvVariables();
  Bloc.observer = HSAppBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(HSAuthenticationRepository())
            ..add(AuthenticationStarted()),
        ),
        BlocProvider(
            create: (context) =>
                HSThemeBloc(HSThemeRepository(service: HSThemeService()))
                  ..add(HSInitialThemeSetEvent())),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSThemeBloc, HSThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const BlocNavigate(),
          title: HSConstants.title,
          theme: state.theme,
        );
      },
    );
  }
}

class BlocNavigate extends StatelessWidget {
  const BlocNavigate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          return const HomePage();
        } else {
          return const RegisterPage();
        }
      },
    );
  }
}
