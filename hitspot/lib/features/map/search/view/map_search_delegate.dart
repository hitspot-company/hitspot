import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/map/search/cubit/hs_map_search_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_user_tile.dart';
import 'package:hitspot/widgets/spot/hs_better_spot_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class MapSearchDelegate extends SearchDelegate<String> {
  MapSearchDelegate(this.mapSearchCubit);

  // Dummy list
  final List<String> searchList = [
    "Apple",
    "Banana",
    "Cherry",
    "Date",
    "Fig",
    "Grapes",
    "Kiwi",
    "Lemon",
    "Mango",
    "Orange",
    "Papaya",
    "Raspberry",
    "Strawberry",
    "Tomato",
    "Watermelon",
  ];

  final HSMapSearchCubit mapSearchCubit;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          // When pressed here the query will be cleared from the search bar.
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, "IDK"),
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
            tabs: [
              Icon(FontAwesomeIcons.user),
              Icon(FontAwesomeIcons.solidMap),
            ],
          ),
          const Gap(16.0),
          Expanded(
            child: TabBarView(
              children: [
                _FetchedSpotsPage(mapSearchCubit: mapSearchCubit, query: query),
                Container(color: Colors.amber),
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

  final HSMapSearchCubit mapSearchCubit;
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
        if (spots.isEmpty) {}
        return ListView.separated(
          separatorBuilder: (context, index) => const Gap(16.0),
          itemCount: spots.length,
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
    );
  }
}
