import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/app/hs_app.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

part 'widgets/user_profile_widgets.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
      builder: (context, state) {
        final HSUser? user = state.user;
        final bool loading = state.status == HSUserProfileStatus.loading;
        final bool ownProfile = context.read<HSUserProfileCubit>().isOwnProfile;

        return HSScaffold(
          appBar: HSAppBar(
            enableDefaultBackButton: true,
            right: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ownProfile
                    ? IconButton(
                        onPressed: navi.toEditProfile,
                        icon: const Icon(FontAwesomeIcons.userEdit),
                      )
                    : const SizedBox.shrink(),
                IconButton(
                  onPressed: navi.toSettings,
                  icon: const Icon(FontAwesomeIcons.gears),
                ),
              ],
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
                      _UserProfileInfo(
                        context: context,
                        loading: loading,
                        user: user,
                      ),
                      const SizedBox(height: 8),
                      _UserProfileActionButton(isLoading: loading),
                      const SizedBox(height: 8),
                      _UserDataBar(loading: loading, user: user),
                      const SizedBox(height: 16),
                      _TabBarWidget(),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _TabContent(
                        context: context,
                        isLoading: loading,
                        elements: state.spots,
                        title: 'Spots',
                      ),
                      _TabContent(
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
