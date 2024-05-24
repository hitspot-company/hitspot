import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HSSearchRepository {
  static final HSSearchRepository instance = HSSearchRepository();
  final algoliaCredentials = _AlgoliaCredentials.instance;

  UsersSearcher get usersSearcher => algoliaCredentials.users;
  SpotsSearcher get spotsSearcher => algoliaCredentials.spots;

  Stream<UsersHitsPage> get usersSearchPage =>
      usersSearcher.searcher.responses.map(UsersHitsPage.fromResponse);

  // void dispose() {
  //   if (!usersSearcher.isDisposed) usersSearcher.dispose();
  //   if (!spotsSearcher.isDisposed) spotsSearcher.dispose();
  // }
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

  SpotsSearcher get spots => SpotsSearcher(applicationID!, apiKey!);
  UsersSearcher get users => UsersSearcher(applicationID!, apiKey!);

  late final String? apiKey;
  late final String? applicationID;
}

class SpotsSearcher {
  SpotsSearcher(String applicationID, String apiKey) {
    spotsSearcher = HitsSearcher(
      applicationID: applicationID,
      apiKey: apiKey,
      indexName: indexName,
    ); // TODO: Change spots to dev_spots
  }

  final String indexName = "spots";
  late final HitsSearcher spotsSearcher;
}

class UsersSearcher {
  UsersSearcher(String applicationID, String apiKey) {
    searcher = HitsSearcher(
      applicationID: applicationID,
      apiKey: apiKey,
      indexName: indexName,
      debounce: const Duration(milliseconds: 200),
    );
    filterState.add(FilterGroupID("is_profile_completed"), filterCategory);
    searcher.connectFilterState(filterState);

    // Paging
    searchPage.listen((page) {
      if (page.pageKey == 0) {
        pagingController.refresh();
      }
      pagingController.appendPage(page.items, page.nextPageKey);
    }).onError((e) => pagingController.error = e);
    pagingController.addPageRequestListener((pageKey) =>
        searcher.applyState((state) => state.copyWith(page: pageKey)));
  }

  late final HitsSearcher searcher;
  final String indexName = "users";

  // FILTERING
  final filterState = FilterState();
  final filterCategory = FilterGroup.facet(
    name: 'is_profile_completed',
    filters: {Filter.facet('is_profile_completed', true)},
  );

  final PagingController<int, HSUser> pagingController =
      PagingController(firstPageKey: 0);
  Stream<UsersHitsPage> get searchPage =>
      searcher.responses.map(UsersHitsPage.fromResponse);

  void queryChanged(String query) {
    searcher.applyState(
      (state) => state.copyWith(
        query: query,
        page: 0,
      ),
    );
  }

  void dispose() {
    searcher.dispose();
    pagingController.dispose();
    filterState.dispose();
  }
}

class UsersHitsPage {
  const UsersHitsPage(this.items, this.pageKey, this.nextPageKey);

  final List<HSUser> items;
  final int pageKey;
  final int? nextPageKey;

  factory UsersHitsPage.fromResponse(SearchResponse response) {
    final items = response.hits
        .map((e) => HSUser.deserialize(e, uid: e['objectID']))
        .toList();
    final isLastPage = response.page >= response.nbPages;
    final nextPageKey = isLastPage ? null : response.page + 1;
    return UsersHitsPage(items, response.page, nextPageKey);
  }
}
