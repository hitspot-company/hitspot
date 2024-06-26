import 'package:flutter/material.dart';
import 'package:hitspot/features/search/users/view/user_search_provider.dart';
import 'package:hitspot/widgets/hs_appbar.dart';
import 'package:hitspot/widgets/hs_scaffold.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HSScaffold(
      appBar: HSAppBar(
        enableDefaultBackButton: true,
      ),
      body: const DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              indicatorColor: Colors.transparent,
              tabs: [
                Tab(text: "Users"),
                Tab(text: "Spots"),
                Tab(text: "Boards"),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  UserSearchProvider(),
                  Text("Spots"),
                  Text("Tags"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
