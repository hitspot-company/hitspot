import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSUserProfileUserDataAppBarReady extends StatelessWidget {
  const HSUserProfileUserDataAppBarReady({super.key, required this.user});

  final HSUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${user.name}",
          style: textTheme.headlineSmall!.hintify,
        ),
        Text("@${user.username}", style: textTheme.headlineLarge),
      ],
    );
  }
}
