import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';

class HSNotificationHandler {
  static Future<void> messageHandler(RemoteMessage message) async {
    HSDebugLogger.logInfo("Handling message: $message");
    final data = message.data;
    final type = data['type'];
    final senderID = data['sender'];
    final spotID = data['spot'];
    final boardID = data['board'];

    final HSNotificationType notificationType =
        HSNotificationType.fromString(type);
    switch (notificationType) {
      case HSNotificationType.spotlike:
        navi.toSpot(sid: spotID);
        break;
      case HSNotificationType.spotcomment:
        navi.toSpot(sid: spotID);
        break;
      case HSNotificationType.userfollow:
        navi.toUser(userID: senderID);
        break;
      case HSNotificationType.boardlike:
        navi.toBoard(boardID: boardID, title: "");
        break;
      default:
        break;
    }
  }
}
