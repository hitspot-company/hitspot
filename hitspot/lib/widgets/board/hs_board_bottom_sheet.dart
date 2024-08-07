import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/boards/create/view/create_board_provider.dart';
import 'package:hitspot/widgets/hs_modal_bottom_sheet_item.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSBoardBottomSheet extends StatelessWidget {
  const HSBoardBottomSheet(
      {super.key,
      required this.isEditor,
      required this.board,
      required this.inviteCollaborator,
      required this.share,
      required this.removeBoard});

  final bool isEditor;
  final HSBoard board;
  final VoidCallback inviteCollaborator, share, removeBoard;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(8.0),
          if (isEditor)
            HSModalBottomSheetItem(
              title: "Edit",
              iconData: FontAwesomeIcons.penToSquare,
              onTap: () =>
                  navi.pushPage(page: CreateBoardProvider(prototype: board)),
            ),
          HSModalBottomSheetItem(
            iconData: FontAwesomeIcons.userPlus,
            title: "Add editor",
            onTap: inviteCollaborator,
          ),
          HSModalBottomSheetItem(
            title: "Share",
            iconData: FontAwesomeIcons.arrowUpRightFromSquare,
            onTap: share,
          ),
          if (isEditor)
            HSModalBottomSheetItem(
              iconData: FontAwesomeIcons.trashCan,
              title: "Delete",
              onTap: removeBoard,
            ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
}
