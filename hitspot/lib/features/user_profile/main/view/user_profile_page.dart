import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/user_profile/main/cubit/hs_user_profile_cubit.dart';
import 'package:hitspot/features/user_profile/main/view/widgets/hs_user_profile_headline.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileCubit = BlocProvider.of<HSUserProfileCubit>(context);
    return BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
      builder: (context, state) {
        final HSUser? user = userProfileCubit.state.user;
        final bool loading = state.status == HSUserProfileStatus.loading;
        final bool ownProfile = userProfileCubit.isOwnProfile;
        return RefreshIndicator.adaptive(
          onRefresh: userProfileCubit.refresh,
          child: HSScaffold(
            appBar: HSAppBar(
              enableDefaultBackButton: true,
              right: ownProfile
                  ? IconButton(
                      onPressed: navi.toSettings,
                      icon: const Icon(
                        FontAwesomeIcons.ellipsisVertical,
                      ),
                    )
                  : null,
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  surfaceTintColor: const Color.fromARGB(0, 97, 51, 51),
                  expandedHeight: 140.0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: HSUserAvatar(
                              loading: loading,
                              radius: 70.0,
                              iconSize: 50,
                              imageUrl: user?.avatarUrl,
                            ).animate().fadeIn(duration: 300.ms).scale(
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1, 1)),
                          ),
                        ),
                        Expanded(
                          child: loading
                              ? const HSShimmer(
                                  child:
                                      HSShimmerSkeleton(height: 60, width: 100),
                                ).animate().fadeIn(duration: 300.ms).scale(
                                  begin: const Offset(0.95, 0.95),
                                  end: const Offset(1, 1))
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${user?.name}",
                                      style: textTheme.headlineSmall!.hintify,
                                    ).animate().fadeIn(duration: 300.ms).scale(
                                        begin: const Offset(0.95, 0.95),
                                        end: const Offset(1, 1)),
                                    Text("@${user?.username}",
                                            style: textTheme.headlineLarge)
                                        .animate()
                                        .fadeIn(duration: 300.ms)
                                        .scale(
                                            begin: const Offset(0.95, 0.95),
                                            end: const Offset(1, 1)),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                if (loading)
                  HSShimmerBox(width: screenWidth, height: 60)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1))
                      .toSliver,
                if (!loading && user?.biogram != null)
                  SliverMainAxisGroup(
                    slivers: [
                      const HSUserProfileHeadline(title: "About Me"),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Text(
                            user?.biogram ?? "",
                            style: textTheme.titleSmall,
                          ).animate().fadeIn(duration: 300.ms).scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1)),
                        ),
                      )
                    ],
                  ),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                SliverAppBar(
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: 100.0,
                  floating: true,
                  snap: false,
                  pinned: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: [
                        BlocBuilder<HSUserProfileCubit, HSUserProfileState>(
                          builder: (context, state) {
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                    child: HSUserProfileStatsChip(
                                  label: "Followers",
                                  value: user?.followers,
                                  loading: loading,
                                ).animate().fadeIn(duration: 300.ms).scale(
                                        begin: const Offset(0.95, 0.95),
                                        end: const Offset(1, 1))),
                                Expanded(
                                    child: HSUserProfileStatsChip(
                                  label: "Following",
                                  value: user?.following,
                                  loading: loading,
                                ).animate().fadeIn(duration: 300.ms).scale(
                                        begin: const Offset(0.95, 0.95),
                                        end: const Offset(1, 1))),
                                Expanded(
                                    child: HSUserProfileStatsChip(
                                  label: "Spots",
                                  value: user?.spots,
                                  loading: loading,
                                ).animate().fadeIn(duration: 300.ms).scale(
                                        begin: const Offset(0.95, 0.95),
                                        end: const Offset(1, 1))),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50.0,
                    child: _UserProfileActionButton(
                            isLoading: loading,
                            userProfileCubit: userProfileCubit)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1)),
                  ),
                ),
                if (loading)
                  SliverMainAxisGroup(slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 16.0,
                      ),
                    ),
                    SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                      ),
                      itemCount: 12,
                      itemBuilder: (BuildContext context, int index) {
                        return const HSShimmerBox(width: 10, height: 10)
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .scale(
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1, 1));
                      },
                    ),
                  ])
                else
                  SliverMainAxisGroup(
                    slivers: [
                      const Gap(24.0).toSliver,
                      const HSUserProfileHeadline(title: "Spots"),
                      const Gap(24.0).toSliver,
                      SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12.0,
                          crossAxisSpacing: 12.0,
                          mainAxisExtent: 140.0,
                        ),
                        itemCount: state.spots.length,
                        itemBuilder: (BuildContext context, int index) {
                          final HSSpot spot = state.spots[index];
                          return GestureDetector(
                            onTap: () => navi.toSpot(sid: spot.sid!),
                            child: CachedNetworkImage(
                              imageUrl: spot.images!.first,
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      const HSShimmerBox(width: 60, height: 60)
                                          .animate()
                                          .fadeIn(duration: 300.ms)
                                          .scale(
                                              begin: const Offset(0.95, 0.95),
                                              end: const Offset(1, 1)),
                              imageBuilder: (context, imageProvider) => Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ).animate().fadeIn(duration: 300.ms).scale(
                                        begin: const Offset(0.95, 0.95),
                                        end: const Offset(1, 1)),
                                  ),
                                  const Gap(12),
                                  AutoSizeText(
                                    spot.title!,
                                    style: textTheme.bodyMedium,
                                    minFontSize: 12.0,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ).animate().fadeIn(duration: 300.ms).scale(
                                      begin: const Offset(0.95, 0.95),
                                      end: const Offset(1, 1)),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  )
              ],
            ),
          ),
        );
      },
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
      return const SizedBox(
        height: 8.0,
        width: 8.0,
        child: CircularProgressIndicator.adaptive(),
      );
    }
    final user = userProfileCubit.state.user;
    return HSButton(
      child: Text(
        "Add a Spot",
      ),
      onPressed: () async {
        // final bool? created = await navi.toCreateSpot(
        //     user: user, source: HSSpotCreateSource.userProfile);
        // if (created == true && context.mounted) {
        //   userProfileCubit.refresh();
        // }
      },
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

class HSUserProfileStatsChip extends StatelessWidget {
  const HSUserProfileStatsChip({
    super.key,
    required this.label,
    required this.value,
    required this.loading,
  });

  final String label;
  final int? value;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: HSShimmerBox(width: 60, height: 60),
      );
    }
    return Column(
      children: [
        Text(label, style: textTheme.headlineSmall),
        Text("${value ?? 0}", style: textTheme.labelLarge),
      ],
    );
  }
}

// class _UserProfileActionButton extends StatelessWidget {
//   const _UserProfileActionButton(
//       {required this.isLoading, required this.userProfileCubit});

//   final bool isLoading;
//   final HSUserProfileCubit userProfileCubit;

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const HSShimmer(
//         child: HSShimmerSkeleton(
//           borderRadius: 8.0,
//           child: Opacity(
//               opacity: 0.0,
//               child: HSButton(
//                 child: Text("data"),
//               )),
//         ),
//       );
//     }
//     if (userProfileCubit.isOwnProfile) {
//       return HSButton.outlined(
//           onPressed: navi.toEditProfile, child: const Text("Edit Profile"));
//     } else {
//       if (userProfileCubit.state.isFollowed == true) {
//         return HSButton.outlined(
//             borderRadius: 6.0,
//             onPressed: userProfileCubit.followUser,
//             child: const Text("Unfollow"));
//       } else {
//         return HSButton(
//             onPressed: userProfileCubit.followUser,
//             child: const Text("Follow"));
//       }
//     }
//   }
// }
