import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/blocs/theme/hs_theme_bloc.dart';
import 'package:hitspot/presentation/widgets/hs_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      body: Container(
        child: Center(
          child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<HSThemeBloc>().add(HSThemeSwitchEvent()),
              icon: const Icon(FontAwesomeIcons.pallet),
              label: const Text("Change theme")),
        ),
      ),
    );
  }
}
