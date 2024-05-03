import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/app/hs_app.dart';
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
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    super.key,
    required this.labelText,
    required this.icon,
    this.onPressed,
  });

  final String labelText;
  final VoidCallback? onPressed;
  final Icon icon;

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
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0.0,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: icon,
            ),
            Center(
              child: Text(
                labelText,
                style: TextStyle(color: theme.colorScheme.secondary).boldify(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
