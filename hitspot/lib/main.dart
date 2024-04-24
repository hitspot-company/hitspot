// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:get/get.dart';
import 'package:hitspot/blocs/authentication/hs_app_bloc.dart';
import 'package:hitspot/firebase_options.dart';
import 'package:hitspot/repositories/hs_authentication_repository.dart';
import 'package:hitspot/utils/hs_app.dart';
import 'package:hs_firebase_config/hs_firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: HSFirebaseConfigLoader.loadOptions);
  await FlutterConfig.loadEnvVariables();

  final authenticationRepository = HSAuthenticationRepository();
  // Bind Firebase authentication stream to our HSUser
  await authenticationRepository.user.first;

  // Get.put(HSApp());
  runApp(App(
    authenticationRepository: authenticationRepository,
  ));
}

class App extends StatelessWidget {
  final HSAuthenticationRepository _authenticationRepository;

  const App(
      {required HSAuthenticationRepository authenticationRepository, super.key})
      : _authenticationRepository = authenticationRepository;
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: BlocProvider(
        create: (_) => HSAppBloc(
          authenticationRepository: _authenticationRepository,
        ),
        child: Container(),
      ),
    );
  }
}
