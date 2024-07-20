import 'package:hs_database_repository/src/notifications/hs_notification.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSNotificationsRepository {
  final String _notifications;
  final SupabaseClient _supabase;

  HSNotificationsRepository(this._notifications, this._supabase);

  // CREATE
  Future<void> create(HSNotification notificaton) async {
    try {
      await _supabase.rpc("notification_create_notification", params: {
        "p_user_to_id": notificaton.to,
        "p_user_from_id": notificaton.from,
        "p_board_id": notificaton.boardID,
        "p_spot_id": notificaton.spotID,
        "p_type": notificaton.type.str,
        "p_message": notificaton.message,
      });
    } catch (e) {
      HSDebugLogger.logError("Error creating notification: $e");
      rethrow;
    }
  }

  // READ
  Future<HSNotification> read(
      HSNotification? notification, String? notificationID) async {
    try {
      assert(!(notification != null && notificationID != null),
          "Either notification or notificationID has to be provided");
      // final
      return;
    } catch (e) {
      HSDebugLogger.logError("Error reading notification: $e");
      rethrow;
    }
  }

  // UPDATE
  // DELETE
}
