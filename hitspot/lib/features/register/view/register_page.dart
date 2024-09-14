import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/register/cubit/hs_register_cubit.dart';
import 'package:hitspot/features/register/view/register_form.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/auth/hs_auth_page_title.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      resizeToAvoidBottomInset: true,
      sidePadding: 16.0,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider<HSRegisterCubit>(
          create: (_) => HSRegisterCubit(app.authenticationRepository),
          child: ListView(
            children: [
              const Gap(32.0),
              const HSAuthPageTitle(
                leftTitle: "Create a ",
                rightTitle: "free account",
              ),
              const RegisterForm(),
              Text.rich(
                TextSpan(
                  text: "By creating an account you agree to our",
                  children: [
                    TextSpan(
                        text: " Terms of Service",
                        style: app.textTheme.bodySmall!
                            .colorify(HSTheme.instance.mainColor)
                            .boldify,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrlString(
                              'https://hitspot.app/terms-of-service.pdf')),
                    const TextSpan(
                      text: " and",
                    ),
                    TextSpan(
                      text: " Privacy Policy",
                      style: app.textTheme.bodySmall!
                          .colorify(HSTheme.instance.mainColor)
                          .boldify,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrlString(
                            'https://hitspot.app/privacy-policy.pdf'),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
