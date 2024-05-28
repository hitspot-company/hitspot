import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.headingText,
    required this.bodyText,
  });

  final String headingText;
  final String bodyText;

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(headingText,
              style: textTheme.headlineLarge, textAlign: TextAlign.center),
          const Gap(8.0),
          Text(bodyText, textAlign: TextAlign.center),
          const Gap(8.0),
          HSButton.icon(
              label: const Text(
                "Home",
                style: TextStyle(fontSize: 18.0),
              ),
              onPressed: () => navi.router.go("/"),
              icon: const Icon(
                FontAwesomeIcons.house,
                size: 18.0,
              ))
        ],
      ),
    );
  }
}
