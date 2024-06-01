import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/utils/navigation/hs_navigation_service.dart';
import 'package:hitspot/features/register/cubit/hs_register_cubit.dart';
import 'package:hitspot/widgets/auth/hs_auth_button.dart';
import 'package:hitspot/widgets/auth/hs_auth_horizontal_divider.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hitspot/widgets/hs_text_prompt.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    final hsNavigation = hsApp.navigation;
    final registerCubit = context.read<HSRegisterCubit>();
    return _RegisterFirstPage(
        registerCubit: registerCubit, hsApp: hsApp, hsNavigation: hsNavigation);
  }
}

class _RegisterFirstPage extends StatelessWidget {
  const _RegisterFirstPage(
      {required this.registerCubit,
      required this.hsApp,
      required this.hsNavigation});
  final HSRegisterCubit registerCubit;
  final HSApp hsApp;
  final HSNavigationService hsNavigation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageInitialHeading(registerCubit),
        const Gap(24.0),
        _EmailInput(registerCubit),
        const Gap(24.0),
        _AnimatedPasswordInput(registerCubit),
        _SignUpButton(registerCubit),
        const Gap(16.0),
        HSTextPrompt(
          prompt: "Already have an account?",
          pressableText: " Sign In",
          promptColor: hsApp.theme.mainColor,
          onTap: () => hsNavigation.pop(),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _AnimatedPasswordInput extends StatelessWidget {
  const _AnimatedPasswordInput(this._registerCubit);

  final HSRegisterCubit _registerCubit;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HSRegisterCubit, HSRegisterState, HSRegisterPageState>(
      selector: (state) => state.registerPageState,
      builder: (context, state) => Visibility(
        maintainAnimation: true,
        maintainState: true,
        visible: _registerCubit.passwordInputVisible,
        child: _PasswordInput(_registerCubit)
            .animate(
              target: _registerCubit.opacity,
            )
            .fadeIn(duration: 600.ms)
            .slide(duration: 300.ms)
            .callback(
              callback: (_) => _registerCubit.changeRegisterPageState(
                HSRegisterPageState.passwordFadedIn,
              ),
            ),
      ),
    );
  }
}

class _PageInitialHeading extends StatelessWidget {
  const _PageInitialHeading(this._registerCubit);
  final HSRegisterCubit _registerCubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(24.0),
        HSSocialLoginButtons.google(_registerCubit.logInWithGoogle),
        const Gap(24.0),
        HSSocialLoginButtons.apple(_registerCubit.logInWithApple),
        const Gap(24.0),
        const HSAuthHorizontalDivider(),
      ],
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput(this._registerCubit);
  final HSRegisterCubit _registerCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSRegisterCubit, HSRegisterState>(
      buildWhen: (previous, current) =>
          previous.email != current.email ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) => HSTextField(
        key: const Key('RegisterForm_emailInput_textField'),
        onChanged: _registerCubit.emailChanged,
        keyboardType: TextInputType.emailAddress,
        hintText: "Email",
        prefixIcon: const Icon(FontAwesomeIcons.envelope),
        errorText: _errorText(state),
      ),
    );
  }

  String? _errorText(HSRegisterState state) {
    if (!_registerCubit.passwordInputVisible && state.errorMessage != null) {
      return state.errorMessage;
    }
    if (state.email.displayError != null) return "Invalid email";
    return null;
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput(this._registerCubit);
  final HSRegisterCubit _registerCubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<HSRegisterCubit, HSRegisterState>(
          buildWhen: _buildWhen,
          builder: (context, state) {
            return HSTextField(
              onChanged: _registerCubit.passwordChanged,
              obscureText: !state.isPasswordVisible,
              errorText: _errorText(state),
              hintText: "Password",
              onTapPrefix: _registerCubit.togglePasswordVisibility,
              prefixIcon: Icon(state.isPasswordVisible
                  ? FontAwesomeIcons.lockOpen
                  : FontAwesomeIcons.lock),
            );
          },
        ),
        const Gap(24.0),
      ],
    );
  }

  String? _errorText(HSRegisterState state) {
    if (state.errorMessage != null) return state.errorMessage;
    return null;
  }

  bool _buildWhen(HSRegisterState previous, HSRegisterState current) {
    return (previous.password != current.password) ||
        (previous.isPasswordVisible != current.isPasswordVisible) ||
        (previous.errorMessage != current.errorMessage);
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
          loading: _isLoading(state),
          valid: state.isValid,
          onPressed: _registerCubit.passwordInputVisible
              ? () => _registerCubit.signUpFormSubmitted()
              : () => _registerCubit.changeRegisterPageState(
                  HSRegisterPageState.passwordFadingIn),
        );
      },
    );
  }

  bool _isLoading(HSRegisterState state) {
    return (state.status.isInProgress ||
        state.registerPageState == HSRegisterPageState.passwordFadingIn);
  }
}
