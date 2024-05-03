import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/hs_database_repository_users.dart';

class HSDatabaseRepository {
  static final _usersRepository = HSUsersRepository();

  Future<void> completeUserProfile(HSUser user) async =>
      await _usersRepository.completeUserProfile(user);

  Future<void> updateUserInfoInDatabase(HSUser user) async =>
      await _usersRepository.updateUserInfoInDatabase(user);

  Future<HSUser?> getUserFromDatabase(String uid) async =>
      await _usersRepository.getUserFromDatabase(uid);

  Future<bool> isUsernameAvailable(String username) async =>
      await _usersRepository.isUsernameAvailable(username);
}
