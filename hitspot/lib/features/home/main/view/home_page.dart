import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/home/main/cubit/hs_home_cubit.dart';
import 'package:hitspot/features/map/clustered/view/clustered_map_page.dart';
import 'package:hitspot/features/map/main/view/map_provider.dart';
import 'package:hitspot/features/spots/create/map/cubit/hs_choose_location_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_search_bar.dart';
import 'package:hitspot/widgets/hs_spots_grid.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:page_transition/page_transition.dart';

import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<HSHomeCubit>(context);
    Completer<GoogleMapController> mapController = homeCubit.mapController;
    return HSScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => navi.pushPage(
            page: const MapPage(
          spots: [
            HSSpot(
              latitude: 40.7128,
              longitude: -74.0060,
              geohash: "dr5reg",
              title: "New York City",
            ),
            HSSpot(
              latitude: 40.7128,
              longitude: -74.0760,
              geohash: "dr5reg",
              title: "New Yoooork",
            ),
            HSSpot(
              latitude: 51.5074,
              longitude: -0.1278,
              geohash: "gcpvj",
              title: "London",
            ),
            HSSpot(
              latitude: 35.6762,
              longitude: 139.6503,
              geohash: "xn76ur",
              title: "Tokyo",
            ),
            HSSpot(
              latitude: -33.8688,
              longitude: 151.2093,
              geohash: "r3gx2f",
              title: "Sydney",
            ),
            HSSpot(
              latitude: 48.8566,
              longitude: 2.3522,
              geohash: "u09tvw",
              title: "Paris",
            ),
            HSSpot(
              latitude: 37.7749,
              longitude: -122.4194,
              geohash: "9q8yyk",
              title: "San Francisco",
            ),
            HSSpot(
              latitude: 55.7558,
              longitude: 37.6173,
              geohash: "ucfu9v",
              title: "Moscow",
            ),
            HSSpot(
              latitude: -22.9068,
              longitude: -43.1729,
              geohash: "75cjm",
              title: "Rio de Janeiro",
            ),
            HSSpot(
              latitude: 1.3521,
              longitude: 103.8198,
              geohash: "w21z7",
              title: "Singapore",
            ),
            HSSpot(
              latitude: 25.2048,
              longitude: 55.2708,
              geohash: "thrn1",
              title: "Dubai",
            ),
          ],
        )),
        child: const Icon(Icons.add),
      ),
      defaultBottombarEnabled: true,
      body: BlocSelector<HSHomeCubit, HSHomeState, HSHomeStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          final isLoading = status == HSHomeStatus.loading;
          final trendingBoards = homeCubit.state.tredingBoards;
          return RefreshIndicator.adaptive(
            onRefresh: homeCubit.handleRefresh,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  surfaceTintColor: Colors.transparent,
                  titleSpacing: 0.0,
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      app.assets.textLogo,
                      height: 30,
                      alignment: Alignment.centerLeft,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.2, end: 0),
                  actions: <Widget>[
                    IconButton(
                      icon: HSUserAvatar(
                          radius: 30.0, imageUrl: currentUser.avatarUrl),
                      onPressed: () => navi.toUser(
                        userID: currentUser.uid!,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.2, end: 0),
                  ],
                  floating: true,
                  pinned: true,
                ),
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: false,
                  titleSpacing: 0.0,
                  title: Text.rich(
                    TextSpan(
                      text: "Hello ",
                      children: [
                        TextSpan(
                            text: currentUser.username,
                            style: textTheme.headlineMedium),
                        TextSpan(
                            text: " ,\nWhere would you like to go?",
                            style: textTheme.headlineLarge!.hintify),
                      ],
                    ),
                    style: textTheme.headlineMedium!.hintify,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  floating: true,
                  pinned: true,
                ),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                SliverToBoxAdapter(
                  child: HSSearchBar(height: 52.0)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1)),
                ),
                const Gap(32.0).toSliver,
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: BlocSelector<HSHomeCubit, HSHomeState, Position?>(
                        selector: (state) => state.currentPosition,
                        builder: (context, currentPosition) {
                          if (currentPosition != null) {
                            homeCubit.animateCameraToNewLatLng(
                                currentPosition.toLatLng);
                          }
                          return GestureDetector(
                            onTap: () => navi.pushTransition(
                              PageTransitionType.fade,
                              MapProvider(
                                  initialCameraPosition: currentPosition),
                            ),
                            child: AbsorbPointer(
                              absorbing: true,
                              child: GoogleMap(
                                onMapCreated: (GoogleMapController controller) {
                                  if (mapController.isCompleted) {
                                    mapController =
                                        Completer<GoogleMapController>();
                                  }
                                  mapController.complete(controller);
                                  app.theme.applyMapDarkStyle(mapController);
                                },
                                myLocationButtonEnabled: false,
                                myLocationEnabled: true,
                                initialCameraPosition: const CameraPosition(
                                  zoom: 16.0,
                                  target: LatLng(0, 0),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                ),
                if (trendingBoards.isNotEmpty)
                  SliverMainAxisGroup(
                    slivers: [
                      const Gap(32.0).toSliver,
                      Text("Trending Boards", style: textTheme.headlineMedium)
                          .animate()
                          .fadeIn(duration: 700.ms)
                          .slideX(begin: -0.2, end: 0)
                          .toSliver,
                      const Gap(16.0).toSliver,
                      SliverToBoxAdapter(
                        child: _TrendingBoardsBuilder(
                          isLoading: isLoading,
                          trendingBoards: trendingBoards,
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .slideX(begin: 0.2, end: 0),
                      ),
                    ],
                  ),
                const Gap(32.0).toSliver,
                if (!isLoading && homeCubit.state.nearbySpots.isNotEmpty)
                  SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Text("Nearby Spots",
                                style: textTheme.headlineMedium)
                            .animate()
                            .fadeIn(duration: 900.ms)
                            .slideX(begin: -0.2, end: 0),
                      ),
                      const SliverToBoxAdapter(
                        child: Gap(16.0),
                      ),
                      BlocSelector<HSHomeCubit, HSHomeState, List<HSSpot>>(
                        selector: (state) => state.nearbySpots,
                        builder: (context, nearbySpots) => HSSpotsGrid(
                          spots: nearbySpots,
                          isSliver: true,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                        ),
                      ),
                    ],
                  )
                else
                  SliverAnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 1000),
                    sliver: HSSpotsGrid.loading(isSliver: true),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrendingBoardsBuilder extends StatelessWidget {
  const _TrendingBoardsBuilder({
    super.key,
    this.height = 300.0,
    required this.isLoading,
    required this.trendingBoards,
  });

  final double height;
  final bool isLoading;
  final List<HSBoard> trendingBoards;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: trendingBoards.length == 1 ? height / 2 : height,
      child: MasonryGridView.count(
        scrollDirection: Axis.horizontal,
        crossAxisCount: trendingBoards.length == 1 ? 1 : 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        itemCount: isLoading ? 16 : trendingBoards.length,
        itemBuilder: (context, index) {
          if (isLoading) {
            return HSShimmerBox(width: (index % 3 + 2) * 60, height: null)
                .animate()
                .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                .shimmer(duration: 1500.ms, color: Colors.white24);
          }
          final board = trendingBoards[index];
          return GestureDetector(
            onTap: () => navi.toBoard(boardID: board.id!, title: board.title),
            child: HSBoardTile(
              board: board,
              width: (index % 3 + 2) * 80,
            ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms).scale(
                begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
          );
        },
      ),
    );
  }
}

class HSBoardTile extends StatelessWidget {
  const HSBoardTile({
    super.key,
    required this.board,
    this.width,
    this.height,
  });

  final HSBoard board;
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HSImage(
          width: width,
          height: height,
          color: board.color ?? appTheme.mainColor,
          borderRadius: BorderRadius.circular(14.0),
          imageUrl: board.image,
          opacity: .8,
        ),
      ],
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 2000.ms, color: Colors.white24)
        .then(delay: 2000.ms);
  }
}
