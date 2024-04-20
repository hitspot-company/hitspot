import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/bloc/bloc/hs_profile_completion_bloc.dart';
import 'package:hitspot/presentation/widgets/global/hs_appbar.dart';
import 'package:hitspot/presentation/widgets/global/hs_scaffold.dart';
import 'package:hitspot/presentation/widgets/global/hs_textfield.dart';

class ProfileCompletionPage extends StatelessWidget {
  const ProfileCompletionPage({super.key});

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
                              BlocProvider.of<HSProfileCompletionBloc>(context)
                                  .add(HSProfileCompletionNextStepEvent(step)),
                          onStepCancel: () => BlocProvider.of<
                                  HSProfileCompletionBloc>(context)
                              .add(HSProfileCompletionPreviousStepEvent(step)),
                          steps: [
                            Step(
                              title: const Text("Birthdate"),
                              content: HSTextField(
                                hintText: DateTime.now().toString(),
                              ),
                            ),
                            const Step(
                              title: Text("Full name"),
                              content: HSTextField(
                                hintText: "Your name",
                              ),
                            ),
                            const Step(
                              title: Text("Username"),
                              content: HSTextField(
                                hintText: "unique_username",
                              ),
                            ),
                          ],
                        );
                      },
                    ))),
          ],
        ));
  }
}
