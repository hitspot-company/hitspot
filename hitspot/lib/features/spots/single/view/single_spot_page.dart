import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_comments_cubit.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_cubit.dart';
import 'package:hitspot/features/spots/single/view/single_spot_comments_page.dart';
import 'package:hitspot/features/user_profile/multiple/cubit/hs_user_profile_multiple_cubit.dart';
import 'package:hitspot/features/user_profile/multiple/view/user_profile_multiple_provider.dart';
import 'package:hitspot/utils/gallery/hs_gallery.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_button.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/map/hs_google_map.dart';
import 'package:hitspot/widgets/map/show_maps_choice_bottom_sheet.dart';
import 'package:hitspot/widgets/user/hs_user_widgets.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

part 'single_spot_widgets.dart';

class SingleSpotPage extends StatelessWidget {
  const SingleSpotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final singleSpotCubit = BlocProvider.of<HSSingleSpotCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
          enableDefaultBackButton: true,
          right: BlocSelector<HSSingleSpotCubit, HSSingleSpotState, bool>(
            selector: (state) =>
                state.status == HSSingleSpotStatus.error ||
                state.status == HSSingleSpotStatus.loading,
            builder: (context, inValid) {
              return IconButton(
                icon: const Icon(FontAwesomeIcons.ellipsisVertical),
                onPressed: inValid ? null : singleSpotCubit.showBottomSheet,
              )
                  .animate()
                  .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  );
            },
          )),
      body: RefreshIndicator(
        onRefresh: singleSpotCubit.refresh,
        child: BlocBuilder<HSSingleSpotCubit, HSSingleSpotState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.spot != current.spot,
          builder: (context, state) {
            final status = state.status;
            if (status == HSSingleSpotStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48)
                        .animate()
                        .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                        .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1)),
                    const Gap(16),
                    Text(
                      'Something went wrong.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                    const Gap(16),
                    HSButton(
                      onPressed:
                          singleSpotCubit.fetchSpot, // TODO: To be verified
                      child: const Text("Retry"),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              );
            }
            if (status == HSSingleSpotStatus.loading) {
              return const HSLoadingIndicator()
                  .animate()
                  .fadeIn(duration: 300.ms, curve: Curves.easeInOut);
            }
            final spot = singleSpotCubit.state.spot;
            final imagesCount = spot.images?.length ?? 0;
            return CustomScrollView(
              slivers: [
                Text(
                  "${spot.title}",
                  style: Theme.of(context).textTheme.displayMedium,
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slideY(begin: 0.2, end: 0)
                    .toSliver,
                const Gap(24.0).toSliver,
                _AnimatedImageTile(
                  imageUrl: spot.images!.first,
                ).toSliver,
                const Gap(16.0).toSliver,
                AutoSizeText(
                  spot.getAddress,
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  maxLines: 2,
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0)
                    .toSliver,
                const _AnimatedTagsBuilder().toSliver,
                const Gap(32.0).toSliver,
                Text(spot.description!, style: const TextStyle(fontSize: 16.0))
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0)
                    .toSliver,
                const Gap(32.0).toSliver,
                _AnimatedUserAndActionBar(singleSpotCubit: singleSpotCubit)
                    .toSliver,
                const Gap(32.0).toSliver,
                _AnimatedMapView(singleSpotCubit: singleSpotCubit).toSliver,
                const Gap(32.0).toSliver,
                SliverList.separated(
                  itemCount: imagesCount - 1,
                  separatorBuilder: (context, index) => const Gap(16.0),
                  itemBuilder: (context, index) => _AnimatedImageTile(
                    imageUrl: spot.images![index + 1],
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (400 + index * 100).ms)
                      .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1)),
                ),
                const Gap(32.0).toSliver,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedImageTile extends StatelessWidget {
  const _AnimatedImageTile({required this.imageUrl, this.height = 300.0});

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HSSingleSpotCubit>(context);
    return GestureDetector(
      onTap: () => navi.pushPage(
        page: HSGalleryBuilder(
          images: cubit.state.spot.images!,
          initialIndex: cubit.state.spot.images!.indexOf(imageUrl),
          type: HSImageGalleryType.network,
          backgroundDecoration:
              BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        ),
      ),
      child: Hero(
        tag: imageUrl,
        child: HSImage(
          imageUrl: imageUrl,
          height: height,
          width: screenWidth,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

class _AnimatedMapView extends StatelessWidget {
  const _AnimatedMapView({required this.singleSpotCubit});

  final HSSingleSpotCubit singleSpotCubit;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HSSingleSpotCubit, HSSingleSpotState, bool>(
      selector: (state) =>
          state.spot.latitude != null && state.spot.longitude != null,
      builder: (context, isSpotLocationLoaded) {
        if (isSpotLocationLoaded) {
          final LatLng spotLocation = singleSpotCubit.spotLocation!;
          return SizedBox(
            height: 200.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: GestureDetector(
                onTap: () => showMapsChoiceBottomSheet(
                  context: context,
                  coords: spotLocation,
                  description: singleSpotCubit.state.spot.getAddress,
                  title: singleSpotCubit.state.spot.title!,
                ),
                child: AbsorbPointer(
                  absorbing: true,
                  child: HSGoogleMap(
                    cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                        southwest: spotLocation, northeast: spotLocation)),
                    initialCameraPosition: CameraPosition(
                      target: spotLocation,
                      zoom: 16.0,
                    ),
                    myLocationEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('1'),
                        position: spotLocation,
                      )
                    },
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 500.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
        }
        return const SizedBox();
      },
    );
  }
}

class _AnimatedTagsBuilder extends StatelessWidget {
  const _AnimatedTagsBuilder();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSSingleSpotCubit, HSSingleSpotState>(
      builder: (context, state) {
        final tags = state.tags;
        if (tags.isEmpty) {
          return const SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Wrap(
            children: tags
                .asMap()
                .map((index, tag) => MapEntry(
                      index,
                      GestureDetector(
                        onTap: () => navi.toTagsExplore(tag.value!),
                        child: Chip(
                          side: BorderSide.none,
                          label: Text("#${tag.value}"),
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: 300.ms, delay: (200 + index * 50).ms)
                          .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1)),
                    ))
                .values
                .toList(),
          ),
        );
      },
    );
  }
}

class _AnimatedUserAndActionBar extends StatelessWidget {
  const _AnimatedUserAndActionBar({required this.singleSpotCubit});

  final HSSingleSpotCubit singleSpotCubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HSUserTileUp(
          user: singleSpotCubit.state.spot.author!,
          width: screenWidth / 2,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Spacer(),
              Column(
                children: [
                  _AnimatedActionButton(
                    onTap: singleSpotCubit.likeDislikeSpot,
                    onLongPress: () {
                      navi.pushPage(
                          page: UserProfileMultipleProvider(
                        type: HSUserProfileMultipleType.likes,
                        spotID: singleSpotCubit.spotID,
                      ));
                    },
                    selector: (state) => state.isSpotLiked,
                    activeIcon: FontAwesomeIcons.solidHeart,
                    inactiveIcon: FontAwesomeIcons.heart,
                    loadingStatus: HSSingleSpotStatus.liking,
                    delay: 450.ms,
                  ),
                  const _Counter(_CounterType.likes),
                ],
              ),
              Column(
                children: [
                  _AnimatedActionButton(
                    onTap: () => showModalBottomSheet(
                      context: app.context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BlocProvider(
                          create: (context) => HSSingleSpotCommentsCubit(
                              spotID: singleSpotCubit.spotID),
                          child: const SingleSpotCommentsSection()),
                    ),
                    selector: (state) => state.isCommentSectionVisible,
                    activeIcon: FontAwesomeIcons.solidComment,
                    inactiveIcon: FontAwesomeIcons.comment,
                    loadingStatus: HSSingleSpotStatus.commenting,
                    delay: 500.ms,
                  ),
                  const _Counter(_CounterType.comments),
                ],
              ),
              Column(
                children: [
                  _AnimatedActionButton(
                    onTap: singleSpotCubit.saveUnsaveSpot,
                    selector: (state) => state.isSpotSaved,
                    activeIcon: FontAwesomeIcons.solidBookmark,
                    inactiveIcon: FontAwesomeIcons.bookmark,
                    loadingStatus: HSSingleSpotStatus.saving,
                    onLongPress: singleSpotCubit.saveOnLongPress,
                    delay: 550.ms,
                  ),
                  const _Counter(_CounterType.saves),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _CounterType { likes, comments, saves }

class _Counter extends StatelessWidget {
  const _Counter(this.type);

  final _CounterType type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSSingleSpotCubit, HSSingleSpotState>(
      builder: (context, state) {
        final String value;
        switch (type) {
          case _CounterType.likes:
            value = state.spot.formattedLikesCount;
            break;
          case _CounterType.comments:
            value = state.spot.formattedCommentsCount;
            break;
          case _CounterType.saves:
            value = state.spot.formattedSavesCount;
            break;
        }
        return Text(value, style: const TextStyle(fontSize: 12.0));
      },
    );
  }
}

class _AnimatedActionButton extends StatelessWidget {
  const _AnimatedActionButton({
    required this.onTap,
    required this.selector,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.loadingStatus,
    required this.delay,
    this.onLongPress,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool Function(HSSingleSpotState) selector;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final HSSingleSpotStatus loadingStatus;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress?.call();
        },
        onTap: () {
          HapticFeedback.lightImpact(); // Adds slight vibration
          onTap();
        },
        child: BlocSelector<HSSingleSpotCubit, HSSingleSpotState, bool>(
          selector: selector,
          builder: (context, isActive) {
            return Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? appTheme.mainColor : null,
            )
                .animate(
                  onPlay: (controller) => controller.forward(),
                )
                .fadeIn(duration: 300.ms, delay: delay)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                );
          },
        ),
      ),
    );
  }
}
