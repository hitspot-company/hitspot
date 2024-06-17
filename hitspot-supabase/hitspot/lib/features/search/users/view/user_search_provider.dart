import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/search/users/cubit/hs_user_search_cubit.dart';
import 'package:hitspot/features/search/users/view/user_search_page.dart';

class UserSearchProvider extends StatelessWidget {
  const UserSearchProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HSUserSearchCubit(),
      child: const UserSearchPage(),
    );
  }
}
