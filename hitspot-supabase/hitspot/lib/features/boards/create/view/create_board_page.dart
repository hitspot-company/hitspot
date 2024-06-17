import 'package:auto_size_text/auto_size_text.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/create/cubit/hs_create_board_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/form/hs_form.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class CreateBoardPage extends StatelessWidget {
  const CreateBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final addBoardCubit = context.read<HSCreateBoardCubit>();
    return HSScaffold(
      resizeToAvoidBottomInset: true,
      appBar: HSAppBar(
        enableDefaultBackButton: true,
        titleText: addBoardCubit.pageTitle,
        titleBold: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: addBoardCubit.pageController,
          children: [
            _FirstPage(addBoardCubit),
            _SecondPage(addBoardCubit),
            _ThirdPage(addBoardCubit),
          ],
        ),
      ),
    );
  }
}

class _FirstPage extends StatelessWidget {
  _FirstPage(this._addBoardCubit);
  final HSCreateBoardCubit _addBoardCubit;

  final FocusNode descriptionNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const HSFormHeadline(
          text: "Step 1/3: basic information",
          headlineType: HSFormHeadlineType.display,
        ),
        const HSFormCaption(
          text: "Tell us more about your board.",
        ),
        const SizedBox(
          height: 32.0,
        ),
        const HSFormHeadline(
          text: "What will you call your board?",
        ),
        const Gap(8.0),
        HSTextField.filled(
          onChanged: _addBoardCubit.updateTitle,
          suffixIcon: const Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Title",
          initialValue: _addBoardCubit.state.title,
          textInputAction: TextInputAction.next,
          fillColor: appTheme.textfieldFillColor,
        ),
        const Gap(32.0),
        const HSFormCaption(
          text: "Give us some details about the board.",
        ),
        const Gap(8.0),
        HSTextField.filled(
          textInputAction: TextInputAction.done,
          maxLines: 5,
          onChanged: _addBoardCubit.updateDescription,
          initialValue: _addBoardCubit.state.description,
          suffixIcon: const Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Description",
        ),
        const Gap(8.0),
        BlocSelector<HSCreateBoardCubit, HSCreateBoardState, String?>(
          selector: (state) => state.errorText,
          builder: (context, errorText) {
            if (errorText != null) {
              return Text(errorText, style: const TextStyle(color: Colors.red));
            }
            return const SizedBox();
          },
        ),
        const Gap(32.0),
        HSFormButtonsRow(
            right: BlocBuilder<HSCreateBoardCubit, HSCreateBoardState>(
          buildWhen: (previous, current) =>
              previous.title != current.title ||
              previous.description != current.description,
          builder: (context, state) {
            final bool valid =
                state.title.isNotEmpty && state.description.isNotEmpty;
            return HSFormButton(
              icon: const Icon(FontAwesomeIcons.arrowRight),
              onPressed: valid ? _addBoardCubit.nextPage : null,
              child: const Text("Customize"),
            );
          },
        ))
      ],
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage(this._addBoardCubit);
  final HSCreateBoardCubit _addBoardCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const HSFormHeadline(
            text: "Step 2/3: customization",
            headlineType: HSFormHeadlineType.display),
        const HSFormCaption(text: "Define the character of your board."),
        const Gap(32.0),
        const HSFormHeadline(
          text: "Color",
        ),
        const HSFormCaption(text: "give your board a unique aura."),
        BlocSelector<HSCreateBoardCubit, HSCreateBoardState, bool>(
          selector: (state) => state.color != null,
          builder: (context, isColorSelected) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isColorSelected,
                      onChanged: (value) => _addBoardCubit.pickColor(true),
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.maximumDensity,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text("Select"),
                    const Gap(16.0),
                    Radio<bool>(
                      value: false,
                      groupValue: isColorSelected,
                      onChanged: (value) => _addBoardCubit.pickColor(false),
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text("No"),
                  ],
                ),
                if (isColorSelected)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 60,
                        width: 60,
                        color: _addBoardCubit.state.color ??
                            app.theme.mainColor.withOpacity(.6),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const Gap(32.0),
        const HSFormHeadline(text: "Cover"),
        const HSFormCaption(text: "choose the cover of your board."),
        BlocSelector<HSCreateBoardCubit, HSCreateBoardState, bool>(
          selector: (state) => state.image.isNotEmpty,
          builder: (context, isImageSelected) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isImageSelected,
                      onChanged: (value) => _addBoardCubit.chooseImage(true),
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.maximumDensity,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text("Select"),
                    const Gap(16.0),
                    Radio<bool>(
                      value: false,
                      groupValue: isImageSelected,
                      onChanged: (value) => _addBoardCubit.chooseImage(false),
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text("No"),
                  ],
                ),
                if (isImageSelected)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: HSImage(
                          height: 120.0,
                          width: screenWidth,
                          imageProvider: _imageProvider,
                          fit: BoxFit.cover,
                          opacity: .6),
                    ),
                  ),
              ],
            );
          },
        ),
        const Gap(32.0),
        HSFormButtonsRow(
          left: HSFormButton(
            onPressed: _addBoardCubit.prevPage,
            child: const Text("Back"),
          ),
          right: BlocSelector<HSCreateBoardCubit, HSCreateBoardState, bool>(
            selector: (state) => state.color != null && state.image.isNotEmpty,
            builder: (context, valid) {
              return HSFormButton(
                onPressed: valid ? _addBoardCubit.nextPage : null,
                icon: const Icon(FontAwesomeIcons.arrowRight),
                child: const Text("Visibility"),
              );
            },
          ),
        ),
      ],
    );
  }

  bool get isImageSelected {
    final String image = _addBoardCubit.state.image;
    return (image.isNotEmpty && _addBoardCubit.prototype?.image != image);
  }

  ImageProvider<Object>? get _imageProvider {
    if (_addBoardCubit.state.image.isNotEmpty &&
        _addBoardCubit.prototype?.image != null &&
        _addBoardCubit.state.image == _addBoardCubit.prototype?.image) {
      return NetworkImage(_addBoardCubit.prototype!.image!);
    } else if (_addBoardCubit.state.image.isNotEmpty) {
      return AssetImage(_addBoardCubit.state.image);
    }
    return null;
  }
}

class _ThirdPage extends StatelessWidget {
  const _ThirdPage(this._addBoardCubit);
  final HSCreateBoardCubit _addBoardCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const HSFormHeadline(
            text: "Step 3/3: Visibility",
            headlineType: HSFormHeadlineType.display),
        const HSFormCaption(text: "Who should be able to see your board."),
        const Gap(8.0),
        SizedBox(
          width: screenWidth,
          child: GestureDetector(
            onTap: () => HSDebugLogger.logInfo("Change visibility"),
            child: BlocSelector<HSCreateBoardCubit, HSCreateBoardState,
                HSBoardVisibility>(
              selector: (state) => state.boardVisibility,
              builder: (context, boardVisibility) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: HSBoardVisibility.values
                      .map<Widget>((HSBoardVisibility visibility) {
                    return RadioListTile<HSBoardVisibility>(
                      contentPadding: const EdgeInsets.all(0.0),
                      title: Text(visibility.name.capitalize,
                          style: textTheme.titleMedium),
                      subtitle: Text(visibility.description),
                      value: visibility,
                      groupValue: boardVisibility,
                      onChanged: _addBoardCubit.updateVisibility,
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
            onPressed: _addBoardCubit.prevPage,
            child: const Text("Back"),
          ),
          right: BlocSelector<HSCreateBoardCubit, HSCreateBoardState,
              HSCreateBoardUploadState>(
            selector: (state) => state.uploadState,
            builder: (context, uploadState) {
              switch (uploadState) {
                case HSCreateBoardUploadState.initial ||
                      HSCreateBoardUploadState.error:
                  return HSButton.icon(
                    label: const Text("Submit"),
                    onPressed: _addBoardCubit.submit,
                    icon: const Icon(FontAwesomeIcons.check),
                  );

                case HSCreateBoardUploadState.uploading:
                  return const HSButton(
                    onPressed: null,
                    child: HSLoadingIndicator(
                      size: 24.0,
                    ),
                  );
                case HSCreateBoardUploadState.error:
                  return const HSButton(
                    onPressed: null,
                    child: Text("Error"),
                  );
              }
            },
          ),
        )
      ],
    );
  }
}
