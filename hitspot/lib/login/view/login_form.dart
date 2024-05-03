import 'package:flutter/cupertino.dart';
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
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
        _PageTitle(hsApp: hsApp),
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
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "OR",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const Gap(24.0),
        _GoogleLoginButton(loginCubit),
        const Gap(24.0),
        _AppleLoginButton(loginCubit),
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

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    super.key,
    required this.hsApp,
  });

  final HSApp hsApp;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "Log in to ",
        children: [
          TextSpan(
            text: "Hitspot",
            style: const TextStyle().colorify(hsApp.theme.mainColor),
          ),
        ],
      ),
      style: hsApp.textTheme.displaySmall!.boldify(),
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
    // if (state.errorMessage != null && state.errorMessage == "") return "";
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
        return SizedBox(
          width: double.maxFinite,
          child: CupertinoButton(
            color: HSApp.instance.theme.mainColor,
            child: state.status.isInProgress
                ? LoadingAnimationWidget.staggeredDotsWave(
                    size: 24.0,
                    color: Colors.white,
                  )
                : Text(buttonText),
            onPressed: () {
              if (state.isValid) {
                _loginCubit.logInWithCredentials();
              }
            },
          ),
        );
      },
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  const _GoogleLoginButton(this._loginCubit);
  final HSLoginCubit _loginCubit;
  final String labelText = "Continue with Google";

  @override
  Widget build(BuildContext context) {
    return _SocialLoginButton(
      labelText: labelText,
      icon: const Icon(FontAwesomeIcons.google),
      onPressed: _loginCubit.logInWithGoogle,
    );
  }
}

class _AppleLoginButton extends StatelessWidget {
  const _AppleLoginButton(this._loginCubit);
  final HSLoginCubit _loginCubit;
  final String labelText = "Continue with Apple";

  @override
  Widget build(BuildContext context) {
    return _SocialLoginButton(
      labelText: labelText,
      icon: const Icon(FontAwesomeIcons.apple),
      onPressed: _loginCubit.logInWithApple,
    );
  }
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
