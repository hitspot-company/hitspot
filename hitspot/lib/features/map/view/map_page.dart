import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/cubit/hs_map_cubit.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  final appBarHeight = 120.0;
  final persistentHeaderHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final double expandedHeight = screenHeight - appBarHeight;
    final mapCubit = BlocProvider.of<HSMapCubit>(context);
    return HSScaffold(
      sidePadding: 0.0,
      topSafe: false,
      bottomSafe: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ExpandableBottomSheet(
            enableToggle: true,
            background: GoogleMap(
              initialCameraPosition: CameraPosition(
                zoom: 16.0,
                target: mapCubit.state.cameraPosition!,
              ),
              onMapCreated: mapCubit.onMapCreated,
              myLocationButtonEnabled: false,
              onCameraIdle: mapCubit.onCameraIdle,
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
              child: BlocSelector<HSMapCubit, HSMapState, int>(
                selector: (state) => state.spotsInView.length,
                builder: (context, spotsCount) {
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
                      Text("Found $spotsCount spots",
                          style: textTheme.headlineSmall),
                    ],
                  ));
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: spots.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Gap(16.0);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return HSBetterSpotTile(
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
                  child: HSAppBar(
                    enableDefaultBackButton: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
