import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

import 'widgets/user_profile_widgets.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
      builder: (context, state) {
        final HSUser? user = state.user;
        final bool loading = state.status == HSUserProfileStatus.loading;

        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            titleText: 'User Profile',
            right: IconButton(
              onPressed: navi.toSettings,
              icon: const Icon(FontAwesomeIcons.gears),
            ),
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UserProfileInfo(
                        context: context,
                        loading: loading,
                        user: user,
                      ),
                      const SizedBox(height: 8),
                      // UserProfileActionButton(isLoading: loading),
                      // const SizedBox(height: 16),
                      UserDataBar(loading: loading, user: user),
                      const SizedBox(height: 16),
                      TabBarWidget(),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      TabContent(
                        context: context,
                        isLoading: loading,
                        elements: state.spots,
                        title: 'Spots',
                      ),
                      TabContent(
                        context: context,
                        isLoading: loading,
                        elements: state.boards,
                        title: 'Boards',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
