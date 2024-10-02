import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_updated_cubit.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_page_updated.dart';

class UserProfileProviderUpdated extends StatelessWidget {
  const UserProfileProviderUpdated({super.key, required this.userID});

  final String userID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HsUserProfileUpdatedCubit(userID),
      child: const UserProfilePageUpdated(),
    );
  }
}
