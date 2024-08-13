import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/home/main/view/home_page.dart';
import 'package:hitspot/features/search/cubit/hs_main_search_cubit.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmers/hs_shimmer_box.dart';
import 'package:hitspot/widgets/spot/hs_animated_spot_tile.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';

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
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Gap(16.0),
          TabBar(
            dividerHeight: 0.0,
            indicatorColor: app.theme.mainColor,
            labelColor: app.theme.mainColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Spots'),
              Tab(text: 'Boards'),
              Tab(text: 'Tags'),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
          const Gap(16.0),
          Expanded(
            child: TabBarView(
              children: [
                _FetchedSpotsPage(mapSearchCubit: mapSearchCubit, query: query),
                _FetchedBoardsPage(
                    mapSearchCubit: mapSearchCubit, query: query),
                _FetchedTagsPage(mapSearchCubit: mapSearchCubit, query: query),
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
    if (query.isEmpty) {
      mapSearchCubit.fetchTrendingUsers();
    }
    return BlocSelector<HSMainSearchCubit, HSMainSearchState, List<HSUser>>(
      selector: (state) => state.users,
      builder: (context, fetchedUsers) {
        final List<HSUser> users = fetchedUsers;
        if (users.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: 3,
              separatorBuilder: (BuildContext context, int index) {
                return const Gap(16.0);
              },
              itemBuilder: (BuildContext context, int index) {
                return HSShimmerBox(width: screenWidth, height: 80.0);
              },
            ),
          );
        }
        return Column(
          children: [
            const Gap(16.0),
            Expanded(
              child: SizedBox(
                width: screenWidth,
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(thickness: .1, color: Colors.grey),
                  ),
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = users[index];
                    return _AnimatedUserTile(user: user, index: index);
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

class _TrendingSpotsPage extends StatelessWidget {
  const _TrendingSpotsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  Widget build(BuildContext context) {
    final List<HSSpot> spots = mapSearchCubit.state.trendingSpots;
    if (spots.isEmpty) {
      return Text("No spots found for $query", textAlign: TextAlign.center)
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: spots.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedSpotTile(
          spot: spots[index],
          index: index,
          padding: const EdgeInsets.all(8.0),
        );
      },
    );
  }
}

class _AnimatedUserTile extends StatelessWidget {
  const _AnimatedUserTile({required this.user, required this.index});

  final HSUser user;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => navi.toUser(userID: user.uid!),
      title: Text(user.username!),
      subtitle: Text(user.name!),
      leading: HSUserAvatar(
        radius: 24.0,
        imageUrl: user.avatarUrl,
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(
        begin: -0.2,
        end: 0,
        duration: 300.ms,
        delay: (50 * index).ms,
        curve: Curves.easeOutQuad);
  }
}

class _FetchedSpotsPage extends StatelessWidget {
  const _FetchedSpotsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  Widget build(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    if (query.isEmpty) {
      return _TrendingSpotsPage(
        mapSearchCubit: mapSearchCubit,
        query: query,
      );
    }
    return FutureBuilder<List<HSSpot>>(
      future: mapSearchCubit.fetchSpots(),
      builder: (BuildContext context, AsyncSnapshot<List<HSSpot>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const HSLoadingIndicator()
              .animate()
              .fadeIn(duration: 300.ms, curve: Curves.easeInOut);
        }
        final List<HSSpot> spots = snapshot.data ?? [];
        if (spots.isEmpty) {
          return Text("No spots found for $query", textAlign: TextAlign.center)
              .animate()
              .fadeIn(duration: 300.ms);
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: spots.length,
            itemBuilder: (BuildContext context, int index) {
              return AnimatedSpotTile(
                spot: spots[index],
                index: index,
              );
            },
          ),
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
    if (query.isEmpty) {
      mapSearchCubit.fetchTrendingBoards();
    }
    return BlocSelector<HSMainSearchCubit, HSMainSearchState, List<HSBoard>>(
      selector: (state) => state.boards,
      builder: (context, state) {
        final List<HSBoard> boards = state;
        if (boards.isEmpty) {
          return const HSLoadingIndicator()
              .animate()
              .fadeIn(duration: 300.ms, curve: Curves.easeInOut);
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: boards.length,
          itemBuilder: (BuildContext context, int index) {
            return _AnimatedBoardTile(board: boards[index], index: index);
          },
        );
      },
    );
  }
}

class _AnimatedBoardTile extends StatelessWidget {
  const _AnimatedBoardTile({required this.board, required this.index});

  final HSBoard board;
  final int index;

  @override
  Widget build(BuildContext context) {
    return HSBoardGridItem(board: board)
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutQuad);
  }
}

class _FetchedTagsPage extends StatelessWidget {
  const _FetchedTagsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  Widget build(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    if (query.isEmpty) {
      mapSearchCubit.fetchTrendingTags();
    }
    return BlocSelector<HSMainSearchCubit, HSMainSearchState, List<HSTag>>(
      selector: (state) => state.tags,
      builder: (context, state) {
        final List<HSTag> tags = state;
        if (tags.isEmpty) {
          return const HSLoadingIndicator()
              .animate()
              .fadeIn(duration: 300.ms, curve: Curves.easeInOut);
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: tags.length,
            itemBuilder: (BuildContext context, int index) {
              return _AnimatedTagTile(tag: tags[index], index: index);
            },
          ),
        );
      },
    );
  }
}

class _AnimatedTagTile extends StatelessWidget {
  const _AnimatedTagTile({required this.tag, required this.index});

  final HSTag tag;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => navi.toTagsExplore(tag.value!),
        child: Center(
          child: ListTile(
            title: AutoSizeText(tag.value!,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1),
            leading: const Icon(FontAwesomeIcons.hashtag),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1),
        duration: 300.ms,
        curve: Curves.easeOutQuad);
  }
}
