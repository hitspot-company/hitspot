import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/boards/hs_board.dart';
import 'package:hs_database_repository/src/boards/hs_boards_repository.dart';
import 'package:hs_database_repository/src/users/hs_users_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSDatabaseRepsitory {
  HSDatabaseRepsitory(this._supabaseClient) {
    this._usersRepository = HSUsersRepository(_supabaseClient, users);
    this._boardsRepository = HSBoardsRepository(_supabaseClient, boards);
  }

  static const String users = "users";
  static const String boards = "boards";
  final SupabaseClient _supabaseClient;
  late final HSUsersRepository _usersRepository;
  late final HSBoardsRepository _boardsRepository;

  Future<void> userCreate({required HSUser user}) async =>
      await _usersRepository.create(user);

  Future<HSUser> userRead({HSUser? user, String? userID}) async =>
      await _usersRepository.read(user, userID);

  Future<void> userUpdate({required HSUser user}) async =>
      await _usersRepository.update(user);

  Future<bool> isUsernameAvailable({required String username}) async =>
      await _usersRepository.isUsernameAvailable(username);

  Future<String> boardCreate({required HSBoard board}) async =>
      await _boardsRepository.create(board);

  Future<HSBoard> boardRead({HSBoard? board, String? boardID}) async =>
      await _boardsRepository.read(board, boardID);

  Future<void> boardUpdate({required HSBoard board}) async =>
      await _boardsRepository.update(board);

  Future<void> boardDelete({required HSBoard board}) async =>
      await _boardsRepository.delete(board);

  Future<List<HSBoard>> fetchUserBoards({HSUser? user, String? userID}) async =>
      await _boardsRepository.fetchUserBoards(user, userID);
}
