import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';

class HSAppBar extends StatelessWidget {
  HSAppBar({
    super.key,
    this.height = 60.0,
    this.left,
    this.title,
    this.right,
    this.titleText = "",
    this.maxLines = 1,
    this.fontSize = 18.0,
    this.enableDefaultBackButton = false,
    this.titleBold = false,
    this.defaultBackButtonCallback,
    this.sidePadding,
    this.defaultButtonBackIcon,
  }) {
    assert(title != null || titleText != null,
        "Either a title widget or titleText should be provided.");
    assert(!(enableDefaultBackButton && left != null),
        "enableDefaultBackButton and left cannot be used at the same time.");
    assert(!(!enableDefaultBackButton && defaultBackButtonCallback != null),
        "In order to use the default defaultBackButtonCallback you need to enable the defaultBackButton.");
    assert(!(!enableDefaultBackButton && defaultButtonBackIcon != null),
        "In order to set the default defaultBackButtonIcon you need to enable the defaultBackButton.");
  }

  final double height;
  final Widget? left;
  final Widget? title;
  final Widget? right;
  final String? titleText;
  final int maxLines;
  final double fontSize;
  final bool enableDefaultBackButton;
  final bool titleBold;
  final VoidCallback? defaultBackButtonCallback;
  final double? sidePadding;
  final IconData? defaultButtonBackIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sidePadding ?? 0.0),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            if (enableDefaultBackButton)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(0.0),
                  onPressed: defaultBackButtonCallback ?? app.navigation.pop,
                  icon: Icon(defaultButtonBackIcon ?? backIcon.icon),
                ),
              ),
            if (left != null)
              Align(alignment: Alignment.centerLeft, child: left!),
            if (title != null)
              Align(alignment: Alignment.center, child: title!)
            else
              Align(
                alignment: Alignment.center,
                child: AutoSizeText(
                  titleText!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight:
                            titleBold ? FontWeight.bold : FontWeight.normal,
                        fontSize: fontSize,
                      ),
                  maxLines: maxLines,
                ),
              ),
            if (right != null)
              Align(alignment: Alignment.centerRight, child: right!)
          ],
        ),
      ),
    );
  }
}
