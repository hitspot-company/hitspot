import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/bloc/authentication/hs_authentication_bloc.dart';
import 'package:hitspot/bloc/form_validator/hs_form_validator_cubit.dart';
import 'package:hitspot/bloc/form_validator/hs_validator.dart';
import 'package:hitspot/constants/hs_const.dart';
import 'package:hitspot/presentation/screens/email_validation/email_validation.dart';
import 'package:hitspot/presentation/screens/home/home.dart';
import 'package:hitspot/presentation/screens/login/login.dart';
import 'package:hitspot/presentation/widgets/global/hs_appbar.dart';
import 'package:hitspot/utils/hs_display_size.dart';
import 'package:hitspot/presentation/widgets/global/hs_scaffold.dart';
import 'package:hitspot/presentation/widgets/global/hs_textfield.dart';
import 'package:hitspot/constants/hs_theming.dart';
import 'package:hitspot/utils/hs_notifications.dart';

class RegisterPage extends StatelessWidget with HSValidator {
  static const String id = "register_page";
  RegisterPage({super.key});

  final String title = "Let's register!";
  final String headline = "Please enter your details";
  final String buttonText = "Sign Up";
  final _formKey = GlobalKey<FormState>();
  final FocusNode passwordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final formValidatorCubit = context.read<HSFormValidatorCubit>();
    return HSScaffold(
      sidePadding: 16.0,
      appBar: HSAppBar(
        center: Image.asset(
          HSApp.assets.textLogoPath,
        ),
      ),
      body: BlocSelector<HSFormValidatorCubit, HSFormValidatorState,
          AutovalidateMode>(
        bloc: context.read<HSFormValidatorCubit>(),
        selector: (state) => state.autovalidateMode,
        builder: (context, autovalidateMode) {
          return Form(
            key: _formKey,
            autovalidateMode: autovalidateMode,
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
                HSTextField(
                  validator: validateEmail,
                  onChanged: formValidatorCubit.updateEmail,
                  hintText: "Email",
                  prefixIcon: const Icon(FontAwesomeIcons.envelope),
                ),
                const Gap(24.0),
                BlocSelector<HSFormValidatorCubit, HSFormValidatorState, bool>(
                  selector: (state) => state.obscureText,
                  builder: (context, obscure) {
                    return HSTextField(
                      validator: validatePassword,
                      onChanged: formValidatorCubit.updatePassword,
                      obscureText: obscure,
                      node: passwordNode,
                      hintText: "Password",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: IconButton(
                        onPressed: formValidatorCubit.toggleObscureText,
                        icon: obscure
                            ? const Icon(FontAwesomeIcons.lock)
                            : const Icon(FontAwesomeIcons.eye),
                      ),
                    );
                  },
                ),
                const Gap(32.0),
                SizedBox(
                  width: displayWidth(context) - 32.0,
                  height: 60,
                  child:
                      BlocConsumer<HSAuthenticationBloc, HSAuthenticationState>(
                    listener: (context, state) {
                      if (state is HSAuthenticationFailureState) {
                        HSNotifications.instance
                            .snackbar(context)
                            .error(title: "Error", message: state.errorMessage);
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            BlocProvider.of<HSAuthenticationBloc>(context).add(
                                HSSignUpEvent(
                                    email: formValidatorCubit.state.email,
                                    password: formValidatorCubit.state.email));
                          } else {
                            formValidatorCubit.updateAutovalidateMode(
                                AutovalidateMode.onUserInteraction);
                          }
                        },
                        label: state is HSAuthenticationLoadingState &&
                                state.isLoading
                            ? const Text("....")
                            : Text(buttonText),
                        icon: const Icon(FontAwesomeIcons.arrowRight),
                      );
                    },
                  ),
                ),
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
                            .colorify(HSApp.theming.mainColor)
                            .boldify(),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushReplacementNamed(
                              context, LoginPage.id),
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
                            .colorify(HSApp.theming.mainColor)
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
                            .colorify(HSApp.theming.mainColor)
                            .boldify(),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => print("PP"),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
