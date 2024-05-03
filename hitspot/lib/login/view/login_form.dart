import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/login/cubit/login_cubit.dart';
import 'package:hitspot/register/view/register_page.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  final String title = "Log in to Hitspot";

  @override
  Widget build(BuildContext context) {
    return BlocListener<HSLoginCubit, HSLoginState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          // TODO: Change to HSToasts
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failure'),
              ),
            );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(32.0),
          Text(
            title,
            style: HSApp.instance.textTheme.displaySmall!.boldify(),
            textAlign: TextAlign.left,
          ),
          const Gap(24.0),
          _EmailInput(),
          const Gap(24.0),
          _PasswordInput(),
          const Gap(16.0),
          SizedBox(
            width: double.maxFinite,
            child: Text.rich(
              TextSpan(
                text: "Don't have an account?",
                style: HSApp.instance.textTheme.bodySmall!.hintify(),
                children: [
                  TextSpan(
                    text: " Sign Up",
                    style: HSApp.instance.textTheme.bodySmall!
                        .colorify(HSTheme.instance.mainColor)
                        .boldify(),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context)
                          .push<void>(RegisterPage.route()),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const Gap(32.0),
          _LoginButton(),
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
          _GoogleLoginButton(),
          const Gap(24.0),
          _AppleLoginButton(),
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
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSLoginCubit, HSLoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) => HSTextField(
        key: const Key("loginForm_emailInput_textField"),
        onChanged: (email) => context.read<HSLoginCubit>().emailChanged(email),
        keyboardType: TextInputType.emailAddress,
        hintText: "email@example.com",
        suffixIcon: const Icon(FontAwesomeIcons.envelope),
        errorText: state.email.displayError != null ? "Invalid email" : null,
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSLoginCubit, HSLoginState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.isPasswordVisible != current.isPasswordVisible,
      builder: (context, state) {
        return HSTextField(
          key: const Key('loginForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<HSLoginCubit>().passwordChanged(password),
          obscureText: !state.isPasswordVisible,
          errorText:
              state.password.displayError != null ? 'invalid password' : null,
          hintText: "Your Password",
          onTapSuffix: () =>
              context.read<HSLoginCubit>().togglePasswordVisibility(),
          suffixIcon: Icon(state.isPasswordVisible
              ? FontAwesomeIcons.eye
              : FontAwesomeIcons.eyeSlash),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
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
                context.read<HSLoginCubit>().logInWithCredentials();
              }
            },
          ),
        );
      },
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = HSApp.instance.currentTheme;
    return SizedBox(
      width: double.maxFinite,
      height: 44.0,
      child: ElevatedButton.icon(
        key: const Key('loginForm_googleLogin_raisedButton'),
        label: Text(
          'Continue with Google',
          style: TextStyle(color: theme.colorScheme.secondary).boldify(),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0.0,
        ),
        icon: const Icon(FontAwesomeIcons.google),
        onPressed: () => context.read<HSLoginCubit>().logInWithGoogle(),
      ),
    );
  }
}

class _AppleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = HSApp.instance.currentTheme;
    return SizedBox(
      width: double.maxFinite,
      height: 44.0,
      child: ElevatedButton.icon(
        key: const Key('loginForm_appleLogin_raisedButton'),
        label: Text(
          'Continue with Apple',
          style: TextStyle(color: theme.colorScheme.secondary).boldify(),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0.0,
        ),
        icon: const Icon(FontAwesomeIcons.apple),
        onPressed: () => context.read<HSLoginCubit>().logInWithApple(),
      ),
    );
  }
}
