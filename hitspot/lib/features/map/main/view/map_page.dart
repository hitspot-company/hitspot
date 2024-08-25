import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/main/cubit/hs_map_cubit.dart';
import 'package:hitspot/widgets/auth/hs_text_prompt.dart';
import 'package:hitspot/widgets/hs_icon_prompt.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/map/hs_google_map.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  final appBarHeight = 120.0;
  final persistentHeaderHeight = 120.0;

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
          BlocBuilder<HSMapCubit, HSMapState>(
            buildWhen: (previous, current) =>
                previous.selectedSpot != current.selectedSpot ||
                previous.spotsInView != current.spotsInView,
            builder: (context, currentState) {
              final isSelected = currentState.currentlySelectedSpot != null;
              return ExpandableBottomSheet(
                key: mapCubit.sheetKey,
                enableToggle: true,
                onIsContractedCallback: mapCubit.updateSheetExpansionStatus,
                onIsExtendedCallback: mapCubit.updateSheetExpansionStatus,
                background: BlocSelector<HSMapCubit, HSMapState, List<Marker>>(
                    selector: (state) => state.markersInView,
                    builder: (context, markersInView) => HSGoogleMap(
                          fortyFiveDegreeImageryEnabled: true,
                          key: mapCubit.mapKey,
                          initialCameraPosition: CameraPosition(
                            zoom: 16.0,
                            target: mapCubit.state.cameraPosition ??
                                const LatLng(0.0, 0.0),
                          ),
                          myLocationButtonEnabled: true,
                          myLocationButtonCallback: mapCubit.resetPosition,
                          onMapCreated: mapCubit.onMapCreated,
                          onCameraIdle: mapCubit.onCameraIdle,
                          markers: Set.from(markersInView),
                          onCameraMove: (CameraPosition position) {
                            mapCubit.toggleIsMoving(true);
                          },
                          onTap: (argument) => mapCubit.clearSelectedSpot(),
                        )),
                persistentHeader: _PersistentHeader(
                    isSelected: isSelected,
                    persistentHeaderHeight: persistentHeaderHeight),
                expandableContent: _ExpandableContent(
                    isSelected: isSelected,
                    expandedHeight: expandedHeight,
                    persistentHeaderHeight: persistentHeaderHeight),
              );
            },
          ),
          _TopBar(appBarHeight: appBarHeight),
          BlocSelector<HSMapCubit, HSMapState, HSSpot?>(
            selector: (state) => state.currentlySelectedSpot,
            builder: (context, spot) {
              if (spot != null) {
                return _InfoWindow(spot: spot);
              }
              return const SizedBox();
            },
          )
        ],
      ),
    );
  }
}

class _ExpandableContent extends StatelessWidget {
  const _ExpandableContent(
      {required this.isSelected,
      required this.expandedHeight,
      required this.persistentHeaderHeight});

  final bool isSelected;
  final double expandedHeight, persistentHeaderHeight;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return const SizedBox();
    }
    return Container(
      height: expandedHeight - persistentHeaderHeight,
      color: currentTheme.scaffoldBackgroundColor,
      child: BlocBuilder<HSMapCubit, HSMapState>(
        buildWhen: (previous, current) =>
            previous.spotsInView != current.spotsInView ||
            previous.selectedSpot != current.selectedSpot,
        builder: (context, state) {
          final spots = state.spotsInView;
          final selectedSpot = state.currentlySelectedSpot;
          HSDebugLogger.logInfo(
              "Selected spot changed: ${selectedSpot?.title}");
          if (spots.isEmpty) {
            return const HSIconPrompt(
                message: "No spots in the area.",
                iconData: FontAwesomeIcons.mapPin);
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
              return HSBetterSpotTile(
                onTap: (p0) => navi.toSpot(sid: p0!.sid!),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                borderRadius: BorderRadius.circular(20.0),
                spot: spot,
                height: 120,
              );
            },
          );
        },
      ),
    );
  }
}

class _PersistentHeader extends StatelessWidget {
  const _PersistentHeader(
      {required this.isSelected, required this.persistentHeaderHeight});

  final bool isSelected;
  final double persistentHeaderHeight;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return const SizedBox();
    }
    return BlocBuilder<HSMapCubit, HSMapState>(
      buildWhen: (previous, current) =>
          previous.spotsInView != current.spotsInView ||
          previous.status != current.status ||
          previous.isMoving != current.isMoving,
      builder: (context, state) {
        final int spotsCount = state.spotsInView.length;
        final bool isLoading = state.status == HSMapStatus.fetchingSpots;
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 4.0),
                  child: SizedBox(
                    width: 128.0,
                    child: Divider(thickness: 4),
                  ),
                ),
                const Gap(4.0),
                if (isLoading)
                  const HSShimmerBox(width: 128, height: 24.0)
                else if (state.spotsInView.isEmpty)
                  const _CreateSpotPrompt()
                else
                  HSTextPrompt(
                          prompt: "Spots in the area: $spotsCount \n",
                          pressableText: "Show",
                          promptColor: app.theme.mainColor,
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                          ),
                          onTap: null)
                      .animate()
                      .fadeIn(duration: 400.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoWindow extends StatelessWidget {
  const _InfoWindow({required this.spot});

  final HSSpot spot;

  @override
  Widget build(BuildContext context) {
    return Positioned(
            bottom: 32.0,
            left: 16.0,
            right: 16.0,
            child: GestureDetector(
              onTap: () => navi.toSpot(sid: spot.sid!),
              child: SizedBox(
                height: 240.0,
                width: screenWidth,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
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
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
            ))
        .animate()
        .fadeIn(duration: 400.ms)
        .slide(duration: 100.ms, begin: const Offset(0, 1));
  }
}

class _CreateSpotPrompt extends StatelessWidget {
  const _CreateSpotPrompt();

  @override
  Widget build(BuildContext context) {
    return HSTextPrompt(
            prompt: "No spots in the area.\n",
            pressableText: "CREATE",
            promptColor: app.theme.mainColor,
            textStyle: const TextStyle(
              fontSize: 18.0,
            ),
            onTap: navi.toCreateSpot)
        .animate()
        .fadeIn(duration: 400.ms);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.appBarHeight = 120.0});
  final double appBarHeight;

  @override
  Widget build(BuildContext context) {
    final mapCubit = BlocProvider.of<HSMapCubit>(context);

    return Positioned(
      top: 0.0,
      child: Container(
        width: screenWidth,
        height: appBarHeight,
        decoration: BoxDecoration(
          color: app.currentTheme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: BlocSelector<HSMapCubit, HSMapState, ExpansionStatus>(
            selector: (state) => state.sheetExpansionStatus,
            builder: (context, state) {
              final isExpanded =
                  mapCubit.sheetStatus == ExpansionStatus.expanded;
              final icon = isExpanded ? Icons.close : backIcon.icon;
              final titleText = isExpanded ? "Fetched Spots" : "";
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(icon,
                          color: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.color ??
                              Colors.white),
                      onPressed: mapCubit.defaultButtonCallback,
                    ).animate().fade(),
                    if (titleText.isNotEmpty)
                      Text(
                        titleText,
                        style: textTheme.headlineSmall,
                      ).animate().fade(),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => mapCubit.searchLocation(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
