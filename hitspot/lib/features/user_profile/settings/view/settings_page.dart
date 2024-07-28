import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/settings/bloc/hs_settings_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        title:
            Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        enableDefaultBackButton: true,
      ),
      body: BlocBuilder<HsSettingsBloc, HsSettingsState>(
        builder: (context, settingsState) {
          HsSettingsBloc settingsCubit = context.read<HsSettingsBloc>();
          if (settingsState is HsSettingsStateInitial) {
            return const HSLoadingIndicator(
              size: 64.0,
            );
          }
          return ListView(
            children: [
              ThemedSettingsSection(
                title: 'Application',
                tiles: [
                  SettingsTile(
                    icon: FontAwesomeIcons.globe,
                    title: 'Language',
                    enabled: false,
                  ),
                  SettingsTile(
                    icon: FontAwesomeIcons.moon,
                    title: 'Switch Theme',
                    subtitle: 'Press here to toggle theme.',
                    onTap: () => settingsCubit.switchTheme(),
                  ),
                ],
              ),
              ThemedSettingsSection(
                title: 'Permissions',
                tiles: [
                  const SettingsTile(
                    icon: FontAwesomeIcons.bell,
                    title: 'Push Notifications',
                    enabled: false,
                  ),
                  const SettingsTile(
                    icon: FontAwesomeIcons.mapPin,
                    title: 'Location',
                    enabled: false,
                  ),
                  SettingsTile(
                    icon: FontAwesomeIcons.images,
                    title: 'Gallery',
                    onTap: () => settingsCubit
                        .launchSettings(HSLaunchSettingsType.gallery),
                  ),
                ],
              ),
              const ThemedSettingsSection(
                title: 'Legal',
                tiles: [
                  SettingsTile(
                    icon: FontAwesomeIcons.file,
                    title: 'Terms and Conditions',
                    enabled: false,
                  ),
                  SettingsTile(
                    icon: FontAwesomeIcons.file,
                    title: 'Privacy Policy',
                    enabled: false,
                  ),
                ],
              ),
              ThemedSettingsSection(
                title: 'Account',
                tiles: [
                  const SettingsTile(
                    icon: FontAwesomeIcons.lock,
                    title: 'Change Password',
                    // onTap: () => settingsCubit.changePassword(),
                    enabled: false,
                  ),
                  SettingsTile(
                    icon: FontAwesomeIcons.trash,
                    title: 'Delete Account',
                    onTap: () => settingsCubit.deleteAccount(),
                  ),
                  SettingsTile(
                    icon: FontAwesomeIcons.signOutAlt,
                    title: 'Sign Out',
                    onTap: () => settingsCubit.signOut(),
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

class ThemedSettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsTile> tiles;

  const ThemedSettingsSection({
    Key? key,
    required this.title,
    required this.tiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.brightness == Brightness.light
          ? theme.scaffoldBackgroundColor
          : theme.highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          ...tiles,
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      minLeadingWidth: 24,
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      trailing: onTap != null ? Icon(Icons.chevron_right) : null,
    );
  }
}
