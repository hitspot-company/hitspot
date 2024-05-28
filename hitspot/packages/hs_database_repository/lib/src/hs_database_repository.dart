import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:hs_database_repository/src/hs_database_repository_boards.dart';
import 'package:hs_database_repository/src/hs_database_repository_users.dart';

class HSDatabaseRepository {
  const HSDatabaseRepository();
  static final CollectionReference boards =
      FirebaseFirestore.instance.collection("boards");
  static final CollectionReference users =
      FirebaseFirestore.instance.collection("users");

  static final _usersRepository = HSUsersRepository();
  static final _boardsRepository = HSBoardsRepository(boards, users);

  Future<void> followUser(HSUser currentUser, HSUser user) async =>
      await _usersRepository.followUser(currentUser, user);

  Future<void> unfollowUser(HSUser currentUser, HSUser user) async =>
      await _usersRepository.unfollowUser(currentUser, user);

  Future<void> updateField(HSUser user, String field, String newValue) async =>
      _usersRepository.updateField(user, field, newValue);

  Future<void> completeUserProfile(HSUser user) async =>
      await _usersRepository.completeUserProfile(user);

  Future<void> updateUserInfoInDatabase(HSUser user) async =>
      await _usersRepository.updateUserInfoInDatabase(user);

  Future<HSUser?> getUserFromDatabase(String uid) async {
    try {
      final HSUser? user = await _usersRepository.getUserFromDatabase(uid);
      return (user);
    } catch (e) {
      throw DatabaseConnectionFailure("The user could not be fetched");
    }
  }

  Future<bool> isUsernameAvailable(String username) async =>
      await _usersRepository.isUsernameAvailable(username);

  Future<HSBoard> getBoard(String boardID) async =>
      await _boardsRepository.getBoard(boardID);

  Future<String> createBoard(HSBoard board) async =>
      await _boardsRepository.createBoard(board);

  Future<void> updateBoard(HSBoard board) async =>
      await _boardsRepository.updateBoard(board);

  Future<void> saveBoard(
          {required HSBoard board, required HSUser user}) async =>
      await _boardsRepository.saveBoard(board, user);

  Future<void> unsaveBoard(
          {required HSBoard board, required HSUser user}) async =>
      await _boardsRepository.unsaveBoard(board, user);

  Future<List<HSBoard>> getUserBoards({required HSUser user}) async =>
      await _boardsRepository.getUserBoards(user);

  Future<List<HSBoard>> getSavedBoards({required HSUser user}) async =>
      await _boardsRepository.getSavedBoards(user);

  Future<void> deleteBoard({required HSBoard board}) async =>
      await _boardsRepository.deleteBoard(board: board);

  Future<void> deleteBoardImage({required HSBoard board}) async =>
      await _boardsRepository.deleteBoardImage(board);
}
