import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/main/cubit/hs_map_cubit.dart';
import 'package:hitspot/features/spots/single/view/single_spot_provider.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:page_transition/page_transition.dart';

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
          BlocSelector<HSMapCubit, HSMapState, HSSpot?>(
            selector: (state) => state.currentlySelectedSpot,
            builder: (context, selectedSpot) {
              final isSelected = selectedSpot != null;
              return ExpandableBottomSheet(
                key: mapCubit.sheetKey,
                enableToggle: true,
                onIsContractedCallback: mapCubit.updateSheetExpansionStatus,
                onIsExtendedCallback: mapCubit.updateSheetExpansionStatus,
                background: BlocSelector<HSMapCubit, HSMapState, List<Marker>>(
                  selector: (state) => state.markersInView,
                  builder: (context, markersInView) => GoogleMap(
                    // style: TODO: Implement style like this,
                    fortyFiveDegreeImageryEnabled: true,
                    key: mapCubit.mapKey,
                    initialCameraPosition: CameraPosition(
                      zoom: 16.0,
                      target: mapCubit.state.cameraPosition ?? LatLng(0.0, 0.0),
                    ),
                    onMapCreated: mapCubit.onMapCreated,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    onCameraIdle: mapCubit.onCameraIdle,
                    markers: Set.from(markersInView),
                    onCameraMove: (CameraPosition position) {
                      mapCubit.toggleIsMoving(true);
                    },
                    onTap: (argument) => mapCubit.clearSelectedSpot(),
                  ),
                ),
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
                return const _InfoWindow();
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
      {super.key,
      required this.isSelected,
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
      {super.key,
      required this.isSelected,
      required this.persistentHeaderHeight});

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
                else
                  Text("Found $spotsCount spots",
                      style: textTheme.headlineSmall),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoWindow extends StatelessWidget {
  const _InfoWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final mapCubit = BlocProvider.of<HSMapCubit>(context);
    return Positioned(
      bottom: 32.0,
      left: 16.0,
      right: 16.0,
      child: HSBetterSpotTile(
        borderRadius: BorderRadius.circular(14.0),
        spot: mapCubit.state.currentlySelectedSpot!,
        onTap: (p0) => navi.pushTransition(
            PageTransitionType.scale, SingleSpotProvider(spotID: p0!.sid!)),
        height: 120.0,
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slide(duration: 100.ms, begin: const Offset(0, 1));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({super.key, this.appBarHeight = 120.0});

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
          color: currentTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
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
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: HSAppBar(
                  enableDefaultBackButton: true,
                  defaultBackButtonCallback: mapCubit.defaultButtonCallback,
                  titleText: titleText,
                  right: IconButton(
                    icon: const Icon(FontAwesomeIcons.magnifyingGlass),
                    onPressed: () => mapCubit.searchLocation(context),
                  ),
                  defaultButtonBackIcon: icon,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
