import 'package:flutter/material.dart';

class HSNavigationService {
  // SINGLETON
  HSNavigationService._internal();
  static final HSNavigationService _instance = HSNavigationService._internal();
  static HSNavigationService get instance => _instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  dynamic pushNamed(String route, {dynamic arguments}) {
    return navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  dynamic pop() {
    return navigatorKey.currentState?.pop();
  }
}

// class _HSRoutes {
//   static Route<dynamic> generateRoutes(RouteSettings settings) {
//     switch (settings.name) {
//       case '/home':
//         return MaterialPageRoute(builder: (context) => const HomePage());
//       case '/login':
//         return MaterialPageRoute(builder: (context) => const LoginPage());
//       case '/register':
//         return MaterialPageRoute(builder: (context) => const RegisterPage());
//       case '/profile_completion':
//         return MaterialPageRoute(
//             builder: (context) => const ProfileCompletionPage());
//       default:
//         return MaterialPageRoute(
//           builder: (context) => Scaffold(
//             body: Center(
//               child: Text("Not found ${settings.name}"),
//             ),
//           ),
//         );
//     }
//   }
// }
