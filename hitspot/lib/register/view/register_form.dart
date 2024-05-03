import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/register/cubit/hs_register_cubit.dart';
import 'package:hitspot/widgets/auth/hs_auth_button.dart';
import 'package:hitspot/widgets/auth/hs_auth_horizontal_divider.dart';
import 'package:hitspot/widgets/auth/hs_auth_page_title.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    final hsNavigation = hsApp.navigation;
    final registerCubit = context.read<HSRegisterCubit>();
    return ListView(
      children: [
        const Gap(32.0),
        const HSAuthPageTitle(
          leftTitle: "Create a ",
          rightTitle: "free account",
        ),
        const Gap(24.0),
        HSSocialLoginButtons.google(registerCubit.logInWithGoogle),
        const Gap(24.0),
        HSSocialLoginButtons.apple(registerCubit.logInWithApple),
        const Gap(24.0),
        const HSAuthHorizontalDivider(),
        const Gap(24.0),
        _EmailInput(),
        const Gap(32.0),
        _SignUpButton(registerCubit),
        const Gap(16.0),
        Text.rich(
          TextSpan(
            text: "Already have an account?",
            style: Theme.of(context).textTheme.bodySmall!.hintify(),
            children: [
              TextSpan(
                text: " Sign In",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .colorify(HSTheme.instance.mainColor)
                    .boldify(),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => hsNavigation.pop(),
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .colorify(HSTheme.instance.mainColor)
                    .boldify(),
                recognizer: TapGestureRecognizer()..onTap = () => print("TOS"),
              ),
              const TextSpan(
                text: " and",
              ),
              TextSpan(
                text: " Privacy Policy",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .colorify(HSTheme.instance.mainColor)
                    .boldify(),
                recognizer: TapGestureRecognizer()..onTap = () => print("PP"),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSRegisterCubit, HSRegisterState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) => HSTextField(
        key: const Key('RegisterForm_emailInput_textField'),
        onChanged: (email) =>
            context.read<HSRegisterCubit>().emailChanged(email),
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
    return BlocBuilder<HSRegisterCubit, HSRegisterState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.isPasswordVisible != current.isPasswordVisible,
      builder: (context, state) {
        return HSTextField(
          key: const Key('RegisterForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<HSRegisterCubit>().passwordChanged(password),
          obscureText: !state.isPasswordVisible,
          errorText:
              state.password.displayError != null ? 'Invalid password' : null,
          hintText: "Password",
          onTapPrefix: () =>
              context.read<HSRegisterCubit>().togglePasswordVisibility(),
          prefixIcon: Icon(state.isPasswordVisible
              ? FontAwesomeIcons.lockOpen
              : FontAwesomeIcons.lock),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSRegisterCubit, HSRegisterState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.isPasswordVisible != current.isPasswordVisible ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return HSTextField(
          key: const Key('RegisterForm_confirmedPasswordInput_textField'),
          onChanged: (confirmPassword) => context
              .read<HSRegisterCubit>()
              .confirmedPasswordChanged(confirmPassword),
          obscureText: !state.isPasswordVisible,
          errorText: state.confirmedPassword.displayError != null
              ? 'Passwords do not match'
              : null,
          hintText: "Confirm Password",
          onTapPrefix: () =>
              context.read<HSRegisterCubit>().togglePasswordVisibility(),
          prefixIcon: Icon(state.isPasswordVisible
              ? FontAwesomeIcons.lockOpen
              : FontAwesomeIcons.lock),
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton(this._registerCubit);
  final String buttonText = "Continue with Email";
  final HSRegisterCubit _registerCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSRegisterCubit, HSRegisterState>(
      builder: (context, state) {
        return HSAuthButton(
          buttonText: buttonText,
          loading: state.status.isInProgress,
          valid: state.isValid,
          callback: () => HSDebugLogger.logInfo(
              "TO BE IMPLEMENTED USING ANIMATED OPACITY AND SHIT"),
        );
      },
    );
  }
}
