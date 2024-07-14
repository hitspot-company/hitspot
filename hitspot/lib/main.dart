import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/connectivity/bloc/hs_connectivity_bloc.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:hs_storage_repository/hs_storage_repository.dart';
import 'package:hs_theme_repository/hs_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  final url = FlutterConfig.get("SUPABASE_URL");
  final anon = FlutterConfig.get("SUPABASE_ANON_KEY");
  HSDebugLogger.logInfo("$url: $anon");
  await Supabase.initialize(url: url, anonKey: anon);

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
        RepositoryProvider(
          create: (_) => HSLocationRepository(
            FlutterConfig.get("GOOGLE_MAPS_KEY"),
            FlutterConfig.get("GOOGLE_MAPS_KEY"),
          ),
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
          BlocProvider(
            create: (_) => HSMainSearchCubit(),
          ),
          BlocProvider(
            create: (_) => HSConnectivityLocationBloc(),
          )
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
              );
            },
          ),
        ),
      ),
    );
  }
}
