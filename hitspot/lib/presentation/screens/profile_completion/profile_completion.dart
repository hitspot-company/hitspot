import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/bloc/form_validator/hs_validator.dart';
import 'package:hitspot/bloc/profile_completion/hs_profile_completion_cubit.dart';
import 'package:hitspot/presentation/widgets/global/hs_appbar.dart';
import 'package:hitspot/presentation/widgets/global/hs_scaffold.dart';
import 'package:choice/choice.dart';
import 'package:hitspot/presentation/widgets/global/hs_textfield.dart';

class ProfileCompletionPage extends StatelessWidget with HSValidator {
  ProfileCompletionPage({super.key});

  final List<String> choices = ["graffiti", "landscape", "urban"];
  final String headline =
      "Before we help reshape your travelling habits we first need to get to know you a little.\n\nPlease enter your details below.";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        title: "Your Details",
      ),
      body: Column(
        children: [
          Text(headline),
          Expanded(
            child: BlocProvider(
              create: (context) => HSProfileCompletionCubit(),
              child: BlocBuilder<HSProfileCompletionCubit,
                  HSProfileCompletionState>(
                builder: (context, state) {
                  int step = state.step;
                  final profileCompletionCubit =
                      context.read<HSProfileCompletionCubit>();
                  return Form(
                    key: _formKey,
                    child: Stepper(
                      currentStep: step,
                      onStepContinue: () =>
                          profileCompletionCubit.changeStep(step + 1),
                      onStepCancel: () =>
                          profileCompletionCubit.changeStep(step - 1),
                      onStepTapped: (stepNum) =>
                          profileCompletionCubit.changeStep(stepNum),
                      steps: [
                        Step(
                          title: const Text("Birthdate"),
                          content: HSTextField(
                            readOnly: true,
                            onTap: () async {
                              DateTime now = DateTime.now();
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.parse("1900-01-01"),
                                  lastDate: DateTime(
                                      now.year - 18, now.month, now.day));
                              if (pickedDate != null) {
                                profileCompletionCubit
                                    .updateBirthdate(pickedDate.toString());
                              }
                            },
                            hintText: DateTime.now().toString(),
                          ),
                        ),
                        Step(
                          title: const Text("Full name"),
                          content: HSTextField(
                            validator: validateFullname,
                            onChanged: profileCompletionCubit.updateFullname,
                            hintText: "Your name",
                          ),
                        ),
                        Step(
                          title: const Text("Username"),
                          content: HSTextField(
                            validator: validateUsername,
                            onChanged: profileCompletionCubit.updateUsername,
                            hintText: "unique_username",
                          ),
                        ),
                        Step(
                          title: const Text("Preferences"),
                          content: InlineChoice.multiple(
                            clearable: true,
                            itemCount: choices.length,
                            value: profileCompletionCubit.state.preferences,
                            onChanged: (val) =>
                                profileCompletionCubit.updatePreferences(val),
                            itemBuilder: (choiceState, i) {
                              return ChoiceChip(
                                selected: choiceState.selected(choices[i]),
                                onSelected: choiceState.onSelected(choices[i]),
                                label: Text(choices[i]),
                              );
                            },
                          ),
                        ),
                        Step(
                          title: const Text("Confirm"),
                          state: StepState.complete,
                          content: ListView(
                            shrinkWrap: true,
                            children: List.from([
                              state.bday,
                              state.fullname,
                              state.username,
                              state.preferences
                            ]).map((e) => Text(e.toString())).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChooseHashtags extends StatelessWidget {
  // const
  ChooseHashtags({super.key});

  final List<String> choices = ["graffiti", "landscape", "urban"];

  @override
  Widget build(BuildContext context) {
    return InlineChoice.multiple(
      clearable: true,
      itemCount: choices.length,
      onChanged:
          BlocProvider.of<HSProfileCompletionCubit>(context).updatePreferences,
      itemBuilder: (choiceState, i) {
        return ChoiceChip(
          selected: choiceState.selected(choices[i]),
          onSelected: choiceState.onSelected(choices[i]),
          label: Text(choices[i]),
        );
      },
    );
  }
}
