import 'package:shared_preferences/shared_preferences.dart';

class HSThemeService {
  Future<bool> isDark() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_dark") ?? false;
  }

  Future<void> setTheme(bool isDark) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_dark", !isDark);
    print("Theme set to: ${!isDark ? "Light" : "Dark"}");
  }
}
