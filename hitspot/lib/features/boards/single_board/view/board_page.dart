import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/single_board/bloc/hs_board_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_spots_grid.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final boardBloc = context.read<HSBoardBloc>();
    return BlocBuilder<HSBoardBloc, HSBoardState>(
      builder: (context, state) {
        if (state is HSBoardErrorState) {
          return HSScaffold(
            appBar: HSAppBar(
              enableDefaultBackButton: true,
            ),
            body: Center(
              child: Text(
                state.error,
                style: textTheme.displayMedium!.colorify(Colors.red),
              ),
            ),
          );
        } else if (state is HSBoardReadyState) {
          final HSBoard board = state.board;
          final HSUser author = state.author;
          final HSBoardSaveState boardSaveState = state.boardSaveState;
          return HSScaffold(
            appBar: HSAppBar(
              enableDefaultBackButton: true,
              titleText: board.title,
              right: board.isOwner(currentUser)
                  ? IconButton(
                      onPressed: boardBloc.showModalSheet,
                      icon: const Icon(FontAwesomeIcons.bars))
                  : null,
            ),
            floatingActionButton: HSButton.icon(
                label: Text(
                  "CREATE TRIP",
                  style: textTheme.headlineMedium!
                      .colorify(currentTheme.mainColor),
                ),
                icon: const Icon(FontAwesomeIcons.mapPin),
                onPressed: () => HSDebugLogger.logInfo(
                    "Create Trip")), // TODO: Navigate a create trip page from the bottom
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  navi.router.push("/user/${author.uid}"),
                              child: HSUserAvatar(
                                radius: 40.0,
                                imgUrl: author.profilePicture,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("@${author.username}",
                                    style: textTheme.headlineMedium),
                                Text(author.fullName!),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(
                    thickness: .3,
                  ),
                ),
                const Gap(8.0).sliver,
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Visibility", style: textTheme.headlineSmall),
                      Text(
                        board.boardVisibility!.name.capitalize,
                      ),
                      const Gap(16.0),
                      Text(
                        "About",
                        style: textTheme.headlineSmall,
                      ),
                      Text(
                        board.description!,
                      ),
                      const Gap(16.0),
                      Text(
                        "Saves",
                        style: textTheme.headlineSmall,
                      ),
                      Text(
                        "${board.saves?.length ?? 0}",
                      ),
                      const Gap(16.0),
                      SizedBox(
                        width: screenWidth,
                        height: 50.0,
                        child: _SaveActionButton(
                          isEditor: board.isEditor(currentUser),
                          state: state,
                          boardBloc: boardBloc,
                          boardSaveState: boardSaveState,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16.0).sliver,
                const SliverToBoxAdapter(
                  child: Divider(
                    thickness: .3,
                  ),
                ),
                const Gap(8.0).sliver,
                HSSpotsGrid.loading(
                    isSliver:
                        true), // TODO: Change when wojtek is done with adding spots
              ],
            ),
          );
        }
        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
          ),
          body: const HSLoadingIndicator(),
        );
      },
    );
  }
}

extension SliverGap on Gap {
  SliverToBoxAdapter get sliver {
    return SliverToBoxAdapter(
      child: this,
    );
  }
}

extension SliverExt on StatelessWidget {
  SliverToBoxAdapter get sliver {
    return SliverToBoxAdapter(
      child: this,
    );
  }
}

class _SaveActionButton extends StatelessWidget {
  const _SaveActionButton(
      {required this.isEditor,
      required this.state,
      required this.boardBloc,
      required this.boardSaveState});

  final bool isEditor;
  final HSBoardReadyState state;
  final HSBoardBloc boardBloc;
  final HSBoardSaveState boardSaveState;

  @override
  Widget build(BuildContext context) {
    if (isEditor) {
      return HSButton.icon(
          label: const Text("EDIT"),
          onPressed: () => HSDebugLogger.logInfo("Edit"),
          icon: const Icon(FontAwesomeIcons.pen));
    }
    switch (boardSaveState) {
      case HSBoardSaveState.saved:
        return HSButton.icon(
            label: const Text("UNSAVE BOARD"),
            icon: const Icon(FontAwesomeIcons.solidBookmark),
            onPressed: boardBloc.saveUnsaveBoard);
      case HSBoardSaveState.unsaved:
        return HSButton.icon(
            label: const Text("SAVE BOARD"),
            icon: const Icon(FontAwesomeIcons.bookmark),
            onPressed: boardBloc.saveUnsaveBoard);
      case HSBoardSaveState.updating:
        return const HSButton(
            onPressed: null, child: HSLoadingIndicator(size: 24));
    }
  }
}

class HSBoardModalBottonSheet extends StatelessWidget {
  const HSBoardModalBottonSheet({super.key, this.items});

  final List<Widget>? items;

  @override
  Widget build(BuildContext context) {
    final children = items ?? defaultItems;
    return SafeArea(
      top: false,
      bottom: true,
      child: ListView.separated(
        itemCount: children.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 8.0),
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(thickness: .3),
        itemBuilder: (BuildContext context, int index) => children[index],
      ),
    );
  }

  static final List<ModalBottomSheetItem> defaultItems = [
    const ModalBottomSheetItem(text: "Item 1"),
    const ModalBottomSheetItem(text: "Item 2"),
    const ModalBottomSheetItem(text: "Item 3"),
  ];
}

class ModalBottomSheetItem extends StatelessWidget {
  const ModalBottomSheetItem(
      {super.key, this.child, this.text, this.onPressed, this.icon});

  final Widget? child;
  final String? text;
  final VoidCallback? onPressed;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    late final Widget label;
    assert(!(child != null && text != null),
        "Text and child cannot be provided at the same time");
    if (child == null) {
      assert((text != null), "Either a child or a text should be provided.");
      if (icon != null) {
        label = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: icon,
              ),
              Center(
                child: Text(text!, style: textTheme.headlineSmall),
              )
            ],
          ),
        );
      } else {
        label = Text(text!, style: textTheme.headlineSmall);
      }
    } else {
      assert(!(child != null && icon != null),
          "Icon and child cannot be provided at the same time.");
      assert((child != null), "Either a child or a text should be provided.");
      label = child!;
    }
    return InkWell(
      onTap: onPressed ?? () => HSDebugLogger.logInfo("No callback specified"),
      child: SizedBox(
        height: 60,
        width: screenWidth,
        child: Center(child: label),
      ),
    );
  }
}
