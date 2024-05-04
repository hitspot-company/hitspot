import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/register/view/register_page.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/login/cubit/login_cubit.dart';
import 'package:hitspot/widgets/auth/hs_auth_button.dart';
import 'package:hitspot/widgets/auth/hs_auth_horizontal_divider.dart';
import 'package:hitspot/widgets/auth/hs_auth_page_title.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  final String title = "Log in to Hitspot";

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    final hsNavigation = hsApp.navigation;
    final loginCubit = context.read<HSLoginCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(32.0),
        const HSAuthPageTitle(
          leftTitle: "Log in to ",
          rightTitle: "Hitspot",
        ),
        const Gap(24.0),
        _EmailInput(loginCubit),
        const Gap(24.0),
        _PasswordInput(loginCubit),
        const Gap(16.0),
        SizedBox(
          width: double.maxFinite,
          child: Text.rich(
            TextSpan(
              text: "Don't have an account?",
              style: hsApp.textTheme.bodySmall!.hintify(),
              children: [
                TextSpan(
                  text: " Sign Up",
                  style: hsApp.textTheme.bodySmall!
                      .colorify(HSTheme.instance.mainColor)
                      .boldify(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => hsNavigation.push(RegisterPage.route()),
                ),
              ],
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const Gap(32.0),
        _LoginButton(loginCubit),
        const Gap(32.0),
        const HSAuthHorizontalDivider(),
        const Gap(24.0),
        HSSocialLoginButtons.google(loginCubit.logInWithGoogle),
        const Gap(24.0),
        HSSocialLoginButtons.apple(loginCubit.logInWithApple),
        const Spacer(),
        const Text.rich(
          TextSpan(
            text:
                "Hitspot uses cookies for analytics, personalised content and ads. By using Hitspot's services you agree to this use of cookies.",
            children: [
              TextSpan(
                text: " Learn more",
                style: TextStyle(
                  color: Color.fromARGB(255, 130, 130, 130),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          style: TextStyle(
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
        key: const Key("loginForm_emailInput_textField"),
        onChanged: _loginCubit.emailChanged,
        keyboardType: TextInputType.emailAddress,
        hintText: "email@example.com",
        suffixIcon: const Icon(FontAwesomeIcons.envelope),
        errorText: _errorText(state),
      ),
    );
  }

  String? _errorText(HSLoginState state) {
    if (state.email.displayError != null) return "Invalid email address.";
    if (state.errorMessage != null && state.errorMessage == "") {
      return "Invalid credentials.";
    }
    return null;
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput(this._loginCubit);
  final HSLoginCubit _loginCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSLoginCubit, HSLoginState>(
      buildWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.password != current.password ||
          previous.isPasswordVisible != current.isPasswordVisible,
      builder: (context, state) {
        return HSTextField(
          key: const Key('loginForm_passwordInput_textField'),
          onChanged: _loginCubit.passwordChanged,
          obscureText: !state.isPasswordVisible,
          errorText: _errorText(state),
          hintText: "Your Password",
          onTapSuffix: _loginCubit.togglePasswordVisibility,
          suffixIcon: Icon(_getSuffixIcon(state)),
        );
      },
    );
  }

  String? _errorText(HSLoginState state) {
    String? error;

    if (state.errorMessage != null) {
      error = state.errorMessage;
    }
    return error;
  }

  IconData _getSuffixIcon(HSLoginState state) {
    return state.isPasswordVisible
        ? FontAwesomeIcons.eye
        : FontAwesomeIcons.eyeSlash;
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton(this._loginCubit);
  final HSLoginCubit _loginCubit;
  final String buttonText = "Sign In";

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
