import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/login/cubit/hs_login_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/auth/hs_auth_button.dart';
import 'package:hitspot/widgets/auth/hs_auth_horizontal_divider.dart';
import 'package:hitspot/widgets/auth/hs_auth_page_title.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<HSLoginCubit>();
    return HSScaffold(
      resizeToAvoidBottomInset: false,
      bottomSafe: true,
      sidePadding: 24.0,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Gap(32.0),
          ),
          const SliverToBoxAdapter(
            child: HSAuthPageTitle(
              leftTitle: "Welcome to ",
              rightTitle: "Hitspot",
            ),
          ),
          const SliverToBoxAdapter(child: Gap(24.0)),
          SliverToBoxAdapter(child: _EmailInput(loginCubit)),
          const SliverToBoxAdapter(child: Gap(32.0)),
          SliverToBoxAdapter(child: _LoginButton(loginCubit)),
          const SliverToBoxAdapter(child: Gap(32.0)),
          const SliverToBoxAdapter(child: HSAuthHorizontalDivider()),
          const SliverToBoxAdapter(child: Gap(24.0)),
          SliverToBoxAdapter(
              child: HSSocialLoginButtons.google(loginCubit.logInWithGoogle)),
          if (Platform.isIOS) ...[
            const SliverToBoxAdapter(child: Gap(24.0)),
            SliverToBoxAdapter(
                child: HSSocialLoginButtons.apple(loginCubit.logInWithApple)),
          ],
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: _Footer(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
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
                ..onTap = () =>
                    launchUrlString('https://hitspot.app/privacy-policy.pdf'),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput(this._loginCubit);
  final HSLoginCubit _loginCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSLoginCubit, HSLoginState>(
      buildWhen: (previous, current) =>
          previous.email != current.email ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) => HSTextField(
        fillColor: app.textFieldFillColor,
        onChanged: _loginCubit.emailChanged,
        keyboardType: TextInputType.emailAddress,
        hintText: "email@example.com",
        suffixIcon: const Icon(FontAwesomeIcons.envelope),
        errorText: _errorText(state),
      ),
    );
  }

  String? _errorText(HSLoginState state) {
    if (state.errorMessage != null) return state.errorMessage;
    if (state.errorMessage != null && state.errorMessage == "") {
      return "Invalid credentials.";
    }
    return null;
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton(this._loginCubit);
  final HSLoginCubit _loginCubit;
  final String buttonText = "Send Magic Link";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSLoginCubit, HSLoginState>(
      builder: (context, state) {
        return HSAuthButton(
          buttonText: buttonText,
          loading: state.status.isInProgress,
          valid: state.isValid,
          onPressed: _loginCubit.logInWithCredentials,
        );
      },
    );
  }
}
