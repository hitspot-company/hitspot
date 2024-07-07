import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/home/main/cubit/hs_home_cubit.dart';
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<HSHomeCubit>(context);
    Completer<GoogleMapController> mapController = homeCubit.mapController;
    return HSScaffold(
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
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: HSUserAvatar(
                          radius: 30.0, imageUrl: currentUser.avatarUrl),
                      onPressed: () => navi.toUser(
                        userID: currentUser.uid!,
                      ),
                    ),
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
                      style: textTheme.headlineMedium!.hintify),
                  floating: true,
                  pinned: true,
                ),
                const SliverToBoxAdapter(
                  child: Gap(16.0),
                ),
                const SliverAppBar(
                  titleSpacing: 0.0,
                  automaticallyImplyLeading: false,
                  surfaceTintColor: Colors.transparent,
                  stretch: true,
                  title: HSSearchBar(height: 52.0),
                  centerTitle: true,
                ),
                const Gap(32.0).toSliver,
                SizedBox(
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
                            MapProvider(initialCameraPosition: currentPosition),
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
                ).toSliver,
                if (trendingBoards.isNotEmpty)
                  SliverMainAxisGroup(
                    slivers: [
                      const Gap(32.0).toSliver,
                      Text("Trending Boards", style: textTheme.headlineMedium)
                          .toSliver,
                      const Gap(16.0).toSliver,
                      SliverToBoxAdapter(
                        child: _TrendingBoardsBuilder(
                          isLoading: isLoading,
                          trendingBoards: trendingBoards,
                        ),
                      ),
                    ],
                  ),
                const Gap(32.0).toSliver,
                if (!isLoading && homeCubit.state.nearbySpots.isNotEmpty)
                  SliverMainAxisGroup(
                    slivers: [
                      Text("Nearby Spots", style: textTheme.headlineMedium)
                          .toSliver,
                      const Gap(16.0).toSliver,
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
                  HSSpotsGrid.loading(isSliver: true),
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
            return HSShimmerBox(width: (index % 3 + 2) * 60, height: null);
          }
          final board = trendingBoards[index];
          return GestureDetector(
            onTap: () => navi.toBoard(boardID: board.id!, title: board.title),
            child: HSBoardTile(
              board: board,
              width: (index % 3 + 2) * 80,
            ),
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
        // Positioned(
        //   bottom: 8.0,
        //   left: 16.0,
        //   right: 16.0,
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(8.0),
        //     child: Container(
        //       color: Colors.white,
        //       padding: const EdgeInsets.all(4.0),
        //       child: AutoSizeText(
        //         board.title!,
        //         style: textTheme.headlineMedium,
        //         maxLines: 1,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
