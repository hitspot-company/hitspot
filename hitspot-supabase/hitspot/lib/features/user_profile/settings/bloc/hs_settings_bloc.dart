import 'package:app_settings/app_settings.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

part 'hs_settings_event.dart';
part 'hs_settings_state.dart';

class HsSettingsBloc extends Bloc<HsSettingsEvent, HsSettingsState> {
  HsSettingsBloc() : super(const HsSettingsStateReady()) {
    on<HSSettingsSwitchThemeModeEvent>((event, emit) async {
      app.themeBloc.add(HSThemeSwitchEvent());
    });
  }

  void switchTheme() => add(const HSSettingsSwitchThemeModeEvent());

  void signOut() => app.signOut();

  void launchSettings(HSLaunchSettingsType launchSettingsType) {
    switch (launchSettingsType) {
      case HSLaunchSettingsType.gallery:
        AppSettings.openAppSettings(type: AppSettingsType.settings);
        break;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final bool? isDelete = await showAdaptiveDialog(
        context: app.context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text('Delete Account'),
          content: const Text.rich(
            TextSpan(
              text: 'Destructive Action. ',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: "Your account will be deleted permanently.",
                    style: TextStyle(fontWeight: FontWeight.normal))
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => navi.pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => navi.pop(true),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (isDelete == true) {
        HSDebugLogger.logSuccess("Delete");
      } else {
        HSDebugLogger.logError("Cancelled");
      }
    } catch (_) {
      HSDebugLogger.logError(_.toString());
    }
  }
}
