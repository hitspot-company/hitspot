import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/notifications/hs_announcement.dart';
import 'package:hs_database_repository/src/notifications/hs_notification.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      final List<HSNotification> ret = await Future.wait(result.map((e) async {
        return HSNotification.deserialize(e)
            .copyWith(isRead: await notificationIsRead(e['id']));
      }));
      return ret;
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

  Future<void> changeFcmToken(String userID, String fcmToken) async {
    await _supabase.rpc("notifications_register_fcm_token", params: {
      "p_user_id": userID,
      "p_fcm_token": fcmToken,
    });
  }

  Future<bool> notificationIsRead(String id) async {
    try {
      SharedPreferences instance = await SharedPreferences.getInstance();
      HSDebugLogger.logInfo("Checking if the notification is read");
      return instance.getBool("notification_$id") ?? false;
    } catch (_) {
      HSDebugLogger.logError("Failed to check if the notification is read");
      rethrow;
    }
  }

  Future<void> notificationMarkAsRead(String id) async {
    try {
      SharedPreferences instance = await SharedPreferences.getInstance();
      await instance.setBool("notification_$id", true);
      HSDebugLogger.logSuccess("Marked the notification as read");
    } catch (_) {
      HSDebugLogger.logError("Failed to set as the notification as read");
      rethrow;
    }
  }

  // ANNOUNCEMENTS
  // Fetch recent announcements
  Future<List<HSAnnouncement>> announcementGetRecent(
      int batchLimit, int batchOffset) async {
    try {
      final List<Map<String, dynamic>> response =
          await Supabase.instance.client.rpc(
        'announcement_get_recent',
        params: {'p_batch_limit': batchLimit, 'p_batch_offset': batchOffset},
      );
      HSDebugLogger.logInfo("Fetched $response");
      final List<HSAnnouncement> ret =
          await Future.wait(response.map((e) async {
        return HSAnnouncement.deserialize(e)
            .copyWith(isRead: await announcementIsRead(e['id']));
      }));
      return ret;
    } catch (e) {
      HSDebugLogger.logError("Error fetching recent announcements: $e");
      rethrow;
    }
  }

  // Fetch announcement by ID
  Future<HSAnnouncement?> announcementGetByID(String id) async {
    final response = await _supabase.rpc(
      'announcement_get_by_id',
      params: {'p_id': id},
    );

    return response != null ? HSAnnouncement.deserialize(response) : null;
  }

  Future<bool> announcementIsRead(String id) async {
    try {
      SharedPreferences instance = await SharedPreferences.getInstance();
      HSDebugLogger.logInfo("Checking if the announcement is read");
      return instance.getBool("announcement_$id") ?? false;
    } catch (_) {
      HSDebugLogger.logError("Failed to check if the notification is read");
      rethrow;
    }
  }

  Future<void> announcementMarkAsRead(String id) async {
    try {
      SharedPreferences instance = await SharedPreferences.getInstance();
      await instance.setBool("announcement_$id", true);
      HSDebugLogger.logSuccess("Marked the announcement as read");
    } catch (_) {
      HSDebugLogger.logError("Failed to set as the announcement as read");
      rethrow;
    }
  }
}
