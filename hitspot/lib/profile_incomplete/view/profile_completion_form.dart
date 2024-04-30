import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/hs_theme.dart';
import 'package:hitspot/profile_incomplete/cubit/hs_profile_completion_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

class ProfileCompletionForm extends StatelessWidget {
  ProfileCompletionForm({super.key});

  final FocusNode birthdayNode = FocusNode();
  final FocusNode usernameNode = FocusNode();
  final FocusNode fullnameNode = FocusNode();
  final FocusNode confirmNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HSProfileCompletionCubit, HSProfileCompletionState,
        int>(
      selector: (state) => state.step,
      builder: (context, currentStep) {
        final profileCompletionCubit = context.read<HSProfileCompletionCubit>();
        return Stepper(
          currentStep: currentStep,
          onStepTapped: profileCompletionCubit.updateStep,
          onStepContinue: profileCompletionCubit.onStepContinue,
          onStepCancel: profileCompletionCubit.onStepCancel,
          controlsBuilder: _controlsBuilder,
          steps: [
            const Step(
              title: Text("Birthdate"),
              content: _BirthdayInput(),
            ),
            Step(
              title: const Text("Username"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _UsernameGuidelines(),
                  const Gap(16.0),
                  _UsernameInput(),
                ],
              ),
            ),
            Step(
              title: const Text("Full name"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Make it easier for your friends to find you using your name.",
                    style: HSTheme.instance.textTheme(context).titleMedium,
                  ),
                  const Gap(16.0),
                  _FullnameInput(),
                ],
              ),
            ),
            Step(
                title: const Text("Confirm"),
                content: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your details",
                        style: HSTheme.instance.textTheme(context).titleMedium,
                      ),
                      const Gap(16.0),
                      Text(
                        profileCompletionCubit.state.birthday
                            .dateTimeToReadableString(),
                      ),
                      const Gap(16.0),
                      Text(
                        profileCompletionCubit.state.username.value,
                      ),
                      const Gap(16.0),
                      Text(profileCompletionCubit.state.fullname.value),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _controlsBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          HSButton(onPressed: details.onStepCancel!, child: const Text('BACK')),
          HSButton(
              onPressed: details.onStepContinue!, child: const Text('SAVE')),
        ],
      ),
    );
  }
}

class _UsernameGuidelines extends StatelessWidget {
  const _UsernameGuidelines() : super();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "Your username has to be ",
        children: [
          TextSpan(
            text: "unique, ",
            style: const TextStyle().boldify(),
          ),
          const TextSpan(
            text: "between ",
          ),
          TextSpan(
            text: "5 ",
            style: const TextStyle().boldify(),
          ),
          const TextSpan(
            text: "and ",
          ),
          TextSpan(
            text: "16 ",
            style: const TextStyle().boldify(),
          ),
          const TextSpan(
            text: "characters long, ",
          ),
          const TextSpan(
            text: "and can only contain ",
          ),
          TextSpan(
            text: "alphanumeric ",
            style: const TextStyle().boldify(),
          ),
          const TextSpan(
            text: "characters plus the ",
          ),
          TextSpan(
            text: "'_'",
            style: const TextStyle().boldify(),
          ),
        ],
      ),
    );
  }
}

class _BirthdayInput extends StatelessWidget {
  const _BirthdayInput();

  @override
  Widget build(BuildContext context) {
    final profileCompletionCubit = context.read<HSProfileCompletionCubit>();
    return BlocBuilder<HSProfileCompletionCubit, HSProfileCompletionState>(
      buildWhen: (previous, current) => previous.birthday != current.birthday,
      builder: (context, state) => HSTextField(
        key: const Key('ProfileCompletionForm_birthdayInput_textField'),
        prefixIcon: const Icon(FontAwesomeIcons.cakeCandles),
        readOnly: true,
        onTap: () async {
          DateTime now = DateTime.now();
          DateTime? pickedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(now.year - 100, now.month, now.day),
              lastDate: DateTime(now.year - 18, now.month, now.day));
          if (pickedDate != null) {
            profileCompletionCubit.updateBirthday(pickedDate.toString());
          }
        },
        hintText: state.birthday.dateTimeToReadableString(),
      ),
    );
  }
}

// TODO: Talk about debounce to limit queries
class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSProfileCompletionCubit, HSProfileCompletionState>(
      buildWhen: (previous, current) =>
          previous.username != current.username ||
          previous.usernameAvailable != current.usernameAvailable,
      builder: (context, state) => HSTextField(
        textInputAction: TextInputAction.next,
        scrollPadding: const EdgeInsets.all(84.0),
        key: const Key('ProfileCompletionForm_usernameInput_textField'),
        onChanged: context.read<HSProfileCompletionCubit>().updateUsername,
        hintText: "Username",
        prefixIcon: Icon(state.username.error != null && !state.username.isPure
            ? FontAwesomeIcons.exclamation
            : FontAwesomeIcons.check),
        errorText: _errorText(state),
      ),
    );
  }

  String? _errorText(HSProfileCompletionState state) {
    UsernameValidationError? error = state.username.displayError;
    if (!state.usernameAvailable) error = UsernameValidationError.unavailable;
    if (error == null) return null;
    switch (error) {
      case UsernameValidationError.notLowerCase:
        return "No uppercase letters.";
      case UsernameValidationError.short:
        return "At least 5 characters.";
      case UsernameValidationError.long:
        return "More than 16 characters.";
      case UsernameValidationError.unavailable:
        return "The username is already taken.";
      default:
        return "Invalid username";
    }
  }
}

class _FullnameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSProfileCompletionCubit, HSProfileCompletionState>(
      buildWhen: (previous, current) => previous.fullname != current.fullname,
      builder: (context, state) => HSTextField(
        key: const Key('ProfileCompletionForm_usernameInput_textField'),
        onChanged: context.read<HSProfileCompletionCubit>().updateFullname,
        hintText: "Name and Surname",
        prefixIcon: const Icon(FontAwesomeIcons.solidUser),
        errorText: state.fullname.displayError != null
            ? "Invalid name and surname"
            : null,
      ),
    );
  }
}

extension ProfileCompletionExtensions on String {
  String dateTimeToReadableString() {
    return toString().split(" ").elementAt(0);
  }

  Timestamp? dateTimeStringToTimestamp() {
    final DateTime date = DateTime.parse(this);
    final Timestamp ts = Timestamp.fromDate(date);
    return (ts);
  }
}
