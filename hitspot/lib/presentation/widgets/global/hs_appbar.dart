import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    this.enableDefaultBackButton = false,
  }) {
    assert(center != null || title != null,
        "Either a center widget or title should be provided.");
    assert(!(enableDefaultBackButton && left != null),
        "enableDefaultBackButton and left cannot be used at the same time.");
  }

  final double height;
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final String? title;
  final int maxLines;
  final double fontSize;
  final bool enableDefaultBackButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (enableDefaultBackButton)
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(FontAwesomeIcons.arrowLeft)),
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
