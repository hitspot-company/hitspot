import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/main/cubit/hs_map_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/map/hs_spot_info_window.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:newton_particles/newton_particles.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  final appBarHeight = 120.0;
  final persistentHeaderHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final double expandedHeight = screenHeight;
    final mapCubit = BlocProvider.of<HSMapCubit>(context);
    return HSScaffold(
      sidePadding: 0.0,
      topSafe: false,
      bottomSafe: false,
      body: Stack(
        children: [
          ExpandableBottomSheet(
            key: mapCubit.sheetKey,
            enableToggle: true,
            onIsContractedCallback: mapCubit.updateSheetExpansionStatus,
            onIsExtendedCallback: mapCubit.updateSheetExpansionStatus,
            background: BlocSelector<HSMapCubit, HSMapState, List<Marker>>(
              selector: (state) => state.markersInView,
              builder: (context, markersInView) => GoogleMap(
                key: mapCubit.mapKey,
                initialCameraPosition: CameraPosition(
                  zoom: 16.0,
                  target: mapCubit.state.cameraPosition!,
                ),
                onMapCreated: mapCubit.onMapCreated,
                onCameraIdle: mapCubit.onCameraIdle,
                markers: Set.from(markersInView),
                onCameraMove: (CameraPosition position) {
                  mapCubit.hideInfoWindow();
                  mapCubit.toggleIsMoving(true);
                },
                onTap: (LatLng latLng) => mapCubit.hideInfoWindow(),
              ),
            ),
            persistentHeader: BlocBuilder<HSMapCubit, HSMapState>(
              buildWhen: (previous, current) =>
                  previous.spotsInView != current.spotsInView ||
                  previous.status != current.status ||
                  previous.isMoving != current.isMoving,
              builder: (context, state) {
                final int spotsCount = state.spotsInView.length;
                final bool isLoading =
                    state.status == HSMapStatus.fetchingSpots;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: currentTheme.scaffoldBackgroundColor,
                  ),
                  height: persistentHeaderHeight,
                  width: screenWidth,
                  child: Center(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 4.0),
                          child: SizedBox(
                            width: 128.0,
                            child: Divider(thickness: 4),
                          ),
                        ),
                        const Gap(4.0),
                        if (isLoading)
                          const HSShimmerBox(width: 128, height: 24.0)
                        else
                          Text("Found $spotsCount spots",
                              style: textTheme.headlineSmall),
                      ],
                    ),
                  ),
                );
              },
            ),
            expandableContent: Container(
              height: expandedHeight - persistentHeaderHeight,
              color: currentTheme.scaffoldBackgroundColor,
              child: BlocBuilder<HSMapCubit, HSMapState>(
                buildWhen: (previous, current) =>
                    previous.spotsInView != current.spotsInView ||
                    previous.selectedSpot != current.selectedSpot,
                builder: (context, state) {
                  final spots = state.spotsInView;
                  final selectedSpot = state.selectedSpot;
                  HSDebugLogger.logInfo(
                      "Selected spot changed: ${selectedSpot?.title}");
                  if (spots.isEmpty) {
                    return const Center(
                      child: Text("No spots in the area."),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: spots.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Gap(16.0);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final spot = spots[index];
                      if (spot.sid == selectedSpot?.sid) {
                        return SizedBox(
                          height: 200.0,
                          width: screenWidth,
                          child: Newton(
                            activeEffects: [
                              PulseEffect(
                                particleConfiguration: ParticleConfiguration(
                                  shape: CircleShape(),
                                  size: const Size(5, 5),
                                  color: const SingleParticleColor(
                                      color: Colors.white),
                                ),
                                effectConfiguration:
                                    const EffectConfiguration(),
                              ),
                            ],
                          ),
                          // child: Stack(
                          //   // fit: StackFit.expand,
                          //   children: [
                          //     SizedBox(
                          //       height: 140.0,
                          //       width: screenWidth,
                          //       child: Center(
                          //         child: Newton(
                          //           child: HSBetterSpotTile(
                          //             onTap: (p0) => navi.toSpot(sid: p0!.sid!),
                          //             padding: const EdgeInsets.symmetric(
                          //                 horizontal: 16.0, vertical: 8.0),
                          //             borderRadius: BorderRadius.circular(20.0),
                          //             spot: spots[index],
                          //             height: 120,
                          //           ),
                          //           activeEffects: [
                          //             PulseEffect(
                          //               particleConfiguration:
                          //                   ParticleConfiguration(
                          //                 shape: CircleShape(),
                          //                 size: const Size(5, 5),
                          //                 color: const SingleParticleColor(
                          //                     color: Colors.white),
                          //               ),
                          //               effectConfiguration:
                          //                   const EffectConfiguration(),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        );
                      }
                      return HSBetterSpotTile(
                        onTap: (p0) => navi.toSpot(sid: p0!.sid!),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        borderRadius: BorderRadius.circular(20.0),
                        spot: spots[index],
                        height: 120,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            child: Container(
              width: screenWidth,
              height: appBarHeight,
              color: currentTheme.scaffoldBackgroundColor,
              child: Center(
                child: SafeArea(
                  child: BlocSelector<HSMapCubit, HSMapState, ExpansionStatus>(
                    selector: (state) => state.sheetExpansionStatus,
                    builder: (context, state) {
                      late final IconData icon;
                      late final String? titleText;
                      if (mapCubit.sheetStatus == ExpansionStatus.expanded) {
                        icon = FontAwesomeIcons.xmark;
                        titleText = "Fetched Spots";
                      } else {
                        icon = FontAwesomeIcons.arrowLeft;
                        titleText = "";
                      }
                      return HSAppBar(
                        enableDefaultBackButton: true,
                        defaultBackButtonCallback:
                            mapCubit.defaultButtonCallback,
                        titleText: titleText,
                        right: IconButton(
                          icon: const Icon(FontAwesomeIcons.magnifyingGlass),
                          onPressed: () => mapCubit.searchLocation(context),
                        ),
                        defaultButtonBackIcon: icon,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _getMapHeight() {
  //   RenderBox? renderBoxRed =
  //       _keyGoogleMap?.currentContext?.findRenderObject() as RenderBox?;
  //   final size = renderBoxRed?.size;
  //   return size?.height;
  // }
}
