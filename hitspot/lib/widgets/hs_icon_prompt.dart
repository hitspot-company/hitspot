import 'package:flutter/material.dart';

class HSIconPrompt extends StatelessWidget {
  const HSIconPrompt(
      {super.key,
      this.useWithRefresh = false,
      required this.message,
      this.iconSize = 64,
      this.iconColor = Colors.grey,
      required this.iconData});
  final bool useWithRefresh;
  final String message;
  final IconData iconData;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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
    if (useWithRefresh) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: content));
        }),
      );
    }

    return content;
  }
}
