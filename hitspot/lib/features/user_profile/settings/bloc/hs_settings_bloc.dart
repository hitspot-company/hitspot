import 'package:app_settings/app_settings.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/password_reset/view/password_reset_page.dart';
import 'package:hitspot/theme/bloc/hs_theme_bloc.dart';

part 'hs_settings_event.dart';
part 'hs_settings_state.dart';

class HsSettingsBloc extends Bloc<HsSettingsEvent, HsSettingsState> {
  HsSettingsBloc() : super(const HsSettingsStateReady()) {
    on<HSSettingsSwitchThemeModeEvent>((event, emit) async {
      app.themeBloc.add(HSThemeSwitchEvent());
    });
  }

  void switchTheme() => add(const HSSettingsSwitchThemeModeEvent());

  void signOut() => app.logout();

  void launchSettings(HSLaunchSettingsType launchSettingsType) {
    switch (launchSettingsType) {
      case HSLaunchSettingsType.gallery:
        AppSettings.openAppSettings(type: AppSettingsType.settings);
        break;
    }
  }

  void changePassword() => navi.push(PasswordResetPage.route());
}
