import 'package:hs_authentication_repository/hs_authentication_repository.dart';
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

  Future<List<HSUser>> fetchSpotLikers(
      HSSpot? spot, String? spotID, int batchSize, int batchOffset) async {
    try {
      assert(spot != null || spotID != null, "Spot or spotID must be provided");
      final String spotUID = spot?.sid ?? spotID!;
      final List<Map<String, dynamic>> fetched = await _supabase
          .from('spots_likes')
          .select()
          .eq('spot_id', spotUID)
          .order('created_at', ascending: false)
          .range(batchOffset, batchOffset + batchSize)
          .select();
      // final List<Map<String, dynamic>> fetched = await _supabase
      //     .rpc("spot_fetch_likers", params: {
      //   "p_spot_id": spotUID,
      //   "p_batch_size": batchSize,
      //   "p_batch_offset": batchOffset
      // });
      // final result = await Future.wait(fetched
      //     .map((e) async => await read(null, e['followed_id']))
      //     .toList());
      final result = await Future.wait(
          fetched.map((e) async => await read(null, e['user_id'])).toList());
      return result;
    } catch (e) {
      HSDebugLogger.logError("Error fetching spot likers: $e");
      throw HSReadUserFailure(customDetails: e.toString());
    }
  }

  Future<List<HSUser>> fetchFollowers(
      HSUser? user, String? userID, int batchSize, int batchOffset) async {
    try {
      assert(user != null || userID != null, "User or userID must be provided");
      final String uid = user?.uid ?? userID!;
      final List<Map<String, dynamic>> fetched = await _supabase
          .from('user_follows')
          .select()
          .eq('followed_id', uid)
          .order('created_at', ascending: false)
          .range(batchOffset, batchOffset + batchSize)
          .select();
      // final List<Map<String, dynamic>> fetched = await _supabase
      //     .rpc("user_fetch_followers", params: {
      //   "p_user_id": uid,
      //   "p_batch_size": batchSize,
      //   "p_batch_offset": batchOffset
      // });
      final result = await Future.wait(fetched
          .map((e) async => await read(null, e['follower_id']))
          .toList());
      return result;
    } catch (e) {
      HSDebugLogger.logError("Error fetching followers: $e");
      throw HSReadUserFailure(customDetails: e.toString());
    }
  }

  Future<List<HSUser>> fetchFollowed(
      HSUser? user, String? userID, int batchSize, int batchOffset) async {
    try {
      assert(user != null || userID != null, "User or userID must be provided");
      final String uid = user?.uid ?? userID!;
      final List<Map<String, dynamic>> fetched = await _supabase
          .from('user_follows')
          .select()
          .eq('follower_id', uid)
          .order('created_at', ascending: false)
          .range(batchOffset, batchOffset + batchSize)
          .select();
      final result = await Future.wait(fetched
          .map((e) async => await read(null, e['followed_id']))
          .toList());

      // final List<Map<String, dynamic>> fetched = await _supabase
      //     .rpc("user_fetch_followed", params: {
      //   "p_user_id": uid,
      //   "p_batch_size": batchSize,
      //   "p_batch_offset": batchOffset
      // });
      return result;
    } catch (e) {
      HSDebugLogger.logError("Error fetching followers: $e");
      throw HSReadUserFailure(customDetails: e.toString());
    }
  }
}
