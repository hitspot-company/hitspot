import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cubit/hs_map_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

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
        fit: StackFit.expand,
        children: [
          ExpandableBottomSheet(
            key: mapCubit.sheetKey,
            enableToggle: true,
            onIsContractedCallback: mapCubit.updateSheetExpansionStatus,
            onIsExtendedCallback: mapCubit.updateSheetExpansionStatus,
            background: BlocSelector<HSMapCubit, HSMapState, List<Marker>>(
              selector: (state) => state.markersInView,
              builder: (context, markersInView) => GoogleMap(
                initialCameraPosition: CameraPosition(
                  zoom: 16.0,
                  target: mapCubit.state.cameraPosition!,
                ),
                onMapCreated: mapCubit.onMapCreated,
                myLocationButtonEnabled: false,
                onCameraIdle: mapCubit.onCameraIdle,
                markers: Set.from(markersInView),
              ),
            ),
            persistentHeader: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: currentTheme.scaffoldBackgroundColor,
              ),
              height: persistentHeaderHeight,
              width: screenWidth,
              child: BlocBuilder<HSMapCubit, HSMapState>(
                buildWhen: (previous, current) =>
                    previous.spotsInView != current.spotsInView ||
                    previous.status != current.status,
                builder: (context, state) {
                  final int spotsCount = state.spotsInView.length;
                  final bool isLoading =
                      state.status == HSMapStatus.fetchingSpots;
                  return Center(
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
                  );
                },
              ),
            ),
            expandableContent: Container(
                height: expandedHeight - persistentHeaderHeight,
                color: currentTheme.scaffoldBackgroundColor,
                child: BlocSelector<HSMapCubit, HSMapState, List<HSSpot>>(
                  selector: (state) => state.spotsInView,
                  builder: (context, spots) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: spots.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Gap(16.0);
                      },
                      itemBuilder: (BuildContext context, int index) {
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
                )),
          ),
          Positioned(
            top: 0.0,
            child: Container(
              width: screenWidth,
              height: appBarHeight,
              color: Colors.white,
              child: Center(
                child: SafeArea(
                    child:
                        BlocSelector<HSMapCubit, HSMapState, ExpansionStatus>(
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
                      defaultBackButtonCallback: mapCubit.defaultButtonCallback,
                      titleText: titleText,
                      defaultButtonBackIcon: icon,
                    );
                  },
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
