import 'package:flutter/material.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.infoText});

  final String infoText;

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        titleText: "",
        enableDefaultBackButton: true,
      ),
      body: Center(
        child: Text(infoText, style: Theme.of(context).textTheme.displayLarge),
      ),
    );
  }
}
