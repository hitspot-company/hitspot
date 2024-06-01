import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_storage_repository/hs_storage_repository.dart';
import 'package:hs_theme_repository/hs_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await Supabase.initialize(
      url: FlutterConfig.get("SUPABASE_URL"),
      anonKey: FlutterConfig.get("SUPABASE_ANON_KEY"));

  final HSAuthenticationRepository authenticationRepository =
      HSAuthenticationRepository(supabase);
  final HSThemeRepository themeRepository = HSThemeRepository.instance;
  runApp(MyApp(
    authenticationRepository: authenticationRepository,
    themeRepository: themeRepository,
  ));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key,
      required this.authenticationRepository,
      required this.themeRepository});

  final HSAuthenticationRepository authenticationRepository;
  final HSThemeRepository themeRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: authenticationRepository,
        ),
        RepositoryProvider(
          create: (context) => HSDatabaseRepsitory(supabase),
        ),
        RepositoryProvider(
          create: (context) => HSStorageRepository(supabase),
        ),
        RepositoryProvider.value(
          value: themeRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HSAuthenticationBloc(),
          ),
          BlocProvider(
              create: (_) =>
                  HSThemeBloc(themeRepository)..add(HSInitialThemeSetEvent())),
        ],
        child: BlocListener<HSAuthenticationBloc, HSAuthenticationState>(
          listener: (context, state) {
            app.navigation.router.refresh();
          },
          child: BlocSelector<HSThemeBloc, HSThemeState, ThemeData>(
            selector: (state) => state.theme,
            builder: (context, theme) {
              return MaterialApp.router(
                theme: theme,
                title: 'Hitspot',
                routerConfig: app.navigation.router,
              );
            },
          ),
        ),
      ),
    );
  }
}
