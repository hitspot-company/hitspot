import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/hs_theme.dart';
import 'package:hitspot/login/view/login_page.dart';
import 'package:hitspot/register/cubit/hs_register_cubit.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  final String title = "Welcome!";
  final String headline = "Let's Sign Up";

  @override
  Widget build(BuildContext context) {
    return BlocListener<HSRegisterCubit, HSRegisterState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Sign Up Failure')),
            );
        }
      },
      child: ListView(
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
          const Gap(24.0),
          _ConfirmPasswordInput(),
          const Gap(32.0),
          _SignUpButton(),
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
                    ..onTap = () => Navigator.of(context).pop(),
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
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => print("TOS"),
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
      ),
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
  final String buttonText = "SIGN UP";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSRegisterCubit, HSRegisterState>(
      builder: (context, state) {
        if (state.status.isInProgress) {
          return const CircularProgressIndicator();
        }
        return ElevatedButton.icon(
          key: const Key('RegisterForm_continue_raisedButton'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
          onPressed: () {
            if (state.isValid) {
              context.read<HSRegisterCubit>().signUpFormSubmitted();
            }
          },
          icon: const Icon(FontAwesomeIcons.arrowRight),
          label: Text(buttonText),
        );
      },
    );
  }
}
