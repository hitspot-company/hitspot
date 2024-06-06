import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/user_profile/settings/bloc/hs_settings_bloc.dart';
import 'package:hitspot/features/user_profile/settings/view/settings_page.dart';

class SettingsProvider extends StatelessWidget {
  const SettingsProvider({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SettingsProvider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsSettingsBloc(),
      child: const SettingsPage(),
    );
  }
}
