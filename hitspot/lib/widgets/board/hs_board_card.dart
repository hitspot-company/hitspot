import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

enum HSBoardCardLayout { grid, list }

class HSBoardCard extends StatelessWidget {
  final HSBoard board;
  final double? height, width;
  final HSBoardCardLayout layout;

  const HSBoardCard(
      {super.key,
      required this.board,
      this.height,
      this.width,
      this.layout = HSBoardCardLayout.grid});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const SizedBox(
        width: 80,
        height: 80,
        child: Icon(
          FontAwesomeIcons.layerGroup,
          size: 32.0,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              board.title!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (layout == HSBoardCardLayout.list) const SizedBox(height: 4),
            if (layout == HSBoardCardLayout.list)
              Text(
                board.description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    ];
    final child = layout == HSBoardCardLayout.list
        ? Row(children: children)
        : Column(children: children);
    return GestureDetector(
      onTap: () => navi.toBoard(boardID: board.id!, title: board.title!),
      child: SizedBox(
        height: height,
        width: width,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}
