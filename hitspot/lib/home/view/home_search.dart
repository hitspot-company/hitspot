import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitspot/app/hs_app.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/user_profile/view/user_profile_provider.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_search_repository/hs_search.dart';

class HSHomeSearchDelegate extends SearchDelegate<String> {
  List results = [];
  final _searchRepository = HSApp.instance.searchRepository;

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

  @override
  String? get searchFieldLabel => "Search...";

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
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  // TODO: Export widgets
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: _searchRepository.fetchUsers(query),
      builder: (BuildContext context, AsyncSnapshot<List<HSUser>> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Somethign went wrong"),
          );
        }

        final Widget child = snapshot.connectionState == ConnectionState.waiting
            ? ListView.builder(
                itemCount: 8,
                itemBuilder: (BuildContext context, int index) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: HSShimmer(
                      child: HSShimmerSkeleton(
                        height: 80.0,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              HSUserAvatar(radius: 30, loading: true),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    HSShimmerSkeleton(
                                      height: 16.0,
                                    ),
                                    HSShimmerSkeleton(
                                      height: 16.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    final user = snapshot.data![index];
                    return ListTile(
                      title: Text("@${user.username}"),
                      subtitle: Text(user.fullName ?? ""),
                      leading: HSUserAvatar(
                        radius: 30,
                        imgUrl: user.profilePicture,
                      ),
                    );
                  },
                ),
              );
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000), child: child);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: _searchRepository.streamUsers(query),
      builder: (BuildContext context, AsyncSnapshot<List<HSUser>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: Text(
            "No data",
            style: textTheme.headlineLarge,
          ));
        }
        final List<HSUser> suggestions = snapshot.data!;
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (BuildContext context, int index) {
            final user = suggestions[index];
            return ListTile(
              onTap: () => navi.push(UserProfileProvider.route(user.uid!)),
              title: Text("@${user.username}"),
              subtitle: Text(user.fullName ?? ""),
              leading: HSUserAvatar(
                radius: 30,
                imgUrl: user.profilePicture,
              ),
            );
          },
        );
      },
    );
  }

  // Widget _hits(BuildContext context) => PagedListView<int, Product>(
  //     pagingController: _pagingController,
  //     builderDelegate: PagedChildBuilderDelegate<Product>(
  //         noItemsFoundIndicatorBuilder: (_) => const Center(
  //               child: Text('No results found'),
  //             ),
  //         itemBuilder: (_, item, __) => Container(
  //               color: Colors.white,
  //               height: 80,
  //               padding: const EdgeInsets.all(8),
  //               child: Row(
  //                 children: [
  //                   SizedBox(width: 50, child: Image.network(item.image)),
  //                   const SizedBox(width: 20),
  //                   Expanded(child: Text(item.name))
  //                 ],
  //               ),
  //             )));
}
