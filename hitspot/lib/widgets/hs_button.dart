import 'package:flutter/material.dart';

class HSButton extends StatelessWidget {
  const HSButton(
      {super.key,
      required this.child,
      required this.onPressed,
      this.borderRadius = 10});

  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;

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
