import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/bloc/choose_hashtags/hs_choose_hashtags_cubit.dart';
import 'package:hitspot/bloc/profile_completion/hs_profile_completion_bloc.dart';
import 'package:hitspot/presentation/widgets/global/hs_appbar.dart';
import 'package:hitspot/presentation/widgets/global/hs_scaffold.dart';
import 'package:choice/choice.dart';
import 'package:hitspot/presentation/widgets/global/hs_textfield.dart';

class ProfileCompletionPage extends StatelessWidget {
  ProfileCompletionPage({super.key});

  final bdayController = TextEditingController();
  final fullnameController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        title: "Your Details",
      ),
      body: Column(
        children: [
          const Text(
              "Before we help reshape your travelling habits we first need to get to know you a little.\n\nPlease enter your details below."),
          Expanded(
            child: BlocProvider(
              create: (context) => HSProfileCompletionBloc(),
              child: BlocBuilder<HSProfileCompletionBloc,
                  HSProfileCompletionState>(
                builder: (context, state) {
                  int step = state.step;
                  return Stepper(
                    currentStep: step,
                    onStepContinue: () =>
                        BlocProvider.of<HSProfileCompletionBloc>(context).add(
                      HSProfileCompletionChangeStep(step + 1,
                          username: usernameController.text,
                          fullname: fullnameController.text,
                          bday: bdayController.text),
                    ),
                    onStepCancel: () =>
                        BlocProvider.of<HSProfileCompletionBloc>(context).add(
                      HSProfileCompletionChangeStep(step - 1,
                          username: usernameController.text,
                          fullname: fullnameController.text,
                          bday: bdayController.text),
                    ),
                    onStepTapped: (stepNum) {
                      BlocProvider.of<HSProfileCompletionBloc>(context).add(
                        HSProfileCompletionChangeStep(stepNum,
                            username: usernameController.text,
                            fullname: fullnameController.text,
                            bday: bdayController.text),
                      );
                    },
                    steps: [
                      Step(
                        title: const Text("Birthdate"),
                        content: HSTextField(
                          controller: bdayController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime.parse("1900-01-01"),
                                lastDate: DateTime.parse("2100-01-01"));
                            if (pickedDate != null) {
                              bdayController.text = pickedDate.toString();
                            }
                          },
                          hintText: DateTime.now().toString(),
                        ),
                      ),
                      Step(
                        title: const Text("Full name"),
                        content: HSTextField(
                          controller: fullnameController,
                          hintText: "Your name",
                        ),
                      ),
                      Step(
                        title: const Text("Username"),
                        content: HSTextField(
                          controller: usernameController,
                          hintText: "unique_username",
                        ),
                      ),
                      Step(
                        title: const Text("Preferences"),
                        content: BlocProvider(
                          create: (context) => HSChooseHashtagsCubit(),
                          child: ChooseHashtags(),
                        ),
                      ),
                    ],
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
      onChanged: (value) =>
          BlocProvider.of<HSChooseHashtagsCubit>(context).updateChosen(value),
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
