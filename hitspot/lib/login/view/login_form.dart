import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/hs_theme.dart';
import 'package:hitspot/login/cubit/login_cubit.dart';
import 'package:hitspot/register/view/register_page.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  final String title = "Welcome Back!";
  final String headline = "Let's log in";

  @override
  Widget build(BuildContext context) {
    return BlocListener<HSLoginCubit, HSLoginState>(
      listener: (context, state) {
        if (state.status.isFailure) {
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
        children: [
          ListView(
            shrinkWrap: true,
            children: [
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
              _EmailInput(),
              const Gap(24.0),
              _PasswordInput(),
              const Gap(32.0),
              _LoginButton(),
              const Gap(16.0),
              Text.rich(
                TextSpan(
                  text: "Don't have an account?",
                  style: Theme.of(context).textTheme.bodySmall!.hintify(),
                  children: [
                    TextSpan(
                      text: " Sign Up",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
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
            ],
          ),
          const Spacer(),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Alternatively"),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const Gap(24.0),
          _GoogleLoginButton(),
          const Gap(24.0),
          _AppleLoginButton(),
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
        hintText: "Email",
        prefixIcon: const Icon(FontAwesomeIcons.envelope),
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
          hintText: "Password",
          onTapPrefix: () =>
              context.read<HSLoginCubit>().togglePasswordVisibility(),
          prefixIcon: Icon(state.isPasswordVisible
              ? FontAwesomeIcons.lockOpen
              : FontAwesomeIcons.lock),
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
        return ElevatedButton.icon(
          key: const Key('loginForm_continue_raisedButton'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
          onPressed: () {
            if (state.isValid) {
              context.read<HSLoginCubit>().logInWithCredentials();
            }
          },
          icon: state.status.isInProgress
              ? const SizedBox()
              : const Icon(FontAwesomeIcons.arrowRight),
          label: state.status.isInProgress
              ? LoadingAnimationWidget.staggeredDotsWave(
                  size: 24.0,
                  color: HSTheme.instance.mainColor,
                )
              : Text(buttonText),
        );
      },
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      key: const Key('loginForm_googleLogin_raisedButton'),
      label: const Text(
        'SIGN IN WITH GOOGLE',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: theme.colorScheme.secondary,
      ),
      icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
      onPressed: () => context.read<HSLoginCubit>().logInWithGoogle(),
    );
  }
}

class _AppleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      key: const Key('loginForm_appleLogin_raisedButton'),
      label: const Text(
        'SIGN IN WITH APPLE',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: theme.colorScheme.secondary,
      ),
      icon: const Icon(FontAwesomeIcons.apple, color: Colors.white),
      onPressed: () => context.read<HSLoginCubit>().logInWithApple(),
    );
  }
}
