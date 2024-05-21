import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/features/bloc/hs_authentication_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/features/profile_incomplete/cubit/hs_profile_completion_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

class ProfileCompletionForm extends StatelessWidget {
  const ProfileCompletionForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HSProfileCompletionCubit, HSProfileCompletionState>(
      listener: (context, state) {
        if (state.pageComplete) {
          final authBloc = context.read<HSAuthenticationBloc>();
          final currentUser = authBloc.state.user;
          authBloc.add(HSAppUserChanged(currentUser));
        }
      },
      buildWhen: (previous, current) =>
          previous.step != current.step ||
          previous.usernameValidationState != current.usernameValidationState ||
          previous.loading != current.loading,
      builder: (context, state) {
        final int currentStep = state.step;
        final profileCompletionCubit = context.read<HSProfileCompletionCubit>();
        return Stepper(
          currentStep: currentStep,
          onStepTapped: null, //profileCompletionCubit.updateStep,
          onStepContinue: profileCompletionCubit.onStepContinue,
          onStepCancel: profileCompletionCubit.onStepCancel,
          controlsBuilder: _controlsBuilder,
          steps: [
            Step(
              state: StepState.disabled,
              title: const Text("Birthdate"),
              content: _BirthdayInput(profileCompletionCubit),
            ),
            Step(
              state: StepState.disabled,
              title: const Text("Username"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _UsernameGuidelines(),
                  const Gap(16.0),
                  _UsernameInput(profileCompletionCubit),
                ],
              ),
            ),
            Step(
              state: StepState.disabled,
              title: const Text("Full name"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Make it easier for your friends to find you using your name.",
                    style: HSTheme.instance.textTheme.titleMedium,
                  ),
                  const Gap(16.0),
                  _FullnameInput(profileCompletionCubit),
                ],
              ),
            ),
            Step(
              state: StepState.disabled,
              title: const Text("Confirm"),
              content: _ConfirmationDetails(
                  profileCompletionCubit: profileCompletionCubit),
            ),
          ],
        );
      },
    );
  }

  Widget _controlsBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: details.currentStep != 0
                ? HSButton(
                    onPressed: details.onStepCancel!, child: const Text('BACK'))
                : const SizedBox(),
          ),
          const Gap(8.0),
          Expanded(
            child: getNextButton(context, details),
          ),
        ],
      ),
    );
  }

  HSButton getNextButton(BuildContext context, ControlsDetails details) {
    final profileCompletionCubit = context.read<HSProfileCompletionCubit>();
    final currentUser = context.read<HSAuthenticationBloc>().state.user;
    final usernameValidationState =
        profileCompletionCubit.state.usernameValidationState;
    if (details.currentStep == 3) {
      if (profileCompletionCubit.state.loading) {
        return const HSButton(
          onPressed: null,
          child: HSLoadingIndicator(
            size: 32.0,
          ),
        );
      }
      return HSButton(
        onPressed: () =>
            profileCompletionCubit.completeUserProfile(currentUser),
        child: const Text('SAVE'),
      );
    } else if (details.currentStep == 1) {
      switch (usernameValidationState) {
        case UsernameValidationState.unknown || UsernameValidationState.empty:
          return HSButton(
            onPressed: profileCompletionCubit.isUsernameValid,
            child: const Text('VERIFY'),
          );
        case UsernameValidationState.verifying:
          return const HSButton(
            onPressed: null,
            child: HSLoadingIndicator(
              size: 32.0,
            ),
          );
        case UsernameValidationState.unavailable:
          return const HSButton(
            onPressed: null,
            child: Text("NEXT"),
          );
        case UsernameValidationState.available:
          return HSButton(
            onPressed: details.onStepContinue!,
            child: const Text("NEXT"),
          );
      }
    } else {
      return HSButton(
        onPressed: details.onStepContinue!,
        child: const Text('NEXT'),
      );
    }
  }
}

class _ConfirmationDetails extends StatelessWidget {
  const _ConfirmationDetails({
    required this.profileCompletionCubit,
  });

  final HSProfileCompletionCubit profileCompletionCubit;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HSProfileCompletionCubit, HSProfileCompletionState,
        bool>(
      selector: (state) => state.loading,
      builder: (context, loading) {
        return Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your details",
                style: HSTheme.instance.textTheme.titleMedium,
              ),
              const Gap(16.0),
              Text(
                profileCompletionCubit.state.birthday.value
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
        );
      },
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
  const _BirthdayInput(this._profileCompletionCubit);

  final HSProfileCompletionCubit _profileCompletionCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSProfileCompletionCubit, HSProfileCompletionState>(
      buildWhen: (previous, current) =>
          previous.birthday != current.birthday ||
          previous.birthdayError != current.birthdayError,
      builder: (context, state) => HSTextField(
        key: const Key('ProfileCompletionForm_birthdayInput_textField'),
        prefixIcon: const Icon(FontAwesomeIcons.cakeCandles),
        readOnly: true,
        onTap: () async {
          DateTime now = DateTime.now();
          DateTime? pickedDate = await showDatePicker(
              context: context,
              currentDate: DateTime(now.year - 18, now.month, now.day),
              firstDate: DateTime(now.year - 100, now.month, now.day),
              lastDate: DateTime(now.year - 18, now.month, now.day));
          if (pickedDate != null) {
            _profileCompletionCubit.updateBirthday(pickedDate.toString());
          }
        },
        hintText: _hintText(state.birthday),
        errorText: _errorText(state),
      ),
    );
  }

  String _hintText(Birthdate birthday) {
    if (!birthday.isPure) {
      return birthday.value.dateTimeToReadableString();
    }
    return "Date of Birth";
  }

  String? _errorText(HSProfileCompletionState state) {
    if (state.birthdayError.isNotEmpty) {
      return state.birthdayError;
    }
    return null;
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput(this._profileCompletionCubit);
  final HSProfileCompletionCubit _profileCompletionCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSProfileCompletionCubit, HSProfileCompletionState>(
      buildWhen: (previous, current) =>
          previous.username != current.username ||
          previous.usernameValidationState != current.usernameValidationState,
      builder: (context, state) => HSTextField(
        textInputAction: TextInputAction.next,
        scrollPadding: const EdgeInsets.all(84.0),
        key: const Key('ProfileCompletionForm_usernameInput_textField'),
        onChanged: _profileCompletionCubit.updateUsername,
        hintText: "Username",
        prefixIcon: _getPrefixIcon(state.usernameValidationState),
        errorText: _errorText(state),
      ),
    );
  }

  Icon _getPrefixIcon(UsernameValidationState usernameValidationState) {
    switch (usernameValidationState) {
      case UsernameValidationState.available:
        return const Icon(FontAwesomeIcons.check, color: Colors.green);
      case UsernameValidationState.unavailable:
        return const Icon(FontAwesomeIcons.exclamation, color: Colors.red);
      default:
        return const Icon(FontAwesomeIcons.question);
    }
  }

  String? _errorText(HSProfileCompletionState state) {
    UsernameValidationError? error = state.username.displayError;
    if (state.usernameValidationState == UsernameValidationState.unavailable) {
      error = UsernameValidationError.unavailable;
    } else if (state.usernameValidationState == UsernameValidationState.empty) {
      error = UsernameValidationError.invalid;
    }
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
  const _FullnameInput(this._profileCompletionCubit);
  final HSProfileCompletionCubit _profileCompletionCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSProfileCompletionCubit, HSProfileCompletionState>(
      buildWhen: (previous, current) => previous.fullname != current.fullname,
      builder: (context, state) => HSTextField(
        key: const Key('ProfileCompletionForm_usernameInput_textField'),
        onChanged: _profileCompletionCubit.updateFullname,
        hintText: "Name and Surname",
        prefixIcon: const Icon(FontAwesomeIcons.solidUser),
        errorText: _errorText(state),
      ),
    );
  }

  String? _errorText(HSProfileCompletionState state) {
    if (state.fullname.displayError != null) {
      return "Invalid name and surname";
    }
    return null;
  }
}
