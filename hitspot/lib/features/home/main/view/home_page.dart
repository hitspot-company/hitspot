import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/connectivity/bloc/hs_connectivity_bloc.dart';
import 'package:hitspot/features/home/main/cubit/hs_home_cubit.dart';
import 'package:hitspot/features/map/main/view/map_provider.dart';
import 'package:hitspot/features/spots/create/map/cubit/hs_choose_location_cubit.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/map/hs_google_map.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
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
      defaultBottombarEnabled: true,
      body: BlocSelector<HSHomeCubit, HSHomeState, HSHomeStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          final isLoading = status == HSHomeStatus.loading;
          return RefreshIndicator(
            onRefresh: homeCubit.handleRefresh,
            color: HSTheme.instance.mainColor,
            backgroundColor: app.currentTheme.cardColor,
            strokeWidth: 3.0,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0.0,
                  surfaceTintColor: Colors.transparent,
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
                const Gap(16.0).toSliver,
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: BlocSelector<HSConnectivityLocationBloc,
                          HSConnectivityLocationState, Position?>(
                        selector: (state) => state.location,
                        builder: (context, currentPosition) {
                          if (currentPosition != null) {
                            homeCubit.animateCameraToNewLatLng(
                                currentPosition.toLatLng);
                          }
                          if (isLoading) {
                            return HSShimmerBox(
                                width: screenWidth, height: 240.0);
                          }
                          return GestureDetector(
                            onTap: () => navi.pushTransition(
                              PageTransitionType.fade,
                              const MapProvider(),
                            ),
                            child: AbsorbPointer(
                              absorbing: true,
                              child: HSGoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: currentPosition?.toLatLng ??
                                      const LatLng(0, 0),
                                  zoom: 14.0,
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  if (!mapController.isCompleted) {
                                    mapController.complete(controller);
                                  }
                                },
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
                const _HomeGridBuilder(type: _HomeGridBuilderType.nearbySpots),
                const _HomeGridBuilder(
                    type: _HomeGridBuilderType.trendingBoards),
                const _HomeGridBuilder(
                    type: _HomeGridBuilderType.trendingSpots),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HSBoardGridItem extends StatelessWidget {
  final HSBoard board;

  const HSBoardGridItem({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navi.toBoard(boardID: board.id!, title: board.title!),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: board.color ?? Theme.of(context).cardColor,
          ),
          child: Stack(
            children: [
              if (board.image != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      board.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      board.title!,
                      style: textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _HomeGridBuilderType { nearbySpots, trendingBoards, trendingSpots }

class _HomeGridBuilder extends StatelessWidget {
  const _HomeGridBuilder({
    this.defaultBuilderHeight = 140.0,
    required this.type,
  });

  final double defaultBuilderHeight;
  final _HomeGridBuilderType type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSHomeCubit, HSHomeState>(
      buildWhen: (previous, current) {
        switch (type) {
          case _HomeGridBuilderType.nearbySpots:
            return previous.nearbySpots != current.nearbySpots ||
                previous.status != current.status;
          case _HomeGridBuilderType.trendingBoards:
            return previous.trendingBoards != current.trendingBoards ||
                previous.status != current.status;
          case _HomeGridBuilderType.trendingSpots:
            return previous.trendingSpots != current.trendingSpots ||
                previous.status != current.status;
        }
      },
      builder: (context, state) {
        final isLoading = state.status == HSHomeStatus.loading;
        late final List elements;
        late final String title, subtitle;
        switch (type) {
          case _HomeGridBuilderType.nearbySpots:
            elements = state.nearbySpots;
            title = "Nearby Spots";
            subtitle = "Look around you";
            break;
          case _HomeGridBuilderType.trendingBoards:
            elements = state.trendingBoards;
            title = "Trending Boards";
            subtitle = "The best collections of spots";
            break;
          case _HomeGridBuilderType.trendingSpots:
            elements = state.trendingSpots;
            title = "Trending Spots";
            subtitle = "Our picks for you!";
            break;
        }
        if (isLoading) {
          return SliverMainAxisGroup(
            slivers: [
              const Gap(32.0).toSliver,
              HSShimmerBox(width: screenWidth / 3, height: 40.0).toSliver,
              const Gap(8.0).toSliver,
              HSShimmerBox(width: screenWidth / 3 - 10.0, height: 20.0)
                  .toSliver,
              const Gap(16.0).toSliver,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280.0,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                            crossAxisCount: 2),
                    itemCount: 10,
                    itemBuilder: (context, index) =>
                        const HSShimmerBox(width: 40.0, height: 40.0),
                  ),
                ),
              ),
            ],
          );
        }
        if (elements.isEmpty) {
          return const SizedBox().toSliver;
        }
        final builderHeight = elements.length < 2
            ? defaultBuilderHeight
            : defaultBuilderHeight * 2;
        final crossAxisCount = elements.length < 2 ? 1 : 2;
        return SliverMainAxisGroup(
          slivers: [
            const Gap(32.0).toSliver,
            Text(title, style: textTheme.headlineMedium)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1))
                .toSliver,
            Text(subtitle)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1))
                .toSliver,
            const Gap(8.0).toSliver,
            SliverToBoxAdapter(
              child: SizedBox(
                height: builderHeight,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      crossAxisCount: crossAxisCount),
                  itemCount: elements.length,
                  itemBuilder: (context, index) {
                    if (type == _HomeGridBuilderType.trendingBoards) {
                      return HSBoardGridItem(board: elements[index]);
                    } else {
                      return AnimatedSpotTile(
                          spot: elements[index], index: index);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
