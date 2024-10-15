import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/extensions/hs_sliver_extensions.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/widgets/auth/hs_text_prompt.dart';
import 'package:hitspot/widgets/hs_user_tile.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

part 'main_search_users_builder.dart';
part 'main_search_tags_builder.dart';
part 'main_search_boards_builder.dart';
part 'main_search_spots_builder.dart';

class MainSearchDelegate extends SearchDelegate<String> {
  MainSearchDelegate(this.mapSearchCubit);
  final HSMainSearchCubit mapSearchCubit;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: theme.hintColor),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          mapSearchCubit.updateQuery(query);
        },
      ).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: backIcon,
      onPressed: () => close(context, ""),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut);
  }

  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const Gap(8.0),
            TabBar(
              dividerHeight: 0.0,
              indicatorColor: app.theme.mainColor,
              labelColor: app.theme.mainColor,
              unselectedLabelColor: Colors.grey,
              physics: const NeverScrollableScrollPhysics(),
              tabAlignment: TabAlignment.fill,
              tabs: const [
                Tab(text: 'Users'),
                Tab(text: 'Spots'),
                Tab(text: 'Boards'),
                Tab(text: 'Tags'),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    BlocBuilder<HSMainSearchCubit, HSMainSearchState>(
                      buildWhen: (previous, current) =>
                          previous.users != current.users ||
                          previous.trendingUsers != current.trendingUsers ||
                          previous.status != current.status,
                      builder: (context, state) => _FetchedUsersPage(
                        mapSearchCubit: mapSearchCubit,
                        query: query,
                      ),
                    ),
                    BlocBuilder<HSMainSearchCubit, HSMainSearchState>(
                      buildWhen: (previous, current) =>
                          previous.spots != current.spots ||
                          previous.trendingSpots != current.trendingSpots ||
                          previous.status != current.status,
                      builder: (context, state) => _FetchedSpotsPage(
                        mapSearchCubit: mapSearchCubit,
                        query: query,
                      ),
                    ),
                    BlocBuilder<HSMainSearchCubit, HSMainSearchState>(
                      buildWhen: (previous, current) =>
                          previous.boards != current.boards ||
                          previous.trendingBoards != current.trendingBoards ||
                          previous.status != current.status,
                      builder: (context, state) => _FetchedBoardsPage(
                        mapSearchCubit: mapSearchCubit,
                        query: query,
                      ),
                    ),
                    BlocBuilder<HSMainSearchCubit, HSMainSearchState>(
                      buildWhen: (previous, current) =>
                          previous.tags != current.tags ||
                          previous.trendingTags != current.trendingTags ||
                          previous.status != current.status,
                      builder: (context, state) => _FetchedTagsPage(
                        mapSearchCubit: mapSearchCubit,
                        query: query,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    return buildResults(context);
  }
}

enum HSLoadingWidgetType { list, grid }

class HSLoadingWidget extends StatelessWidget {
  const HSLoadingWidget({super.key, required this.type});

  final HSLoadingWidgetType type;

  @override
  Widget build(BuildContext context) {
    if (type == HSLoadingWidgetType.list) {
      return ListView.separated(
        itemCount: 3,
        separatorBuilder: (BuildContext context, int index) {
          return const Gap(8.0);
        },
        itemBuilder: (BuildContext context, int index) {
          return HSShimmerBox(width: screenWidth, height: 80.0);
        },
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return HSShimmerBox(width: screenWidth, height: 80.0);
        },
      );
    }
  }
}
