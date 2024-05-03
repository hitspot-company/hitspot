import 'package:flutter/material.dart';

class HSButton extends StatelessWidget {
  const HSButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 10,
    this.disabled = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
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
}
