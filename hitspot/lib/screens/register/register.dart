import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/utils/hs_app.dart';
import 'package:hitspot/utils/hs_display_size.dart';
import 'package:hitspot/utils/hs_theming.dart';
import 'package:hitspot/widgets/global/hs_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
            style:
                HSApp.theming.currentTheme.textTheme.displayMedium!.applyBold(),
          ),
          const Gap(8.0),
          Text(
            "Please enter your details",
            style: HSApp.textTheme.bodyMedium,
          ),
          const Gap(24.0),
          const HSTextField(
            hintText: "Email",
            prefixIcon: Icon(FontAwesomeIcons.envelope),
          ),
          const Gap(16.0),
          const HSTextField(
            hintText: "Password",
            prefixIcon: Icon(FontAwesomeIcons.lock),
          ),
        ],
      ),
    );
  }
}

class HSTextField extends StatelessWidget {
  const HSTextField({super.key, this.padding, this.hintText, this.prefixIcon});

  final EdgeInsetsGeometry? padding;
  final String? hintText;
  final Icon? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
            prefixIcon: prefixIcon,
            hintText: hintText,
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)))),
      ),
    );
  }
}
