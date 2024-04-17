import 'package:flutter/material.dart';

class HSScaffold extends StatelessWidget {
  const HSScaffold({
    super.key,
    this.topSafe = true,
    this.bottomSafe = true,
    this.sidePadding = 8.0,
    this.appBar,
  });

  final bool topSafe;
  final bool bottomSafe;
  final double sidePadding;
  final Widget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: topSafe,
        bottom: bottomSafe,
        child: Padding(
          padding: EdgeInsets.all(sidePadding),
          child: Column(
            children: [if (appBar != null) appBar!],
          ),
        ),
      ),
    );
  }
}
