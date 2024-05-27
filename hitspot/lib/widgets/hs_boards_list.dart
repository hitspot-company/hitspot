import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class HSBoardsList extends StatelessWidget {
  const HSBoardsList({super.key, required this.boards, required this.user});

  final List<HSBoard>? boards;
  final HSUser user;

  @override
  Widget build(BuildContext context) {
    if (boards == null || boards!.isEmpty) {
      return Center(
        child: Text("@${user.username} has no boards.",
            style: textTheme.headlineMedium),
      );
    }
    return ListView.separated(
      itemCount: boards!.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Gap(16.0);
      },
      itemBuilder: (BuildContext context, int index) {
        final board = boards![index];
        final Color? boardColor =
            board.image != null ? board.color : board.color?.withOpacity(.7);
        final String? boardImage = board.image;
        return GestureDetector(
          onTap: () => navi.router.push("/board/${board.bid}"),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              width: screenWidth,
              height: 80.0,
              decoration: BoxDecoration(
                color: boardColor,
                image: boardImage != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(boardImage),
                        fit: BoxFit.cover,
                        opacity: .4)
                    : null,
              ),
              child: Center(
                child: Text(board.title!, style: textTheme.headlineSmall),
              ),
            ),
          ),
        );
      },
    );
  }
}
