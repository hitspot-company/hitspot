import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_user_tile.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

class MainSearchDelegate extends SearchDelegate<String> {
  MainSearchDelegate(this.mapSearchCubit);
  final HSMainSearchCubit mapSearchCubit;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ""),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const Gap(16.0),
          const TabBar(
            dividerHeight: 0.0,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(text: 'Spots', icon: Icon(FontAwesomeIcons.mapPin)),
              Tab(text: 'Boards', icon: Icon(FontAwesomeIcons.solidSquare)),
            ],
          ),
          const Gap(16.0),
          Expanded(
            child: TabBarView(
              children: [
                _FetchedSpotsPage(mapSearchCubit: mapSearchCubit, query: query),
                _FetchedBoardsPage(
                    mapSearchCubit: mapSearchCubit, query: query),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    return FutureBuilder<List<HSUser>>(
      future: mapSearchCubit.fetchPredictions(),
      initialData: const [],
      builder: (BuildContext context, AsyncSnapshot<List<HSUser>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final List<HSUser> users = snapshot.data!;
            return Column(
              children: [
                const Gap(16.0),
                Expanded(
                  child: SizedBox(
                    width: screenWidth,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        return HsUserTile(user: users[index]);
                      },
                    ),
                  ),
                ),
              ],
            );
          default:
            return const HSLoadingIndicator();
        }
      },
    );
  }
}

class _FetchedSpotsPage extends StatelessWidget {
  const _FetchedSpotsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  Widget build(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    return FutureBuilder<List<HSSpot>>(
      future: mapSearchCubit.fetchSpots(),
      builder: (BuildContext context, AsyncSnapshot<List<HSSpot>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const HSLoadingIndicator();
        }
        final List<HSSpot> spots = snapshot.data ?? [];
        if (spots.isEmpty) {
          return Text("No spots found for $query", textAlign: TextAlign.center);
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: spots.length,
          itemBuilder: (BuildContext context, int index) {
            return HSBetterSpotTile(
              onTap: (p0) => navi.toSpot(sid: p0!.sid!),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              borderRadius: BorderRadius.circular(20.0),
              spot: spots[index],
            );
          },
        );
      },
    );
  }
}

class _FetchedBoardsPage extends StatelessWidget {
  const _FetchedBoardsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  Widget build(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    return FutureBuilder<List<HSBoard>>(
      future: mapSearchCubit.fetchBoards(),
      builder: (BuildContext context, AsyncSnapshot<List<HSBoard>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const HSLoadingIndicator();
        }
        final List<HSBoard> boards = snapshot.data ?? [];
        if (boards.isEmpty) {
          return Text("No boards found for $query",
              textAlign: TextAlign.center);
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: boards.length,
          itemBuilder: (BuildContext context, int index) {
            return HSBoardTile(board: boards[index]);
          },
        );
      },
    );
  }
}
