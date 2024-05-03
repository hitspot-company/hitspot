import 'package:flutter/material.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HSLoadingIndicator extends StatelessWidget {
  const HSLoadingIndicator({super.key, this.size = 64.0, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.waveDots(
          color: color ?? HSTheme.instance.mainColor, size: size),
    );
  }
}
