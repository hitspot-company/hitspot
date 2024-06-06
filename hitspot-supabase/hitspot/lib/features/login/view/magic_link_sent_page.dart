import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class MagicLinkSentPage extends StatelessWidget {
  const MagicLinkSentPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        title: Text("Magic Link Sent", style: textTheme.headlineSmall),
        enableDefaultBackButton: true,
        defaultBackButtonCallback: app.signOut,
      ),
      body: ListView(
        children: [
          const Gap(32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text.rich(
              TextSpan(
                text: "We have sent a",
                style: textTheme.headlineLarge,
                children: [
                  TextSpan(
                    text: " magic link",
                    style: TextStyle(color: app.theme.mainColor),
                  ),
                  const TextSpan(text: " to "),
                  TextSpan(
                    text: " $email.\n\n",
                    style: TextStyle(color: app.theme.mainColor),
                  ),
                  TextSpan(
                      text:
                          "Please check your inbox and click the link to securely sign in. Enjoy the seamless login experience!",
                      style: textTheme.bodyMedium),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: HSButton(
              onPressed: app.signOut,
              child: const Text("Sign Out"),
            ),
          ),
        ],
      ),
    );
  }
}
