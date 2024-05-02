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
