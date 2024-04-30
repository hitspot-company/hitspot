import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HSScaffold extends StatelessWidget {
  const HSScaffold({
    super.key,
    this.topSafe = true,
    this.bottomSafe = true,
    this.sidePadding = 8.0,
    this.appBar,
    required this.body,
    this.ignoring = false,
  });

  final bool topSafe;
  final bool bottomSafe;
  final double sidePadding;
  final Widget? appBar;
  final Widget body;
  final bool ignoring;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
      child: IgnorePointer(
        ignoring: ignoring,
        child: Scaffold(
          body: SafeArea(
            top: topSafe,
            bottom: bottomSafe,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: Column(
                children: [if (appBar != null) appBar!, Expanded(child: body)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
