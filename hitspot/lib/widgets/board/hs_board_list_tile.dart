import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSBoardListTile extends StatelessWidget {
  const HSBoardListTile({super.key, required this.board, this.onTap});

  final HSBoard board;
  final void Function(HSBoard)? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _onTap,
      leading: AspectRatio(
          aspectRatio: 1.0,
          child: HSImage(
            imageUrl: board.getThumbnail,
            borderRadius: BorderRadius.circular(10.0),
          )),
      title: Text(board.title!),
      subtitle: Text(board.description!),
    );
  }

  void _onTap() {
    if (onTap != null) {
      onTap!(board);
    } else {
      navi.toBoard(boardID: board.id!, title: board.title!);
    }
  }
}
