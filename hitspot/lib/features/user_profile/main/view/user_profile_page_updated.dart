import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_updated_cubit.dart';
import 'package:hitspot/features/user_profile/multiple/cubit/hs_user_profile_multiple_cubit.dart';
import 'package:hitspot/features/user_profile/multiple/view/user_profile_multiple_provider.dart';
import 'package:hitspot/widgets/hs_icon_prompt.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

part 'user_profile_updated_widgets.dart';

class UserProfilePageUpdated extends StatelessWidget {
  const UserProfilePageUpdated({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HsUserProfileUpdatedCubit>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTabController(
          length: 2,
          child:
              BlocBuilder<HsUserProfileUpdatedCubit, HsUserProfileUpdatedState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              final isLoading =
                  state.status == HSUserProfileUpdatedStatus.loading;
              if (isLoading) {
                return const HSLoadingIndicator();
              }
              final isError = state.status == HSUserProfileUpdatedStatus.error;
              if (isError) {
                return const Center(child: Text('Failed to load user profile'));
              }
              final user = state.user;
              final followersCount = state.followersCount;
              final followingCount = state.followingCount;
              final spotsCount = state.spotsCount;
              final spots = state.spots;
              final boards = state.boards;
              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      surfaceTintColor: Colors.transparent,
                      floating: false,
                      pinned: true,
                      title: Text("@${user.username}",
                          style: Theme.of(context).textTheme.headlineMedium),
                      actions: [
                        if (cubit.isCurrentUser)
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: navi.toSettings,
                          ),
                      ],
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      sliver: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: user.avatarUrl ?? "None",
                            placeholder: (context, url) =>
                                const HSShimmerCircleSkeleton(size: 64.0),
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                              radius: 64.0,
                              child: Center(
                                child: Icon(FontAwesomeIcons.user, size: 32.0),
                              ),
                            ),
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                                    radius: 64.0,
                                    backgroundImage: imageProvider),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username!,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  user.name!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Gap(8.0),
                                !cubit.isCurrentUser
                                    ? SizedBox(
                                        width: double.infinity,
                                        child: _FollowButton(cubit: cubit),
                                      )
                                    : const SizedBox()
                              ],
                            ),
                          ),
                        ],
                      ).toSliver,
                    ),
                    _UserProfileUpdatedBiogram(user),
                    const SizedBox(height: 32.0).toSliver,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _UserProfileUpdatedStatItem(
                            value: 'Followers',
                            type: HSUserProfileMultipleType.followers,
                            label: followersCount.toString()),
                        _UserProfileUpdatedStatItem(
                            value: 'Following',
                            type: HSUserProfileMultipleType.following,
                            label: followingCount.toString()),
                        // _UserProfileUpdatedStatItem(
                        //     value: 'Spots', label: spotsCount.toString()),
                      ],
                    ).animate().fadeIn(delay: 600.ms).toSliver,
                    const SizedBox(height: 16.0).toSliver,
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          tabs: [
                            Tab(text: "Spots"),
                            Tab(text: "Boards"),
                          ],
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _UserProfileUpdatedSpotsBuilder(spots),
                    _UserProfileUpdatedBoardsBuilder(boards),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    super.key,
    required this.cubit,
  });

  final HsUserProfileUpdatedCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HsUserProfileUpdatedCubit, HsUserProfileUpdatedState,
        bool>(
      selector: (state) => state.isFollowed,
      builder: (context, isFollowed) {
        if (isFollowed) {
          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              side: BorderSide(color: appTheme.mainColor, width: 2.0),
            ),
            onPressed: cubit.followUnfollow,
            child: Text(
              "Following",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: appTheme.mainColor,
            side: BorderSide(color: Theme.of(context).scaffoldBackgroundColor),
          ),
          onPressed: cubit.followUnfollow,
          child: Text(
            "Follow",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      },
    );
  }
}
