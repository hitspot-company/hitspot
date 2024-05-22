import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/settings/bloc/hs_settings_bloc.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<HsSettingsBloc>();
    return HSScaffold(
      appBar: HSAppBar(
        title: "",
        enableDefaultBackButton: true,
      ),
      body: BlocBuilder<HsSettingsBloc, HsSettingsState>(
        builder: (context, state) {
          if (state is HsSettingsStateInitial) {
            return const HSLoadingIndicator(
              size: 64.0,
            );
          }
          return SettingsList(
            contentPadding: const EdgeInsets.all(0.0),
            lightTheme: SettingsThemeData(
              settingsSectionBackground:
                  currentTheme.currentTheme.scaffoldBackgroundColor,
              settingsListBackground:
                  currentTheme.currentTheme.scaffoldBackgroundColor,
            ),
            darkTheme: SettingsThemeData(
              settingsSectionBackground:
                  currentTheme.currentTheme.highlightColor,
              settingsListBackground:
                  currentTheme.currentTheme.scaffoldBackgroundColor,
            ),
            sections: [
              SettingsSection(
                title: const Text('Application'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.globe),
                    title: const Text('Language'),
                    enabled: false,
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.moon),
                    title: const Text('Switch Theme'),
                    description: const Text('Press here to toggle theme.'),
                    onPressed: (context) =>
                        settingsCubit.switchTheme(), // BUG: Weird Colors
                  )
                ],
              ),
              SettingsSection(
                title: const Text('Permissions'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.bell),
                    title: const Text('Push Notifications'),
                    enabled: false,
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.mapPin),
                    title: const Text('Location'),
                    enabled: false,
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.images),
                    title: const Text('Gallery'),
                    onPressed: (_) => settingsCubit
                        .launchSettings(HSLaunchSettingsType.gallery),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Legal'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.file),
                    title: const Text('Terms and Conditions'),
                    enabled: false,
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.file),
                    title: const Text('Privacy Policy'),
                    enabled: false,
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Account'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.lock),
                    title: const Text('Change Password'),
                    onPressed: (_) => settingsCubit.changePassword(),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.trash),
                    title: const Text('Delete Account'),
                    enabled: false,
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.arrowRightFromBracket),
                    title: const Text('Sign Out'),
                    onPressed: (_) => settingsCubit.signOut(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
