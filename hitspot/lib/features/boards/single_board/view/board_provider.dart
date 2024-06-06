import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/boards/single_board/bloc/hs_board_bloc.dart';
import 'package:hitspot/features/boards/single_board/view/board_page.dart';

class BoardProvider extends StatelessWidget {
  const BoardProvider({super.key, required this.boardID});

  final String boardID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HSBoardBloc(boardID: boardID)..add(HSBoardInitialEvent()),
      child: const BoardPage(),
    );
  }
}
