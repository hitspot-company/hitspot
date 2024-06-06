import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/choose_users/cubit/hs_choose_users_cubit.dart';
import 'package:hitspot/features/choose_users/view/choose_users_page.dart';

class ChooseUsersProvider extends StatelessWidget {
  const ChooseUsersProvider(
      {super.key, required this.description, required this.title});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSChooseUsersCubit(
        title: title,
        description: description,
      ),
      child: const ChooseUsersPage(),
    );
  }
}
