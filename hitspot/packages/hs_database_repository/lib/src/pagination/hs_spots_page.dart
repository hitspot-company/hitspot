import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSSpotsPage {
  HSSpotsPage({this.pageSize = 20, required this.fetchSpots}) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }
  final int pageSize;
  final Future<List<HSSpot>> Function(int batchSize, int batchOffset)
      fetchSpots;

  final PagingController<int, HSSpot> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, HSSpot> get pagingController => _pagingController;

  Future<void> _fetchPage(int pageKey) async {
    try {
      HSDebugLogger.logInfo("Fetching more");
      final newItems = await fetchSpots(pageSize, pageKey);
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
