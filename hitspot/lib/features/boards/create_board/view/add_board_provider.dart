import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/boards/create_board/cubit/hs_create_board_cubit.dart';
import 'package:hitspot/features/boards/create_board/view/add_board_page.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class CreateBoardProvider extends StatelessWidget {
  const CreateBoardProvider({super.key, this.prototype});

  final HSBoard? prototype;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HSCreateBoardCubit(prototype: prototype),
        child: const CreateBoardPage());
  }
}
