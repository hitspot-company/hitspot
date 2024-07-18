import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
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
        return HSScaffold(
          topSafe: false,
          sidePadding: 0.0,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(loading, user?.avatarUrl),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildUserInfo(context, loading, user, userProfileCubit),
                      const SizedBox(height: 16),
                      _UserDataBar(loading: loading, user: user)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverMainAxisGroup(slivers: [
                  const _UserProfileGridBuilder(
                      type: _UserProfileGridBuilderType.spots),
                  const Gap(32.0).toSliver,
                  const _UserProfileGridBuilder(
                      type: _UserProfileGridBuilderType.boards),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(bool isLoading, String? userAvatar) {
    return SliverAppBar(
      scrolledUnderElevation: 0.0,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      actions: [
        IconButton.filledTonal(
            onPressed: navi.toSettings,
            icon: const Icon(FontAwesomeIcons.gears))
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _background(isLoading, userAvatar),
      ),
    );
  }

  Widget _background(bool isLoading, String? userAvatar) {
    if (isLoading) {
      return const HSShimmerBox(width: double.infinity, height: 250);
    } else if (userAvatar != null) {
      return HSImage(
        imageUrl: userAvatar,
        fit: BoxFit.cover,
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
            Colors.white.withOpacity(0.2),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, bool loading, HSUser? user,
      HSUserProfileCubit userProfileCubit) {
    return Column(
      children: [
        if (loading)
          const HSShimmerBox(width: 200, height: 30)
        else
          Text(
            user?.name ?? '',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 4),
        if (loading)
          const HSShimmerBox(width: 150, height: 20)
        else
          Text(
            '@${user?.username ?? ''}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        _UserProfileActionButton(
          isLoading: loading,
          userProfileCubit: userProfileCubit,
        ),
      ],
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
          height: 60,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: app.currentTheme.primaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDataItem('${user?.spots}', 'spots'),
          _buildDataItem('${user?.followers}', 'followers'),
          _buildDataItem('${user?.following}', 'following'),
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
          width: 50.0,
          height: 50,
        ),
      );
    }

    final bool ownProfile = userProfileCubit.isOwnProfile;
    final bool isFollowed = userProfileCubit.state.isFollowed == true;

    return SizedBox(
      height: 50.0,
      width: screenWidth,
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

enum _UserProfileGridBuilderType { spots, boards }

class _UserProfileGridBuilder extends StatelessWidget {
  const _UserProfileGridBuilder({
    this.defaultBuilderHeight = 140.0,
    required this.type,
  });

  final double defaultBuilderHeight;
  final _UserProfileGridBuilderType type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
      buildWhen: (previous, current) {
        switch (type) {
          case _UserProfileGridBuilderType.spots:
            return previous.spots != current.spots ||
                previous.status != current.status;
          case _UserProfileGridBuilderType.boards:
            return previous.boards != current.boards ||
                previous.status != current.status;
        }
      },
      builder: (context, state) {
        final isLoading = state.status == HSUserProfileStatus.loading;
        late final List elements;
        late final String title;
        switch (type) {
          case _UserProfileGridBuilderType.spots:
            elements = state.spots;
            title = "Spots";
            break;
          case _UserProfileGridBuilderType.boards:
            elements = state.boards;
            title = "Boards";
            break;
        }
        if (elements.isEmpty) {
          return const SizedBox().toSliver;
        }
        if (isLoading) {
          return SliverMainAxisGroup(
            slivers: [
              HSShimmerBox(width: screenWidth / 3, height: 40.0).toSliver,
              const Gap(8.0).toSliver,
              HSShimmerBox(width: screenWidth / 3 - 10.0, height: 20.0)
                  .toSliver,
              const Gap(16.0).toSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280.0,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                            crossAxisCount: 2),
                    itemCount: 10,
                    itemBuilder: (context, index) =>
                        const HSShimmerBox(width: 40.0, height: 40.0),
                  ),
                ),
              ),
            ],
          );
        }
        final builderHeight = elements.length < 2
            ? defaultBuilderHeight
            : defaultBuilderHeight * 2;
        final crossAxisCount = elements.length < 2 ? 1 : 2;
        return SliverMainAxisGroup(
          slivers: [
            Row(
              children: [
                Text(title, style: textTheme.headlineMedium)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1)),
                IconButton(
                  onPressed: () {},
                  icon: nextIcon,
                  iconSize: 16.0,
                ),
              ],
            ).toSliver,
            SliverToBoxAdapter(
              child: SizedBox(
                height: builderHeight,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      crossAxisCount: crossAxisCount),
                  itemCount: elements.length,
                  itemBuilder: (context, index) {
                    if (type == _UserProfileGridBuilderType.boards) {
                      return HSBoardGridItem(board: elements[index]);
                    } else {
                      return AnimatedSpotTile(
                          spot: elements[index], index: index);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
