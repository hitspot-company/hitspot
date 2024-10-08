import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/form/cubit/hs_create_spot_form_cubit.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class CreateSpotFormPage extends StatelessWidget {
  const CreateSpotFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final createSpotCubit = context.read<HsCreateSpotFormCubit>();
    return HSScaffold(
        appBar: HSAppBar(
          titleText: 'Create Spot',
          enableDefaultBackButton: true,
          defaultBackButtonCallback: () {
            if (createSpotCubit.pageController.page == 0) {
              navi.pop(true);
            } else {
              createSpotCubit.pageController.previousPage(
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 300));
            }
          },
        ),
        body: BlocSelector<HsCreateSpotFormCubit, HSCreateSpotFormState,
            HSCreateSpotFormStatus>(
          selector: (state) => state.status,
          builder: (context, status) {
            final isVisible = status != HSCreateSpotFormStatus.submitting;
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
    final createSpotCubit = context.read<HsCreateSpotFormCubit>();
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
          right:
              BlocSelector<HsCreateSpotFormCubit, HSCreateSpotFormState, bool>(
            selector: (state) => state.title.isNotEmpty,
            builder: (context, isValid) {
              return HSFormButton(
                icon: nextIcon,
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
    final HsCreateSpotFormCubit createSpotCubit =
        context.read<HsCreateSpotFormCubit>();
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
          right:
              BlocSelector<HsCreateSpotFormCubit, HSCreateSpotFormState, bool>(
            selector: (state) => state.description.isNotEmpty,
            builder: (context, isValid) {
              return HSFormButton(
                icon: nextIcon,
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
    final createSpotCubit = context.read<HsCreateSpotFormCubit>();
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
          right: BlocSelector<HsCreateSpotFormCubit, HSCreateSpotFormState,
              HSCreateSpotFormStatus>(
            selector: (state) => state.status,
            builder: (context, status) {
              final isSubmitting = status == HSCreateSpotFormStatus.submitting;
              final isError = status == HSCreateSpotFormStatus.error;
              if (isSubmitting) return HSFormButton.loading();
              if (isError) return HSFormButton.error();
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
  const _SelectedTagsBuilder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: BlocSelector<HsCreateSpotFormCubit, HSCreateSpotFormState,
          List<String>>(
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
                    context.read<HsCreateSpotFormCubit>().selectTag(tag);
                  } else {
                    context.read<HsCreateSpotFormCubit>().deselectTag(tag);
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
      child: BlocBuilder<HsCreateSpotFormCubit, HSCreateSpotFormState>(
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
          final bool isUniqueTag = !queriedTags.contains(state.tagsQuery);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: queriedTags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return ChoiceChip(
                    backgroundColor: appTheme.textfieldFillColor,
                    side: BorderSide.none,
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<HsCreateSpotFormCubit>().selectTag(tag);
                      } else {
                        context.read<HsCreateSpotFormCubit>().deselectTag(tag);
                      }
                    },
                    label: Text('#$tag'),
                  );
                }).toList(),
              ),
              if (isUniqueTag && state.tagsQuery.isNotEmpty)
                Center(
                  child: HSButton(
                    onPressed: () {
                      context
                          .read<HsCreateSpotFormCubit>()
                          .selectTag(state.tagsQuery);
                    },
                    child: const Text("Add new tag"),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
