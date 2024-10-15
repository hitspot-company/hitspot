import 'package:hs_database_repository/hs_database_repository.dart';

class HSSpotsPage extends HSHitsPage<HSSpot> {
  HSSpotsPage({
    super.pageSize = 20,
    required super.fetch,
  }) : super(type: HSHitsPageType.spots);
}
