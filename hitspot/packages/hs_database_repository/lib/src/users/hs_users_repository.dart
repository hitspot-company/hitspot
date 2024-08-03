import 'package:hs_authentication_repository/src/models/hs_user.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/notifications/hs_notifications_repository.dart';
import 'package:hs_database_repository/src/users/exceptions/hs_update_user_failure.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSUsersRepository {
  const HSUsersRepository(
      this._supabase, this._users, this._notificationsRepository);

  final SupabaseClient _supabase;
  final String _users;
  final HSNotificationsRepository _notificationsRepository;

  // CREATE
  Future<void> create(HSUser user) async {
    try {
      final insertedUser =
          await _supabase.from(_users).insert(user.serialize()).select();
      HSDebugLogger.logSuccess("User created: ${insertedUser.isNotEmpty}");
    } catch (_) {
      throw HSCreateUserFailure(customDetails: _.toString());
    }
  }

  // READ
  Future<HSUser> read(HSUser? user, String? userID) async {
    try {
      assert(user != null || userID != null, "User or userID must be provided");
      late final String uid = user?.uid ?? userID!;
      final List<Map<String, dynamic>> fetched =
          await _supabase.rpc("user_fetch", params: {"p_user_id": uid});
      if (fetched.isEmpty) throw HSReadUserFailure(code: 404);
      return HSUser.deserialize(fetched.first);
    } catch (_) {
      HSDebugLogger.logError("Error fetching user: $_");
      throw HSReadUserFailure(customDetails: _.toString());
    }
  }

  // UPDATE
  Future<void> update(HSUser user) async {
    try {
      await _supabase.from(_users).update(user.serialize()).eq("id", user.uid!);
      HSDebugLogger.logSuccess("User (${user.uid}) data updated!");
    } catch (_) {
      throw HSUpdateUserFailure(customDetails: _.toString());
    }
  }

  // DELETE
  Future<void> deleteAccount(HSUser? user, String? userID) async {
    assert((user != null || userID != null), "User or userID must be provided");
    try {
      final uid = user?.uid ?? userID!;
      await _supabase.from(_users).delete().eq("id", uid);
      await _supabase.auth.signOut();
      HSDebugLogger.logSuccess("User (${uid}) deleted!");
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      throw HSUserException(message: "Error deleting user account.");
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      final res = await _supabase
          .from(_users)
          .select("username")
          .eq("username", username)
          .count(CountOption.exact);
      final int count = res.count;
      return count == 0;
    } catch (_) {
      throw HSUserException(message: "Error verifying username availability.");
    }
  }

  Future<void> unfollow(String? followerID, String? followedID,
      HSUser? follower, HSUser? followed) async {
    assert(followerID != null || follower != null,
        "Follower or followerID must be provided");
    assert(followedID != null || followed != null,
        "Followed or followedID must be provided");
    try {
      final followerUID = follower?.uid ?? followerID!;
      final followedUID = followed?.uid ?? followedID!;
      await _supabase.rpc('user_unfollow',
          params: {"p_follower_id": followerUID, "p_followed_id": followedUID});
      await _notificationsRepository.delete(HSNotification(
        from: followerUID,
        to: followedUID,
        type: HSNotificationType.userfollow,
      ));
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      rethrow;
    }
  }

  Future<void> follow(String? followerID, String? followedID, HSUser? follower,
      HSUser? followed) async {
    try {
      assert(followerID != null || follower != null,
          "Follower or followerID must be provided");
      assert(followedID != null || followed != null,
          "Followed or followedID must be provided");
      final followerUID = follower?.uid ?? followerID!;
      final followedUID = followed?.uid ?? followedID!;
      await _supabase.rpc('user_follow',
          params: {"p_followed_id": followedUID, "p_follower_id": followerUID});
      await _notificationsRepository.create(HSNotification(
        from: followerUID,
        to: followedUID,
        type: HSNotificationType.userfollow,
        message: "Unfollowed",
      ));
      HSDebugLogger.logSuccess("Followed");
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      rethrow;
    }
  }

  Future<bool?> isUserFollowed(String? followerID, HSUser? follower,
      String? followedID, HSUser? followed) async {
    assert(followerID != null || follower != null,
        "Follower or followerID must be provided");
    assert(followedID != null || followed != null,
        "Followed or followedID must be provided");
    try {
      final String followedUID = followed?.uid ?? followedID!;
      final String followerUID = follower?.uid ?? followerID!;
      final bool response = await _supabase.rpc('user_is_followed', params: {
        'p_follower_id': followerUID,
        'p_followed_id': followedUID,
      });
      return (response);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      rethrow;
    }
  }
}
