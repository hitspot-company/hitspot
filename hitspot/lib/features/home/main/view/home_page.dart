import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/home/main/cubit/hs_home_cubit.dart';
import 'package:hitspot/features/spots/create/form/cubit/hs_spot_upload_cubit.dart';
import 'package:hitspot/features/spots/multiple/cubit/hs_multiple_spots_cubit.dart';
import 'package:hitspot/features/theme/bloc/hs_theme_bloc.dart';
import 'package:hitspot/utils/theme/hs_theme.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hitspot/widgets/spot/hs_upload_progress_widget.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_location_repository/hs_location_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:upgrader/upgrader.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<HSHomeCubit>(context);
    return BlocSelector<HSHomeCubit, HSHomeState, HSHomeStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        if (status == HSHomeStatus.updateRequired) {
          return HSScaffold(
            defaultBottombarEnabled: false,
            body: Center(
                child: UpgradeCard(
              upgrader: homeCubit.upgrader,
              onIgnore: homeCubit.updateRefresh,
              onLater: homeCubit.updateRefresh,
            )),
          );
        }
        final isLoading = status == HSHomeStatus.loading;
        return HSScaffold(
          defaultBottombarEnabled: true,
          body: RefreshIndicator(
            onRefresh: () => homeCubit.handleRefresh(true),
            color: HSTheme.instance.mainColor,
            backgroundColor: app.currentTheme.cardColor,
            strokeWidth: 3.0,
            child: CustomScrollView(
              slivers: [
                BlocConsumer<HSSpotUploadCubit, HSSpotUploadState>(
                  listener: (context, state) {
                    if (state.status == HSUploadStatus.success) {
                      homeCubit.handleRefresh();
                      homeCubit.showUploadBar();
                    }
                  },
                  builder: (context, state) {
                    return BlocSelector<HSHomeCubit, HSHomeState, bool>(
                      selector: (state) => state.hideUploadBar,
                      builder: (context, hideUploadBar) {
                        final status = state.status;
                        final bool showUploadBar =
                            status != HSUploadStatus.initial && !hideUploadBar;
                        return SliverAppBar(
                          automaticallyImplyLeading: false,
                          titleSpacing: 0.0,
                          forceMaterialTransparency: true,
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
                              icon: const Icon(FontAwesomeIcons.bell),
                              onPressed: navi.toNotifications,
                            )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.2, end: 0),
                          ],
                          floating: true,
                          pinned: true,
                          bottom: PreferredSize(
                              preferredSize: showUploadBar
                                  ? const Size.fromHeight(100.0)
                                  : const Size.fromHeight(0.0),
                              child: showUploadBar
                                  ? const HSUploadProgressWidget()
                                  : const SizedBox()),
                          collapsedHeight: showUploadBar ? 60.0 : null,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const Gap(16.0).toSliver,
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: isLoading
                            ? HSShimmerBox(width: screenWidth, height: 120)
                            : GestureDetector(
                                onTap: () => navi.toSpotsMap(),
                                child: AbsorbPointer(
                                  absorbing: true,
                                  child: GoogleMap(
                                    markers: homeCubit.state.markers,
                                    style: context
                                        .read<HSThemeBloc>()
                                        .state
                                        .mapStyle,
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: false,
                                    initialCameraPosition:
                                        homeCubit.initialCameraPosition,
                                  ),
                                ),
                              )
                        // ),
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                ),
                const _HomeGridBuilder(type: HomeGridBuilderType.nearbySpots),
                const _HomeGridBuilder(
                    type: HomeGridBuilderType.trendingBoards),
                const _HomeGridBuilder(type: HomeGridBuilderType.trendingSpots),
              ],
            ),
          ),
        );
      },
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
              if (board.thumbnail != null || board.image != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      board.getThumbnail,
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
                        Colors.black.withOpacity(0.1),
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
                    AutoSizeText(
                      board.title!,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .colorify(Colors.white),
                      maxLines: 1,
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

enum HomeGridBuilderType { nearbySpots, trendingBoards, trendingSpots }

class _HomeGridBuilder extends StatelessWidget {
  const _HomeGridBuilder({
    required this.type,
    this.defaultBuilderHeight = 140.0,
  });

  final double defaultBuilderHeight;
  final HomeGridBuilderType type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HSHomeCubit, HSHomeState>(
      buildWhen: (previous, current) {
        switch (type) {
          case HomeGridBuilderType.nearbySpots:
            return previous.nearbySpots != current.nearbySpots ||
                previous.status != current.status;
          case HomeGridBuilderType.trendingBoards:
            return previous.trendingBoards != current.trendingBoards ||
                previous.status != current.status;
          case HomeGridBuilderType.trendingSpots:
            return previous.trendingSpots != current.trendingSpots ||
                previous.status != current.status;
        }
      },
      builder: (context, state) {
        final isLoading = state.status == HSHomeStatus.loading;
        late final List elements;
        late final String title, subtitle;
        switch (type) {
          case HomeGridBuilderType.nearbySpots:
            elements = state.nearbySpots;
            title = "Nearby Spots";
            subtitle = "Look around you";
            break;
          case HomeGridBuilderType.trendingBoards:
            elements = state.trendingBoards;
            title = "Trending Boards";
            subtitle = "The best collections of spots";
            break;
          case HomeGridBuilderType.trendingSpots:
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
            Text(title, style: Theme.of(context).textTheme.headlineMedium)
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
                  itemCount: elements.length + 1,
                  itemBuilder: (context, index) {
                    if (index == elements.length) {
                      return _HomeMoreTile(
                        type: HSMultipleSpotsType.fromHomeType(type),
                      );
                    }
                    if (type == HomeGridBuilderType.trendingBoards) {
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

class _HomeMoreTile extends StatelessWidget {
  const _HomeMoreTile({
    required this.type,
  });

  final HSMultipleSpotsType type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navi.toMultipleSpots(type),
      child: SizedBox(
        width: 60.0,
        height: 60.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              color: app.textFieldFillColor,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(child: Icon(FontAwesomeIcons.chevronRight)),
                Positioned(
                  bottom: 8.0,
                  child: Text(
                    "See More",
                    style: Theme.of(context).textTheme.titleSmall!.boldify,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
