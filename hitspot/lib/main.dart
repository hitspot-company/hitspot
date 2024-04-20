import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hitspot/bloc/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/bloc/form_validator/hs_form_validator_cubit.dart';
import 'package:hitspot/bloc/theme/theme_bloc.dart';
import 'package:hitspot/constants/hs_const.dart';
import 'package:hitspot/presentation/screens/auth/auth.dart';
import 'package:hitspot/presentation/screens/email_validation/email_validation.dart';
import 'package:hitspot/presentation/screens/home/home.dart';
import 'package:hitspot/presentation/screens/login/login.dart';
import 'package:hitspot/presentation/screens/register/register.dart';
import 'package:hitspot/repositories/authentication/hs_authentication.dart';
import 'package:hitspot/repositories/theme/hs_theme.dart';
import 'package:hitspot/services/authentication/hs_authentication.dart';
import 'package:hitspot/services/theme/hs_theme.dart';
import 'package:hitspot/utils/hs_app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterConfig.loadEnvVariables();
  Bloc.observer = HSAppBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                HSThemeBloc(HSThemeRepository(service: HSThemeService()))
                  ..add(HSInitialThemeSetEvent())),
        BlocProvider(
          create: (context) => HSFormValidatorCubit(),
        ),
        BlocProvider(
          create: (context) => HSAuthenticationBloc(
            HSAuthenticationRepository(
              authenticationService: HSAuthenticationService(),
            ),
          ),
        ),
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
          routes: {
            HomePage.id: (context) => const HomePage(),
            RegisterPage.id: (context) => RegisterPage(),
            LoginPage.id: (context) => LoginPage(),
            EmailValidationPage.id: (context) => const EmailValidationPage(),
          },
          debugShowCheckedModeBanner: false,
          home: const AuthFlowScreen(),
          title: HSConstants.title,
          theme: state.theme,
        );
      },
    );
  }
}
