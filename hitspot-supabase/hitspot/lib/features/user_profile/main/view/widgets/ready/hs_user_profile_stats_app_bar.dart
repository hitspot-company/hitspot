import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/features/user_profile/main/bloc/hs_user_profile_bloc.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/ready/hs_user_profile_action_button.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/ready/hs_user_profile_stats_chip_ready.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSUserProfileStatsAppBar extends StatelessWidget {
  const HSUserProfileStatsAppBar({
    super.key,
    this.user,
    this.loading = false,
    this.userProfileBloc,
  });

  final HSUser? user;
  final bool loading;
  final HSUserProfileBloc? userProfileBloc;

  factory HSUserProfileStatsAppBar.loading() {
    return const HSUserProfileStatsAppBar(
      loading: true,
    );
  }

  factory HSUserProfileStatsAppBar.ready(
      {required HSUser user, required HSUserProfileBloc userProfileBloc}) {
    return HSUserProfileStatsAppBar(
      user: user,
      userProfileBloc: userProfileBloc,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) user!;
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 150.0,
      floating: true,
      snap: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
          background: Column(
        children: [
          BlocBuilder<HSUserProfileBloc, HSUserProfileState>(
            // buildWhen: (previous, current) {
            //   if (previous is HSUserProfileReady &&
            //       current is HSUserProfileReady) {
            //     return previous.user?.followers != current.user?.followers ||
            //         previous.user?.following != current.user?.following;
            //   }
            //   return false;
            // },
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  HSUserProfileStatsChipReady(
                    label: "Followers",
                    value: 0, // user?.followers?.length,
                  ),
                  HSUserProfileStatsChipReady(
                    label: "Following",
                    value: 0, //user?.following?.length,
                  ),
                  HSUserProfileStatsChipReady(
                      label: "Spots", value: 0 // user?.spots?.length,
                      ),
                ],
              );
            },
          ),
          const SizedBox(
            height: 24.0,
          ),
          _button(loading),
        ],
      )),
    );
  }

  Widget _button(bool isLoading) {
    if (isLoading) {
      return HSShimmer(
        child: HSShimmerSkeleton(
          borderRadius: 8.0,
          child: Opacity(
            opacity: 0.0,
            child: HSUserProfileActionButton.editProfile(true),
          ),
        ),
      );
    }
    if (userProfileBloc!.isOwnProfile) {
      return HSUserProfileActionButton.editProfile(false, userProfileBloc!);
    } else {
      if (userProfileBloc!.isUserFollowed()) {
        return HSUserProfileActionButton.unfollow(userProfileBloc!);
      }
      return HSUserProfileActionButton.follow(userProfileBloc!);
    }
  }
}
