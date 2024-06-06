import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/boards/multiple_boards/bloc/hs_boards_bloc.dart';
import 'package:hitspot/features/boards/multiple_boards/view/boards_page.dart';

class BoardsProvider extends StatelessWidget {
  const BoardsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSBoardsBloc(),
      child: const BoardsPage(),
    );
  }
}
