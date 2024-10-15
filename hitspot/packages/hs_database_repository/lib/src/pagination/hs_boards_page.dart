import 'package:hs_database_repository/hs_database_repository.dart';

class HSBoardsPage extends HSHitsPage<HSBoard> {
  HSBoardsPage({
    super.pageSize = 20,
    required super.fetch,
  }) : super(type: HSHitsPageType.boards);
}
