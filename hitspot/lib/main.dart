import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:get/get.dart';
import 'package:hitspot/const/const.dart';
import 'package:hitspot/screens/home/home.dart';
import 'package:hitspot/screens/register/register.dart';
import 'package:hitspot/utils/hs_app.dart';
import 'package:hitspot/utils/hs_app_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterConfig.loadEnvVariables();
  Bloc.observer = HSAppBlocObserver();
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Hitspot',
//       theme: HSApp.instance.theming.darkTheme,
//       initialRoute:
//           "/register", // TODO: Remake as splash screen / some logo animation
//       getPages: [
//         GetPage(name: "/register", page: () => const RegisterPage()),
//         GetPage(name: "/home", page: () => const HomePage()),
//       ],
//     );
//   }
// }
