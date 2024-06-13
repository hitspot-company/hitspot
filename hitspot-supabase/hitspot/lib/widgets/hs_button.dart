import 'package:flutter/material.dart';

class HSButton extends StatelessWidget {
  const HSButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = 10,
    this.icon,
    this.isIconButton = false,
    this.isOutlined = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final bool isIconButton;
  final Icon? icon;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        key: key,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: child,
      );
    }
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

  factory HSButton.outlined({
    required Widget child,
    VoidCallback? onPressed,
    double borderRadius = 10,
  }) {
    return HSButton(
      isOutlined: true,
      onPressed: onPressed,
      borderRadius: borderRadius,
      child: child,
    );
  }

  factory HSButton.icon(
      {required Widget label, VoidCallback? onPressed, required Icon icon}) {
    return HSButton(
      onPressed: onPressed,
      icon: icon,
      isIconButton: true,
      child: label,
    );
  }
}
