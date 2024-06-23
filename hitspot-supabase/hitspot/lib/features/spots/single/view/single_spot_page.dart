import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/boards/single/view/single_board_page.dart';
import 'package:hitspot/features/spots/single/cubit/hs_single_spot_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_tile.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class SingleSpotPage extends StatelessWidget {
  const SingleSpotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final singleSpotCubit = BlocProvider.of<HSSingleSpotCubit>(context);
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
      ),
      body: BlocBuilder<HSSingleSpotCubit, HsSingleSpotState>(
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.spot != current.spot,
        builder: (context, state) {
          final status = state.status;
          if (status == HSSingleSpotStatus.loading) {
            return const HSLoadingIndicator();
          } else if (status == HSSingleSpotStatus.error) {
            return const Center(child: Text('Error fetching spot'));
          }
          final spot = singleSpotCubit.state.spot;
          final imagesCount = spot.images?.length ?? 0;
          return CustomScrollView(
            slivers: [
              Text(
                "${spot.title}",
                style: textTheme.displayMedium,
              ).toSliver,
              const Gap(24.0).toSliver,
              HSImage(
                imageUrl: spot.images?.first,
                height: 300.0,
                width: screenWidth,
                borderRadius: BorderRadius.circular(16.0),
              ).toSliver,
              const Gap(16.0).toSliver,
              AutoSizeText(
                "${spot.address}",
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                maxLines: 2,
              ).toSliver,
              const Gap(32.0).toSliver,
              Text(spot.description!, style: const TextStyle(fontSize: 16.0))
                  .toSliver,
              const Gap(32.0).toSliver,
              Row(
                children: [
                  HsUserTile(
                    user: spot.author!,
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: singleSpotCubit.likeDislikeSpot,
                        child: BlocSelector<HSSingleSpotCubit,
                            HsSingleSpotState, bool>(
                          selector: (state) => state.isSpotLiked,
                          builder: (context, isSpotLiked) {
                            if (singleSpotCubit.state.status ==
                                HSSingleSpotStatus.liking) {
                              return const HSLoadingIndicator(size: 24.0);
                            }
                            if (isSpotLiked) {
                              return Icon(FontAwesomeIcons.solidHeart,
                                  color: appTheme.mainColor);
                            }
                            return const Icon(FontAwesomeIcons.heart);
                          },
                        ),
                      ),
                      const Icon(FontAwesomeIcons.comment),
                      GestureDetector(
                        onTap: singleSpotCubit.saveUnsaveSpot,
                        child: BlocSelector<HSSingleSpotCubit,
                            HsSingleSpotState, bool>(
                          selector: (state) => state.isSpotSaved,
                          builder: (context, isSpotSaved) {
                            if (singleSpotCubit.state.status ==
                                HSSingleSpotStatus.saving) {
                              return const HSLoadingIndicator(size: 24.0);
                            }
                            if (isSpotSaved) {
                              return Icon(FontAwesomeIcons.solidBookmark,
                                  color: appTheme.mainColor);
                            }
                            return const Icon(FontAwesomeIcons.bookmark);
                          },
                        ),
                      ),
                    ],
                  )),
                ],
              ).toSliver,
              const Gap(32.0).toSliver,
              // TODO: Style the map in dark colors
              _MapView(singleSpotCubit: singleSpotCubit).toSliver,
              const Gap(32.0).toSliver,
              SliverList.separated(
                itemCount: imagesCount - 1,
                separatorBuilder: (context, index) => const Gap(16.0),
                itemBuilder: (context, index) => HSImage(
                  imageUrl: spot.images?[index + 1],
                  height: 300.0,
                  width: screenWidth,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              const Gap(32.0).toSliver,
            ],
          );
        },
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({
    required this.singleSpotCubit,
  });

  final HSSingleSpotCubit singleSpotCubit;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HSSingleSpotCubit, HsSingleSpotState, bool>(
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
          );
        }
        return const SizedBox();
      },
    );
  }
}
