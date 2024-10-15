import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/spots/create/images/view/create_spot_images_provider.dart';
import 'package:hitspot/widgets/board/hs_board_list_tile.dart';
import 'package:hitspot/widgets/hs_button.dart';
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
              onTap: () => navi.pushPage(
                  page: CreateSpotImagesProvider(prototype: spot)),
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
            SizedBox(
              width: screenWidth - 16.0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: navi.pop,
                  icon: const Icon(FontAwesomeIcons.x),
                ),
              ),
            ),
            ...boards.map(
                (board) => HSBoardListTile(board: board, onTap: addToBoard)),
            const Gap(8.0),
            SizedBox(
              width: screenWidth - 32.0,
              child: HSButton.icon(
                  label: const Text("New board"),
                  icon: const Icon(Icons.add),
                  onPressed: navi.toCreateBoard),
            ),
            const Gap(32.0),
          ],
        ),
      ),
    );
  }
}
