import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/features/user_profile/main/bloc/hs_user_profile_bloc.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_page.dart';

class UserProfileProvider extends StatelessWidget {
  const UserProfileProvider({super.key, required this.userID});

  final String userID;

  static Route<void> route(String userID) {
    return MaterialPageRoute<void>(
      builder: (_) => UserProfileProvider(
        userID: userID,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = HSApp.instance;
    return BlocProvider(
      create: (context) => HSUserProfileBloc(
          userID: userID, databaseRepository: app.databaseRepository)
        ..add(HSUserProfileInitialEvent()),
      child: const UserProfilePage(),
    );
  }
}
