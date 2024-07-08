import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
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
        body: BlocSelector<HSCreateSpotCubit, HSCreateSpotState, bool>(
          selector: (state) =>
              state.status == HSCreateSpotStatus.fillingData ||
              state.status == HSCreateSpotStatus.submitting,
          builder: (context, isVisible) {
            if (!isVisible) return const HSLoadingIndicator();
            return PageView(
              controller: createSpotCubit.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [_FirstPage(), _SecondPage(), _ThirdPage()],
            );
          },
        ));
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
          autofocus: true,
          maxLength: 64,
          onChanged: createSpotCubit.updateTitle,
          hintText: createSpotCubit.titleHint,
          initialValue: createSpotCubit.titleInitialValue,
        ),
        const Gap(8.0),
        HSFormButtonsRow(
          right: BlocSelector<HSCreateSpotCubit, HSCreateSpotState, bool>(
            selector: (state) => state.title.isNotEmpty,
            builder: (context, isValid) {
              return HSFormButton(
                icon: backIcon,
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
          autofocus: true,
          autocorrect: false,
          onChanged: createSpotCubit.updateDescription,
          hintText: createSpotCubit.descriptionHint,
          initialValue: createSpotCubit.descriptionInitialValue,
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
                icon: backIcon,
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
          controller: createSpotCubit.categoriesController,
          onChanged: createSpotCubit.updateTagsQuery,
          hintText: "Search for category...",
          suffixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
        ),
        const Gap(16.0),
        const _TagsBuilder(),
        const Gap(16.0),
        const _SelectedTagsBuilder(),
        const Gap(16.0),
        const Gap(16.0),
        HSFormButtonsRow(
          right: BlocSelector<HSCreateSpotCubit, HSCreateSpotState, bool>(
            selector: (state) => state.status == HSCreateSpotStatus.submitting,
            builder: (context, isSubmitting) {
              if (isSubmitting) return HSFormButton.loading();
              return HSFormButton(
                onPressed: createSpotCubit.submitSpot,
                child: const Text("Submit"),
              );
            },
          ),
          left: HSFormButton(
              onPressed: createSpotCubit.prevPage, child: const Text("Back")),
        )
      ],
    );
  }
}

class _SelectedTagsBuilder extends StatelessWidget {
  const _SelectedTagsBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: BlocSelector<HSCreateSpotCubit, HSCreateSpotState, List<String>>(
        selector: (state) => state.selectedTags,
        builder: (context, selectedTags) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: selectedTags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              return ChoiceChip(
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context.read<HSCreateSpotCubit>().selectTag(tag);
                  } else {
                    context.read<HSCreateSpotCubit>().deselectTag(tag);
                  }
                },
                label: Text('#$tag'), // Prefix the tag with a hashtag
                showCheckmark: false,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _TagsBuilder extends StatelessWidget {
  const _TagsBuilder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: BlocBuilder<HSCreateSpotCubit, HSCreateSpotState>(
        buildWhen: (previous, current) =>
            previous.queriedTags != current.queriedTags ||
            previous.isLoading != current.isLoading ||
            previous.selectedTags != current.selectedTags ||
            previous.tagsQuery != current.tagsQuery,
        builder: (context, state) {
          final List<String> queriedTags = state.queriedTags;
          final List<String> selectedTags = state.selectedTags;
          HSDebugLogger.logInfo("Selected tags: $selectedTags");
          if (state.isLoading) {
            return const HSLoadingIndicator();
          }
          if (queriedTags.isEmpty && state.tagsQuery.isNotEmpty) {
            return Column(
              children: [
                const AutoSizeText(
                  "This tag does not exist yet. Would you like to add it?",
                  maxLines: 1,
                ),
                const SizedBox(height: 8.0),
                HSButton(
                  onPressed: () {
                    context
                        .read<HSCreateSpotCubit>()
                        .selectTag(state.tagsQuery);
                  },
                  child: const Text("Add new tag"),
                ),
              ],
            );
          }

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: queriedTags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              return ChoiceChip(
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context.read<HSCreateSpotCubit>().selectTag(tag);
                  } else {
                    context.read<HSCreateSpotCubit>().deselectTag(tag);
                  }
                },
                label: Text('#$tag'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
