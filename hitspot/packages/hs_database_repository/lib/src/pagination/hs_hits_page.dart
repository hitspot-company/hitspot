import 'package:hs_database_repository/hs_database_repository.dart';

enum HSHitsPageType { spots, boards, users, notifications }

class HSHitsPage<T> {
  HSHitsPage(
      {this.pageSize = 20,
      required this.fetch,
      this.type = HSHitsPageType.spots}) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  final int pageSize;
  final Future<List<T>> Function(int batchSize, int batchOffset) fetch;
  final PagingController<int, T> _pagingController =
      PagingController(firstPageKey: 0);
  final HSHitsPageType type;

  PagingController<int, T> get pagingController => _pagingController;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await fetch(pageSize, pageKey);
      final isLastPage = newItems.length < pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void dispose() {
    _pagingController.dispose();
  }
}
