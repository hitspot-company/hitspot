import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/boards/single/cubit/hs_single_board_cubit.dart';
import 'package:hitspot/features/boards/single/view/single_board_page.dart';

class SingleBoardProvider extends StatelessWidget {
  const SingleBoardProvider(
      {super.key, required this.boardID, required this.title});

  final String boardID;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSSingleBoardCubit(
        boardID: boardID,
        title: title,
      ),
      child: const SingleBoardPage(),
    );
  }
}
