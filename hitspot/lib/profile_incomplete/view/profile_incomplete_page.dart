import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class ProfileIncompletePage extends StatelessWidget {
  const ProfileIncompletePage({super.key});

  static Page<void> page() =>
      const MaterialPage<void>(child: ProfileIncompletePage());

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        title: "Complete Profile",
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("THIS PAGE IS YET TO BE IMPLEMENT"),
          const Gap(16.0),
          ElevatedButton(
              onPressed: () => context
                  .read<HSAuthenticationBloc>()
                  .add(const HSAppLogoutRequested()),
              child: const Text("SIGN OUT")),
        ],
      ),
    );
  }
}
