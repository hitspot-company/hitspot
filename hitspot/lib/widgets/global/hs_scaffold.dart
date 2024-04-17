import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class HSScaffold extends StatelessWidget {
  const HSScaffold({
    super.key,
    this.topSafe = true,
    this.bottomSafe = true,
    this.sidePadding = 8.0,
    this.appBar,
    required this.body,
  });

  final bool topSafe;
  final bool bottomSafe;
  final double sidePadding;
  final Widget? appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
      child: Scaffold(
        body: SafeArea(
          top: topSafe,
          bottom: bottomSafe,
          child: Padding(
            padding: EdgeInsets.all(sidePadding),
            child: Column(
              children: [if (appBar != null) appBar!, Expanded(child: body)],
            ),
          ),
        ),
      ),
    );
  }
}
