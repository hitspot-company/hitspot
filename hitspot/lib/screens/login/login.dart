import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hitspot/const/const.dart';
import 'package:hitspot/utils/hs_app.dart';
import 'package:hitspot/utils/hs_display_size.dart';
import 'package:hitspot/utils/hs_theming.dart';
import 'package:hitspot/widgets/global/hs_scaffold.dart';
import 'package:hitspot/widgets/global/hs_textfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  final String title = "Let's register!";
  final String headline = "Please enter your details";
  final String buttonText = "Register";

  static final app = HSApp.instance;

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(RegisterController());
    var controller;
    return HSScaffold(
      sidePadding: 16.0,
      body: ListView(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: displayWidth(context) * .3,
              child: Image.asset(
                app.images.icon,
              ),
            ),
          ),
          const Gap(32.0),
          Text(
            title,
            style: app.theming.currentTheme.textTheme.displaySmall!.boldify(),
            textAlign: TextAlign.center,
          ),
          const Gap(8.0),
          Text(headline,
              style: app.textTheme.bodyMedium, textAlign: TextAlign.center),
          const Gap(48.0),
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
            child: Obx(
              () => controller.loading
                  ? const CupertinoActivityIndicator()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onPressed: controller.register,
                      label: Text(buttonText),
                      icon: const Icon(FontAwesomeIcons.arrowRight),
                    ),
            ),
          ),
          const Gap(16.0),
          Text.rich(
            TextSpan(
              text: "Already have an account?",
              style: app.textTheme.bodySmall!.hintify(),
              children: [
                TextSpan(
                  text: " Sign In",
                  style: app.textTheme.bodySmall!
                      .colorify(app.theming.mainColor)
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
                  style: app.textTheme.bodySmall!
                      .colorify(app.theming.mainColor)
                      .boldify(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => print("TOS"),
                ),
                const TextSpan(
                  text: " and",
                ),
                TextSpan(
                  text: " Privacy Policy",
                  style: app.textTheme.bodySmall!
                      .colorify(app.theming.mainColor)
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
