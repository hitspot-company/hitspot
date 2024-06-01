import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/utils/navigation/hs_navigation.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await Supabase.initialize(
      url: FlutterConfig.get("SUPABASE_URL"),
      anonKey: FlutterConfig.get("SUPABASE_ANON_KEY"));

  final HSAuthenticationRepository authenticationRepository =
      HSAuthenticationRepository(supabase);
  runApp(MyApp(
    authenticationRepository: authenticationRepository,
  ));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.authenticationRepository});

  final HSAuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: authenticationRepository,
        ),
        RepositoryProvider(
          create: (context) => HSDatabaseRepsitory(supabase),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HSAuthenticationBloc(),
          ),
        ],
        child: BlocListener<HSAuthenticationBloc, HSAuthenticationState>(
          listener: (context, state) {
            app.navigation.router.refresh();
          },
          child: MaterialApp.router(
            title: 'Hitspot',
            routerConfig: app.navigation.router,
          ),
        ),
      ),
    );
  }
}
