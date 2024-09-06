import 'package:hs_database_repository/hs_database_repository.dart';

class HSBoardsPage {
  HSBoardsPage({this.pageSize = 20, required this.fetchBoards}) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }
  final int pageSize;
  final Future<List<HSBoard>> Function(int batchSize, int batchOffset)
      fetchBoards;

  final PagingController<int, HSBoard> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, HSBoard> get pagingController => _pagingController;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await fetchBoards(pageSize, pageKey);
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
