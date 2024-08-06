import 'package:flutter/material.dart';

class HSIconPrompt extends StatelessWidget {
  const HSIconPrompt(
      {super.key,
      required this.message,
      this.iconSize = 64,
      this.iconColor = Colors.grey,
      required this.iconData});

  final String message;
  final IconData iconData;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
