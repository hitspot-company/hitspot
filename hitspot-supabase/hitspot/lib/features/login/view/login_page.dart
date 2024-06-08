import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/login/cubit/hs_login_cubit.dart';
import 'package:hitspot/widgets/auth/hs_auth_button.dart';
import 'package:hitspot/widgets/auth/hs_auth_horizontal_divider.dart';
import 'package:hitspot/widgets/auth/hs_auth_page_title.dart';
import 'package:hitspot/widgets/auth/hs_auth_social_buttons.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<HSLoginCubit>();
    return HSScaffold(
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
          const SliverToBoxAdapter(child: Gap(24.0)),
          SliverToBoxAdapter(
              child: HSSocialLoginButtons.apple(loginCubit.logInWithApple)),
          const SliverToBoxAdapter(child: Gap(24.0)),
          const SliverToBoxAdapter(child: _Footer()),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  final String info =
      "Hitspot uses cookies for analytics, personalised content and ads. By using Hitspot's services you agree to this use of cookies.";
  final String pressableText = " Learn more";

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: info,
        children: [
          TextSpan(
            text: pressableText,
            style: const TextStyle(
              color: Color.fromARGB(255, 130, 130, 130),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      style: const TextStyle(
        color: Colors.grey,
      ),
      textAlign: TextAlign.center,
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
