import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/boards/single/map/cubit/hs_single_board_map_cubit.dart';
import 'package:hitspot/features/boards/single/map/view/single_board_map_page.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class SingleBoardMapProvider extends StatelessWidget {
  const SingleBoardMapProvider(
      {super.key, required this.boardID, required this.board});

  final String boardID;
  final HSBoard board;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSSingleBoardMapCubit(
        board: board,
        boardID: boardID,
      ),
      child: const SingleBoardMapPage(),
    );
  }
}
