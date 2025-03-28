import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';

class HSAuthPageTitle extends StatelessWidget {
  const HSAuthPageTitle({
    super.key,
    required this.leftTitle,
    required this.rightTitle,
  });

  final String leftTitle;
  final String rightTitle;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText.rich(
      TextSpan(
        text: leftTitle,
        children: [
          TextSpan(
            text: rightTitle,
            style: const TextStyle().colorify(app.theme.mainColor),
          ),
        ],
      ),
      style: app.textTheme.displayMedium!.boldify,
      maxLines: 1,
    );
  }
}
