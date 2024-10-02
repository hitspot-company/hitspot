import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_updated_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
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
                    Center(
                            child: HSUserAvatar(
                                radius: 70.0, imageUrl: user.avatarUrl))
                        .toSliver,
                    const SizedBox(height: 16).toSliver,
                    Center(
                            child: Text(user.name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium)
                                .animate()
                                .fadeIn(delay: 300.ms))
                        .toSliver,
                    _UserProfileUpdatedBiogram(user),
                    const SizedBox(height: 32.0).toSliver,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _UserProfileUpdatedStatItem(
                            value: 'Followers',
                            label: followersCount.toString()),
                        _UserProfileUpdatedStatItem(
                            value: 'Following',
                            label: followingCount.toString()),
                        _UserProfileUpdatedStatItem(
                            value: 'Spots', label: spotsCount.toString()),
                      ],
                    ).animate().fadeIn(delay: 600.ms).toSliver,
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
