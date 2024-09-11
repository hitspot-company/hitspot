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
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const Gap(16.0),
          TabBar(
            dividerHeight: 0.0,
            indicatorColor: app.theme.mainColor,
            labelColor: app.theme.mainColor,
            unselectedLabelColor: Colors.grey,
            physics: const NeverScrollableScrollPhysics(),
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Spots'),
              Tab(text: 'Boards'),
              Tab(text: 'Tags'),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
          const Gap(16.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    mapSearchCubit.updateQuery(query);
    return buildResults(context);
  }
}

class _FetchedUsersPage extends StatefulWidget {
  const _FetchedUsersPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  State<_FetchedUsersPage> createState() => _FetchedUsersPageState();
}

class _FetchedUsersPageState extends State<_FetchedUsersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = widget.mapSearchCubit.state;

    if (widget.mapSearchCubit.isLoading) {
      return const HSLoadingWidget(type: HSLoadingWidgetType.list);
    }

    if (widget.query.isNotEmpty && state.users.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          HSTextPrompt(
                  prompt: "No users found for ",
                  pressableText: widget.query,
                  promptColor: app.theme.mainColor,
                  onTap: null)
              .toSliver,
          const Gap(16.0).toSliver,
          Text(
            "Maybe you will like to see these users instead",
            style: Theme.of(context).textTheme.headlineSmall,
          ).toSliver,
          const Gap(16.0).toSliver,
          SliverFillRemaining(
              child: _AnimatedUsersBuilder(users: state.trendingUsers)),
        ],
      );
    }

    final List<HSUser> users =
        state.users.isEmpty ? state.trendingUsers : state.users;

    return _AnimatedUsersBuilder(users: users);
  }
}

class _AnimatedUsersBuilder extends StatelessWidget {
  const _AnimatedUsersBuilder({
    required this.users,
  });

  final List<HSUser> users;

  @override
  Widget build(BuildContext context) {
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

class _FetchedSpotsPage extends StatefulWidget {
  const _FetchedSpotsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  State<_FetchedSpotsPage> createState() => _FetchedSpotsPageState();
}

class _FetchedSpotsPageState extends State<_FetchedSpotsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = widget.mapSearchCubit.state;
    if (widget.mapSearchCubit.isLoading) {
      return const HSLoadingWidget(
        type: HSLoadingWidgetType.grid,
      );
    }
    final List<HSSpot> trendingSpots = state.trendingSpots;
    if (widget.query.isEmpty) {
      return _AnimatedSpotsBuilder(spots: trendingSpots);
    }
    if (widget.query.isNotEmpty && state.spots.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          HSTextPrompt(
                  prompt: "No spots found for ",
                  pressableText: widget.query,
                  promptColor: app.theme.mainColor,
                  onTap: null)
              .toSliver,
          const Gap(16.0).toSliver,
          Text(
            "Maybe you will like these spots instead",
            style: Theme.of(context).textTheme.headlineSmall,
          ).toSliver,
          const Gap(16.0).toSliver,
          SliverFillRemaining(
              child: _AnimatedSpotsBuilder(spots: trendingSpots)),
        ],
      );
    }
    final List<HSSpot> spots = state.spots;
    return _AnimatedSpotsBuilder(spots: spots);
  }
}

class _AnimatedSpotsBuilder extends StatelessWidget {
  const _AnimatedSpotsBuilder({
    required this.spots,
  });

  final List<HSSpot> spots;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
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
  }
}

class _FetchedBoardsPage extends StatefulWidget {
  const _FetchedBoardsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  State<_FetchedBoardsPage> createState() => _FetchedBoardsPageState();
}

class _FetchedBoardsPageState extends State<_FetchedBoardsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = widget.mapSearchCubit.state;

    if (widget.mapSearchCubit.isLoading) {
      return const HSLoadingWidget(
        type: HSLoadingWidgetType.grid,
      );
    }
    final List<HSBoard> boards = state.boards;
    final List<HSBoard> trendingBoards = state.trendingBoards;
    if (widget.query.isEmpty) {
      return _AnimatedBoardsBuilder(boards: trendingBoards);
    }
    if (widget.query.isNotEmpty && state.boards.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          HSTextPrompt(
                  prompt: "No boards found for ",
                  pressableText: widget.query,
                  promptColor: app.theme.mainColor,
                  onTap: null)
              .toSliver,
          const Gap(16.0).toSliver,
          Text(
            "Maybe you will like these boards instead",
            style: Theme.of(context).textTheme.headlineSmall,
          ).toSliver,
          const Gap(16.0).toSliver,
          SliverFillRemaining(
              child: _AnimatedBoardsBuilder(boards: trendingBoards)),
        ],
      );
    }
    return _AnimatedBoardsBuilder(boards: boards);
  }
}

class _AnimatedBoardsBuilder extends StatelessWidget {
  const _AnimatedBoardsBuilder({
    required this.boards,
  });

  final List<HSBoard> boards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: boards.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedBoardTile(board: boards[index], index: index);
      },
    );
  }
}

class AnimatedBoardTile extends StatelessWidget {
  const AnimatedBoardTile(
      {super.key, required this.board, required this.index});

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

class _FetchedTagsPage extends StatefulWidget {
  const _FetchedTagsPage({required this.mapSearchCubit, required this.query});

  final HSMainSearchCubit mapSearchCubit;
  final String query;

  @override
  State<_FetchedTagsPage> createState() => _FetchedTagsPageState();
}

class _FetchedTagsPageState extends State<_FetchedTagsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = widget.mapSearchCubit.state;

    if (widget.mapSearchCubit.isLoading) {
      return const HSLoadingWidget(
        type: HSLoadingWidgetType.grid,
      );
    }
    final List<HSTag> trendingTags = state.trendingTags;
    if (widget.query.isEmpty) {
      return _AnimatedTagsBuilder(tags: trendingTags);
    }
    if (widget.query.isNotEmpty && state.tags.isEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          HSTextPrompt(
                  prompt: "No tags found for ",
                  pressableText: widget.query,
                  promptColor: app.theme.mainColor,
                  onTap: null)
              .toSliver,
          const Gap(16.0).toSliver,
          Text(
            "Maybe you will like these tags instead",
            style: Theme.of(context).textTheme.headlineSmall,
          ).toSliver,
          const Gap(16.0).toSliver,
          SliverFillRemaining(child: _AnimatedTagsBuilder(tags: trendingTags)),
        ],
      );
    }
    final List<HSTag> tags = state.tags;
    return _AnimatedTagsBuilder(tags: tags);
  }
}

class _AnimatedTagsBuilder extends StatelessWidget {
  const _AnimatedTagsBuilder({
    required this.tags,
  });

  final List<HSTag> tags;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
