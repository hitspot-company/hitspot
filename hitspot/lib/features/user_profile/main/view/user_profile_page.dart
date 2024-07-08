import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
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
          sidePadding: 0.0,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: loading
                      ? const HSShimmerBox(width: double.infinity, height: 300)
                      : HSImage(
                          imageUrl: user?.avatarUrl,
                          color: Colors.amber, // TODO; Change to some gradient
                        ).animate().fadeIn(duration: 300.ms),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
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
                        child: Column(
                          children: [
                            if (loading)
                              const HSShimmerBox(width: 200, height: 30)
                            else
                              _UserProfileActionButton(
                                  isLoading: loading,
                                  userProfileCubit: userProfileCubit),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _UserDataBar(loading: loading, user: user)
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 16),
                            if (loading)
                              const HSShimmerBox(width: 250, height: 20)
                            else
                              Text(
                                'linkedin.com/in/marysnyder14',
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: Colors.blue),
                              ).animate().fadeIn(duration: 300.ms),
                            const SizedBox(height: 8),
                            if (loading)
                              Column(
                                children: List.generate(
                                    3,
                                    (_) => const HSShimmerBox(
                                        width: double.infinity, height: 15)),
                              )
                            else
                              Text(
                                'Product designer at @airbnb with a love for exploring the great outdoors. Creating beautiful interfaces and seamless user experiences is my jam!',
                                style: textTheme.bodyMedium,
                              ).animate().fadeIn(duration: 300.ms),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildContentItem('194', 'photos', loading),
                                _buildContentItem('15', 'videos', loading),
                                _buildContentItem('9', 'stories', loading),
                                _buildContentItem('85', 'tags', loading),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        );
      },
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
