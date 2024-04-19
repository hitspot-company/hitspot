import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class HSAppBar extends StatelessWidget {
  HSAppBar({
    super.key,
    this.height = 60.0,
    this.left,
    this.center,
    this.right,
    this.title,
    this.maxLines = 1,
    this.fontSize = 18.0,
  }) {
    assert(center != null || title != null,
        "Either a center widget or title should be provided.");
  }

  final double height;
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final String? title;
  final int maxLines;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (left != null) left!,
          if (center != null)
            Expanded(child: center!)
          else
            Expanded(
              child: AutoSizeText(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize),
                maxLines: maxLines,
              ),
            ),
          if (right != null) right!
        ],
      ),
    );
  }
}
