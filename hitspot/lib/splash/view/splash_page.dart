import 'package:flutter/material.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: SplashPage());

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      body: Center(
        child: LoadingAnimationWidget.beat(
          color: HSTheme.instance.mainColor,
          size: 40.0,
        ),
      ),
    );
  }
}
