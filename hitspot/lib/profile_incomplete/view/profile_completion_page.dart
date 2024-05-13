import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/authentication/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/profile_incomplete/cubit/hs_profile_completion_cubit.dart';
import 'package:hitspot/profile_incomplete/view/profile_completion_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class ProfileCompletionPage extends StatelessWidget {
  const ProfileCompletionPage({super.key});

  static Page<void> page() =>
      const MaterialPage<void>(child: ProfileCompletionPage());

  @override
  Widget build(BuildContext context) {
    final HSUser currentUser = context.read<HSAuthenticationBloc>().state.user;
    final app = HSApp.instance;
    return HSScaffold(
      appBar: HSAppBar(
        title: "Complete Profile",
        enableDefaultBackButton: true,
        defaultBackButtonCallback: app.logout,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: AutoSizeText.rich(
              TextSpan(
                text: "Welcome ",
                children: [
                  TextSpan(
                    text: currentUser.email,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              style: HSTheme.instance.textTheme.titleMedium,
              maxLines: 1,
            ),
          ),
          const Gap(16.0),
          const Text(
              "It seems like your profile is missing a few details.\nPlease enter them below before continuing."),
          BlocProvider(
            create: (context) =>
                HSProfileCompletionCubit(context.read<HSDatabaseRepository>()),
            child: const ProfileCompletionForm(),
          ),
        ],
      ),
    );
  }
}
