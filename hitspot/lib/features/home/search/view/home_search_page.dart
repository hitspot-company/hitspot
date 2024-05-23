import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hitspot/features/user_profile/main/view/user_profile_provider.dart';
import 'package:hitspot/widgets/hs_loading_indicator.dart';
import 'package:hitspot/widgets/hs_shimmer.dart';
import 'package:hitspot/widgets/hs_user_avatar.dart';
import 'package:hitspot/widgets/shimmer_skeleton.dart';
import 'package:hs_search_repository/hs_search.dart';

class HSHomeSearchDelegate extends SearchDelegate {
  final HitsSearcher searcher = HSSearchRepository.instance.usersSearcher;

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
    return StreamBuilder(
      stream: searcher.responses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Builder();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.hits.isEmpty) {
          return Center(child: Text('No results found.'));
        }

        final hits = snapshot.data!.hits;
        return _Builder(
            data: hits, titleField: "username", subtitleField: "full_name");
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    searcher.query(query);
    return buildResults(context);
  }

  @override
  void showResults(BuildContext context) {
    searcher.rerun(); // TODO: Verify if not too much
    super.showResults(context);
  }

  @override
  void showSuggestions(BuildContext context) {
    searcher.query(query);
    super.showResults(context);
  }
}

class _Builder extends StatelessWidget {
  const _Builder({this.data, this.titleField, this.subtitleField});

  final List? data;
  final String? titleField, subtitleField;
  final double radius = 24.0;

  @override
  Widget build(BuildContext context) {
    late final int childCount;
    if (data == null) {
      childCount = 8;
    } else {
      childCount = data!.length;
    }
    return ListView.builder(
      itemCount: childCount,
      itemBuilder: (BuildContext context, int index) {
        if (data == null) {
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
                onTap: () {},
              ),
            ),
          );
        }
        final hit = data![index];
        return ListTile(
          leading: HSUserAvatar(
            imgUrl: hit['profile_picture'],
            radius: radius,
          ),
          title: Text(hit[titleField] ?? ""),
          subtitle: Text(hit[subtitleField] ?? ""),
          // onTap: () => navi.push(UserProfileProvider.route(hit)),
        );
      },
    );
  }
}
