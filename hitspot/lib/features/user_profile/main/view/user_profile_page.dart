import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

import 'package:hs_database_repository/hs_database_repository.dart';

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
                  delegate: SliverChildListDelegate([
                    _buildUserInfo(context, loading, user, userProfileCubit),
                    const SizedBox(height: 16),
                    _UserDataBar(loading: loading, user: user)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    if (!loading)
                      Text(
                        user?.biogram ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 24),
                    _buildContentSection(
                        context, "Spots", loading, userProfileCubit),
                    const SizedBox(height: 24),
                    _buildContentSection(
                        context, "Boards", loading, userProfileCubit),
                    if (userProfileCubit.state.spots.isEmpty &&
                        userProfileCubit.state.boards.isEmpty &&
                        !loading)
                      _buildEmptyContent(context),
                  ]),
                ),
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

  Widget _buildContentSection(BuildContext context, String title, bool loading,
      HSUserProfileCubit userProfileCubit) {
    if (title == "Spots" && userProfileCubit.state.spots.isEmpty) {
      return const SizedBox();
    }
    if (title == "Boards" && userProfileCubit.state.boards.isEmpty) {
      return const SizedBox();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   title,
        //   style: Theme.of(context).textTheme.headlineSmall,
        // ).animate().fadeIn(duration: 300.ms),
        if (title == "Spots")
          _SpotsList(userProfileCubit: userProfileCubit, loading: loading)
        else
          _BoardsList(userProfileCubit: userProfileCubit, loading: loading),
      ],
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.xmark,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No spots or boards yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SpotsList extends StatelessWidget {
  final HSUserProfileCubit userProfileCubit;
  final bool loading;

  const _SpotsList({required this.userProfileCubit, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildLoadingList();
    }

    final spots = userProfileCubit.state.spots;
    if (spots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'The user has no spots',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12, // Reduced from 16 to 12
        mainAxisSpacing: 12, // Reduced from 16 to 12
        childAspectRatio: 0.8,
      ),
      itemCount: spots.length,
      itemBuilder: (context, index) {
        final spot = spots[index];
        return _SpotCard(spot: spot, index: index);
      },
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLoadingList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const HSShimmerBox(
          height: 40,
          width: 40.0,
        );
      },
    );
  }
}

class _SpotCard extends StatelessWidget {
  final HSSpot spot;
  final int index;

  const _SpotCard({required this.spot, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navi.toSpot(sid: spot.sid!),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: HSImage(
                  imageUrl: spot.images!.first,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.title!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    "${spot.likesCount} likes • ${spot.commentsCount} comments",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms),
    );
  }
}

class _BoardsList extends StatelessWidget {
  final HSUserProfileCubit userProfileCubit;
  final bool loading;

  const _BoardsList({required this.userProfileCubit, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildLoadingList();
    }

    final boards = userProfileCubit.state.boards;
    if (boards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.library_books,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'The user has no boards',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return SizedBox(height: 90.0, child: _BoardCard(board: board));
      },
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: HSShimmerBox(
            height: 100,
            width: 100,
          ),
        );
      },
    );
  }
}

class _BoardCard extends StatelessWidget {
  final HSBoard board;

  const _BoardCard({required this.board});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navi.toBoard(boardID: board.id!, title: board.title!),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              board.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: HSImage(
                        imageUrl: board.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(
                        FontAwesomeIcons.layerGroup,
                        size: 32.0,
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      board.title!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      board.description!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
