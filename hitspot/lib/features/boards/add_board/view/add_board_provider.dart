import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/boards/add_board/cubit/hs_add_board_cubit.dart';
import 'package:hitspot/features/boards/add_board/view/add_board_page.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class AddBoardProvider extends StatelessWidget {
  const AddBoardProvider({super.key, this.prototype});

  final HSBoard? prototype;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HSAddBoardCubit(prototype: prototype),
        child: const AddBoardPage());
  }
}
