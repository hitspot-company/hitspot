import 'package:hs_database_repository/hs_database_repository.dart';

class HSNotificationsPage {
  HSNotificationsPage({this.pageSize = 20, required this.fetch}) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }
  final int pageSize;
  final Future<List<HSNotification>> Function(int batchSize, int batchOffset)
      fetch;

  final PagingController<int, HSNotification> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, HSNotification> get pagingController =>
      _pagingController;

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
