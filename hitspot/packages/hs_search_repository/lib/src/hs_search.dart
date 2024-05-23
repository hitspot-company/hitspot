import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';

class HSSearchRepository {
  static final HSSearchRepository instance = HSSearchRepository();
  final algoliaCredentials = _AlgoliaCredentials.instance;

  HitsSearcher get usersSearcher => algoliaCredentials.users.usersSearcher;
  HitsSearcher get spotsSearcher => algoliaCredentials.spots.spotsSearcher;

  Stream<UsersHitsPage> get usersSearchPage =>
      usersSearcher.responses.map(UsersHitsPage.fromResponse);

  void dispose() {
    if (!usersSearcher.isDisposed) usersSearcher.dispose();
    if (!spotsSearcher.isDisposed) spotsSearcher.dispose();
  }
}

class _AlgoliaCredentials {
  // SINGLETON
  _AlgoliaCredentials() {
    this.apiKey = FlutterConfig.get("ALGOLIA_API_KEY");
    this.applicationID = FlutterConfig.get("ALGOLIA_APP_ID");
    assert((this.apiKey != null),
        "The algolia api key cannot be null. Please check the .env file at the root of the project.");
    assert((this.applicationID != null),
        "The algolia application id cannot be null. Please check the .env file at the root of the project.");
  }
  static final _AlgoliaCredentials _instance = _AlgoliaCredentials();
  static _AlgoliaCredentials get instance => _instance;

  _SpotsSearcher get spots => _SpotsSearcher(applicationID!, apiKey!);
  _UsersSearcher get users => _UsersSearcher(applicationID!, apiKey!);

  late final String? apiKey;
  late final String? applicationID;
}

class _SpotsSearcher {
  _SpotsSearcher(String applicationID, String apiKey) {
    spotsSearcher = HitsSearcher(
      applicationID: applicationID,
      apiKey: apiKey,
      indexName: indexName,
    ); // TODO: Change spots to dev_spots
  }

  final String indexName = "spots";
  late final HitsSearcher spotsSearcher;
}

class _UsersSearcher {
  _UsersSearcher(String applicationID, String apiKey) {
    usersSearcher = HitsSearcher(
      applicationID: applicationID,
      apiKey: apiKey,
      indexName: indexName,
      debounce: const Duration(milliseconds: 200),
    ); // TODO: Change users to dev_users
    filterState.add(FilterGroupID("is_profile_completed"), filterCategory);
    usersSearcher.connectFilterState(filterState);
  }

  late final HitsSearcher usersSearcher;
  final String indexName = "users";

  // FILTERING
  final filterState = FilterState();
  final filterCategory = FilterGroup.facet(
    name: 'is_profile_completed',
    filters: {Filter.facet('is_profile_completed', true)},
  );
}

class UsersHitsPage {
  const UsersHitsPage(this.items, this.pageKey, this.nextPageKey);

  final List<HSUser> items;
  final int pageKey;
  final int? nextPageKey;

  factory UsersHitsPage.fromResponse(SearchResponse response) {
    final items = response.hits.map((e) {
      for (var element in e.entries) {
        print("entry: ${element.key} : ${element.value}");
      }
      return HSUser.deserialize(e);
    }).toList();
    final isLastPage = response.page >= response.nbPages;
    final nextPageKey = isLastPage ? null : response.page + 1;
    return UsersHitsPage(items, response.page, nextPageKey);
  }
}
