import 'package:flutter/material.dart';
import 'package:hitspot/widgets/hs_button.dart';

class HSFormButton extends StatelessWidget {
  const HSFormButton({this.icon, required this.child, this.onPressed});

  final Icon? icon;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return HSButton.icon(
        label: child,
        onPressed: onPressed,
        icon: icon!,
      );
    }
    return HSButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
