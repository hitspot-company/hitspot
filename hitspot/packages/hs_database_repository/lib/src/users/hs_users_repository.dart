import 'package:hs_authentication_repository/src/models/hs_user.dart';
import 'package:hs_database_repository/src/users/exceptions/hs_create_user_failure.dart';
import 'package:hs_database_repository/src/users/exceptions/hs_read_user_failure.dart';
import 'package:hs_database_repository/src/users/exceptions/hs_update_user_failure.dart';
import 'package:hs_database_repository/src/users/exceptions/hs_user_exception.dart';
import 'package:hs_debug_logger/hs_debug_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSUsersRepository {
  const HSUsersRepository(this._supabase, this._users);

  final SupabaseClient _supabase;
  final String _users;

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
      final fetchedUser = await _supabase.from(_users).select().eq("id", uid);
      if (fetchedUser.isEmpty) throw HSReadUserFailure(code: 404);
      return HSUser.deserialize(fetchedUser.first);
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
      await _supabase.rpc('unfollow_user', params: {
        "follower_uid": followerUID,
        "followed_uid": followedUID,
      });
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      rethrow;
    }
  }

  Future<void> follow(String? followerID, String? followedID, HSUser? follower,
      HSUser? followed) async {
    assert(followerID != null || follower != null,
        "Follower or followerID must be provided");
    assert(followedID != null || followed != null,
        "Followed or followedID must be provided");
    try {
      final followerUID = follower?.uid ?? followerID!;
      final followedUID = followed?.uid ?? followedID!;
      await _supabase.rpc('follow_user',
          params: {"followed_uid": followedUID, "follower_uid": followerUID});
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
      final bool response = await _supabase.rpc('is_user_followed', params: {
        'follower_uid': followerUID,
        'followed_uid': followedUID,
      });
      return (response);
    } catch (_) {
      HSDebugLogger.logError(_.toString());
      rethrow;
    }
  }
}
