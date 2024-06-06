import 'package:flutter/material.dart';

class HSAuthHorizontalDivider extends StatelessWidget {
  const HSAuthHorizontalDivider({
    super.key,
    this.text = "OR",
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
