import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileCubit = BlocProvider.of<HSUserProfileCubit>(context);
    return BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
      builder: (context, state) {
        final HSUser? user = userProfileCubit.state.user;
        final bool loading = state.status == HSUserProfileStatus.loading;
        return DefaultTabController(
          length: 2,
          child: HSScaffold(
            sidePadding: 0.0,
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 300.0,
                    pinned: true,
                    stretch: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _background(loading, user?.avatarUrl),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (loading)
                                      const HSShimmerBox(width: 200, height: 30)
                                    else
                                      Text(
                                        user?.name ?? '',
                                        style: textTheme.headlineMedium,
                                      )
                                          .animate()
                                          .fadeIn(duration: 300.ms)
                                          .slideY(begin: 0.2, end: 0),
                                    if (loading)
                                      const HSShimmerBox(width: 150, height: 20)
                                    else
                                      Text(
                                        '@${user?.username ?? ''}',
                                        style: textTheme.titleMedium,
                                      )
                                          .animate()
                                          .fadeIn(duration: 300.ms)
                                          .slideY(begin: 0.2, end: 0),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _UserProfileActionButton(
                                  isLoading: loading,
                                  userProfileCubit: userProfileCubit,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _UserDataBar(loading: loading, user: user)
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 16),
                          if (!loading)
                            Text(
                              'Product designer at @airbnb with a love for exploring the great outdoors. Creating beautiful interfaces and seamless user experiences is my jam!',
                              style: textTheme.bodyMedium,
                            ).animate().fadeIn(duration: 300.ms),
                          const SizedBox(height: 16),
                          const TabBar(
                            tabs: [
                              Tab(text: 'Spots'),
                              Tab(text: 'Boards'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _SpotsList(userProfileCubit: userProfileCubit),
                  _BoardsList(userProfileCubit: userProfileCubit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _background(bool isLoading, String? userAvatar) {
    if (isLoading) {
      return const HSShimmerBox(width: double.infinity, height: 300);
    } else if (userAvatar != null) {
      return HSImage(
        imageUrl: userAvatar,
      ).animate().fadeIn(duration: 300.ms);
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            app.theme.mainColor.withOpacity(0.9),
            app.theme.mainColor.withOpacity(0.6),
            app.theme.mainColor.withOpacity(0.4),
            app.theme.mainColor.withOpacity(0.2),
            app.currentTheme.scaffoldBackgroundColor.withOpacity(0.2),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool loading) {
    if (loading) {
      return const Column(
        children: [
          HSShimmerBox(width: 50, height: 25),
          HSShimmerBox(width: 70, height: 15),
        ],
      );
    }
    return Column(
      children: [
        Text(value, style: textTheme.headlineSmall),
        Text(label, style: textTheme.bodySmall),
      ],
    ).animate().fadeIn(duration: 300.ms)
      ..scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0));
  }

  Widget _buildContentItem(String count, String type, bool loading) {
    if (loading) {
      return const Column(
        children: [
          HSShimmerBox(width: 40, height: 20),
          HSShimmerBox(width: 60, height: 15),
        ],
      );
    }
    return Column(
      children: [
        Text(count, style: textTheme.titleMedium?.copyWith(color: Colors.red)),
        Text(type, style: textTheme.bodySmall),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0));
  }
}

class _SpotsList extends StatelessWidget {
  const _SpotsList({required this.userProfileCubit});

  final HSUserProfileCubit userProfileCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
      builder: (context, state) {
        if (state.status == HSUserProfileStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final spots = state.spots;
        final bool isFetchingMore =
            state.status == HSUserProfileStatus.loadingMoreSpots;
        return GridView.builder(
          shrinkWrap: true,
          controller: userProfileCubit.spotsScrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: spots.length,
          itemBuilder: (BuildContext context, int index) {
            return AnimatedSpotTile(spot: spots[index], index: index);
          },
        );
      },
    );
  }
}

class _BoardsList extends StatelessWidget {
  const _BoardsList({required this.userProfileCubit});

  final HSUserProfileCubit userProfileCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
      builder: (context, state) {
        if (state.status == HSUserProfileStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final bool isFetchingMore =
            state.status == HSUserProfileStatus.loadingMoreBoards;
        return ListView.builder(
          controller: userProfileCubit.spotsScrollController,
          itemCount: state.boards.length + 1,
          itemBuilder: (context, index) {
            if (index == state.boards.length) {
              return isFetchingMore
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox();
            }
            final board = state.boards[index];
            return ListTile(
              title: Text(board.title ?? ''),
              // Add more board details here
            );
          },
        );
      },
    );
  }
}

class _UserDataBar extends StatelessWidget {
  const _UserDataBar({
    required this.loading,
    required this.user,
  });

  final bool loading;
  final HSUser? user;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: const HSShimmerBox(
          width: double.infinity,
          height: 50,
        ),
      );
    }

    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: app.currentTheme.primaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDataItem('214', 'posts'),
          _buildDataItem('13k', 'followers'),
          _buildDataItem('134', 'following'),
        ],
      ),
    );
  }

  Widget _buildDataItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: textTheme.headlineSmall),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

class _UserProfileActionButton extends StatelessWidget {
  const _UserProfileActionButton({
    required this.isLoading,
    required this.userProfileCubit,
  });

  final bool isLoading;
  final HSUserProfileCubit userProfileCubit;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        child: HSShimmerBox(
          width: double.infinity,
          height: 50,
        ),
      );
    }

    final bool ownProfile = userProfileCubit.isOwnProfile;
    final bool isFollowed = userProfileCubit.state.isFollowed == true;

    return SizedBox(
      width: screenWidth,
      height: 50.0,
      child: HSButton(
        onPressed:
            ownProfile ? navi.toEditProfile : userProfileCubit.followUser,
        child: Text(
          ownProfile ? 'Edit Profile' : (isFollowed ? 'Unfollow' : 'Follow'),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
          ),
    );
  }
}
