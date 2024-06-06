import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';

class HSSocialLoginButtons {
  static Widget google(VoidCallback onPressed) => _SocialLoginButton(
      labelText: "Continue with Google",
      icon: const Icon(FontAwesomeIcons.google),
      onPressed: onPressed);

  static Widget apple(VoidCallback onPressed) => _SocialLoginButton(
      labelText: "Continue with Apple",
      icon: const Icon(FontAwesomeIcons.apple),
      onPressed: onPressed);

  static Widget custom(
          {required String labelText,
          Icon? icon,
          required VoidCallback onPressed,
          Color? backgroundColor}) =>
      _SocialLoginButton(
        labelText: labelText,
        icon: icon,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
      );
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.labelText,
    this.icon,
    this.onPressed,
    this.backgroundColor,
  });

  final String labelText;
  final VoidCallback? onPressed;
  final Icon? icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = HSApp.instance.currentTheme;
    return SizedBox(
      width: double.maxFinite,
      height: 44.0,
      child: ElevatedButton(
        key: key,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: HSApp.instance.theme.mainColor, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
          elevation: 0.0,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (icon != null)
              Align(
                alignment: Alignment.centerLeft,
                child: icon,
              ),
            Center(
              child: Text(
                labelText,
                style: textTheme.headlineSmall!
                    .colorify(theme.colorScheme.secondary)
                    .boldify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
