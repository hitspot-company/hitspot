import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/user_profile/update/bloc/user_profile_bloc.dart';
import 'package:hitspot/user_profile/update/view/user_profile_page.dart';

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
    return BlocProvider(
        create: (context) => UserProfileBloc(app.databaseRepository, userID)
          ..add(UserProfileLoad(userID)),
        child: const UserProfilePage());
  }
}
