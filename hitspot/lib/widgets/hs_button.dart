import 'package:flutter/material.dart';

class HSButton extends StatelessWidget {
  const HSButton(
      {super.key,
      required this.child,
      required this.onPressed,
      this.borderRadius = 10,
      this.disabled = false,
      this.isIconButton = false,
      this.icon});

  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final bool disabled;
  final bool isIconButton;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    if (isIconButton) {
      assert((icon != null), "The icon cannot be null");
      return ElevatedButton.icon(
        key: key,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        label: child,
        icon: icon!,
      );
    }
    return ElevatedButton(
      key: key,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }

  factory HSButton.icon(
      {required Widget label,
      required VoidCallback onPressed,
      required Icon icon}) {
    return HSButton(
      onPressed: onPressed,
      icon: icon,
      isIconButton: true,
      child: label,
    );
  }
}
