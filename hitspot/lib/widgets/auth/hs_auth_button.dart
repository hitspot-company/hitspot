import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';

class HSAuthButton extends StatelessWidget {
  const HSAuthButton(
      {super.key,
      required this.buttonText,
      required this.loading,
      required this.valid,
      required this.onPressed});
  final String buttonText;
  final bool loading;
  final bool valid;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: CupertinoButton(
        color: app.theme.mainColor,
        onPressed: onPressed,
        child: loading
            ? const HSLoadingIndicator(
                color: Colors.white,
                size: 24.0,
              )
            : Text(buttonText,
                style: textTheme.headlineSmall!
                    .copyWith(color: currentTheme.colorScheme.background)),
      ),
    );
  }
}
