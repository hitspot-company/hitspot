import 'package:auto_size_text/auto_size_text.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/add_board/cubit/hs_add_board_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_textfield.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class AddBoardPage extends StatelessWidget {
  const AddBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final addBoardCubit = context.read<HSAddBoardCubit>();
    return HSScaffold(
      resizeToAvoidBottomInset: true,
      appBar: HSAppBar(
        enableDefaultBackButton: true,
        title: "New Board",
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
  final HSAddBoardCubit _addBoardCubit;

  final FocusNode descriptionNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          "Step 1/3: basic information",
          style: textTheme.headlineMedium!.boldify,
        ),
        Text(
          "Tell us more about your board.",
          style: textTheme.titleMedium,
        ),
        const SizedBox(
          height: 32.0,
        ),
        Text(
          "What will you call your board?",
          style: textTheme.titleMedium!.boldify,
        ),
        const Gap(8.0),
        HSTextField(
          onChanged: _addBoardCubit.updateTitle,
          suffixIcon: const Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Title",
          textInputAction: TextInputAction.next,
        ),
        const Gap(32.0),
        Text(
          "Give us some details about the board.",
          style: textTheme.titleMedium!.boldify,
        ),
        const Gap(8.0),
        HSTextField(
          textInputAction: TextInputAction.done,
          maxLines: 5,
          onChanged: _addBoardCubit.updateDescription,
          suffixIcon: const Icon(FontAwesomeIcons.a, color: Colors.transparent),
          hintText: "Description",
        ),
        const Gap(32.0),
        _ButtonsRow(
            right: _Button(
          icon: const Icon(FontAwesomeIcons.arrowRight),
          onPressed: _addBoardCubit.nextPage,
          child: const Text("Customize"),
        ))
      ],
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage(this._addBoardCubit);
  final HSAddBoardCubit _addBoardCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          "Step 2/3: customization",
          style: textTheme.headlineMedium!.boldify,
        ),
        Text(
          "Define the character of your board.",
          style: textTheme.titleMedium,
        ),
        const Gap(8.0),
        AutoSizeText(
          "This section is completely optional. You can skip it.",
          maxLines: 1,
          style: const TextStyle(color: Colors.grey).hintify,
        ),
        const Gap(32.0),
        Text("Color", style: textTheme.titleLarge!.boldify),
        const Text("Tap on the rectangle to change color."),
        const Gap(8.0),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _addBoardCubit.colorPickerDialog,
            child: BlocSelector<HSAddBoardCubit, HSAddBoardState, Color?>(
              selector: (state) => state.color,
              builder: (context, state) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 60,
                    width: 60,
                    color: _addBoardCubit.state.color ??
                        currentTheme.mainColor.withOpacity(.6),
                  ),
                );
              },
            ),
          ),
        ),
        const Gap(32.0),
        Text("Image", style: textTheme.titleLarge!.boldify),
        const Text("Tap on the rectangle to change your board image."),
        const Gap(8.0),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _addBoardCubit.chooseImage,
            child: BlocSelector<HSAddBoardCubit, HSAddBoardState, String?>(
              selector: (state) => state.image,
              builder: (context, imagePath) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 120,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      image: imagePath != null
                          ? DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.cover,
                              opacity: .6)
                          : null,
                      color: imagePath == null
                          ? currentTheme.mainColor.withOpacity(.6)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Gap(32.0),
        _ButtonsRow(
          left: _Button(
            onPressed: _addBoardCubit.prevPage,
            child: const Text("Back"),
          ),
          right: _Button(
            onPressed: _addBoardCubit.nextPage,
            icon: const Icon(FontAwesomeIcons.arrowRight),
            child: const Text("Participants"),
          ),
        ),
      ],
    );
  }
}

class _ThirdPage extends StatelessWidget {
  const _ThirdPage(this._addBoardCubit);
  final HSAddBoardCubit _addBoardCubit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          "Step 3/3: visibility",
          style: textTheme.headlineMedium!.boldify,
        ),
        Text(
          "Who should be able to see your board.",
          style: textTheme.titleMedium,
        ),
        const Gap(32.0),
        Text("Type of Visibility", style: textTheme.titleLarge!.boldify),
        const Text("Decide who should be able to see your board."),
        const Gap(8.0),
        SizedBox(
          width: screenWidth,
          child: GestureDetector(
            onTap: () => HSDebugLogger.logInfo("Change visibility"),
            child: BlocSelector<HSAddBoardCubit, HSAddBoardState,
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
        _ButtonsRow(
          left: _Button(
            onPressed: _addBoardCubit.prevPage,
            child: const Text("Back"),
          ),
          right: BlocSelector<HSAddBoardCubit, HSAddBoardState,
              HSAddBoardUploadState>(
            selector: (state) => state.uploadState,
            builder: (context, uploadState) {
              switch (uploadState) {
                case HSAddBoardUploadState.initial:
                  return HSButton.icon(
                    label: const Text("Submit"),
                    onPressed: _addBoardCubit.createBoard,
                    icon: const Icon(FontAwesomeIcons.check),
                  );

                case HSAddBoardUploadState.uploading:
                  return const HSButton(
                    onPressed: null,
                    child: HSLoadingIndicator(
                      size: 24.0,
                    ),
                  );
                case HSAddBoardUploadState.error:
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

class _ButtonsRow extends StatelessWidget {
  const _ButtonsRow({this.left, required this.right});

  final _Button? left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (left != null) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: left!),
          const Gap(16.0),
          Expanded(child: right),
        ],
      );
    }
    return Align(
      alignment: Alignment.centerRight,
      child: right,
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({this.icon, required this.child, this.onPressed});

  final Icon? icon;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return HSButton.icon(
        label: child,
        onPressed: onPressed!,
        icon: icon!,
      );
    }
    return HSButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
