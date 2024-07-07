import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_cubit.dart';
import 'package:hitspot/features/spots/single/view/single_spot_image_full_screen_page.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_tile.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

import 'package:flutter_animate/flutter_animate.dart';

class SingleSpotPage extends StatelessWidget {
  const SingleSpotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final singleSpotCubit = BlocProvider.of<HSSingleSpotCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
        right: BlocSelector<HSSingleSpotCubit, HSSingleSpotState, bool>(
          selector: (state) => state.isAuthor,
          builder: (context, isAuthor) {
            if (!isAuthor) return const SizedBox();
            return IconButton(
              icon: const Icon(FontAwesomeIcons.ellipsisVertical),
              onPressed: singleSpotCubit.showBottomSheet,
            )
                .animate()
                .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
          },
        ),
      ),
      body: BlocBuilder<HSSingleSpotCubit, HSSingleSpotState>(
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.spot != current.spot,
        builder: (context, state) {
          final status = state.status;
          if (status == HSSingleSpotStatus.loading) {
            return const HSLoadingIndicator()
                .animate()
                .fadeIn(duration: 300.ms, curve: Curves.easeInOut);
          } else if (status == HSSingleSpotStatus.error) {
            return const Center(child: Text('Error fetching spot'))
                .animate()
                .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                .slide(begin: const Offset(0, 0.1), end: const Offset(0, 0));
          }
          final spot = singleSpotCubit.state.spot;
          final imagesCount = spot.images?.length ?? 0;
          return CustomScrollView(
            slivers: [
              Text(
                "${spot.title}",
                style: textTheme.displayMedium,
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
                "${spot.address}",
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
    );
  }
}

class _AnimatedImageTile extends StatelessWidget {
  const _AnimatedImageTile({required this.imageUrl, this.height = 300.0});

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navi.pushPage(
          page: SingleSpotImageFullScreenPage(imageUrl: imageUrl)),
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
              child: GoogleMap(
                onMapCreated: (controller) =>
                    controller.setMapStyle(appTheme.mapStyle),
                onTap: (argument) => app.locationRepository.launchMaps(
                  coords: spotLocation,
                  description: singleSpotCubit.state.spot.address!,
                  title: singleSpotCubit.state.spot.title!,
                ),
                cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                    southwest: spotLocation, northeast: spotLocation)),
                initialCameraPosition: CameraPosition(
                  target: spotLocation,
                  zoom: 16.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('1'),
                    position: spotLocation,
                  )
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
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
  const _AnimatedTagsBuilder({super.key});

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
        HsUserTile(
          user: singleSpotCubit.state.spot.author!,
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 400.ms)
            .slideX(begin: -0.2, end: 0),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AnimatedActionButton(
                onTap: singleSpotCubit.likeDislikeSpot,
                selector: (state) => state.isSpotLiked,
                activeIcon: FontAwesomeIcons.solidHeart,
                inactiveIcon: FontAwesomeIcons.heart,
                loadingStatus: HSSingleSpotStatus.liking,
                delay: 450.ms,
              ),
              Icon(FontAwesomeIcons.comment)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 500.ms)
                  .scale(
                      begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
              _AnimatedActionButton(
                onTap: singleSpotCubit.saveUnsaveSpot,
                selector: (state) => state.isSpotSaved,
                activeIcon: FontAwesomeIcons.solidBookmark,
                inactiveIcon: FontAwesomeIcons.bookmark,
                loadingStatus: HSSingleSpotStatus.saving,
                delay: 550.ms,
              ),
            ],
          ),
        ),
      ],
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
  });

  final VoidCallback onTap;
  final bool Function(HSSingleSpotState) selector;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final HSSingleSpotStatus loadingStatus;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BlocSelector<HSSingleSpotCubit, HSSingleSpotState, bool>(
        selector: selector,
        builder: (context, isActive) {
          final cubit = BlocProvider.of<HSSingleSpotCubit>(context);
          if (cubit.state.status == loadingStatus) {
            return const HSLoadingIndicator(size: 24.0);
          }
          return Icon(
            isActive ? activeIcon : inactiveIcon,
            color: isActive ? appTheme.mainColor : null,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .fadeIn(duration: 300.ms, delay: delay)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
          // .then(
          //   duration: 300.ms,
          //   begin: const Offset(1, 1),
          //   end: const Offset(1.1, 1.1),
          //   curve: Curves.easeInOut,
          // );
        },
      ),
    );
  }
}

// class SingleSpotPage extends StatelessWidget {
//   const SingleSpotPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final singleSpotCubit = BlocProvider.of<HSSingleSpotCubit>(context);
//     return HSScaffold(
//       appBar: HSAppBar(
//         enableDefaultBackButton: true,
//         right: BlocSelector<HSSingleSpotCubit, HSSingleSpotState, bool>(
//           selector: (state) => state.isAuthor,
//           builder: (context, isAuthor) {
//             if (!isAuthor) return const SizedBox();
//             return IconButton(
//               icon: const Icon(
//                 FontAwesomeIcons.ellipsisVertical,
//               ),
//               onPressed: singleSpotCubit.showBottomSheet,
//             );
//           },
//         ),
//       ),
//       body: BlocBuilder<HSSingleSpotCubit, HSSingleSpotState>(
//         buildWhen: (previous, current) =>
//             previous.status != current.status || previous.spot != current.spot,
//         builder: (context, state) {
//           final status = state.status;
//           if (status == HSSingleSpotStatus.loading) {
//             return const HSLoadingIndicator();
//           } else if (status == HSSingleSpotStatus.error) {
//             return const Center(child: Text('Error fetching spot'));
//           }
//           final spot = singleSpotCubit.state.spot;
//           final imagesCount = spot.images?.length ?? 0;
//           return CustomScrollView(
//             slivers: [
//               Text(
//                 "${spot.title}",
//                 style: textTheme.displayMedium,
//               ).toSliver,
//               const Gap(24.0).toSliver,
//               _ImageTile(
//                 imageUrl: spot.images!.first,
//               ).toSliver,
//               const Gap(16.0).toSliver,
//               AutoSizeText(
//                 "${spot.address}",
//                 style: const TextStyle(fontSize: 14.0, color: Colors.grey),
//                 maxLines: 2,
//               ).toSliver,

//               const _TagsBuilder().toSliver,
//               const Gap(32.0).toSliver,
//               Text(spot.description!, style: const TextStyle(fontSize: 16.0))
//                   .toSliver,
//               const Gap(32.0).toSliver,
//               Row(
//                 children: [
//                   HsUserTile(
//                     user: spot.author!,
//                   ),
//                   Expanded(
//                       child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       GestureDetector(
//                         onTap: singleSpotCubit.likeDislikeSpot,
//                         child: BlocSelector<HSSingleSpotCubit,
//                             HSSingleSpotState, bool>(
//                           selector: (state) => state.isSpotLiked,
//                           builder: (context, isSpotLiked) {
//                             if (singleSpotCubit.state.status ==
//                                 HSSingleSpotStatus.liking) {
//                               return const HSLoadingIndicator(size: 24.0);
//                             }
//                             if (isSpotLiked) {
//                               return Icon(FontAwesomeIcons.solidHeart,
//                                   color: appTheme.mainColor);
//                             }
//                             return const Icon(FontAwesomeIcons.heart);
//                           },
//                         ),
//                       ),
//                       const Icon(FontAwesomeIcons.comment),
//                       GestureDetector(
//                         onTap: singleSpotCubit.saveUnsaveSpot,
//                         child: BlocSelector<HSSingleSpotCubit,
//                             HSSingleSpotState, bool>(
//                           selector: (state) => state.isSpotSaved,
//                           builder: (context, isSpotSaved) {
//                             if (singleSpotCubit.state.status ==
//                                 HSSingleSpotStatus.saving) {
//                               return const HSLoadingIndicator(size: 24.0);
//                             }
//                             if (isSpotSaved) {
//                               return Icon(FontAwesomeIcons.solidBookmark,
//                                   color: appTheme.mainColor);
//                             }
//                             return const Icon(FontAwesomeIcons.bookmark);
//                           },
//                         ),
//                       ),
//                     ],
//                   )),
//                 ],
//               ).toSliver,
//               const Gap(32.0).toSliver,
//               // TODO: Style the map in dark colors
//               _MapView(singleSpotCubit: singleSpotCubit).toSliver,
//               const Gap(32.0).toSliver,
//               SliverList.separated(
//                 itemCount: imagesCount - 1,
//                 separatorBuilder: (context, index) => const Gap(16.0),
//                 itemBuilder: (context, index) => _ImageTile(
//                   imageUrl: spot.images![index + 1],
//                 ),
//               ),
//               const Gap(32.0).toSliver,
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _ImageTile extends StatelessWidget {
//   const _ImageTile({required this.imageUrl, this.height = 300.0});

//   final String imageUrl;
//   final double height;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => navi.pushPage(
//           page: SingleSpotImageFullScreenPage(imageUrl: imageUrl)),
//       child: Hero(
//         tag: imageUrl,
//         child: HSImage(
//           imageUrl: imageUrl,
//           height: height,
//           width: screenWidth,
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//       ),
//     );
//   }
// }

// class _MapView extends StatelessWidget {
//   const _MapView({
//     required this.singleSpotCubit,
//   });

//   final HSSingleSpotCubit singleSpotCubit;

//   @override
//   Widget build(BuildContext context) {
//     return BlocSelector<HSSingleSpotCubit, HSSingleSpotState, bool>(
//       selector: (state) =>
//           state.spot.latitude != null && state.spot.longitude != null,
//       builder: (context, isSpotLocationLoaded) {
//         if (isSpotLocationLoaded) {
//           final LatLng spotLocation = singleSpotCubit.spotLocation!;
//           return SizedBox(
//             height: 200.0,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16.0),
//               child: GoogleMap(
//                 onMapCreated: (controller) =>
//                     controller.setMapStyle(appTheme.mapStyle),
//                 onTap: (argument) => app.locationRepository.launchMaps(
//                   coords: spotLocation,
//                   description: singleSpotCubit.state.spot.address!,
//                   title: singleSpotCubit.state.spot.title!,
//                 ),
//                 cameraTargetBounds: CameraTargetBounds(LatLngBounds(
//                     southwest: spotLocation, northeast: spotLocation)),
//                 initialCameraPosition: CameraPosition(
//                   target: spotLocation,
//                   zoom: 16.0,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: const MarkerId('1'),
//                     position: spotLocation,
//                   )
//                 },
//                 myLocationEnabled: false,
//                 myLocationButtonEnabled: false,
//               ),
//             ),
//           );
//         }
//         return const SizedBox();
//       },
//     );
//   }
// }

// class _TagsBuilder extends StatelessWidget {
//   const _TagsBuilder({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<HSSingleSpotCubit, HSSingleSpotState>(
//       builder: (context, state) {
//         final tags = state.tags;
//         if (tags.isEmpty) {
//           return const SizedBox();
//         }
//         return Padding(
//           padding: const EdgeInsets.only(top: 16.0),
//           child: Wrap(
//             children: tags
//                 .map(
//                   (tag) => GestureDetector(
//                     onTap: () => navi.toTagsExplore(tag.value!),
//                     child: Chip(
//                       side: BorderSide.none,
//                       label: Text("#${tag.value}"),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//         );
//       },
//     );
//   }
// }
