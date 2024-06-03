import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth,
            ),
            HSUserAvatar(radius: 64, imageUrl: currentUser?.avatarUrl),
            const Gap(16.0),
            HSButton(onPressed: app.switchTheme, child: const Text("SWITCH")),
            const Gap(16.0),
            HSButton(
                onPressed: app.authenticationRepository.signOut,
                child: const Text("LOGOUT")),
          ]),
    );
  }
}
