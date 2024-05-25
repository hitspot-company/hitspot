import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/boards/add_board/cubit/hs_add_board_cubit.dart';
import 'package:hitspot/features/boards/add_board/view/add_board_page.dart';

class AddBoardProvider extends StatelessWidget {
  const AddBoardProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HSAddBoardCubit(), child: const AddBoardPage());
  }
}
