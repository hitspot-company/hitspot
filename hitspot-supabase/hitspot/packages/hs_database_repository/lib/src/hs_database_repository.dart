import 'package:hs_authentication_repository/hs_authentication_repository.dart';
import 'package:hs_database_repository/src/boards/hs_board.dart';
import 'package:hs_database_repository/src/boards/hs_boards_repository.dart';
import 'package:hs_database_repository/src/spots/hs_spot.dart';
import 'package:hs_database_repository/src/spots/hs_spots_repository.dart';
import 'package:hs_database_repository/src/users/hs_users_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HSDatabaseRepsitory {
  HSDatabaseRepsitory(this._supabaseClient) {
    this._usersRepository = HSUsersRepository(_supabaseClient, users);
    this._boardsRepository = HSBoardsRepository(_supabaseClient, boards);
    this._spotsRepository = HSSpotsRepository(_supabaseClient, spots);
  }

  static const String users = "users";
  static const String boards = "boards";
  static const String spots = "spots";
  final SupabaseClient _supabaseClient;
  late final HSUsersRepository _usersRepository;
  late final HSBoardsRepository _boardsRepository;
  late final HSSpotsRepository _spotsRepository;

  Future<void> userCreate({required HSUser user}) async =>
      await _usersRepository.create(user);

  Future<HSUser> userRead({HSUser? user, String? userID}) async =>
      await _usersRepository.read(user, userID);

  Future<void> userUpdate({required HSUser user}) async =>
      await _usersRepository.update(user);

  Future<bool> userIsUsernameAvailable({required String username}) async =>
      await _usersRepository.isUsernameAvailable(username);

  Future<bool?> userIsUserFollowed(
          {String? followerID,
          HSUser? follower,
          String? followedID,
          HSUser? followed}) async =>
      await _usersRepository.isUserFollowed(
          followerID, follower, followedID, followed);

  Future<void> userFollow(
      {required bool isFollowed,
      String? followerID,
      String? followedID,
      HSUser? follower,
      HSUser? followed}) async {
    final bool? foll = await userIsUserFollowed(
        followedID: followedID, followerID: followerID);
    if (foll!) {
      // HSDebugLogger.logInfo("User followed: Yes");
      await _usersRepository.unfollow(
          followerID, followedID, follower, followed);
    } else {
      // HSDebugLogger.logInfo("User followed: No");
      await _usersRepository.follow(followerID, followedID, follower, followed);
    }
  }

  Future<String> boardCreate({required HSBoard board}) async =>
      await _boardsRepository.create(board);

  Future<HSBoard> boardRead({HSBoard? board, String? boardID}) async =>
      await _boardsRepository.read(board, boardID);

  Future<void> boardUpdate({required HSBoard board}) async =>
      await _boardsRepository.update(board);

  Future<void> boardDelete({required HSBoard board}) async =>
      await _boardsRepository.delete(board);

  Future<bool> boardIsBoardSaved(
          {HSBoard? board, String? boardID, HSUser? user, String? userID}) =>
      _boardsRepository.isBoardSaved(board, boardID, user, userID);

  Future<bool> boardIsEditor(
          {HSBoard? board, String? boardID, HSUser? user, String? userID}) =>
      _boardsRepository.isEditor(board, boardID, user, userID);

  Future<bool> boardSaveUnsave(
          {HSBoard? board, String? boardID, HSUser? user, String? userID}) =>
      _boardsRepository.saveUnsave(board, boardID, user, userID);

  Future<List<HSBoard>> boardFetchUserBoards(
          {HSUser? user, String? userID}) async =>
      await _boardsRepository.fetchUserBoards(user, userID);

  Future<List<HSBoard>> boardFetchSavedBoards(
          {HSUser? user, String? userID}) async =>
      await _boardsRepository.fetchSavedBoards(user, userID);

  Future<List<HSBoard>> boardFetchTrendingBoards() async =>
      await _boardsRepository.fetchTrendingBoards();

  Future<String> spotCreate({required HSSpot spot}) async =>
      await _spotsRepository.create(spot);

  Future<HSSpot> spotRead({HSSpot? spot, String? spotID}) async =>
      await _spotsRepository.read(spot, spotID);

  Future<void> spotUpdate({required HSSpot spot}) async =>
      await _spotsRepository.update(spot);

  Future<void> spotDelete({required HSSpot spot}) async =>
      await _spotsRepository.delete(spot);

  Future<void> spotUploadImages(
          {required String spotID,
          required List<String> imageUrls,
          required String uid}) async =>
      await _spotsRepository.uploadImages(spotID, imageUrls, uid);

  Future<List<HSSpot>> fetchNearbySpots(double lat, double long) async =>
      await _spotsRepository.fetchNearbySpots(lat, long);

  Future<List<HSSpot>> spotFetchSpotsWithinRadius(
          {required double lat, required double long, double? radius}) async =>
      await _spotsRepository.fetchSpotsWithinRadius(lat, long, radius);
  Future<HSUser> spotFetchAuthor({HSSpot? spot, String? authorID}) async =>
      await _spotsRepository.fetchSpotAuthor(spot, authorID);
}
