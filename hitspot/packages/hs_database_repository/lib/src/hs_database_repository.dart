import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/hs_database_repository_users.dart';

class HSDatabaseRepository {
  static final _usersRepository = HSUsersRepository();

  Future<void> updateField(HSUser user, String field, String newValue) async =>
      _usersRepository.updateField(user, field, newValue);

  Future<void> completeUserProfile(HSUser user) async =>
      await _usersRepository.completeUserProfile(user);

  Future<void> updateUserInfoInDatabase(HSUser user) async =>
      await _usersRepository.updateUserInfoInDatabase(user);

  Future<HSUser?> getUserFromDatabase(String uid) async {
    try {
      HSUser? user = await _usersRepository.getUserFromDatabase(uid);
      if (user == null) throw DatabaseConnectionFailure("The user is null");
      return (user);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isUsernameAvailable(String username) async =>
      await _usersRepository.isUsernameAvailable(username);
}
