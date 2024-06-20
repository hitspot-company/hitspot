import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/login/magic_link/cubit/hs_magic_link_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class MagicLinkSentPage extends StatelessWidget {
  const MagicLinkSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final magiclinkCubit = BlocProvider.of<HSMagicLinkCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        title: Text("Magic Link Sent", style: textTheme.headlineSmall),
        enableDefaultBackButton: true,
        defaultBackButtonCallback: app.signOut,
      ),
      body: ListView(
        children: [
          const Gap(32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text.rich(
              TextSpan(
                text: "We have sent a",
                style: textTheme.headlineLarge,
                children: [
                  TextSpan(
                    text: " magic link",
                    style: TextStyle(color: app.theme.mainColor),
                  ),
                  const TextSpan(text: " to "),
                  TextSpan(
                    text: " ${magiclinkCubit.email}.\n\n",
                    style: TextStyle(color: app.theme.mainColor),
                  ),
                  TextSpan(
                      text:
                          "Please check your inbox and click the link to securely sign in.",
                      style: textTheme.bodyMedium),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(32.0),
          Center(
            child: Text(
              "Or use the one time code.",
              style: textTheme.headlineSmall,
            ),
          ),
          const Gap(24.0),
          HSTextField.filled(
            hintText: "0123",
            onChanged: magiclinkCubit.updateOtp,
            maxLength: 6,
            keyboardType: TextInputType.number,
          ),
          const Gap(32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocSelector<HSMagicLinkCubit, HSMagicLinkState, bool>(
              selector: (state) => state.status == HSMagicLinkStatus.verifying,
              builder: (context, isVerifying) {
                return HSButton(
                  onPressed: isVerifying ? null : magiclinkCubit.verifyOtp,
                  child: isVerifying
                      ? const HSLoadingIndicator()
                      : const Text("Verify"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
