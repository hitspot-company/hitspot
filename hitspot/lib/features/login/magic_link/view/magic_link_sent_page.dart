import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/features/login/magic_link/cubit/hs_magic_link_cubit.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MagicLinkSentPage extends StatelessWidget {
  const MagicLinkSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final magiclinkCubit = BlocProvider.of<HSMagicLinkCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        title: Text("One Time Password Sent",
            style: Theme.of(context).textTheme.headlineSmall),
        enableDefaultBackButton: true,
        defaultBackButtonCallback: () => navi.pop(),
      ),
      body: ListView(
        children: [
          const Gap(32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text.rich(
              TextSpan(
                text: "We have sent a",
                style: Theme.of(context).textTheme.headlineLarge,
                children: [
                  TextSpan(
                    text: " one time password",
                    style: TextStyle(color: app.theme.mainColor),
                  ),
                  const TextSpan(text: " to "),
                  TextSpan(
                    text: " ${magiclinkCubit.email}",
                    style: TextStyle(color: app.theme.mainColor),
                  ),
                  TextSpan(
                    text: ".\n\n",
                    style: app.textTheme.headlineLarge,
                  ),
                  TextSpan(
                      text: "Please check your inbox and enter the code.",
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutQuad),
          const Gap(32.0),
          BlocSelector<HSMagicLinkCubit, HSMagicLinkState, HSMagicLinkError?>(
            selector: (state) =>
                (state.error != HSMagicLinkError.none) ? state.error : null,
            builder: (context, error) {
              late String errorMessage;

              if (error == HSMagicLinkError.invalidOTP) {
                errorMessage = "OTP is invalid or has expired";
              } else if (error == HSMagicLinkError.emptyOTP) {
                errorMessage = "OTP cannot be empty";
              } else {
                errorMessage = "";
              }

              return HSTextField.filled(
                hintText: "0123",
                errorText: errorMessage,
                onChanged: magiclinkCubit.updateOtp,
                maxLength: 6,
                keyboardType: TextInputType.number,
              );
            },
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 600.ms),
          const Gap(32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocSelector<HSMagicLinkCubit, HSMagicLinkState, bool>(
              selector: (state) => state.status == HSMagicLinkStatus.verifying,
              builder: (context, isVerifying) {
                if (isVerifying) return HSFormButton.loading();
                return HSFormButton(
                  onPressed: magiclinkCubit.verifyOtp,
                  child: const Text("Verify"),
                );
              },
            ),
          )
              .animate()
              .fadeIn(delay: 900.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, delay: 900.ms, duration: 600.ms),
        ],
      ),
    );
  }
}
