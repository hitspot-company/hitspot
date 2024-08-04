import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/notifications/hs_notification.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSNotificationsRepository {
  final SupabaseClient _supabase;

  HSNotificationsRepository(this._supabase);

  // CREATE
  Future<void> create(HSNotification notificaton) async {
    try {
      await _supabase.rpc("notifications_create_notification", params: {
        "p_user_to_id": notificaton.to,
        "p_user_from_id": notificaton.from,
        "p_board_id": notificaton.boardID,
        "p_spot_id": notificaton.spotID,
        "p_type": notificaton.type!.str,
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
      final nid = notification?.id ?? notificationID;
      final Map<String, dynamic> result =
          await _supabase.rpc("notifications_read_notification", params: {
        "p_notification_id": nid,
      });
      return HSNotification.deserialize(result);
    } catch (e) {
      HSDebugLogger.logError("Error reading notification: $e");
      rethrow;
    }
  }

  // READ
  Future<List<HSNotification>> readUserNotifications(
      HSUser? currentUser,
      String? currentUserID,
      int? limit,
      int? offset,
      bool? includeHidden) async {
    try {
      assert(!(currentUser != null && currentUserID != null),
          "Either notification or notificationID has to be provided");
      final uid = currentUser?.uid ?? currentUserID;
      final List<Map<String, dynamic>> result =
          await _supabase.rpc("notification_fetch_user_notifications", params: {
        'p_user_id': uid,
        'p_limit': limit,
        'p_offset': offset,
        'p_include_hidden': includeHidden,
      });
      return result.map(HSNotification.deserialize).toList();
    } catch (e) {
      HSDebugLogger.logError("Error reading notification: $e");
      rethrow;
    }
  }

  // UPDATE
  // DELETE
  Future<void> delete(HSNotification notification) async {
    try {
      await _supabase.rpc("notifications_remove_notification", params: {
        "p_user_from_id": notification.from,
        "p_user_to_id": notification.to,
        "p_spot_id": notification.spotID,
        "p_board_id": notification.boardID,
        "p_type": notification.type!.str,
      });
    } catch (e) {
      HSDebugLogger.logError("Error deleting notification: $e");
      rethrow;
    }
  }
}
