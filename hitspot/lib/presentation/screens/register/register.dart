import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/bloc/theme/theme_bloc.dart';
import 'package:hitspot/constants/hs_const.dart';
import 'package:hitspot/presentation/screens/widgets/global/hs_appbar.dart';
import 'package:hitspot/utils/hs_display_size.dart';
import 'package:hitspot/presentation/screens/widgets/global/hs_scaffold.dart';
import 'package:hitspot/presentation/screens/widgets/global/hs_textfield.dart';
import 'package:hitspot/constants/hs_theming.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  final String title = "Let's register!";
  final String headline = "Please enter your details";
  final String buttonText = "Register";

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      sidePadding: 16.0,
      appBar: HSAppBar(
        center: Image.asset(
          HSConstants.assets.textLogoPath,
        ),
      ),
      body: ListView(
        children: [
          // Align(
          //   alignment: Alignment.center,
          //   child: SizedBox(
          //     width: displayWidth(context) * .8,
          //     child: Image.asset(
          //       HSConstants.assets.textLogoPath,
          //     ),
          //   ),
          // ),
          const Gap(32.0),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall!.boldify(),
            textAlign: TextAlign.center,
          ),
          const Gap(8.0),
          Text(headline,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const Gap(48.0),
          const HSTextField(
            // controller: controller.emailController,
            hintText: "Email",
            prefixIcon: Icon(FontAwesomeIcons.envelope),
          ),
          const Gap(24.0),
          const HSTextField(
            // controller: controller.passwordController,
            hintText: "Password",
            prefixIcon: Icon(FontAwesomeIcons.lock),
          ),
          const Gap(32.0),
          SizedBox(
            width: displayWidth(context) - 32.0,
            height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              onPressed: () =>
                  context.read<HSThemeBloc>().add(HSThemeSwitchEvent()),
              label: Text(buttonText),
              icon: const Icon(FontAwesomeIcons.arrowRight),
            ),
          ),
          const Gap(16.0),
          Text.rich(
            TextSpan(
              text: "Already have an account?",
              style: Theme.of(context).textTheme.bodySmall!.hintify(),
              children: [
                TextSpan(
                  text: " Sign In",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .colorify(HSConstants.theming.mainColor)
                      .boldify(),
                ),
              ],
            ),
            textAlign: TextAlign.right,
          ),
          const Gap(32.0),
          Text.rich(
            TextSpan(
              text: "By creating an account you agree to our",
              children: [
                TextSpan(
                  text: " Terms of Service",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .colorify(HSConstants.theming.mainColor)
                      .boldify(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => print("TOS"),
                ),
                const TextSpan(
                  text: " and",
                ),
                TextSpan(
                  text: " Privacy Policy",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .colorify(HSConstants.theming.mainColor)
                      .boldify(),
                  recognizer: TapGestureRecognizer()..onTap = () => print("PP"),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
