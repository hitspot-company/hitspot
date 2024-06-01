import 'package:hs_authentication_repository/src/models/hs_user.dart';
import 'package:hs_database_repository/src/users/exceptions/hs_create_user_failure.dart';
import 'package:hs_database_repository/src/users/exceptions/hs_read_user_failure.dart';
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
  Future<HSUser> read(HSUser user) async {
    try {
      final fetchedUser =
          await _supabase.from(_users).select().eq("id", user.uid!);
      if (fetchedUser.isEmpty) throw HSReadUserFailure(code: 404);
      return HSUser.deserialize(fetchedUser.first);
    } on HSReadUserFailure catch (_) {
      rethrow;
    } catch (_) {
      throw HSReadUserFailure(customDetails: _.toString());
    }
  }
  // UPDATE
  // DELETE

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
}
