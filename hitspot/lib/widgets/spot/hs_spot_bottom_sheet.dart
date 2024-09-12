import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/view/create_spot_provider.dart';
import 'package:hitspot/widgets/auth/hs_text_prompt.dart';
import 'package:hitspot/widgets/hs_modal_bottom_sheet_item.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HSSpotBottomSheet extends StatelessWidget {
  const HSSpotBottomSheet(
      {super.key,
      required this.isAuthor,
      required this.spot,
      required this.addToBoard,
      required this.shareSpot,
      required this.deleteSpot});

  final bool isAuthor;
  final HSSpot spot;
  final VoidCallback addToBoard, shareSpot, deleteSpot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(8.0),
          if (isAuthor)
            HSModalBottomSheetItem(
              title: "Edit",
              iconData: FontAwesomeIcons.penToSquare,
              onTap: () =>
                  navi.pushPage(page: CreateSpotProvider(prototype: spot)),
            ),
          HSModalBottomSheetItem(
            title: "Add to Board",
            iconData: FontAwesomeIcons.plus,
            onTap: addToBoard,
          ),
          HSModalBottomSheetItem(
            iconData: FontAwesomeIcons.arrowUpRightFromSquare,
            title: "Share",
            onTap: shareSpot,
          ),
          if (isAuthor)
            HSModalBottomSheetItem(
              iconData: FontAwesomeIcons.trashCan,
              title: "Delete",
              onTap: deleteSpot,
            ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
}

class HSSpotAddToBoardSheet extends StatelessWidget {
  const HSSpotAddToBoardSheet(
      {super.key,
      required this.spot,
      required this.boards,
      required this.addToBoard});

  final HSSpot spot;
  final List<HSBoard> boards;
  final Function(HSBoard) addToBoard;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Column(
          children: [
            const Gap(16.0),
            Text(
              "Choose a board",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Gap(16.0),
            if (boards.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HSTextPrompt(
                  prompt: "You don't have any boards yet.",
                  pressableText: "\nCreate",
                  promptColor: appTheme.mainColor,
                  onTap: navi.toCreateBoard,
                ),
              ),
            ...boards.map(
              (e) => HSModalBottomSheetItem(
                title: e.title!,
                onTap: () => addToBoard(e),
              ),
            ),
            const Gap(32.0),
          ],
        ),
      ),
    );
  }
}
