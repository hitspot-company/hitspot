import 'dart:io';

import 'package:currency_picker/currency_picker.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/trips/create_trip/cubit/hs_create_trip_cubit.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_form_inputs/hs_form_inputs.dart';

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
                  _SecondPage(createTripCubit),
                  _ThirdPage(createTripCubit),
                  _FourthPage(createTripCubit),
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
    final String titleHint = _createTripCubit.state.tripTitle.isNotEmpty
        ? _createTripCubit.state.tripTitle
        : "An Awesome Trip to...";
    final String descriptionHint =
        _createTripCubit.state.tripDescription.isNotEmpty
            ? _createTripCubit.state.tripDescription
            : "A trip with friends to...";
    return ListView(
      shrinkWrap: true,
      children: [
        const HSFormHeadline(
          text: "1/4: Basics",
          headlineType: HSFormHeadlineType.display,
        ),
        const HSFormCaption(text: "Tell us more about your trip."),
        const Gap(16.0),
        const HSFormHeadline(text: "Trip Title"),
        const Gap(16.0),
        HSTextField(
          maxLength: 64,
          onChanged: _createTripCubit.updateTitle,
          hintText: titleHint,
          suffixIcon: const Icon(Icons.dangerous, color: Colors.transparent),
        ),
        const Gap(32.0),
        const HSFormHeadline(text: "Trip Description"),
        const Gap(16.0),
        HSTextField(
          maxLength: 512,
          onChanged: _createTripCubit.updateDescription,
          hintText: descriptionHint,
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
        const HSFormHeadline(
            text: "2/4: Planning", headlineType: HSFormHeadlineType.display),
        const HSFormCaption(text: "This section is optional. You can skip it."),
        const Gap(32.0),
        const HSFormHeadline(text: "Budget"),
        const HSFormCaption(text: "What's the trip's budget?"),
        const Gap(8.0),
        BlocSelector<HSCreateTripCubit, HSCreateTripState, Currency?>(
          selector: (state) => state.currency,
          builder: (context, state) {
            return Row(
              children: [
                GestureDetector(
                    onTap: _createTripCubit.changeCurrency,
                    child: Text(
                        _createTripCubit.state.currency?.symbol ??
                            CurrencyTextInputFormatter.simpleCurrency(
                                    locale: Platform.localeName)
                                .format
                                .currencySymbol,
                        style: textTheme.displaySmall)),
                const Gap(16.0),
                Expanded(
                  child: HSTextField(
                    onChanged: (String? val) => _createTripCubit
                        .updateBudget(double.parse(val ?? "0.0")),
                    autofocus: false,
                    hintText: _createTripCubit.state.tripBudget.toString(),
                    suffixIcon: const Icon(FontAwesomeIcons.dollarSign,
                        color: Colors.transparent),
                    onTapPrefix: _createTripCubit.changeCurrency,
                    keyboardType: TextInputType.number,
                  ),
                )
              ],
            );
          },
        ),
        const Gap(16.0),
        const HSFormCaption(text: "Press the currency symbol to change it."),
        const Gap(32.0),
        const HSFormHeadline(text: "Date"),
        const HSFormCaption(text: "When is the trip taking place?"),
        const Gap(8.0),
        BlocSelector<HSCreateTripCubit, HSCreateTripState, String?>(
          selector: (state) => state.tripDate.isEmpty ? null : state.tripDate,
          builder: (context, tripDate) {
            return HSTextField(
              hintText: tripDate?.dateTimeToReadableString() ?? "Trip date...",
              readOnly: true,
              onTap: _createTripCubit.changeTripDate,
              suffixIcon: const Icon(FontAwesomeIcons.dollarSign,
                  color: Colors.transparent),
            );
          },
        ),
        const Gap(32.0),
        HSFormButtonsRow(
          right: HSFormButton(
            onPressed: _createTripCubit.next,
            icon: const Icon(FontAwesomeIcons.arrowRight),
            child: const Text("Company"),
          ),
          left: HSFormButton(
            onPressed: _createTripCubit.back,
            child: const Text("Back"),
          ),
        ),
      ],
    );
  }
}

class _ThirdPage extends StatelessWidget {
  const _ThirdPage(this._createTripCubit);

  final HSCreateTripCubit _createTripCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const HSFormHeadline(
          text: "3/4: Company",
          headlineType: HSFormHeadlineType.display,
        ),
        const HSFormCaption(text: "Add editors and participants of your trip."),
        const Gap(32.0),
        const HSFormHeadline(text: "Editors"),
        const HSFormCaption(
            text: "Press the button below to add up to 5 editors."),
        const Gap(16.0),
        const HSFormButton(
          child: Icon(FontAwesomeIcons.plus),
        ),
        const Gap(32.0),
        const HSFormHeadline(text: "Participants"),
        const HSFormCaption(
            text: "Press the button below to add up to 30 participants."),
        const Gap(16.0),
        const HSFormButton(
          child: Icon(FontAwesomeIcons.plus),
        ),
        const Gap(32.0),
        HSFormButtonsRow(
          right: HSFormButton(
            onPressed: _createTripCubit.next,
            icon: const Icon(FontAwesomeIcons.arrowRight),
            child: const Text("Visibility"),
          ),
          left: HSFormButton(
              onPressed: _createTripCubit.back, child: const Text("Back")),
        )
      ],
    );
  }
}

class _FourthPage extends StatelessWidget {
  const _FourthPage(this._createTripCubit);

  final HSCreateTripCubit _createTripCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const HSFormHeadline(
          text: "4/4: Visibility",
          headlineType: HSFormHeadlineType.display,
        ),
        const HSFormCaption(text: "Who should be able to see your trip."),
        const Gap(16.0),
        SizedBox(
          width: screenWidth,
          child: GestureDetector(
            onTap: () => HSDebugLogger.logInfo("Change visibility"),
            child: BlocSelector<HSCreateTripCubit, HSCreateTripState,
                HSTripVisibility>(
              selector: (state) => state.tripVisibility,
              builder: (context, tripVisibility) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: HSTripVisibility.values
                      .map<Widget>((HSTripVisibility visibility) {
                    return RadioListTile<HSTripVisibility>(
                      contentPadding: const EdgeInsets.all(0.0),
                      title: Text(visibility.name.capitalize,
                          style: textTheme.titleMedium),
                      subtitle: Text(visibility.description.capitalize),
                      value: visibility,
                      groupValue: tripVisibility,
                      onChanged: _createTripCubit.updateVisibility,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
        const Gap(32.0),
        HSFormButtonsRow(
          left: HSFormButton(
            onPressed: _createTripCubit.back,
            child: const Text("Back"),
          ),
          right: BlocSelector<HSCreateTripCubit, HSCreateTripState,
              HSCreateTripStatus>(
            selector: (state) => state.createTripStatus,
            builder: (context, uploadState) {
              switch (uploadState) {
                case HSCreateTripStatus.idle:
                  return HSFormButton(
                      icon: const Icon(FontAwesomeIcons.check),
                      onPressed: _createTripCubit.submit,
                      child: const Text("Submit"));

                case HSCreateTripStatus.uploading:
                  return const HSFormButton(
                      onPressed: null,
                      child: HSLoadingIndicator(
                        size: 24.0,
                      ));
                case HSCreateTripStatus.error:
                  return const HSFormButton(
                      onPressed: null, child: Text("Error"));
              }
            },
          ),
        )
      ],
    );
  }
}
