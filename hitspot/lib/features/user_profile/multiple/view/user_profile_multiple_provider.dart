import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/user_profile/multiple/cubit/hs_user_profile_multiple_cubit.dart';
import 'package:hitspot/features/user_profile/multiple/view/user_profile_multiple_page.dart';

class UserProfileMultipleProvider extends StatelessWidget {
  const UserProfileMultipleProvider(
      {super.key, required this.type, this.userID, this.spotID, this.boardID});

  final HSUserProfileMultipleType type;
  final String? userID, spotID, boardID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HsUserProfileMultipleCubit(type, userID, spotID, boardID),
      child: const UserProfileMultiplePage(),
    );
  }
}
