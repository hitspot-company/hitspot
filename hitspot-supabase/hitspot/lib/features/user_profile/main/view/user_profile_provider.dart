import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_page.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';

class UserProfileProvider extends StatelessWidget {
  const UserProfileProvider({super.key, required this.userID});

  final String userID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HSUserProfileCubit(userID),
        child: const UserProfilePage());
  }
}
