import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/user_profile/update/bloc/user_profile_bloc.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoaded) {
            return Center(
                child: CupertinoButton(
                    color: currentTheme.mainColor,
                    child:
                        Text("Followers: ${state.user.followers?.length ?? 0}"),
                    onPressed: () => context.read<UserProfileBloc>()
                      ..add(UserProfileFollowUser(state.user))));
          } else if (state is UserProfileLoading) {
            return const Center(child: HSLoadingIndicator());
          } else if (state is UserProfileError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          HSDebugLogger.logInfo("State: ${state.toString()}");
          return const SizedBox();
        },
      ),
    );
  }
}
