import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/trips/create_trip/cubit/hs_create_trip_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/form/hs_form_button.dart';
import 'package:hitspot/widgets/form/hs_form_buttons_row.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class CreateTripPage extends StatelessWidget {
  const CreateTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    final createTripCubit = context.read<HSCreateTripCubit>();
    return HSScaffold(
        appBar: HSAppBar(
          enableDefaultBackButton: true,
          defaultButtonBackIcon: FontAwesomeIcons.xmark,
          title: Text(
            "Create Trip",
            style: textTheme.headlineSmall,
          ),
        ),
        body: Column(
          children: [
            const Gap(16.0),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: createTripCubit.pageController,
                children: [
                  _FirstPage(createTripCubit),
                  _SecondPage(createTripCubit)
                ],
              ),
            ),
          ],
        ));
  }
}

class _FirstPage extends StatelessWidget {
  const _FirstPage(this._createTripCubit);
  final HSCreateTripCubit _createTripCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const _Headline(
          text: "1/4: Basics",
          headlineType: _HeadlineType.display,
        ),
        const _Caption(text: "Tell us more about your trip."),
        const Gap(16.0),
        const _Headline(text: "Trip Title"),
        const Gap(16.0),
        HSTextField(
          maxLength: 64,
          onChanged: _createTripCubit.updateTitle,
          hintText: "An Awesome Trip to...",
          suffixIcon: const Icon(Icons.dangerous, color: Colors.transparent),
        ),
        const Gap(32.0),
        const _Headline(text: "Trip Description"),
        const Gap(16.0),
        HSTextField(
          maxLength: 512,
          onChanged: _createTripCubit.updateDescription,
          hintText: "A trip with friends to...",
          maxLines: 5,
          suffixIcon: const Icon(Icons.dangerous, color: Colors.transparent),
        ),
        const Gap(16.0),
        BlocSelector<HSCreateTripCubit, HSCreateTripState, bool>(
          selector: (state) =>
              state.tripTitle.isNotEmpty && state.tripDescription.isNotEmpty,
          builder: (context, isComplete) {
            return HSFormButtonsRow(
              right: HSFormButton(
                icon: const Icon(FontAwesomeIcons.arrowRight),
                onPressed: isComplete ? _createTripCubit.next : null,
                child: const Text("Planning"),
              ),
            );
          },
        )
      ],
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage(this._createTripCubit);

  final HSCreateTripCubit _createTripCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const _Headline(text: "2/4: Planning"),
        const _Caption(text: "This section is optional. You can skip it."),
        const Gap(32.0),
        HSFormButtonsRow(
            right: const HSFormButton(child: Text("Next")),
            left: HSFormButton(
                onPressed: _createTripCubit.back, child: const Text("Back"))),
      ],
    );
  }
}

enum _HeadlineType { display, normal, small }

class _Caption extends StatelessWidget {
  const _Caption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: textTheme.bodyLarge!.hintify);
  }
}

class _Headline extends StatelessWidget {
  const _Headline(
      {required this.text, this.headlineType = _HeadlineType.small});

  final _HeadlineType headlineType;
  final String text;

  @override
  Widget build(BuildContext context) {
    late final TextStyle? textStyle;
    switch (headlineType) {
      case _HeadlineType.display:
        textStyle = textTheme.headlineLarge;
      case _HeadlineType.normal:
        textStyle = textTheme.headlineMedium;
      case _HeadlineType.small:
        textStyle = textTheme.headlineSmall;
    }
    return Text(text, style: textStyle);
  }
}
