import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/bloc/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/bloc/email_validation/hs_email_validation_bloc.dart';
import 'package:hitspot/constants/hs_const.dart';
import 'package:hitspot/constants/hs_theming.dart';
import 'package:hitspot/presentation/screens/home/home.dart';
import 'package:hitspot/presentation/screens/register/register.dart';
import 'package:hitspot/presentation/widgets/global/hs_appbar.dart';
import 'package:hitspot/presentation/widgets/global/hs_loading_indicator.dart';
import 'package:hitspot/presentation/widgets/global/hs_scaffold.dart';
import 'package:hitspot/repositories/email_validation/hs_email_validation_repo.dart';
import 'package:hitspot/services/email_validation/hs_email_validation_service.dart';
import 'package:hitspot/utils/hs_notifications.dart';

class EmailValidationPage extends StatelessWidget {
  static String id = "email_validation_page";
  const EmailValidationPage({super.key, this.enableBackButton = true});

  final bool enableBackButton;

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: enableBackButton,
        title: "Verify email",
      ),
      body: BlocProvider(
        create: (context) => HSEmailValidationBloc(
          HSEmailValidationRepo(
            HSEmailValidationService(),
          ),
        )..add(HSEmailValidationSendEmailEvent()),
        child: BlocConsumer<HSEmailValidationBloc, HSEmailValidationState>(
          listener: (context, state) {
            final snacks = HSNotifications.instance.snackbar(context);
            if (state is HSEmailValidationEmailValidatedState) {
              Navigator.pushReplacementNamed(context, HomePage.id);
            }
            if (state is HSEmailValidationEmailSentState) {
              snacks.success(
                  title: "Email Sent",
                  message: "Verification email has been sent to your inbox.");
            } else if (state is HSEmailValidationErrorState) {
              snacks.error(
                  title: state.errorTitle, message: state.errorMessage);
            }
          },
          builder: (context, state) {
            if (state is HSEmailValidationLoadingState) {
              return const HSLoadingIndicator();
            }
            return Column(
              children: [
                const Text(
                    "Please validate your email address through your inbox. Then proceed by pressing the button below."),
                const Gap(24.0),
                CupertinoButton(
                  color: HSTheming.instance.mainColor,
                  child: const Text("Email verified"),
                  onPressed: () =>
                      BlocProvider.of<HSEmailValidationBloc>(context).add(
                    HSEmailValidationValidateEmail(),
                  ),
                ),
                const Gap(24.0),
                Text.rich(
                  TextSpan(
                    text: "Alternatively go back to the",
                    children: [
                      TextSpan(
                        text: " Register Page.",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .colorify(HSApp.theming.mainColor)
                            .boldify(),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              BlocProvider.of<HSAuthenticationBloc>(context)
                                  .add(HSSignOutEvent()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
