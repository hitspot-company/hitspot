import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/connectivity/bloc/hs_connectivity_bloc.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/features/spots/create/form/cubit/hs_spot_upload_cubit.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/firebase_options.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:hs_storage_repository/hs_storage_repository.dart';
import 'package:hs_theme_repository/hs_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final url = dotenv.env['SUPABASE_URL'];
  final anon = dotenv.env["SUPABASE_ANON_KEY"];
  HSDebugLogger.logInfo("$url: $anon");
  await Supabase.initialize(url: url!, anonKey: anon!);

  await Firebase.initializeApp(
      name: "hitspot", options: DefaultFirebaseOptions.currentPlatform);

  final HSAuthenticationRepository authenticationRepository =
      HSAuthenticationRepository(supabase);
  final HSThemeRepository themeRepository = HSThemeRepository.instance;

  runApp(MyApp(
      authenticationRepository: authenticationRepository,
      themeRepository: themeRepository));
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
            dotenv.env["GOOGLE_MAPS_KEY"]!,
            dotenv.env["GOOGLE_MAPS_KEY"]!,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HSAuthenticationBloc(),
          ),
          BlocProvider(
              create: (_) => HSThemeBloc(
                    themeRepository,
                    HSTheme.instance,
                  )..add(HSInitialThemeSetEvent())),
          BlocProvider(
            create: (_) => HSMainSearchCubit(),
          ),
          BlocProvider(
            create: (_) => HSConnectivityLocationBloc(),
          ),
          BlocProvider(
            create: (_) => HSSpotUploadCubit(),
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
