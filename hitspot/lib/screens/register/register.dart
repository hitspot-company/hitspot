import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hitspot/controllers/register/register.dart';
import 'package:hitspot/utils/hs_app.dart';
import 'package:hitspot/utils/hs_display_size.dart';
import 'package:hitspot/utils/hs_theming.dart';
import 'package:hitspot/widgets/global/hs_scaffold.dart';
import 'package:hitspot/widgets/global/hs_textfield.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());
    return HSScaffold(
      sidePadding: 16.0,
      body: ListView(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: displayWidth(context) * .3,
              child: Image.asset(
                HSApp.images.icon,
              ),
            ),
          ),
          const Gap(32.0),
          Text(
            "Welcome Back!",
            style: HSApp.theming.currentTheme.textTheme.displaySmall!.boldify(),
            textAlign: TextAlign.center,
          ),
          const Gap(8.0),
          Text("Please enter your details",
              style: HSApp.textTheme.bodyMedium, textAlign: TextAlign.center),
          const Gap(24.0),
          HSTextField(
            controller: controller.emailController,
            hintText: "Email",
            prefixIcon: const Icon(FontAwesomeIcons.envelope),
          ),
          const Gap(24.0),
          HSTextField(
            controller: controller.passwordController,
            hintText: "Password",
            prefixIcon: const Icon(FontAwesomeIcons.lock),
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
              onPressed: controller.register,
              label: const Text("Register"),
              icon: const Icon(FontAwesomeIcons.arrowRight),
            ),
          ),
          const Gap(32.0),
          Text.rich(
            TextSpan(
              text: "By creating an account you agree to our",
              children: [
                TextSpan(
                  text: " Terms of Service",
                  style: HSApp.textTheme.bodySmall!
                      .colorify(HSApp.theming.mainColor)
                      .boldify(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => print("TOS"),
                ),
                const TextSpan(
                  text: " and",
                ),
                TextSpan(
                  text: " Privacy Policy",
                  style: HSApp.textTheme.bodySmall!
                      .colorify(HSApp.theming.mainColor)
                      .boldify(),
                  recognizer: TapGestureRecognizer()..onTap = () => print("PP"),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(128.0),
          Text.rich(
            TextSpan(
              text: "Already have an account?",
              style: HSApp.textTheme.bodySmall!.hintify(),
              children: [
                TextSpan(
                  text: " Sign In",
                  style: HSApp.textTheme.bodySmall!
                      .colorify(HSApp.theming.mainColor)
                      .boldify(),
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
