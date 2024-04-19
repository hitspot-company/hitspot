import 'package:hitspot/services/theme/hs_theme.dart';

class HSThemeRepository {
  final HSThemeService service;

  const HSThemeRepository({required this.service});

  Future<bool> isDark() async => await service.isDark();
  Future<void> setTheme(bool isDark) async => await service.setTheme(isDark);
}
