import 'package:hs_database_repository/hs_database_repository.dart';

class HSNotificationsPage extends HSHitsPage<HSNotification> {
  HSNotificationsPage({
    super.pageSize = 20,
    required super.fetch,
  }) : super(type: HSHitsPageType.notifications);
}
