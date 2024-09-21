import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class CreateSpotErrorPage extends StatelessWidget {
  const CreateSpotErrorPage(
      {super.key, required this.title, required this.description});

  final String title, description;

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          FontAwesomeIcons.exclamationTriangle,
          size: 64,
          color: Colors.red,
        ),
        const Gap(16),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Gap(8),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ));
  }
}
