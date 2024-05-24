import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_search_repository/hs_search.dart';

class HSHomeSearchDelegate extends SearchDelegate {
  final UsersSearcher usersSearcher = HSSearchRepository.instance.usersSearcher;
  HitsSearcher get searcher => usersSearcher.searcher;

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
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SearchBuilder(usersSearcher, SearchBuilderType.results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    searcher.query(query);
    return _SearchBuilder(usersSearcher, SearchBuilderType.suggestions);
  }

  @override
  void showResults(BuildContext context) {
    usersSearcher.queryChanged(query);
    super.showResults(context);
  }

  @override
  void showSuggestions(BuildContext context) {
    searcher.query(query);
    usersSearcher.queryChanged(query);
    super.showResults(context);
  }

  @override
  void dispose() {
    usersSearcher.dispose();
    super.dispose();
  }
}

enum SearchBuilderType { loading, suggestions, results }

class _SearchBuilder extends StatelessWidget {
  const _SearchBuilder(this.usersSearcher, this.searchBuilderType);

  final double radius = 24.0;
  final UsersSearcher usersSearcher;
  final SearchBuilderType searchBuilderType;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usersSearcher.searchPage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _UsersBuilder.loading(usersSearcher);
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No results found.'));
        }
        if (searchBuilderType == SearchBuilderType.suggestions) {
          return _UsersBuilder.suggestions(usersSearcher);
        }
        return _UsersBuilder.results(usersSearcher);
      },
    );
  }
}

class _UsersBuilder extends StatelessWidget {
  const _UsersBuilder(
      {required this.usersSearcher,
      required this.isLoading,
      required this.isResults});

  final bool isLoading, isResults;
  final double radius = 24.0;
  final UsersSearcher usersSearcher;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _LoadingBuilder(radius);
    } else if (!isResults) {
      return _SuggestionsBuilder(
        usersSearcher: usersSearcher,
        radius: radius,
        suggestions: usersSearcher.pagingController.itemList ?? [],
      );
    }
    return PagedListView<int, HSUser>(
      pagingController: usersSearcher.pagingController,
      builderDelegate: PagedChildBuilderDelegate<HSUser>(
          firstPageProgressIndicatorBuilder: (_) => const HSLoadingIndicator(),
          noItemsFoundIndicatorBuilder: (_) => const Center(
                child: Text('No results found'),
              ),
          itemBuilder: (_, user, __) => _UserTile(user: user, radius: radius)),
    );
  }

  factory _UsersBuilder.loading(UsersSearcher usersSearcher) {
    return _UsersBuilder(
      isLoading: true,
      isResults: false,
      usersSearcher: usersSearcher,
    );
  }

  factory _UsersBuilder.suggestions(UsersSearcher usersSearcher) {
    return _UsersBuilder(
      isLoading: false,
      isResults: false,
      usersSearcher: usersSearcher,
    );
  }

  factory _UsersBuilder.results(UsersSearcher usersSearcher) {
    return _UsersBuilder(
      isLoading: false,
      isResults: true,
      usersSearcher: usersSearcher,
    );
  }
}

class _SuggestionsBuilder extends StatelessWidget {
  const _SuggestionsBuilder(
      {required this.usersSearcher,
      required this.radius,
      required this.suggestions});

  final UsersSearcher usersSearcher;
  final double radius;
  final List<HSUser> suggestions;

  @override
  Widget build(BuildContext context) {
    final users = suggestions;
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) =>
            _UserTile(user: users[index], radius: radius));
  }
}

class _LoadingBuilder extends StatelessWidget {
  const _LoadingBuilder(this.radius);

  final double radius;
  final int childCount = 8;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: childCount,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: HSShimmer(
            child: ListTile(
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              tileColor: currentTheme.textfieldFillColor,
              leading: HSUserAvatar(
                loading: true,
                radius: radius,
              ),
              title: const HSShimmerSkeleton(
                height: 16.0,
                width: double.infinity,
              ),
              subtitle: const HSShimmerSkeleton(
                height: 16.0,
                width: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.radius});

  final HSUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: HSUserAvatar(
        imgUrl: user.profilePicture,
        radius: radius,
      ),
      title: Text(user.username!),
      subtitle: Text(user.fullName!),
      onTap: () => navi.push(UserProfileProvider.route(user.uid!)),
    );
  }
}
