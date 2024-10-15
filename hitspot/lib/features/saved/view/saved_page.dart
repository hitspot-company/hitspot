import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/saved/cubit/hs_saved_cubit.dart';
import 'package:hitspot/widgets/hs_icon_prompt.dart';
import 'package:hitspot/widgets/hs_image.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';
import 'package:hitspot/widgets/hs_search_bar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedCubit = context.read<HSSavedCubit>();
    return DefaultTabController(
      length: 3,
      child: GestureDetector(
        onTap: HSScaffold.hideInput,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Saved'),
            bottom: const TabBar(
              indicatorPadding: EdgeInsets.only(bottom: 6.0),
              tabs: [
                Tab(text: 'Your Boards'),
                Tab(text: 'Saved Boards'),
                Tab(text: 'Saved Spots'),
              ],
            ),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SearchBar(controller: savedCubit.controller),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _OwnBoardsBuilder(),
                      _SavedBoardsBuilder(),
                      _SpotsBuilder(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LoadingBuilderType { list, grid }

class _LoadingBuilder extends StatelessWidget {
  const _LoadingBuilder({this.type = _LoadingBuilderType.list});

  final _LoadingBuilderType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: type == _LoadingBuilderType.list
          ? ListView.separated(
              shrinkWrap: true,
              itemCount: 4,
              separatorBuilder: (BuildContext context, int index) {
                return const Gap(16.0);
              },
              itemBuilder: (BuildContext context, int index) {
                return HSShimmerBox(height: 80.0, width: screenWidth);
              },
            )
          : GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
              ),
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return HSShimmerBox(height: 80.0, width: screenWidth);
              },
            ),
    );
  }
}

class _SavedBoardsBuilder extends StatelessWidget {
  const _SavedBoardsBuilder();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HSSavedCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: BlocBuilder<HSSavedCubit, HSSavedState>(
        buildWhen: (previous, current) =>
            previous.searchedSavedBoardsResults !=
                current.searchedSavedBoardsResults ||
            previous.status != current.status,
        builder: (context, state) {
          return _BoardsBuilder(hitsPage: cubit.savedBoardsPage);
        },
      ),
    );
  }
}

class _OwnBoardsBuilder extends StatelessWidget {
  const _OwnBoardsBuilder();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HSSavedCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: BlocBuilder<HSSavedCubit, HSSavedState>(
        buildWhen: (previous, current) =>
            previous.searchedBoardsResults != current.searchedBoardsResults,
        builder: (context, state) {
          final results = state.searchedBoardsResults;
          return _BoardsBuilder(
              hitsPage: cubit.yourBoardsPage, results: results);
        },
      ),
    );
  }
}

class _BoardsBuilder extends StatelessWidget {
  const _BoardsBuilder({required this.hitsPage, this.results});
  final HSBoardsPage hitsPage;
  final List<HSBoard>? results;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HSSavedCubit>();
    if (results != null && results!.isNotEmpty) {
      return ListView.separated(
        itemCount: results!.length,
        itemBuilder: (context, index) {
          final board = results![index];
          return ListTile(
            onTap: () => navi.toBoard(boardID: board.id!, title: board.title!),
            leading: AspectRatio(
                aspectRatio: 1.0,
                child: HSImage(
                  imageUrl: board.getThumbnail,
                  borderRadius: BorderRadius.circular(10.0),
                )),
            title: Text(board.title!),
            subtitle: Text(board.description!),
          );
        },
        separatorBuilder: (context, index) => const Gap(16.0),
      );
    }
    return PagedListView.separated(
      pagingController: hitsPage.pagingController,
      builderDelegate: PagedChildBuilderDelegate<HSBoard>(
          firstPageProgressIndicatorBuilder: (context) =>
              const HSLoadingIndicator(),
          noItemsFoundIndicatorBuilder: (context) => HSIconPrompt(
                message: getMessage(cubit),
                iconData: FontAwesomeIcons.bookmark,
              ),
          itemBuilder: (context, board, index) {
            if (hitsPage == cubit.savedBoardsPage) {
              cubit.addSavedBoardToCache(board);
            } else {
              cubit.addOwnBoardToCache(board);
            }
            return ListTile(
              onTap: () =>
                  navi.toBoard(boardID: board.id!, title: board.title!),
              leading: AspectRatio(
                  aspectRatio: 1.0,
                  child: HSImage(
                    imageUrl: board.getThumbnail,
                    borderRadius: BorderRadius.circular(10.0),
                  )),
              title: Text(board.title!),
              subtitle: Text(board.description!),
            );
          }),
      separatorBuilder: (context, index) => const Gap(16.0),
    );
  }

  String getMessage(HSSavedCubit cubit) {
    if (hitsPage == cubit.savedBoardsPage) {
      return "No saved boards";
    }
    return "No boards";
  }
}

class _SpotsBuilder extends StatelessWidget {
  const _SpotsBuilder();

  @override
  Widget build(BuildContext context) {
    final HSSavedCubit cubit = context.read<HSSavedCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: BlocBuilder<HSSavedCubit, HSSavedState>(
        buildWhen: (previous, current) =>
            previous.searchedSavedSpotsResults !=
            current.searchedSavedSpotsResults,
        builder: (context, state) {
          final results = state.searchedSavedSpotsResults;
          final isSearching = state.query.isNotEmpty;
          if (isSearching) {
            return GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemBuilder: (context, index) {
                final spot = results[index];
                return AnimatedSpotTile(spot: spot, index: index);
              },
              itemCount: results.length,
            );
          }
          return PagedGridView(
            pagingController: cubit.savedSpotsPage.pagingController,
            builderDelegate: PagedChildBuilderDelegate<HSSpot>(
                itemBuilder: (context, spot, index) {
              cubit.addSavedSpotToCache(spot);
              return AnimatedSpotTile(spot: spot, index: index);
            }),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final HSSavedCubit searchCubit = context.read<HSSavedCubit>();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: HSSearchBar(
          initialValue: searchCubit.state.query,
          height: 50.0,
          onChanged: (value) => searchCubit.updateQuery(value),
          controller: controller),
    );
  }
}
