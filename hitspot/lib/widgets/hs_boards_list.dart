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
        final Color? boardColor = board.color;
        return Container(
          width: screenWidth,
          height: 80.0,
          color: boardColor,
          child: Center(
            child: Text(board.title!, style: textTheme.headlineSmall),
          ),
        );
      },
    );
  }
}
