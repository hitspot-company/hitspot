import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/features/verify_email/cubit/hs_verify_email_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_text_prompt.dart';

class VerifyEmailForm extends StatelessWidget {
  const VerifyEmailForm({super.key});

  final String headline =
      "Your email is not verified. We have sent a verification link to your inbox.";

  @override
  Widget build(BuildContext context) {
    final app = HSApp.instance;
    final emailVerificationCubit = context.read<HSVerifyEmailCubit>();
    return Column(
      children: [
        Text(
          headline,
          style: app.textTheme.titleMedium!.hintify,
        ),
        const Gap(24.0),
        BlocSelector<HSVerifyEmailCubit, HSVerifyEmailState,
            HSEmailVerificationState>(
          selector: (state) => state.emailVerificationState,
          builder: (context, state) => Column(
            children: [
              SizedBox(
                width: double.maxFinite,
                child: HSButton(
                  onPressed: emailVerificationCubit.isEmailVerified,
                  child: _buttonChild(state),
                ),
              ),
              const Gap(16.0),
              HSTextPrompt(
                prompt: "Didn't receive the link?",
                pressableText: " Resend",
                promptColor: app.theme.mainColor,
                onTap: () => emailVerificationCubit.sendVerificationEmail(),
                textAlign: TextAlign.right,
              ),
              const Gap(16.0),
              _errorWidget(state) ?? const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buttonChild(HSEmailVerificationState state) {
    switch (state) {
      case HSEmailVerificationState.initial || HSEmailVerificationState.resent:
        return const Text("Verify");
      case HSEmailVerificationState.unverified:
        return const Text("Retry");
      case HSEmailVerificationState.sending ||
            HSEmailVerificationState.verifying:
        return const HSLoadingIndicator(size: 24.0);
      case HSEmailVerificationState.verified:
        return const Text("Verified");
      default:
        return const Text("Unknown");
    }
  }

  Text? _errorWidget(HSEmailVerificationState state) {
    const textStyle = TextStyle(color: Colors.red);
    switch (state) {
      case HSEmailVerificationState.failedToResend:
        return const Text(
          "Failed to resend the email. Please try again or contact support at support@hitspot.app",
          style: textStyle,
        );
      case HSEmailVerificationState.unverified:
        return const Text(
          "Your email address is not verified. Have you checked your inbox?",
          style: textStyle,
          textAlign: TextAlign.center,
        );
      default:
        return null;
    }
  }
}
