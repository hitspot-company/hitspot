import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/users/hs_users_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSDatabaseRepsitory {
  HSDatabaseRepsitory(this._supabaseClient) {
    this._usersRepository = HSUsersRepository(_supabaseClient, users);
  }
  static const String users = "users";
  final SupabaseClient _supabaseClient;
  late final HSUsersRepository _usersRepository;

  Future<void> userCreate({required HSUser user}) async =>
      await _usersRepository.create(user);

  Future<HSUser> userRead({required HSUser user}) async =>
      await _usersRepository.read(user);

  Future<void> userUpdate({required HSUser user}) async =>
      await _usersRepository.update(user);

  Future<bool> isUsernameAvailable({required String username}) async =>
      await _usersRepository.isUsernameAvailable(username);
}
