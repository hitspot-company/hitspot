import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/features/spots/create/cubit/hs_create_spot_cubit.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class CreateSpotPage extends StatelessWidget {
  const CreateSpotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final createSpotCubit = context.read<HSCreateSpotCubit>();
    return HSScaffold(
      appBar: HSAppBar(
        titleText: 'Create Spot',
        enableDefaultBackButton: true,
      ),
      body: PageView(
        controller: createSpotCubit.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [const _FirstPage(), const _SecondPage(), const _ThirdPage()],
      ),
    );
  }
}

class _FirstPage extends StatelessWidget {
  const _FirstPage();

  @override
  Widget build(BuildContext context) {
    final HSCreateSpotCubit createSpotCubit = context.read<HSCreateSpotCubit>();
    return HSFormPageBody(
      heading: "Title",
      caption: "Give your spot the name it deserves",
      children: [
        HSTextField.filled(
          maxLength: 64,
          onChanged: createSpotCubit.updateTitle,
          hintText: createSpotCubit.titleHint,
        ),
        const Gap(8.0),
        HSFormButtonsRow(
          right: BlocSelector<HSCreateSpotCubit, HSCreateSpotState, bool>(
            selector: (state) => state.title.isNotEmpty,
            builder: (context, isValid) {
              return HSFormButton(
                icon: const Icon(FontAwesomeIcons.arrowRight),
                onPressed: isValid ? createSpotCubit.nextPage : null,
                child: const Text("Description"),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage();

  @override
  Widget build(BuildContext context) {
    final HSCreateSpotCubit createSpotCubit = context.read<HSCreateSpotCubit>();
    return HSFormPageBody(
      heading: "Description",
      caption:
          "Give the description of the spot, what is it, where is it etc...",
      children: [
        HSTextField.filled(
          onChanged: createSpotCubit.updateDescription,
          hintText: createSpotCubit.descriptionHint,
          maxLength: 512,
          maxLines: 8,
        ),
        const Gap(8.0),
        HSFormButtonsRow(
          left: HSFormButton(
            onPressed: createSpotCubit.prevPage,
            child: const Text("Back"),
          ),
          right: BlocSelector<HSCreateSpotCubit, HSCreateSpotState, bool>(
            selector: (state) => state.description.isNotEmpty,
            builder: (context, isValid) {
              return HSFormButton(
                icon: const Icon(FontAwesomeIcons.arrowRight),
                onPressed: isValid ? createSpotCubit.nextPage : null,
                child: const Text("Categories"),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ThirdPage extends StatelessWidget {
  const _ThirdPage();

  @override
  Widget build(BuildContext context) {
    final createSpotCubit = context.read<HSCreateSpotCubit>();
    return HSFormPageBody(
      heading: "Categories",
      caption: "Select categories that best describe your spot.",
      children: [
        HSTextField.filled(
          onChanged: createSpotCubit.updateTagsQuery,
          hintText: "Search for category...",
          suffixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
        ),
        const Gap(16.0),
        BlocBuilder<HSCreateSpotCubit, HSCreateSpotState>(
          buildWhen: (previous, current) =>
              previous.queriedTags != current.queriedTags ||
              previous.isLoading != current.isLoading,
          builder: (context, state) {
            final List<String> tags = state.queriedTags;
            HSDebugLogger.logInfo("Rebuilding");
            if (state.isLoading) {
              return const HSLoadingIndicator();
            }
            if (tags.isEmpty) {
              return Column(
                children: [
                  const AutoSizeText(
                    "This tag does not exist yet. Would you like to add it?",
                    maxLines: 1,
                  ),
                  const Gap(8.0),
                  HSButton(
                      onPressed: () => HSDebugLogger.logInfo("Create new tag"),
                      child: const Text("Add new tag"))
                ],
              );
            }
            // TODO: Change to the chips choice package and add selecting
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              shrinkWrap: true,
              itemCount: tags.length,
              itemBuilder: (BuildContext context, int index) {
                return Chip(label: Text(tags[index]));
              },
            );
          },
        ),
        HSFormButtonsRow(
          right: const HSFormButton(child: Text("Submit")),
          left: HSFormButton(
              onPressed: createSpotCubit.prevPage, child: const Text("Back")),
        )
      ],
    );
  }
}
