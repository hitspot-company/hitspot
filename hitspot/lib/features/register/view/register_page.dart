import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/features/register/cubit/hs_register_cubit.dart';
import 'package:hitspot/features/register/view/register_form.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/auth/hs_auth_page_title.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    return HSScaffold(
      resizeToAvoidBottomInset: true,
      sidePadding: 16.0,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider<HSRegisterCubit>(
          create: (_) => HSRegisterCubit(HSApp.instance.authRepository),
          child: ListView(
            children: [
              const Gap(32.0),
              const HSAuthPageTitle(
                leftTitle: "Create a ",
                rightTitle: "free account",
              ),
              const Expanded(child: RegisterForm()),
              Text.rich(
                TextSpan(
                  text: "By creating an account you agree to our",
                  children: [
                    TextSpan(
                      text: " Terms of Service",
                      style: hsApp.textTheme.bodySmall!
                          .colorify(HSTheme.instance.mainColor)
                          .boldify(),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => print("TOS"),
                    ),
                    const TextSpan(
                      text: " and",
                    ),
                    TextSpan(
                      text: " Privacy Policy",
                      style: hsApp.textTheme.bodySmall!
                          .colorify(HSTheme.instance.mainColor)
                          .boldify(),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => print("PP"),
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
