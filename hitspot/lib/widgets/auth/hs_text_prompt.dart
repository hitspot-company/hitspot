import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';

class HSTextPrompt extends StatelessWidget {
  const HSTextPrompt({
    super.key,
    required this.prompt,
    required this.pressableText,
    required this.promptColor,
    required this.onTap,
    this.textAlign = TextAlign.center,
    this.textStyle,
  });

  final String prompt;
  final String pressableText;
  final Color promptColor;
  final TextAlign textAlign;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Text.rich(
        TextSpan(
          text: prompt,
          style: textStyle ?? app.textTheme.bodySmall!.hintify,
          children: [
            TextSpan(
              text: pressableText,
              style: app.textTheme.bodySmall!
                  .colorify(HSTheme.instance.mainColor)
                  .boldify,
              recognizer: TapGestureRecognizer()..onTap = () => onTap(),
            ),
          ],
        ),
        textAlign: textAlign,
      ),
    );
  }
}
