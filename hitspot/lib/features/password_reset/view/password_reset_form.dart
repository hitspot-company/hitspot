import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/password_reset/cubit/hs_password_reset_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_textfield.dart';

class PasswordResetForm extends StatelessWidget {
  const PasswordResetForm({super.key});

  @override
  Widget build(BuildContext context) {
    final hsApp = HSApp.instance;
    final passwordResetCubit = context.read<HSPasswordResetCubit>();
    return Column(
      children: [
        const Gap(24.0),
        Text(
          "Please provice your email address below. A reset link will be sent to your inbox.",
          style: hsApp.textTheme.titleMedium,
        ),
        const Gap(24.0),
        _EmailInput(passwordResetCubit),
        const Gap(24.0),
        _SendButton(passwordResetCubit),
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton(
    this._passwordResetCubit,
  );

  final HSPasswordResetCubit _passwordResetCubit;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        child: BlocBuilder<HSPasswordResetCubit, HSPasswordResetState>(
          buildWhen: (previous, current) =>
              previous.pageState != current.pageState,
          builder: (context, state) => HSButton(
            onPressed: _passwordResetCubit.sending || _passwordResetCubit.sent
                ? null
                : _passwordResetCubit.sendResetPasswordEmail,
            child: _passwordResetCubit.sending
                ? const HSLoadingIndicator(
                    size: 24.0,
                    color: Colors.white,
                  )
                : const Text("Send Email"),
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput(
    this._passwordResetCubit,
  );

  final HSPasswordResetCubit _passwordResetCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSPasswordResetCubit, HSPasswordResetState>(
        buildWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.email != current.email,
        builder: (context, state) {
          return HSTextField(
            suffixIcon: const Icon(FontAwesomeIcons.envelope),
            hintText: "Email",
            onChanged: _passwordResetCubit.emailChanged,
            errorText: _passwordResetCubit.state.errorMessage,
          );
        });
  }
}
